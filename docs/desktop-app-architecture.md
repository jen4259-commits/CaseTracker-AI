# Desktop App Architecture — First Sprint

## Goal

Define the SwiftUI app shell, navigation, file layout, and first-sprint case list/detail experience. The first sprint is a reviewable desktop prototype, not an autonomous research or publishing system. Human approval remains required for verification and publication.

## App shell

Use a three-column macOS `NavigationSplitView`:

1. **Sidebar:** app sections and case-status filters.
2. **Content column:** case queue or selected workflow section.
3. **Detail column:** selected case overview or selected source/review item.

Suggested shell:

```text
CaseTrackerApp
└── AppRootView
    ├── NavigationSplitView
    │   ├── AppSidebarView
    │   ├── WorkspaceView (selected route)
    │   └── CaseDetailView (selected case, when applicable)
    └── AppCommands (New Case, Search, Import JSON)
```

Keep the initial implementation in SwiftUI. The current repository has Swift files but no committed Xcode project file (`project.pbxproj`), so confirm/create the actual Xcode project target and add new source files to it before expecting the app to build.

## Navigation model

Use typed navigation state rather than string routes. One selected section controls the workspace; a selected case UUID controls the optional detail column. Search/filter state belongs in a small observable view model, not in the navigation enum.

```swift
enum AppSection: Hashable, CaseIterable, Identifiable {
    case cases
    case sources
    case review
    case exports

    var id: Self { self }
    var title: String { /* human-readable label */ }
    var systemImage: String { /* SF Symbol */ }
}

@MainActor
@Observable
final class AppNavigationModel {
    var selectedSection: AppSection = .cases
    var selectedCaseID: UUID?
    var searchText = ""
    var caseStatusFilter: CaseStatusFilter = .all
}

enum CaseStatusFilter: Hashable {
    case all, candidate, research, verification, production, review, published
}
```

Implementation can use `@Observable` on supported deployment targets or `ObservableObject`/`@StateObject` if targeting an older macOS version. Keep one approach consistent with the app's deployment target.

Sidebar sections for sprint 1:
- Cases (with status filter subitems)
- Sources
- Review Inbox
- Exports

Selecting a case opens its detail workspace. Links from the case detail can select a source or review item without losing the selected case. Use stable UUIDs for selection; do not retain references to mutable array indices.

## File layout

```text
desktop/CaseTrackerApp/
├── CaseTrackerApp.swift
├── App/
│   ├── AppRootView.swift
│   ├── AppNavigationModel.swift
│   └── AppSection.swift
├── Models/
│   ├── CaseRecord.swift
│   ├── SourceRecord.swift
│   ├── EvidenceRecord.swift
│   ├── ClaimRecord.swift
│   ├── EpisodeRecord.swift
│   ├── EpisodeSegment.swift
│   ├── ReviewRecord.swift
│   └── CaseTrackerStore.swift
├── Services/
│   ├── JSONCaseRepository.swift
│   └── SchemaValidationService.swift
├── ViewModels/
│   ├── CaseQueueViewModel.swift
│   ├── CaseDetailViewModel.swift
│   └── SourceReviewViewModel.swift
├── Views/
│   ├── Sidebar/AppSidebarView.swift
│   ├── Cases/CaseQueueView.swift
│   ├── Cases/CaseListRowView.swift
│   ├── Cases/CaseDetailView.swift
│   ├── Cases/CaseOverviewView.swift
│   ├── Sources/SourceReviewView.swift
│   ├── Sources/SourceListRowView.swift
│   ├── Review/ReviewInboxView.swift
│   ├── Review/ReviewGateView.swift
│   ├── Exports/ExportArchiveView.swift
│   └── Components/
│       ├── StatusBadge.swift
│       ├── BlockerSummaryView.swift
│       └── EmptyStateView.swift
└── Resources/
    └── (sample JSON copied or bundled from data/)
```

The repository currently has `Models/Episode.swift` and `Views/ContentView.swift`; migrate from the old episode-only sample store rather than keeping two competing stores. Keep the existing blueprint parser separate from case persistence.

## Model objects

Use Codable DTOs that match the JSON Schema contracts for import/export. Add SwiftData `@Model` persistence only after confirming the app target and migration approach. This avoids treating a prototype persistence layer as the source of truth before relationships and schema evolution are settled.

### `CaseRecord`
- `id: UUID`
- `title`, `category`, `caseType`, `jurisdiction`, `summary`
- `status: CaseStatus`
- `startDate: Date?`
- `keyPeople: [PersonRecord]`
- `storyAngle: String`
- `sourceIDs: [UUID]`
- `verificationStatus: VerificationStatus`
- `episodeStatus: EpisodeStatus`
- `createdAt`, `updatedAt: Date`

Derived values (not editable stored fields): source count, unresolved review count, and publication blockers.

### `SourceRecord`
- IDs: `id`, `caseID`
- `sourceType`, `title`, `url`, `citation`
- `publication`, `author`, `publishDate`, `retrievedAt`
- `summary`, `verificationStatus`, `confidenceScore?`
- `reviewer?`, `reviewedAt?`, `rightsNotes`, `notes`

### `EvidenceRecord`
- IDs: `id`, `caseID`, `sourceID`
- `evidenceType`, `label`, `locator?`, `filePath?`, `mediaType?`, `checksum?`
- `verificationStatus`, `contextNotes`, `rightsStatus`, `timestamp?`

### `ClaimRecord`
The existing JSON schema does not yet include a claim schema. Treat this model as provisional until `claim.schema.json` is added.
- IDs: `id`, `caseID`
- `text`, `claimType`, `sourceIDs`, `evidenceIDs`
- `verificationStatus`, `reviewer?`, `reviewedAt?`, `notes`

### `EpisodeRecord` and `EpisodeSegment`
- Episode: IDs `id`, `caseID`; `title`, `outline`, `script`, `targetRuntimeSeconds`, `format`, `status`, `segments`, `reviewStatus`, `approvals`, `exportPath?`, timestamps.
- Segment: `id`, `title`, `order`, `plannedDurationSeconds`, `claimIDs`, `evidenceIDs`, `assetIDs`.

### `ReviewRecord`
A UI/domain model for approval history. The episode schema currently nests approvals; maintain a single mapping until a standalone review schema is introduced.
- `id`, `caseID`, `episodeID?`, `reviewType`, `status`, `reviewer?`, `reviewedAt`, `notes`, `blockingIssues`.

### Enums

Keep raw JSON values aligned with the schema. Examples:
- `VerificationStatus`: `unreviewed`, `in_review`, `supported`, `partially_supported`, `conflicted`, `unsupported`, `rejected`.
- `EpisodeStatus`: `outline`, `research`, `script`, `production`, `review`, `approved`, `exported`, `published`.
- `ReviewStatus`: `pending`, `approved`, `changes_requested`.
- `RightsStatus`: values from `evidence.schema.json`; unknown or restricted rights are blockers for publication.

## First-sprint views

### Case queue (`CaseQueueView`)

**Toolbar:** title, search field, status filter, sort menu, New Case, Import JSON.

**List columns/row content:**
- case title and category
- jurisdiction
- lifecycle status badge
- verification badge
- episode status
- source count
- blocker count with text label
- updated date

Selecting a row updates `selectedCaseID`. Search matches title, jurisdiction, category, and story angle. Filters operate on explicit statuses. Sort defaults to recently updated. Do not rank cases by an unexplained confidence or “truth” score.

### Case detail (`CaseDetailView`)

Header:
- title and category
- jurisdiction and procedural status (show “not entered” if absent)
- lifecycle, verification, and episode status badges
- clear draft/placeholder marker when applicable
- blocker summary and last updated date

Detail navigation:
- Overview
- Sources
- Claims & Evidence
- Episode
- Reviews

For the first sprint, implement Overview and Sources; other tabs may show a deliberate “Not implemented yet” state rather than blank or misleading data.

Overview layout:
- left/main column: neutral case summary, story angle, key people
- right inspector: workflow status, source count, unresolved items, next action
- lower section: recent source/review activity and open questions

### Source review (`SourceReviewView`)

Show a searchable list with source title, publisher/type, date, verification state, and rights note. Detail pane shows URL/citation, retrieval information, summary, notes, and actions to change review state. Record reviewer and timestamp for each decision. A confidence score, if present, must be labelled as a triage aid only.

### Review gate (`ReviewGateView`)

Display a checklist and blockers for claim support, conflicts, rights, privacy/editorial review, and technical export. “Approve” is disabled until required checks are complete. For sprint 1, approval can be a local human-entered record; do not implement automatic approval.

### Export archive (`ExportArchiveView`)

Sprint 1 can be read-only or show an empty state. Later records should include file location, output format, runtime, checksum, created date, and approval reference. Do not trigger publishing or uploads from this view.

## List/detail interaction

- Use `NavigationSplitView` selection and a detail view rather than pushing a new screen for every case.
- Keep selection stable across list filtering; if the selected case is filtered out, clear the detail selection safely.
- Show a useful empty state when no case is selected or when filters return no results.
- Status badges always include readable text; color is supplementary.
- Blockers appear in the queue and detail header and link to the relevant source/claim/review section.
- Confirm destructive changes and retain status-change audit information.

## Data loading for the first sprint

1. Load and decode the Gideon case/source/evidence/claim/episode JSON seed records from a controlled local resource location.
2. Validate required fields and enum values; show actionable import errors rather than silently dropping fields.
3. Mark seeded content as research/draft. The retrial outcome remains `in_review`; the episode remains `not_ready` until human review.
4. Allow explicit JSON export so edits can be reviewed and versioned.
5. Do not assume the user's Desktop host video is available to the app or repository. Store a user-selected asset URL/bookmark in a later asset model; the provided local path is not a portable app resource.

## Acceptance criteria

- App launches into a useful case queue and displays the Gideon research-draft case.
- Search and status filters work and selection opens the correct detail.
- Case overview shows status and outstanding review blockers without suggesting publication readiness.
- Sources can be inspected and their review status changed with reviewer/date recorded.
- Unknown or restricted rights, unresolved conflicts, and unsupported claims are visible blockers.
- Import errors identify the file and field; valid records round-trip without changing schema status strings.
- No UI action publishes, uploads, or automatically approves an episode.

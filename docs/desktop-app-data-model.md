# Desktop App Data Model and Dashboard Specification

## Purpose

Define the first desktop-app experience around the existing Case, Source, Evidence, and Episode JSON contracts. The desktop app should make provenance and review status visible, support human decisions, and prevent incomplete work from appearing publication-ready.

## Data model mapping

Use the JSON Schema files in `data/schemas/` as the initial interchange contracts. SwiftData persistence can use UUID identifiers and typed relationships; JSON import/export must preserve the field names and status values in those contracts.

### Case
- `CaseRecord` maps to the case schema.
- Relationships: sources, evidence, episodes, and (future) claims/timeline events.
- Derived UI values such as source count must be computed from relationships, not stored as a separate editable truth.
- Keep procedural posture and last-checked date visible in the case workspace; add explicit fields through a versioned schema migration when implemented.

### Source
- `SourceRecord` belongs to one case and may be cited by multiple evidence and claim records.
- Preserve original citation/URL, retrieval timestamp, review state, reviewer, rights notes, and source limitations.
- The confidence score is optional triage metadata, never a truth determination.

### Evidence
- `EvidenceRecord` belongs to a case and references a source, locator, and optional controlled asset path/checksum.
- Keep context notes and rights status visible. A media excerpt should retain a reference to its original source and time range.
- Evidence is not itself a claim or a conclusion.

### Episode
- `EpisodeRecord` belongs to a case and has ordered segments, target runtime, review state, approvals, and export metadata.
- Segments reference claims, evidence, and assets by stable IDs.
- Actual export records should also record output format, runtime, checksum, created date, and destination; add a versioned export schema before implementing persistence.

### Recommended next entities

The four initial schemas do not yet define claims, timeline events, or media assets as standalone records. Add these before implementing the full research-to-edit workflow:
- `ClaimRecord`: neutral claim text, claim type, linked source/evidence IDs, status, reviewer, and checked-at timestamp.
- `TimelineEventRecord`: date/date precision, description, linked claims/evidence, and whether the date is disputed or approximate.
- `MediaAssetRecord`: original source, locator/time range, local reference/checksum, edit history, rights/permission status, attribution, and intended use.
- `ReviewRecord`: review category, reviewer, decision, timestamp, notes, and any blocking issues.

## Dashboard information architecture

### 1. Case queue
Show candidate and active cases with title, category, jurisdiction, lifecycle state, verification state, last updated, and blocking items. Filters: status, verification state, episode state, and needs-review. Avoid a single unexplained numerical “truth” score.

### 2. Case workspace
Tabs or navigation sections:
- **Overview:** neutral case brief, selection rationale, procedural posture, last-checked date, open questions.
- **Sources:** searchable source list, provenance, source type, dates, status, rights notes, reviewer.
- **Claims & evidence:** claims mapped to source locators, conflicts, evidence items, and verification decisions.
- **Timeline:** dated events with precision and conflict indicators.
- **Episode:** outline, script, storyboard segments, runtime plan, and references.
- **Reviews & exports:** approvals, unresolved blockers, export history, and traceability report.

### 3. Episode production board
Use explicit stages: Outline → Research → Script → Production → Review → Approved → Exported → Published. Each stage lists required inputs and blockers. Dragging a card must not bypass a required approval gate.

### 4. Review inbox
Prioritize unresolved conflicts, unsupported or partially supported claims, stale time-sensitive facts, unknown media rights, missing citations, and pending approvals. Each item should show enough context to inspect the underlying source.

## Publication gate

The app must not mark an episode approved or ready to publish if any material claim is unsupported or conflicted, any required rights status is unknown/restricted, or a required human approval is missing. Provide actionable blockers; never silently auto-approve based on agent output.

## Initial implementation order

1. Read/import/export records that validate against current JSON Schemas.
2. Implement case queue and case detail view.
3. Implement source/evidence lists and manual verification updates with reviewer/date audit details.
4. Add episode outline and segment timing editor.
5. Add review inbox and hard publication gate.
6. Add claims, timeline, media asset, and export models through schema migrations.

## Usability and accessibility

- Use text labels alongside status colors.
- Make keyboard navigation and VoiceOver labels available for status, blockers, and review controls.
- Show dates with timezone/context where relevant.
- Confirm before destructive edits and preserve an audit trail for status changes.
- Make it clear when records are placeholders, drafts, or based on unreviewed sources.

## Current seed records

`data/cases/pilot-1-case.json` is explicitly an unselected-case placeholder. `data/episodes/pilot-1-sample.json` is a timing-only sample with empty claim/evidence/asset references. They demonstrate structure, not researched case facts, and must not be presented as publication-ready.

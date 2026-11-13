import Foundation
import Combine

// Lightweight first-sprint view model. JSON/SwiftData persistence is intentionally
// deferred until the Xcode target and schema migration strategy are established.
enum CaseWorkflowStatus: String, CaseIterable, Identifiable {
    case candidate
    case research
    case verification
    case production
    case review
    case published

    var id: String { rawValue }
    var title: String { rawValue.replacingOccurrences(of: "_", with: " ").capitalized }
}

enum CaseVerificationStatus: String {
    case unreviewed
    case inReview = "in_review"
    case supported
    case partiallySupported = "partially_supported"
    case conflicted
    case unsupported
    case rejected

    var title: String { rawValue.replacingOccurrences(of: "_", with: " ").capitalized }
}

enum CaseEpisodeStatus: String {
    case notStarted = "not_started"
    case outline
    case script
    case production
    case review
    case approved
    case published

    var title: String { rawValue.replacingOccurrences(of: "_", with: " ").capitalized }
}

struct CaseRecord: Identifiable {
    let id: UUID
    var title: String
    var category: String
    var jurisdiction: String
    var summary: String
    var storyAngle: String
    var status: CaseWorkflowStatus
    var verificationStatus: CaseVerificationStatus
    var episodeStatus: CaseEpisodeStatus
    var sourceCount: Int
    var blockerCount: Int
    var updatedAt: Date
    var isResearchDraft: Bool

    static let pilot = CaseRecord(
        id: UUID(uuidString: "4d3e0402-bd3a-4dfc-b570-1fd0a5b8c5e1")!,
        title: "Gideon v. Wainwright",
        category: "Landmark decision",
        jurisdiction: "Florida · U.S. Supreme Court",
        summary: "Clarence Earl Gideon challenged his Florida felony conviction after he was denied appointed counsel. In 1963, the U.S. Supreme Court held that the right to counsel applies to state felony defendants.",
        storyAngle: "Trace the right-to-counsel case from Gideon's Florida prosecution to the Supreme Court decision, distinguishing the Court's holding from later historical accounts.",
        status: .research,
        verificationStatus: .partiallySupported,
        episodeStatus: .outline,
        sourceCount: 3,
        blockerCount: 4,
        updatedAt: Date(timeIntervalSince1970: 1_794_528_000),
        isResearchDraft: true
    )
}

@MainActor
final class CaseTrackerStore: ObservableObject {
    @Published private(set) var cases: [CaseRecord] = [.pilot]

    func caseRecord(id: UUID?) -> CaseRecord? {
        guard let id else { return nil }
        return cases.first(where: { $0.id == id })
    }
}

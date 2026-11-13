import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: CaseTrackerStore
    @State private var selectedSection: WorkspaceSection? = .cases
    @State private var selectedCaseID: UUID? = CaseRecord.pilot.id
    @State private var searchText = ""

    private var filteredCases: [CaseRecord] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.cases }
        return store.cases.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || $0.category.localizedCaseInsensitiveContains(query)
                || $0.jurisdiction.localizedCaseInsensitiveContains(query)
                || $0.storyAngle.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationSplitView {
            List(WorkspaceSection.allCases, selection: $selectedSection) { section in
                Label(section.title, systemImage: section.symbol)
                    .tag(section)
            }
            .listStyle(.sidebar)
            .navigationTitle("CaseTracker-AI")
            .frame(minWidth: 190)
        } content: {
            switch selectedSection ?? .cases {
            case .cases:
                caseQueue
            case .sources:
                placeholder(title: "Sources", message: "Select a case to review its source records.", symbol: "doc.text.magnifyingglass")
            case .review:
                placeholder(title: "Review Inbox", message: "Unresolved claims, rights checks, and approvals will appear here.", symbol: "checkmark.shield")
            case .exports:
                placeholder(title: "Exports", message: "Approved episode exports and archive records will appear here.", symbol: "square.and.arrow.up")
            }
        } detail: {
            if selectedSection == .cases, let selectedCase = store.caseRecord(id: selectedCaseID) {
                CaseDetailView(caseRecord: selectedCase)
            } else {
                ContentUnavailableView("Select a Case", systemImage: "folder", description: Text("Choose a case from the list to inspect its status and review blockers."))
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    private var caseQueue: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cases").font(.title2).bold()
                Spacer()
                Button {} label: { Label("New Case", systemImage: "plus") }
                    .disabled(true)
                    .help("Case creation will be added after data entry and persistence are implemented.")
            }
            .padding()

            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search cases", text: $searchText)
                    .textFieldStyle(.plain)
                    .accessibilityLabel("Search cases")
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .padding(.bottom, 8)

            List(selection: $selectedCaseID) {
                ForEach(filteredCases) { record in
                    CaseListRowView(caseRecord: record)
                        .tag(record.id)
                }
            }
            .listStyle(.inset)
            .overlay {
                if filteredCases.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
        .frame(minWidth: 330)
    }

    private func placeholder(title: String, message: String, symbol: String) -> some View {
        ContentUnavailableView(title, systemImage: symbol, description: Text(message))
            .frame(minWidth: 330)
    }
}

private enum WorkspaceSection: String, CaseIterable, Identifiable {
    case cases, sources, review, exports

    var id: String { rawValue }
    var title: String {
        switch self {
        case .cases: "Cases"
        case .sources: "Sources"
        case .review: "Review Inbox"
        case .exports: "Exports"
        }
    }
    var symbol: String {
        switch self {
        case .cases: "folder"
        case .sources: "doc.text"
        case .review: "checkmark.shield"
        case .exports: "square.and.arrow.up"
        }
    }
}

private struct CaseListRowView: View {
    let caseRecord: CaseRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(caseRecord.title).font(.headline).lineLimit(1)
                Spacer(minLength: 4)
                Text(caseRecord.status.title).font(.caption).foregroundStyle(.secondary)
            }
            Text(caseRecord.jurisdiction)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            HStack(spacing: 8) {
                StatusBadge(title: caseRecord.verificationStatus.title, symbol: "checkmark.seal")
                StatusBadge(title: "\(caseRecord.blockerCount) blockers", symbol: "exclamationmark.triangle")
            }
            HStack {
                Text("\(caseRecord.sourceCount) sources")
                Spacer()
                Text(caseRecord.updatedAt, format: .dateTime.month(.abbreviated).day().year())
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
    }
}

private struct CaseDetailView: View {
    let caseRecord: CaseRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(caseRecord.title).font(.largeTitle).bold()
                        if caseRecord.isResearchDraft {
                            StatusBadge(title: "Research draft", symbol: "pencil.and.outline")
                        }
                    }
                    Text("\(caseRecord.category) · \(caseRecord.jurisdiction)")
                        .font(.title3).foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        StatusBadge(title: caseRecord.status.title, symbol: "circle.dashed")
                        StatusBadge(title: caseRecord.verificationStatus.title, symbol: "checkmark.seal")
                        StatusBadge(title: "Episode: \(caseRecord.episodeStatus.title)", symbol: "film")
                    }
                }

                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 18) {
                        section("Case summary") {
                            Text(caseRecord.summary)
                        }
                        section("Story angle") {
                            Text(caseRecord.storyAngle)
                        }
                        section("Sources") {
                            Text("\(caseRecord.sourceCount) source records are linked. Review source pinpoints and rights before using material in a final episode.")
                            Button("Open source review", systemImage: "arrow.right") {}
                                .disabled(true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Review status").font(.headline)
                        Label("\(caseRecord.blockerCount) items need review", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("The episode is not approved for publication. Confirm source pinpoints, review the retrial account, clear media rights, and complete human fact-checking.")
                            .font(.callout).foregroundStyle(.secondary)
                        Divider()
                        Text("Last updated").font(.caption).foregroundStyle(.secondary)
                        Text(caseRecord.updatedAt, format: .dateTime.month(.abbreviated).day().year())
                    }
                    .padding()
                    .frame(width: 260, alignment: .leading)
                    .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(28)
            .frame(maxWidth: 1000, alignment: .leading)
        }
        .navigationTitle(caseRecord.title)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content().foregroundStyle(.secondary)
        }
    }
}

private struct StatusBadge: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.quaternary, in: Capsule())
            .accessibilityLabel(title)
    }
}

#Preview {
    ContentView().environmentObject(CaseTrackerStore())
}

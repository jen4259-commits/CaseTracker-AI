import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: EpisodeStore

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Episodes")
                    .font(.title2)
                    .fontWeight(.bold)

                Button(action: {
                    store.loadSampleData()
                }) {
                    Label("Import PDF", systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    // Replace with real PDF import action later
                }) {
                    Label("Parse Blueprint", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                List(store.episodes) { episode in
                    NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                        VStack(alignment: .leading) {
                            Text("Episode \(episode.episodeNumber)")
                                .font(.headline)
                            Text(episode.caseName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .padding()
        } detail: {
            Text("Select an episode to review details.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}

struct EpisodeDetailView: View {
    let episode: Episode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(episode.caseName)
                    .font(.title)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Agency: \(episode.agency.isEmpty ? "Unknown" : episode.agency)", systemImage: "building.2")
                    Label("Docket: \(episode.courtDocket.isEmpty ? "N/A" : episode.courtDocket)", systemImage: "doc.text")
                    Label("People: \(episode.people.joined(separator: ", "))", systemImage: "person.2")
                }
                .font(.body)

                if !episode.videoLinks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Video links")
                            .font(.headline)
                        ForEach(episode.videoLinks, id: \ .self) { link in
                            Link(link, destination: URL(string: link) ?? URL(string: "https://example.com")!)
                                .lineLimit(1)
                        }
                    }
                }

                if !episode.timeline.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Timeline")
                            .font(.headline)
                        ForEach(episode.timeline, id: \ .self) { item in
                            Text("• \(item)")
                        }
                    }
                }

                if !episode.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        Text(episode.notes)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(EpisodeStore())
}

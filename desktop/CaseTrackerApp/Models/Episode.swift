import Foundation

struct Episode: Identifiable, Codable {
    let id: UUID
    let episodeNumber: Int
    let caseName: String
    let people: [String]
    let agency: String
    let courtDocket: String
    let videoLinks: [String]
    let timeline: [String]
    let notes: String

    init(
        episodeNumber: Int,
        caseName: String,
        people: [String] = [],
        agency: String = "",
        courtDocket: String = "",
        videoLinks: [String] = [],
        timeline: [String] = [],
        notes: String = ""
    ) {
        self.id = UUID()
        self.episodeNumber = episodeNumber
        self.caseName = caseName
        self.people = people
        self.agency = agency
        self.courtDocket = courtDocket
        self.videoLinks = videoLinks
        self.timeline = timeline
        self.notes = notes
    }
}

final class EpisodeStore: ObservableObject {
    @Published var episodes: [Episode] = []

    init() {
        loadSampleData()
    }

    func loadSampleData() {
        episodes = [
            Episode(
                episodeNumber: 1,
                caseName: "The Federal Watchdog",
                people: ["Jane Doe", "Sam Lee"],
                agency: "DOJ",
                courtDocket: "CR-24-101",
                videoLinks: ["https://example.com/video/1"],
                timeline: ["Initial complaint filed", "Discovery begins", "Public hearing"],
                notes: "Prototype case created from the PDF blueprint."
            ),
            Episode(
                episodeNumber: 2,
                caseName: "Hidden Records",
                people: ["Chris Ross", "Alicia Stone"],
                agency: "State Records Office",
                courtDocket: "24-CV-88",
                videoLinks: ["https://example.com/video/2"],
                timeline: ["Records requested", "Agency response", "Appeal filed"],
                notes: "Second episode used for prototype research flow."
            )
        ]
    }
}

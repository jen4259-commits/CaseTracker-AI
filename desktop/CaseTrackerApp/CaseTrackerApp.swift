import SwiftUI

@main
struct CaseTrackerApp: App {
    @StateObject private var store = EpisodeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

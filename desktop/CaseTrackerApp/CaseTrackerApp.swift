import SwiftUI

@main
struct CaseTrackerApp: App {
    @StateObject private var store = CaseTrackerStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 1000, minHeight: 650)
        }
    }
}

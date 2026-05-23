import SwiftUI

@main
struct CalcKitApp: App {
    @State private var historyStore = HistoryStore()

    init() {
        HapticFeedback.warmUp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(historyStore)
        }
    }
}

import SwiftUI

@main
struct CalcKitApp: App {
    @State private var historyStore = HistoryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(historyStore)
        }
   }
}

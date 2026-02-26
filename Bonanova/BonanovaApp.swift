import SwiftUI

@main
struct BonanovaApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container.storage)
                .environmentObject(container.plannerVM)
                .environmentObject(container.goalVM)
        }
    }
}

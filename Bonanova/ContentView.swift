import SwiftUI

struct ContentView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        if hasOnboarded {
            HomeView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppContainer().storage)
        .environmentObject(AppContainer().plannerVM)
        .environmentObject(AppContainer().goalVM)
}

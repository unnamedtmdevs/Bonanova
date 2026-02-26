import Foundation
import Combine

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let colorName: String
}

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Bonanova",
            subtitle: "Your structured daily planner for a more productive, colorful life.",
            icon: "calendar.badge.plus",
            colorName: "Action_Primary"
        ),
        OnboardingPage(
            title: "Organize Your Day",
            subtitle: "Plan tasks by Morning, Afternoon, and Evening with easy drag-and-drop reordering.",
            icon: "sun.and.horizon.fill",
            colorName: "Action_Highlight"
        ),
        OnboardingPage(
            title: "Color Your Priorities",
            subtitle: "Use vibrant color tags to identify urgent, normal, and low-priority tasks instantly.",
            icon: "paintpalette.fill",
            colorName: "Action_Creative"
        ),
        OnboardingPage(
            title: "Track Weekly Progress",
            subtitle: "See your productivity at a glance with weekly and monthly overviews.",
            icon: "chart.bar.fill",
            colorName: "Action_Success"
        ),
        OnboardingPage(
            title: "Start Planning",
            subtitle: "You're all set! Let's make every day count with Bonanova.",
            icon: "star.fill",
            colorName: "Action_Urgent"
        )
    ]

    var isLastPage: Bool { currentPage == pages.count - 1 }

    func nextPage() {
        guard currentPage < pages.count - 1 else { return }
        currentPage += 1
    }
}

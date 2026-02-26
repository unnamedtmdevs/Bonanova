import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var storage: PlannerStorageService
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @EnvironmentObject private var goalVM: GoalViewModel
    @State private var selectedTab: Int = 0
    @State private var showFocusMode = false

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardTab(showFocusMode: $showFocusMode)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            DailyPlannerView()
                .tabItem { Label("Planner", systemImage: "calendar") }
                .tag(1)

            WeeklyOverviewView()
                .tabItem { Label("Weekly", systemImage: "chart.bar.fill") }
                .tag(2)

            GoalView()
                .tabItem { Label("Goals", systemImage: "target") }
                .tag(3)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(4)
        }
        .accentColor(Theme.primary)
        .sheet(isPresented: $showFocusMode) {
            FocusModeView()
                .environmentObject(plannerVM)
        }
    }
}

// MARK: - Dashboard Tab

struct DashboardTab: View {
    @EnvironmentObject private var storage: PlannerStorageService
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @EnvironmentObject private var goalVM: GoalViewModel
    @Binding var showFocusMode: Bool

    private var todayStats: DailyStats {
        AnalyticsService.dailyStats(tasks: storage.tasks, for: Date())
    }

    private var urgentCount: Int {
        plannerVM.urgentTasksForToday().count
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.spacingXL) {
                    // Header card
                    headerCard

                    // Stats grid
                    statsGrid

                    // Focus mode card
                    focusModeCard

                    // Today's tasks preview
                    todayTasksPreview

                    // Goals overview
                    goalsOverview
                }
                .padding(.horizontal, Theme.spacingLG)
                .padding(.bottom, Theme.spacingXXL)
            }
            .background(Theme.bgPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Bonanova")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var headerCard: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: Theme.cornerXL)
                .fill(Theme.bgSecondary)

            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                Text(DateHelper.shared.fullDateString(Date()))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Text("Good \(timeOfDayGreeting)! 👋")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text(todayStats.total == 0
                     ? "No tasks yet — add your first one!"
                     : "\(todayStats.completed)/\(todayStats.total) tasks completed today")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))

                if todayStats.total > 0 {
                    SmallProgressBar(progress: todayStats.completionRate, colorName: "Action_Highlight")
                        .padding(.top, Theme.spacingXS)
                }
            }
            .padding(Theme.spacingXL)
        }
        .frame(maxWidth: .infinity)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacingMD) {
            StatCardView(
                title: "Today's Tasks",
                value: "\(todayStats.total)",
                icon: "checkmark.square.fill",
                colorName: "Action_Primary"
            )
            StatCardView(
                title: "Completed",
                value: "\(todayStats.completed)",
                icon: "checkmark.circle.fill",
                colorName: "Action_Success"
            )
            StatCardView(
                title: "Urgent Today",
                value: "\(urgentCount)",
                icon: "flame.fill",
                colorName: "Action_Urgent"
            )
            StatCardView(
                title: "Active Goals",
                value: "\(storage.goals.filter { !$0.isCompleted }.count)",
                icon: "target",
                colorName: "Action_Creative"
            )
        }
    }

    private var focusModeCard: some View {
        Button(action: { showFocusMode = true }) {
            HStack(spacing: Theme.spacingMD) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: "bolt.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Focus Mode")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(urgentCount == 0
                         ? "No urgent tasks right now"
                         : "\(urgentCount) urgent task\(urgentCount == 1 ? "" : "s") waiting")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(Theme.spacingLG)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerLG)
                    .fill(Theme.urgent)
            )
        }
        .buttonStyle(.plain)
    }

    private var todayTasksPreview: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            HStack {
                Text("Today's Tasks")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                Text("See All")
                    .font(.caption)
                    .foregroundColor(Theme.primary)
            }

            let tasks = plannerVM.allTasksForSelectedDate()
            if tasks.isEmpty {
                Text("No tasks for today yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Theme.spacingMD)
            } else {
                ForEach(tasks.prefix(3)) { task in
                    TaskCardView(
                        task: task,
                        category: plannerVM.categoryFor(id: task.categoryId),
                        onToggle: { plannerVM.toggleCompletion(task: task) },
                        onDelete: { plannerVM.deleteTask(task) }
                    )
                }
                if tasks.count > 3 {
                    Text("+ \(tasks.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }

    private var goalsOverview: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Goals Overview")
                .font(.system(size: 17, weight: .bold))

            let activeGoals = storage.goals.filter { !$0.isCompleted }
            if activeGoals.isEmpty {
                Text("No active goals. Create your first one in Goals!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Theme.spacingMD)
            } else {
                ForEach(activeGoals.prefix(2)) { goal in
                    GoalSummaryRow(goal: goal)
                }
            }
        }
    }

    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }
}

struct GoalSummaryRow: View {
    let goal: Goal

    var body: some View {
        HStack(spacing: Theme.spacingMD) {
            ProgressRingView(
                progress: goal.completionRate,
                colorName: goal.colorName,
                size: 48,
                lineWidth: 5
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(goal.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                Text("\(goal.completedCount)/\(goal.subtasks.count) subtasks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerMD)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

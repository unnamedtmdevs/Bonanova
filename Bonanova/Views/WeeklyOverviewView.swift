import SwiftUI

struct WeeklyOverviewView: View {
    @EnvironmentObject private var storage: PlannerStorageService
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @State private var currentDate: Date = Date()
    @State private var viewMode: ViewMode = .weekly

    enum ViewMode: String, CaseIterable {
        case weekly = "Week"
        case monthly = "Month"
    }

    private var weeklyStats: WeeklyStats {
        AnalyticsService.weeklyStats(tasks: storage.tasks, for: currentDate)
    }

    private var monthlyRate: Double {
        AnalyticsService.monthlyCompletionRate(tasks: storage.tasks, for: currentDate)
    }

    private var monthlyTaskCount: Int {
        let dates = DateHelper.shared.monthDates(for: currentDate)
        return storage.tasks.filter { task in
            dates.contains { DateHelper.shared.isSameDay(task.date, $0) }
        }.count
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.spacingXL) {
                    // Mode toggle
                    Picker("View", selection: $viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Theme.spacingLG)

                    if viewMode == .weekly {
                        weeklyContent
                    } else {
                        monthlyContent
                    }
                }
                .padding(.bottom, Theme.spacingXXL)
            }
            .background(Theme.bgPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewMode == .weekly
                         ? DateHelper.shared.weekRangeString(for: currentDate)
                         : DateHelper.shared.monthYearString(currentDate))
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            currentDate = viewMode == .weekly
                                ? DateHelper.shared.previousWeek(from: currentDate)
                                : DateHelper.shared.previousMonth(from: currentDate)
                        }
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            currentDate = viewMode == .weekly
                                ? DateHelper.shared.nextWeek(from: currentDate)
                                : DateHelper.shared.nextMonth(from: currentDate)
                        }
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Weekly Content

    private var weeklyContent: some View {
        VStack(spacing: Theme.spacingXL) {
            // Week day bars
            WeekBarChartView(weeklyStats: weeklyStats, selectedDate: $plannerVM.selectedDate)
                .padding(.horizontal, Theme.spacingLG)

            // Weekly stats cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacingMD) {
                StatCardView(
                    title: "Total Tasks",
                    value: "\(weeklyStats.totalTasks)",
                    icon: "square.stack.fill",
                    colorName: "Action_Primary"
                )
                StatCardView(
                    title: "Completed",
                    value: "\(weeklyStats.completedTasks)",
                    icon: "checkmark.circle.fill",
                    colorName: "Action_Success"
                )
                StatCardView(
                    title: "Completion",
                    value: "\(Int(weeklyStats.completionRate * 100))%",
                    icon: "chart.pie.fill",
                    colorName: "Action_Creative"
                )
                StatCardView(
                    title: "Active Days",
                    value: "\(weeklyStats.activeDays)",
                    icon: "calendar",
                    colorName: "BG_Secondary"
                )
            }
            .padding(.horizontal, Theme.spacingLG)
        }
    }

    // MARK: - Monthly Content

    private var monthlyContent: some View {
        VStack(spacing: Theme.spacingXL) {
            // Calendar grid
            MonthCalendarView(
                currentDate: currentDate,
                tasks: storage.tasks,
                selectedDate: $plannerVM.selectedDate
            )
            .padding(.horizontal, Theme.spacingLG)

            // Monthly stats
            VStack(spacing: Theme.spacingMD) {
                HStack(spacing: Theme.spacingMD) {
                    StatCardView(
                        title: "Completion Rate",
                        value: "\(Int(monthlyRate * 100))%",
                        icon: "chart.pie.fill",
                        colorName: "Action_Primary"
                    )
                    StatCardView(
                        title: "Total Tasks",
                        value: "\(monthlyTaskCount)",
                        icon: "square.stack.fill",
                        colorName: "Action_Creative"
                    )
                }

                // Productivity ring
                HStack {
                    Spacer()
                    VStack(spacing: Theme.spacingSM) {
                        ProgressRingView(
                            progress: monthlyRate,
                            colorName: "Action_Primary",
                            size: 120,
                            lineWidth: 12
                        )
                        Text("Monthly Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, Theme.spacingMD)
            }
            .padding(.horizontal, Theme.spacingLG)
        }
    }
}

// MARK: - Week Bar Chart

struct WeekBarChartView: View {
    let weeklyStats: WeeklyStats
    @Binding var selectedDate: Date

    private var maxTasks: Int {
        max(weeklyStats.dailyStats.map { $0.total }.max() ?? 1, 1)
    }

    var body: some View {
        VStack(spacing: Theme.spacingMD) {
            Text("Task Density This Week")
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)

            HStack(alignment: .bottom, spacing: Theme.spacingSM) {
                ForEach(weeklyStats.dailyStats, id: \.date) { stat in
                    DayBarView(
                        stat: stat,
                        maxTasks: maxTasks,
                        isSelected: DateHelper.shared.isSameDay(stat.date, selectedDate),
                        isToday: Calendar.current.isDateInToday(stat.date)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedDate = stat.date
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.spacingMD)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerLG)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            )
        }
    }
}

struct DayBarView: View {
    let stat: DailyStats
    let maxTasks: Int
    let isSelected: Bool
    let isToday: Bool

    private var barHeight: CGFloat {
        guard stat.total > 0 else { return 4 }
        return max(8, CGFloat(stat.total) / CGFloat(maxTasks) * 100)
    }

    private var completedHeight: CGFloat {
        guard stat.total > 0 else { return 0 }
        return barHeight * CGFloat(stat.completionRate)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(stat.total)")
                .font(.caption2.bold())
                .foregroundColor(isSelected ? Theme.primary : .secondary)
                .opacity(stat.total > 0 ? 1 : 0)

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.primary.opacity(0.15))
                    .frame(width: 28, height: barHeight)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.success)
                    .frame(width: 28, height: completedHeight)
                    .animation(.easeInOut(duration: 0.4), value: completedHeight)
            }

            Text(DateHelper.shared.shortDayName(stat.date))
                .font(.caption2)
                .foregroundColor(isSelected ? Theme.primary : .secondary)
                .fontWeight(isToday ? .bold : .regular)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXS)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerSM)
                .fill(isSelected ? Theme.primary.opacity(0.1) : Color.clear)
        )
    }
}

// MARK: - Month Calendar

struct MonthCalendarView: View {
    let currentDate: Date
    let tasks: [PlannerTask]
    @Binding var selectedDate: Date

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let helper = DateHelper.shared

    var body: some View {
        VStack(spacing: Theme.spacingMD) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(helper.weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(helper.monthGridDates(for: currentDate).enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            taskCount: AnalyticsService.taskCountFor(date: date, tasks: tasks),
                            completedCount: AnalyticsService.completedCountFor(date: date, tasks: tasks),
                            isSelected: helper.isSameDay(date, selectedDate),
                            isToday: Calendar.current.isDateInToday(date)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDate = date
                            }
                        }
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerLG)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }
}

struct CalendarDayCell: View {
    let date: Date
    let taskCount: Int
    let completedCount: Int
    let isSelected: Bool
    let isToday: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(DateHelper.shared.dayNumber(date))
                .font(.system(size: 13, weight: isToday ? .bold : .regular))
                .foregroundColor(
                    isSelected ? .white
                    : isToday ? Theme.primary
                    : .primary
                )
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ? Theme.primary : Color.clear)
                )

            // Task density dots
            if taskCount > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<min(taskCount, 3), id: \.self) { i in
                        Circle()
                            .fill(i < completedCount ? Theme.success : Theme.primary.opacity(0.5))
                            .frame(width: 4, height: 4)
                    }
                }
            } else {
                Color.clear.frame(height: 6)
            }
        }
        .frame(height: 44)
    }
}

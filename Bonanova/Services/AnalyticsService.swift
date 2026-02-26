import Foundation

struct DailyStats {
    let date: Date
    let total: Int
    let completed: Int

    var completionRate: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var isEmpty: Bool { total == 0 }
}

struct WeeklyStats {
    let weekStart: Date
    let dailyStats: [DailyStats]

    var totalTasks: Int { dailyStats.reduce(0) { $0 + $1.total } }
    var completedTasks: Int { dailyStats.reduce(0) { $0 + $1.completed } }

    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }

    var activeDays: Int {
        dailyStats.filter { !$0.isEmpty }.count
    }
}

enum AnalyticsService {
    static func dailyStats(tasks: [PlannerTask], for date: Date) -> DailyStats {
        let dayTasks = tasks.filter { DateHelper.shared.isSameDay($0.date, date) }
        return DailyStats(
            date: date,
            total: dayTasks.count,
            completed: dayTasks.filter { $0.isCompleted }.count
        )
    }

    static func weeklyStats(tasks: [PlannerTask], for date: Date) -> WeeklyStats {
        let dates = DateHelper.shared.weekDates(for: date)
        let daily = dates.map { dailyStats(tasks: tasks, for: $0) }
        return WeeklyStats(weekStart: dates.first ?? date, dailyStats: daily)
    }

    static func monthlyCompletionRate(tasks: [PlannerTask], for date: Date) -> Double {
        let dates = DateHelper.shared.monthDates(for: date)
        let monthTasks = tasks.filter { task in
            dates.contains { DateHelper.shared.isSameDay(task.date, $0) }
        }
        guard !monthTasks.isEmpty else { return 0 }
        return Double(monthTasks.filter { $0.isCompleted }.count) / Double(monthTasks.count)
    }

    static func taskCountFor(date: Date, tasks: [PlannerTask]) -> Int {
        tasks.filter { DateHelper.shared.isSameDay($0.date, date) }.count
    }

    static func completedCountFor(date: Date, tasks: [PlannerTask]) -> Int {
        tasks.filter { DateHelper.shared.isSameDay($0.date, date) && $0.isCompleted }.count
    }
}

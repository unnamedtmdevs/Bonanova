import Foundation

struct DateHelper {
    static let shared = DateHelper()

    private var calendar: Calendar { Calendar.current }

    func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }

    func weekDates(for date: Date) -> [Date] {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        guard let startOfWeek = calendar.date(from: comps) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    func monthDates(for date: Date) -> [Date] {
        let comps = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth) }
    }

    func monthGridDates(for date: Date) -> [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: comps) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let firstDayOfWeek = calendar.firstWeekday
        let offset = (firstWeekday - firstDayOfWeek + 7) % 7

        var dates: [Date?] = Array(repeating: nil, count: offset)
        let days = calendar.range(of: .day, in: .month, for: startOfMonth) ?? (1..<1)
        for day in days {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(d)
            }
        }
        while dates.count % 7 != 0 { dates.append(nil) }
        return dates
    }

    func previousMonth(from date: Date) -> Date {
        calendar.date(byAdding: .month, value: -1, to: date) ?? date
    }

    func nextMonth(from date: Date) -> Date {
        calendar.date(byAdding: .month, value: 1, to: date) ?? date
    }

    func previousWeek(from date: Date) -> Date {
        calendar.date(byAdding: .weekOfYear, value: -1, to: date) ?? date
    }

    func nextWeek(from date: Date) -> Date {
        calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
    }

    func shortDayName(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }

    func monthYearString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    func fullDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: date)
    }

    func mediumDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    func weekRangeString(for date: Date) -> String {
        let dates = weekDates(for: date)
        guard let first = dates.first, let last = dates.last else { return "" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: first)) – \(f.string(from: last))"
    }

    var weekdaySymbols: [String] {
        var symbols = calendar.shortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        return Array(symbols[offset...] + symbols[..<offset])
    }
}

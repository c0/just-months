import Foundation

// MARK: - Calendar Cell Model

struct CalendarCell: Identifiable {
    let id: Int          // 0..<42, unique per month instance
    let date: Date
    let isCurrentMonth: Bool
}

// MARK: - Calendar Logic

enum CalendarLogic {
    /// Generates a 42-cell grid (6 rows x 7 columns) for the given month.
    /// The grid starts on Sunday.
    static func calendarCells(
        for month: Date,
        calendar: Calendar = .current
    ) -> [CalendarCell] {
        let comps = calendar.dateComponents([.year, .month], from: month)
        let firstDay = calendar.date(from: comps)!
        let offset = calendar.component(.weekday, from: firstDay) - 1
        return (0..<42).map { i in
            let date = calendar.date(byAdding: .day, value: i - offset, to: firstDay)!
            let inMonth = calendar.component(.month, from: date) == comps.month!
            return CalendarCell(id: i, date: date, isCurrentMonth: inMonth)
        }
    }

    /// Returns whether two dates fall on the same calendar day.
    static func isToday(
        _ cellDate: Date,
        today: Date,
        calendar: Calendar = .current
    ) -> Bool {
        calendar.isDate(cellDate, inSameDayAs: today)
    }

    /// Returns whether cellDate is strictly before today (day granularity).
    static func isPast(
        _ cellDate: Date,
        today: Date,
        calendar: Calendar = .current
    ) -> Bool {
        calendar.startOfDay(for: cellDate) < calendar.startOfDay(for: today)
    }

    /// Computes which months to show for a given widget configuration.
    static func monthsToShow(
        today: Date,
        monthCount: Int,
        isExtraLarge: Bool,
        calendar: Calendar = .current
    ) -> [Date] {
        let start: Date
        if isExtraLarge {
            let lookback = calendar.date(byAdding: .day, value: -14, to: today)!
            start = calendar.date(
                from: calendar.dateComponents([.year, .month], from: lookback))!
        } else {
            start = calendar.date(
                from: calendar.dateComponents([.year, .month], from: today))!
        }
        return (0..<monthCount).compactMap {
            calendar.date(byAdding: .month, value: $0, to: start)
        }
    }
}

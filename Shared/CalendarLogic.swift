import Foundation

enum CalendarLogic {
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

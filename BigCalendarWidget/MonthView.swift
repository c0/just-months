import SwiftUI

// MARK: - Month View

struct MonthView: View {
    let month: Date
    let today: Date

    private let calendar = Calendar.current

    private var sevenColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    }

    private var headerText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month).uppercased()
    }

    private var firstWeekdayOffset: Int {
        let components = calendar.dateComponents([.year, .month], from: month)
        let firstDay = calendar.date(from: components)!
        // weekday: 1 = Sunday ... 7 = Saturday
        return calendar.component(.weekday, from: firstDay) - 1
    }

    private var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: month)!
        let components = calendar.dateComponents([.year, .month], from: month)
        return range.compactMap { day -> Date? in
            var dc = components
            dc.day = day
            return calendar.date(from: dc)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Month header: "FEBRUARY 2026"
            Text(headerText)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            // Day-of-week headers: S M T W T F S
            let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
            HStack(spacing: 0) {
                ForEach(dayLabels.indices, id: \.self) { i in
                    Text(dayLabels[i])
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Date grid
            LazyVGrid(columns: sevenColumns, spacing: 1) {
                // Empty cells before first day
                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                    Color.clear
                        .frame(minHeight: 20)
                }
                // Day cells
                ForEach(daysInMonth, id: \.self) { day in
                    DayCell(
                        day: day,
                        isToday: isSameDay(day, today),
                        isPast: isPastDay(day, today)
                    )
                }
            }
        }
    }

    private func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    private func isPastDay(_ day: Date, _ ref: Date) -> Bool {
        // A day is "past" if it's before today's date (not including today)
        let dayStart = calendar.startOfDay(for: day)
        let refStart = calendar.startOfDay(for: ref)
        return dayStart < refStart
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let day: Date
    let isToday: Bool
    let isPast: Bool

    private var dayNumber: String {
        let cal = Calendar.current
        return "\(cal.component(.day, from: day))"
    }

    var body: some View {
        Text(dayNumber)
            .font(.system(size: 13, weight: isToday ? .bold : .regular))
            .foregroundStyle(
                isToday
                    ? Color.white
                    : (isPast ? Color.secondary.opacity(0.5) : Color.primary)
            )
            .frame(maxWidth: .infinity, minHeight: 20)
            .background {
                if isToday {
                    Circle()
                        .fill(Color.accentColor)
                        .padding(1)
                }
            }
    }
}

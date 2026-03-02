import SwiftUI

// MARK: - Calendar Cell Model

fileprivate struct CalendarCell: Identifiable {
    let id: Int          // 0..<42, unique per month instance
    let date: Date
    let isCurrentMonth: Bool
}

// MARK: - Month View

struct MonthView: View {
    let month: Date
    let today: Date

    private let calendar = Calendar.current

    private var headerText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }

    private var calendarCells: [CalendarCell] {
        let comps = calendar.dateComponents([.year, .month], from: month)
        let firstDay = calendar.date(from: comps)!
        let offset = calendar.component(.weekday, from: firstDay) - 1  // 0=Sun
        return (0..<42).map { i in
            let date = calendar.date(byAdding: .day, value: i - offset, to: firstDay)!
            let inMonth = calendar.component(.month, from: date) == comps.month!
            return CalendarCell(id: i, date: date, isCurrentMonth: inMonth)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Month header: "March 2026"
            Text(headerText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .center)

            // Day-of-week headers: S M T W T F S
            let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
            HStack(spacing: 0) {
                ForEach(dayLabels.indices, id: \.self) { i in
                    Text(dayLabels[i])
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            // Date grid: 6 rows × 7 cols
            VStack(spacing: 2) {
                ForEach(0..<6, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { col in
                            DayCell(cell: calendarCells[row * 7 + col], today: today)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Day Cell

struct DayCell: View {
    fileprivate let cell: CalendarCell
    let today: Date

    private let calendar = Calendar.current

    var isToday: Bool { calendar.isDate(cell.date, inSameDayAs: today) }
    var isPast: Bool {
        calendar.startOfDay(for: cell.date) < calendar.startOfDay(for: today)
    }

    var body: some View {
        Text("\(calendar.component(.day, from: cell.date))")
            .font(.system(size: 13, weight: isToday ? .bold : .regular))
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity, minHeight: 22)
            .background {
                if isToday { Circle().fill(Color.accentColor).padding(1) }
            }
    }

    var foregroundColor: Color {
        if isToday { return .white }
        if !cell.isCurrentMonth { return Color.primary.opacity(0.25) }
        if isPast { return Color.primary.opacity(0.45) }
        return .primary
    }
}

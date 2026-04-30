import SwiftUI
import WidgetKit

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
            let dateComps = calendar.dateComponents([.year, .month], from: date)
            let inMonth = dateComps.year == comps.year && dateComps.month == comps.month
            return CalendarCell(id: i, date: date, isCurrentMonth: inMonth)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Month header: "March 2026"
            Text(headerText)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Color("PrimaryText"))
                .frame(maxWidth: .infinity, alignment: .center)

            // Day-of-week headers: S M T W T F S
            let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
            HStack(spacing: 0) {
                ForEach(dayLabels.indices, id: \.self) { i in
                    Text(dayLabels[i])
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color("DimmedText"))
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
    @Environment(\.widgetRenderingMode) var renderingMode

    private let calendar = Calendar.current

    var isToday: Bool {
        cell.isCurrentMonth && calendar.isDate(cell.date, inSameDayAs: today)
    }
    var isPast: Bool {
        calendar.startOfDay(for: cell.date) < calendar.startOfDay(for: today)
    }

    var body: some View {
        Text("\(calendar.component(.day, from: cell.date))")
            .font(.system(size: 11, weight: isToday ? .bold : .regular, design: .monospaced))
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity, minHeight: 18)
            .background {
                // In vibrant rendering mode (macOS desktop), colors are mapped by luminance.
                // Coral has high luminance and renders as near-white, making the number invisible.
                // Bold text alone marks today reliably in that context.
                if isToday && renderingMode != .vibrant {
                    Rectangle().fill(Color("TodayAccent")).padding(1)
                }
            }
    }

    var foregroundColor: Color {
        if isToday { return Color("PrimaryText") }
        if !cell.isCurrentMonth { return Color("DimmedText").opacity(0.5) }
        if isPast { return Color("DimmedText") }
        return Color("PrimaryText")
    }
}

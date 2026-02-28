import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct CalendarEntry: TimelineEntry {
    let date: Date
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    nonisolated func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date())
    }

    nonisolated func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(CalendarEntry(date: Date()))
    }

    nonisolated func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let entry = CalendarEntry(date: Date())
        let midnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0),
            matchingPolicy: .nextTime
        )!
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
}

// MARK: - Widget View

struct JustMonthsView: View {
    let entry: CalendarEntry
    @Environment(\.widgetFamily) var family

    var monthCount: Int {
        switch family {
        case .systemExtraLarge: return 6
        default: return 4
        }
    }

    var columns: Int {
        switch family {
        case .systemExtraLarge: return 3
        default: return 2
        }
    }

    var rows: Int { monthCount / columns }

    var today: Date { entry.date }

    var monthsToShow: [Date] {
        CalendarLogic.monthsToShow(
            today: today,
            monthCount: monthCount,
            isExtraLarge: family == .systemExtraLarge
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(alignment: .top, spacing: 6) {
                    ForEach(0..<columns, id: \.self) { col in
                        let index = row * columns + col
                        if index < monthsToShow.count {
                            MonthView(month: monthsToShow[index], today: today)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding(6)
        .widgetURL(URL(string: "justmonths://open")!)
        .containerBackground(Color("WidgetBackground"), for: .widget)
    }
}

// MARK: - Widget Configuration

@main
struct JustMonthsWidget: Widget {
    let kind = "JustMonthsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            JustMonthsView(entry: entry)
        }
        .configurationDisplayName("Just Months")
        .description("Multi-month calendar. No clutter.")
        .supportedFamilies([.systemLarge, .systemExtraLarge])
    }
}

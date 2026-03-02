import XCTest

final class CalendarCellTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func testCellCountIs42() {
        let cells = CalendarLogic.calendarCells(for: date(year: 2026, month: 3, day: 1), calendar: calendar)
        XCTAssertEqual(cells.count, 42)
    }

    func testCellIdsAreSequential() {
        let cells = CalendarLogic.calendarCells(for: date(year: 2026, month: 3, day: 1), calendar: calendar)
        for i in 0..<42 {
            XCTAssertEqual(cells[i].id, i)
        }
    }

    // March 2026 starts on Sunday, so cell 0 should be March 1
    func testMarchStartsOnSunday() {
        let cells = CalendarLogic.calendarCells(for: date(year: 2026, month: 3, day: 1), calendar: calendar)
        XCTAssertEqual(calendar.component(.day, from: cells[0].date), 1)
        XCTAssertEqual(calendar.component(.month, from: cells[0].date), 3)
        XCTAssertTrue(cells[0].isCurrentMonth)
    }

    // April 2026 starts on Wednesday (offset 3), so cells 0-2 should be March
    func testAprilOffset() {
        let cells = CalendarLogic.calendarCells(for: date(year: 2026, month: 4, day: 1), calendar: calendar)
        XCTAssertFalse(cells[0].isCurrentMonth)
        XCTAssertFalse(cells[1].isCurrentMonth)
        XCTAssertFalse(cells[2].isCurrentMonth)
        XCTAssertTrue(cells[3].isCurrentMonth)
        XCTAssertEqual(calendar.component(.day, from: cells[3].date), 1)
    }

    func testCurrentMonthFlagging() {
        let cells = CalendarLogic.calendarCells(for: date(year: 2026, month: 3, day: 1), calendar: calendar)
        let marchCells = cells.filter { $0.isCurrentMonth }
        XCTAssertEqual(marchCells.count, 31) // March has 31 days
    }

    func testFebruaryLeapYear() {
        // 2028 is a leap year
        let cells = CalendarLogic.calendarCells(for: date(year: 2028, month: 2, day: 1), calendar: calendar)
        let febCells = cells.filter { $0.isCurrentMonth }
        XCTAssertEqual(febCells.count, 29)
    }

    func testFebruaryNonLeapYear() {
        let cells = CalendarLogic.calendarCells(for: date(year: 2025, month: 2, day: 1), calendar: calendar)
        let febCells = cells.filter { $0.isCurrentMonth }
        XCTAssertEqual(febCells.count, 28)
    }

    func testAnyDayInMonthProducesSameGrid() {
        let fromFirst = CalendarLogic.calendarCells(for: date(year: 2026, month: 3, day: 1), calendar: calendar)
        let fromFifteenth = CalendarLogic.calendarCells(for: date(year: 2026, month: 3, day: 15), calendar: calendar)
        for i in 0..<42 {
            XCTAssertEqual(
                calendar.isDate(fromFirst[i].date, inSameDayAs: fromFifteenth[i].date), true,
                "Cell \(i) dates should match regardless of input day"
            )
            XCTAssertEqual(fromFirst[i].isCurrentMonth, fromFifteenth[i].isCurrentMonth)
        }
    }
}

import XCTest

final class MonthsToShowTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func testDefaultShowsFourMonths() {
        let months = CalendarLogic.monthsToShow(
            today: date(year: 2026, month: 3, day: 15),
            monthCount: 4, isExtraLarge: false, calendar: calendar
        )
        XCTAssertEqual(months.count, 4)
    }

    func testExtraLargeShowsSixMonths() {
        let months = CalendarLogic.monthsToShow(
            today: date(year: 2026, month: 3, day: 15),
            monthCount: 6, isExtraLarge: true, calendar: calendar
        )
        XCTAssertEqual(months.count, 6)
    }

    func testDefaultStartsAtCurrentMonth() {
        let today = date(year: 2026, month: 3, day: 15)
        let months = CalendarLogic.monthsToShow(
            today: today, monthCount: 4, isExtraLarge: false, calendar: calendar
        )
        XCTAssertEqual(calendar.component(.month, from: months[0]), 3)
        XCTAssertEqual(calendar.component(.year, from: months[0]), 2026)
    }

    // March 10 minus 14 days = Feb 24, so extra large should start at February
    func testExtraLargeLooksBackToFebruary() {
        let today = date(year: 2026, month: 3, day: 10)
        let months = CalendarLogic.monthsToShow(
            today: today, monthCount: 6, isExtraLarge: true, calendar: calendar
        )
        XCTAssertEqual(calendar.component(.month, from: months[0]), 2)
    }

    // March 20 minus 14 days = March 6, so extra large should still start at March
    func testExtraLargeStaysInMarch() {
        let today = date(year: 2026, month: 3, day: 20)
        let months = CalendarLogic.monthsToShow(
            today: today, monthCount: 6, isExtraLarge: true, calendar: calendar
        )
        XCTAssertEqual(calendar.component(.month, from: months[0]), 3)
    }

    func testMonthsAreConsecutive() {
        let months = CalendarLogic.monthsToShow(
            today: date(year: 2026, month: 11, day: 15),
            monthCount: 4, isExtraLarge: false, calendar: calendar
        )
        for i in 1..<months.count {
            let prev = calendar.dateComponents([.year, .month], from: months[i - 1])
            let curr = calendar.dateComponents([.year, .month], from: months[i])
            let expectedMonth = (prev.month! % 12) + 1
            XCTAssertEqual(curr.month!, expectedMonth, "Month \(i) should follow month \(i-1)")
        }
    }
}

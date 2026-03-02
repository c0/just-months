import XCTest

final class DayLogicTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
    }

    private func date(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    // MARK: - isToday

    func testIsTodaySameDate() {
        let d = date(year: 2026, month: 3, day: 15)
        XCTAssertTrue(CalendarLogic.isToday(d, today: d, calendar: calendar))
    }

    func testIsTodayDifferentTimeSameDay() {
        let morning = date(year: 2026, month: 3, day: 15, hour: 8)
        let evening = date(year: 2026, month: 3, day: 15, hour: 22)
        XCTAssertTrue(CalendarLogic.isToday(morning, today: evening, calendar: calendar))
    }

    func testIsTodayDifferentDay() {
        let today = date(year: 2026, month: 3, day: 15)
        let yesterday = date(year: 2026, month: 3, day: 14)
        XCTAssertFalse(CalendarLogic.isToday(yesterday, today: today, calendar: calendar))
    }

    // MARK: - isPast

    func testIsPastYesterday() {
        let today = date(year: 2026, month: 3, day: 15)
        let yesterday = date(year: 2026, month: 3, day: 14)
        XCTAssertTrue(CalendarLogic.isPast(yesterday, today: today, calendar: calendar))
    }

    func testIsPastTomorrow() {
        let today = date(year: 2026, month: 3, day: 15)
        let tomorrow = date(year: 2026, month: 3, day: 16)
        XCTAssertFalse(CalendarLogic.isPast(tomorrow, today: today, calendar: calendar))
    }

    func testIsPastSameDay() {
        let today = date(year: 2026, month: 3, day: 15)
        XCTAssertFalse(CalendarLogic.isPast(today, today: today, calendar: calendar))
    }

    func testIsPastSameDayDifferentTimes() {
        let earlyToday = date(year: 2026, month: 3, day: 15, hour: 1)
        let lateToday = date(year: 2026, month: 3, day: 15, hour: 23)
        XCTAssertFalse(CalendarLogic.isPast(earlyToday, today: lateToday, calendar: calendar))
        XCTAssertFalse(CalendarLogic.isPast(lateToday, today: earlyToday, calendar: calendar))
    }
}

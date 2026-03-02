import XCTest

final class CalendarDestinationTests: XCTestCase {
    func testAllCasesCount() {
        XCTAssertEqual(CalendarDestination.allCases.count, 3)
    }

    func testRawValues() {
        XCTAssertEqual(CalendarDestination.google.rawValue, "google")
        XCTAssertEqual(CalendarDestination.outlook.rawValue, "outlook")
        XCTAssertEqual(CalendarDestination.apple.rawValue, "apple")
    }

    func testLabels() {
        XCTAssertEqual(CalendarDestination.google.label, "Google Calendar")
        XCTAssertEqual(CalendarDestination.outlook.label, "Outlook")
        XCTAssertEqual(CalendarDestination.apple.label, "Apple Calendar")
    }

    func testURLs() {
        XCTAssertEqual(CalendarDestination.google.url.absoluteString, "https://calendar.google.com")
        XCTAssertEqual(CalendarDestination.outlook.url.absoluteString, "https://outlook.office.com/calendar/")
        XCTAssertEqual(CalendarDestination.apple.url.absoluteString, "calshow://")
    }

    func testInitFromRawValue() {
        XCTAssertEqual(CalendarDestination(rawValue: "google"), .google)
        XCTAssertEqual(CalendarDestination(rawValue: "outlook"), .outlook)
        XCTAssertEqual(CalendarDestination(rawValue: "apple"), .apple)
        XCTAssertNil(CalendarDestination(rawValue: "invalid"))
    }
}

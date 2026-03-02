import Foundation

enum CalendarDestination: String, CaseIterable {
    case google = "google"
    case outlook = "outlook"
    case apple = "apple"

    var label: String {
        switch self {
        case .google: return "Google Calendar"
        case .outlook: return "Outlook"
        case .apple: return "Apple Calendar"
        }
    }

    var url: URL {
        switch self {
        case .google: return URL(string: "https://calendar.google.com")!
        case .outlook: return URL(string: "https://outlook.office.com/calendar/")!
        case .apple: return URL(string: "calshow://")!
        }
    }
}

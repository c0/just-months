import SwiftUI

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

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        guard urls.contains(where: { $0.scheme == "bigcalendar" }) else { return }
        let destStr = UserDefaults.standard.string(forKey: "calendarDestination") ?? "google"
        let dest = CalendarDestination(rawValue: destStr) ?? .google
        NSWorkspace.shared.open(dest.url)
    }
}

@main
struct BigCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @AppStorage("calendarDestination") private var destination: String = CalendarDestination.google.rawValue

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)
            Text("Big Calendar")
                .font(.title)
                .fontWeight(.semibold)
            Text("Right-click your desktop and choose\n\"Edit Widgets\" to add the Big Calendar widget.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Divider()
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("When you click the widget, open:")
                    .font(.headline)
                Picker("", selection: $destination) {
                    ForEach(CalendarDestination.allCases, id: \.rawValue) { dest in
                        Text(dest.label).tag(dest.rawValue)
                    }
                }
                .pickerStyle(.radioGroup)
                .labelsHidden()
            }
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 350)
    }
}

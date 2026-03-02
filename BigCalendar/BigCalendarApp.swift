import SwiftUI

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

import SwiftUI
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        guard urls.contains(where: { $0.scheme == "justmonths" }) else { return }
        let destStr = UserDefaults.standard.string(forKey: "calendarDestination") ?? "google"
        let dest = CalendarDestination(rawValue: destStr) ?? .google
        if dest == .apple {
            // calshow:// is iOS-only; open Calendar.app by bundle ID on macOS
            if let calendarAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
                NSWorkspace.shared.open(calendarAppURL)
            }
        } else {
            NSWorkspace.shared.open(dest.url)
        }
    }
}

@main
struct JustMonthsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(updater: updaterController.updater)
        }
    }
}

struct ContentView: View {
    @AppStorage("calendarDestination") private var destination: String = CalendarDestination.google.rawValue
    let updater: SPUUpdater

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)
            Text("Just Months")
                .font(.title)
                .fontWeight(.semibold)
            Text("Right-click your desktop and choose\n\"Edit Widgets\" to add the Just Months widget.")
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

            Divider()
                .padding(.vertical, 8)

            Button("Check for Updates…") {
                updater.checkForUpdates()
            }
            .disabled(!updater.canCheckForUpdates)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 350)
    }
}

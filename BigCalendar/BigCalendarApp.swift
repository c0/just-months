import SwiftUI

@main
struct BigCalendarApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
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
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
    }
}

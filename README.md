# BigCalendar

A native macOS desktop widget that shows multiple months at a glance. Built with WidgetKit + SwiftUI, requires macOS 14 Sonoma or later.

- **Extra Large** widget — 6 months (3×2 grid)
- **Large** widget — 3 months (3×1 grid)
- Starts 2 weeks before today so you can see recent context
- Today highlighted with an accent-color circle
- Past dates dimmed; future dates full brightness
- Auto-refreshes at midnight

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15 or later
- Homebrew (for xcodegen)

## Build

```sh
# 1. Install xcodegen (one-time)
make setup

# 2. Generate the Xcode project
make generate

# 3. Open in Xcode and build
make open
```

In Xcode, select the **BigCalendar** scheme, choose your Mac as the destination, then press **⌘R** to build and run.

> The app itself is just a launch screen — the widget runs as a system extension managed by WidgetKit.

## Add the widget to your desktop

1. Build and run once so macOS registers the widget extension.
2. Right-click an empty area of your desktop.
3. Choose **Edit Widgets**.
4. Search for **Big Calendar**.
5. Drag the **Extra Large** or **Large** size onto your desktop.

## Development

After editing `project.yml`, regenerate the Xcode project:

```sh
make generate
```

After editing Swift source files, just rebuild in Xcode (no regeneration needed).

To trigger a widget reload during development, use the Xcode widget simulator or run:

```sh
xcrun simctl --set previews push booted com.bigcalendar.app.widget widget.json
```

## Project layout

```
project.yml                   xcodegen spec
Makefile                      common tasks
BigCalendar/
  BigCalendarApp.swift        app shell (@main)
  Assets.xcassets/            AppIcon + AccentColor
BigCalendarWidget/
  BigCalendarWidget.swift     Provider, Entry, Widget config, View
  MonthView.swift             MonthView + DayCell components
  Assets.xcassets/            WidgetBackground color
BigCalendar.xcodeproj/        generated — do not edit by hand
```

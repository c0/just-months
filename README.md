<p align="center">
  <img src="app-icon-months.png" width="128" height="128" alt="Just Months icon" />
</p>

<h1 align="center">Just Months</h1>

<p align="center">It's just <code>cal</code>. But yours.</p>

<p align="center">
  <a href="https://github.com/c0/just-months/releases/latest">Download</a>
  &nbsp;·&nbsp;
  <a href="https://justmonths.app">justmonths.app</a>
</p>

---

<p align="center">
  <img src="site/public/screenshot.png" alt="Just Months widget screenshot" width="640" />
</p>

## Features

- Three months at a glance — previous, current, next
- Today highlighted with a coral block cursor
- Click the widget to open your calendar app of choice
- WidgetKit native — lives in Notification Center
- Retro terminal aesthetic: monospace, dark navy, cyan phosphor
- Auto-updates via Sparkle
- Light and dark mode

## Prerequisites

- macOS 14 Sonoma or later
- Xcode 15 or later
- [Homebrew](https://brew.sh)
- xcodegen (`make setup`)

## Quick Start

```sh
make setup      # install xcodegen (one-time)
make generate   # generate JustMonths.xcodeproj from project.yml
make open       # open in Xcode
# press ⌘R to build and run
```

## Project Structure

```
project.yml                          xcodegen spec (source of truth)
Makefile                             build shortcuts
scripts/
  release.sh                         full release pipeline
site/                                Astro marketing site (justmonths.app)
JustMonths/
  JustMonthsApp.swift                app entry point + Sparkle updater
  JustMonths.entitlements            sandbox + network.client (Release)
  JustMonthsLocalRelease.entitlements  adds network.client for local Sparkle testing
  Assets.xcassets/                   AppIcon + AccentColor
JustMonthsWidget/
  JustMonthsWidget.swift             WidgetKit provider, entry, config, view
  MonthView.swift                    MonthView + DayCell
  Assets.xcassets/                   WidgetBackground color
Shared/
  CalendarDestination.swift          calendar destinations (shared by both targets)
  CalendarLogic.swift                month/day calculation logic
JustMonths.xcodeproj/                generated — never edit by hand
```

## Architecture

| Target | Type | Sandbox | Sparkle | Notes |
|---|---|---|---|---|
| `JustMonths` | macOS application | app-sandbox + network.client | Yes | Menu bar shell |
| `JustMonthsWidget` | WidgetKit extension | app-sandbox only | No | Notification Center widget |

Shared Swift sources in `Shared/` compile into both targets. `JustMonthsWidget` must never receive Sparkle or network entitlements — keep it clean.

Build configurations:

| Config | Use |
|---|---|
| `Debug` | Day-to-day development |
| `Release` | Developer ID signed, for distribution |
| `LocalRelease` | Like Release, with `network.client` for Sparkle local testing |

## Supported Calendars

| Calendar | Opens |
|---|---|
| Google Calendar | `https://calendar.google.com` |
| Outlook | `https://outlook.office.com/calendar/` |
| Apple Calendar | `calshow://` (native app) |

## After Editing project.yml

Always regenerate the Xcode project after any `project.yml` change:

```sh
make generate
```

Never edit `JustMonths.xcodeproj` directly — it is fully generated from `project.yml`.

## Release

Releases are handled by an AI-guided skill. From Claude Code:

```
/release
```

This verifies prerequisites, determines the next version from git history, updates `CHANGELOG.md` and the marketing site, then runs `scripts/release.sh` which handles archiving, signing, DMG creation, notarization, tagging, appcast generation, and GitHub Release creation.

To release manually:

```sh
cp .env.example .env   # fill in APPLE_TEAM_ID, APPLE_ID, SIGNING_IDENTITY_NAME
make release VERSION=1.2.3
```

## Website

The marketing site lives in `site/` (Astro 6, deploys to justmonths.app).

```sh
cd site
npm install
npm run dev      # localhost:4321
npm run build    # production build
```

## License

MIT

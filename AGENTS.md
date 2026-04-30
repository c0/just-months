# Just Months — AI Context

## What this is

A macOS menu bar app that displays a three-month calendar (previous / current / next) in a retro terminal aesthetic. Built with SwiftUI + WidgetKit.

## Two-target architecture

| Target | Type | Bundle ID | Notes |
|---|---|---|---|
| `JustMonths` | macOS application | `com.justmonths.app` | Menu bar app shell + Sparkle updater |
| `JustMonthsWidget` | WidgetKit app-extension | `com.justmonths.app.widget` | Notification Center widget, no network |

**Critical constraint:** `JustMonthsWidget` must never have Sparkle or network entitlements. It runs in a tighter sandbox than the app target.

Shared Swift sources live in `Shared/` and are compiled into both targets.

## Key files

| File | Purpose |
|---|---|
| `project.yml` | XcodeGen spec — source of truth for project config |
| `JustMonths.xcodeproj` | Generated — never edit by hand |
| `Makefile` | Build shortcuts |
| `JustMonths/JustMonthsApp.swift` | App entry point |
| `JustMonths/JustMonths.entitlements` | Sandbox entitlements (Release) |
| `JustMonths/JustMonthsLocalRelease.entitlements` | Adds `network.client` for Sparkle local testing |
| `JustMonthsWidget/` | Widget extension sources |
| `Shared/` | Calendar logic shared by both targets |
| `ExportOptions.plist` | Developer ID export config (sed-substituted at release) |
| `scripts/release.sh` | Full release pipeline |
| `site/` | Astro marketing site (justmonths.app) |
| `CHANGELOG.md` | Keep-a-changelog format |

## Build commands

```sh
make setup       # install xcodegen (once)
make generate    # regenerate JustMonths.xcodeproj from project.yml
make build       # xcodebuild Release
make open        # open in Xcode
make local-release  # build LocalRelease config (Sparkle testing)
make release VERSION=1.2.3  # full release pipeline
```

## XcodeGen workflow

**Always edit `project.yml`, never `.xcodeproj` directly.**

After any change to `project.yml`:
```sh
make generate
```

This regenerates `JustMonths.xcodeproj`. The `.xcodeproj` is committed so Xcode can open it without running xcodegen first, but `project.yml` is the authoritative source.

## Design constraints

Design identity: retro terminal / phosphor CRT. See `design/identity.md` for full spec.

- **Monospace only** — SF Mono, Menlo, or Courier
- **Color palette:** navy `#0A0E2A`, cyan `#00FFFF`, coral `#FF4A3D`, pale blue `#E0EFFF`, muted navy `#1C284A`
- **No rounded corners** on calendar cells
- **No animations** — instant redraws only
- **No icons** — numbers and text labels only
- **No gradients or shadows**

## Common dev tasks

**Add a calendar destination (e.g. show 4 months):**
Edit the layout logic in `Shared/`. Both targets recompile automatically.

**Change widget layout:**
Edit `JustMonthsWidget/`. Run `make generate` if you change sources/targets in `project.yml`.

**Force widget reload during development:**
Add a `WidgetCenter.shared.reloadAllTimelines()` call or use Xcode's widget simulator.

**Test Sparkle update locally:**
Build with `make local-release` (uses `JustMonthsLocalRelease.entitlements` which includes `network.client`).
Serve a local appcast with `generate_appcast` and a local HTTP server.

## Release

See `.Codex/skills/release/SKILL.md` for the AI-guided release flow.
Manual pipeline: `make release VERSION=x.y.z` (requires `.env` with team credentials).

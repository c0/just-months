---
name: setup
description: Get a developer up and running with the just-months codebase — prerequisites, architecture, build commands, and common tasks.
---

Orient a new contributor to the just-months codebase and get them to a working build.

## Instructions

### Step 1: Check prerequisites

Verify these are installed. If any are missing, tell the user what to install and stop.

1. **macOS 14+** — `sw_vers -productVersion` (must be ≥ 14.0)
2. **Xcode CLI tools** — `xcode-select -p` (if missing: `xcode-select --install`)
3. **Homebrew** — `which brew` (if missing: direct them to https://brew.sh)
4. **xcodegen** — `which xcodegen` (if missing: `make setup`)

### Step 2: Generate Xcode project and build

```bash
make generate   # regenerate JustMonths.xcodeproj from project.yml
make open       # open in Xcode, then ⌘R
```

Or to build from the terminal:
```bash
make build
```

### Step 3: Orient the developer

Share this architecture overview:

**Two-target structure:**

| Target | Type | Bundle ID | Notes |
|---|---|---|---|
| `JustMonths` | macOS application | `com.justmonths.app` | Menu bar app shell + Sparkle updater |
| `JustMonthsWidget` | WidgetKit app-extension | `com.justmonths.app.widget` | Notification Center widget — no network, no Sparkle |

**Critical constraint:** `JustMonthsWidget` must never get Sparkle or network entitlements. It runs in a tighter sandbox.

**Shared code:** Swift sources in `Shared/` compile into both targets. Calendar logic lives here.

**Key files:**

| File | Purpose |
|---|---|
| `project.yml` | XcodeGen spec — source of truth for all Xcode settings |
| `JustMonths.xcodeproj` | Generated — never edit directly |
| `Makefile` | Build shortcuts |
| `JustMonths/JustMonthsApp.swift` | App entry point, Sparkle updater controller |
| `JustMonths/JustMonths.entitlements` | Sandbox + network.client (Release) |
| `JustMonths/JustMonthsLocalRelease.entitlements` | Same but for local Sparkle testing |
| `JustMonthsWidget/` | Widget extension sources |
| `Shared/` | Calendar logic shared by both targets |
| `site/` | Astro marketing site (justmonths.app) |
| `scripts/release.sh` | Full release pipeline |
| `CHANGELOG.md` | Keep-a-changelog format |

**Build configurations:**

| Config | Purpose |
|---|---|
| `Debug` | Day-to-day development |
| `Release` | Developer ID signed, for distribution |
| `LocalRelease` | Like Release but uses `JustMonthsLocalRelease.entitlements` for Sparkle testing |

**Design identity:** Retro terminal / phosphor CRT. See `design/identity.md`.
- Monospace only (SF Mono, Menlo, Courier)
- Colors: navy `#0A0E2A`, cyan `#00FFFF`, coral `#FF4A3D`
- No rounded corners, no gradients, no shadows, no animations

### Step 4: XcodeGen workflow

Always edit `project.yml`, never the `.xcodeproj` directly. After any change:
```bash
make generate
```

## Common dev tasks

**Add or change a calendar destination:**
Edit the destination logic in `Shared/`. Both targets pick it up automatically after `make generate`.

**Change the widget layout:**
Edit `JustMonthsWidget/`. Run `make generate` only if you changed sources/targets in `project.yml`.

**Force widget reload during development:**
Call `WidgetCenter.shared.reloadAllTimelines()` from the app, or use Xcode's widget simulator.

**Test Sparkle locally:**
```bash
make local-release   # builds LocalRelease config with network.client entitlement
```
Serve a local appcast with `generate_appcast` + a local HTTP server.

## Important Rules

- `project.yml` is the source of truth — never edit `.xcodeproj` directly
- `JustMonthsWidget` must never have Sparkle or network entitlements
- Shared sources in `Shared/` compile into both targets — keep them target-agnostic
- Run `make generate` after any `project.yml` change

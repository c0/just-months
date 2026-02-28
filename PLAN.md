# Plan: Apply Chops Features to just-months

## Context

just-months (SwiftUI + WidgetKit) already uses xcodegen but lacks a marketing site, release
pipeline, Sparkle auto-update, Claude skills, CHANGELOG, CLAUDE.md, and a proper README.
This plan ports all of those from Chops, adapted for just-months' two-target structure.

**Key constraint:** `JustMonthsWidget` must stay clean — no Sparkle, no network entitlements.

---

## Phase 1 — Foundation (no dependencies)

Create these files first; everything else builds on them.

| File | Contents |
|---|---|
| `.env.example` | `APPLE_TEAM_ID=`, `APPLE_ID=`, `SIGNING_IDENTITY_NAME=` |
| `CHANGELOG.md` | Keep-a-changelog format, `[Unreleased]` + `[1.0.0] - 2026-03-21` initial entry |
| `CLAUDE.md` | AI context: two-target arch, build commands, key files, dev rules, xcodegen workflow |
| `ExportOptions.plist` | Developer ID export, `${APPLE_TEAM_ID}` placeholder (sed-substituted at release time) |
| `JustMonths/JustMonthsLocalRelease.entitlements` | `app-sandbox: true` + `network.client: true` (local Sparkle testing) |

---

## Phase 2 — project.yml

Depends on Phase 1 (LocalRelease entitlements file must exist).

Changes to `project.yml`:

**Top-level packages block (new):**
```yaml
packages:
  Sparkle:
    url: https://github.com/sparkle-project/Sparkle
    minorVersion: "2.6.0"
```

**JustMonths `settings.base` additions:**
```yaml
MARKETING_VERSION: "1.0.0"
CURRENT_PROJECT_VERSION: "1"
ENABLE_HARDENED_RUNTIME: YES
```

**JustMonths `settings.configs` block (new):**
```yaml
configs:
  Release:
    CODE_SIGN_IDENTITY: "Developer ID Application"
  LocalRelease:
    CODE_SIGN_IDENTITY: "Developer ID Application"
    CODE_SIGN_ENTITLEMENTS: JustMonths/JustMonthsLocalRelease.entitlements
```

**JustMonths `entitlements.properties` addition:**
```yaml
com.apple.security.network.client: true
```

**JustMonths `info.properties` additions:**
```yaml
SUFeedURL: "https://justmonths.app/appcast.xml"
SUPublicEDKey: "PLACEHOLDER_REPLACE_AT_FIRST_RELEASE"
```

**JustMonths `dependencies` addition:**
```yaml
- package: Sparkle
```

**JustMonthsWidget `settings.base` additions (version only — no Sparkle):**
```yaml
MARKETING_VERSION: "1.0.0"
CURRENT_PROJECT_VERSION: "1"
```

After edits: `make generate` to regenerate the Xcode project and verify Sparkle resolves.

---

## Phase 3 — Swift: Sparkle Integration

Depends on Phase 2 (Sparkle must be in project.yml before it can be imported).

Modify `JustMonths/JustMonthsApp.swift`:

- Add `import Sparkle`
- Add stored property on `JustMonthsApp`: `private let updaterController: SPUStandardUpdaterController`
- Add `init()` that creates `SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)`
- Pass `updaterController.updater` into `ContentView`
- Add "Check for Updates…" `Button` in `ContentView` → calls `updater.checkForUpdates()`, disabled when `!updater.canCheckForUpdates`

---

## Phase 4 — Scripts

Depends on Phase 1 (.env.example) and Phase 2 (project.yml signing config).

### `scripts/release.sh` (new)

Full pipeline:
1. Load `.env`, validate: branch = main, clean tree, AC_PASSWORD keychain accessible
2. Accept `VERSION` as `$1` or prompt (suggests patch bump from last tag)
3. `xcodegen generate`
4. `xcodebuild archive` — Release config, Developer ID signing
5. `xcodebuild -exportArchive` — sed `ExportOptions.plist` → `build/ExportOptions.plist` first
6. Create DMG: `hdiutil create` UDRW → mount → `ln -s /Applications` → copy background if present → AppleScript Finder layout → detach → `hdiutil convert` UDZO
7. `xcrun notarytool submit --wait` + `xcrun stapler staple`
8. `git tag v$VERSION && git push origin v$VERSION`
9. `generate_appcast` → write `site/public/appcast.xml` → commit + push
10. `gh release create` with CHANGELOG notes extracted via awk

### `scripts/dmg-background.png` (new)

Dark navy (#0A0E2A) background PNG. The release.sh guards against its absence:
```sh
if [ -f "$REPO_ROOT/scripts/dmg-background.png" ]; then
  # copy to DMG and set background picture
fi
```
DMG works without it; art can be added later.

### `Makefile` additions

Add to `.PHONY` line, add two new targets:
```makefile
local-release:
	xcodebuild -project JustMonths.xcodeproj -scheme JustMonths \
	           -configuration LocalRelease -derivedDataPath .build

release:
	@[ -f .env ] || (echo "ERROR: .env not found. Copy .env.example."; exit 1)
	@bash scripts/release.sh $(VERSION)
```

---

## Phase 5 — Site

Independent of all other phases (pure static content).

Create `site/` with Astro 6, domain `justmonths.app`:

| File | Purpose |
|---|---|
| `site/package.json` | `astro: ^6.0.0`, dev/build/preview scripts |
| `site/astro.config.mjs` | `site: "https://justmonths.app"` |
| `site/tsconfig.json` | extends `astro/tsconfigs/base` |
| `site/public/appcast.xml` | Stub Sparkle feed (overwritten by release.sh each release) |
| `site/public/favicon.png` | Copy of `app-icon-months.png` |
| `site/public/screenshot.png` | Placeholder (user supplies actual screenshot) |
| `site/src/layouts/Layout.astro` | Retro terminal CSS vars (dark navy/cyan/coral), monospace |
| `site/src/pages/index.astro` | Icon, tagline, download button, feature list, footer |

`index.astro` contains:
```js
const APP_VERSION = "1.0.0";  // ← release skill updates this line on each release
```

Download button links to:
`https://github.com/c0/just-months/releases/download/v{APP_VERSION}/JustMonths-{APP_VERSION}.dmg`

Site design follows the retro terminal identity from `design/identity.md`.

---

## Phase 6 — Claude Skills

Depends on Phase 5 (release skill references `site/src/pages/index.astro`).

### `.claude/skills/setup/SKILL.md`

Onboarding context:
- What the app is + two-target architecture table
- Build commands (make setup/generate/open)
- Key files table
- xcodegen workflow note
- Design constraints (monospace, color palette, no rounded corners)
- Common dev tasks (add calendar destination, change widget layout, force widget reload)

### `.claude/skills/release/SKILL.md`

Interactive AI-guided release flow:
1. Verify prereqs: `.env` exists, AC_PASSWORD keychain valid, clean tree, on main
2. Determine next version: `git tag -l 'v*'` → suggest patch bump → inspect commits for minor/major
3. **`AskUserQuestion` to confirm version** — always required before proceeding
4. Update `CHANGELOG.md`: rename `[Unreleased]` → `[VERSION] - DATE`, add new `[Unreleased]`
5. Update `const APP_VERSION = "..."` in `site/src/pages/index.astro`
6. Commit both files: `git commit -m "chore: update site + changelog for vVERSION"`
7. Run `./scripts/release.sh VERSION`
8. Report: version, GitHub Release URL, appcast updated y/n

---

## Phase 7 — Documentation & Config

Depends on Phases 3, 4, 5 (README references all of them).

### `README.md` — full rewrite

Structure (following Chops pattern):
- Centered `app-icon-months.png` (128px), title, tagline ("It's just `cal`. But yours.")
- Links: Download · justmonths.app
- Screenshot (`site/public/screenshot.png`)
- Features section
- Prerequisites + Quick Start (4 commands)
- Project structure tree
- Architecture table (two targets, sandbox, Sparkle)
- Supported calendars table
- After editing project.yml note
- Release section
- Website section
- License (MIT)

### `.gitignore` additions

```
.env
build/
*.dmg
*.xcarchive
```

### `.claude/settings.local.json` additions

Add to existing `allow` array:
```json
"Bash(bash scripts/release.sh*)",
"Bash(hdiutil:*)",
"Bash(osascript:*)",
"Bash(gh:*)",
"Bash(generate_appcast:*)",
"Bash(npm:*)"
```

---

## Verification

1. `make generate` — succeeds, Sparkle SPM resolves
2. Build in Xcode (⌘R) — app launches with "Check for Updates…" button visible
3. `cd site && npm install && npm run dev` — site at localhost:4321
4. `/release` skill dry-run — reaches version confirmation, cancel there

### One-time Sparkle key setup (first release only, outside this plan)

```sh
generate_keys   # ships with Sparkle / brew install sparkle
# Update SUPublicEDKey in project.yml → make generate
```

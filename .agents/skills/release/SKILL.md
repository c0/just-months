---
name: release
description: Interactively cut a new Just Months release — verify prereqs, determine version, update changelog and site, then run the release pipeline.
---

Cut a new release of Just Months. Checks prerequisites, determines the next version from git history, updates CHANGELOG.md and the marketing site, then runs the full release script.

## Instructions

### Step 1: Verify prerequisites

1. Confirm `.env` exists in the project root. If it does not, stop and tell the user:
   "Missing `.env` file. Copy `.env.example` to `.env` and fill in APPLE_TEAM_ID, APPLE_ID, and SIGNING_IDENTITY_NAME."

2. Confirm `APPLE_APP_SPECIFIC_PASSWORD` is set in `.env`:
   ```bash
   grep -q "APPLE_APP_SPECIFIC_PASSWORD" .env
   ```
   If it's missing or empty, stop and tell the user to add it to `.env`:
   ```
   APPLE_APP_SPECIFIC_PASSWORD=xxxx-xxxx-xxxx-xxxx
   ```
   Generate one at appleid.apple.com → Sign-In and Security → App-Specific Passwords.

3. Confirm the working tree is clean:
   ```bash
   git status --porcelain
   ```
   If there are uncommitted changes, stop and tell the user to commit or stash first.

4. Confirm the current branch is `main`:
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```
   If not on `main`, stop and tell the user to switch first.

### Step 2: Determine the next version

1. Get the latest tag:
   ```bash
   git tag -l 'v*' | sort -V | tail -1
   ```

2. Get commits since that tag:
   ```bash
   git log <latest_tag>..HEAD --oneline --format='%s'
   ```

3. If there are zero commits since the last tag, stop and tell the user there is nothing to release.

4. Apply semver logic:
   - Any commit starting with `feat:` or `feat(` → **minor** bump (e.g. 1.0.0 → 1.1.0)
   - All commits are `fix:`, `chore:`, `docs:` or similar → **patch** bump (e.g. 1.0.0 → 1.0.1)
   - Any commit contains `BREAKING CHANGE` or `!:` suffix → ask the user what version to use
   - If messages are ambiguous, use `AskUserQuestion` to ask

### Step 3: Confirm the version

Always confirm the version before proceeding. Use `AskUserQuestion`:
- question: "Release as v<VERSION>?\n\nCommits included:\n<commit list>"
- header: "Confirm release"
- options: "Yes, release v<VERSION>", "Use a different version", "Cancel"

If the user picks "Use a different version", ask them for the version number. If they pick "Cancel", stop.

### Step 4: Update CHANGELOG.md

1. Check if `CHANGELOG.md` has an `## [Unreleased]` section with content.
2. If the `## [Unreleased]` section is empty or missing, draft user-facing entries from commits:
   - Rewrite each entry from the user's perspective — what changed, what it fixes, what it enables
   - No commit prefixes, no technical jargon
   - Confirm the drafted entries with the user using `AskUserQuestion`
3. Rename `## [Unreleased]` → `## [VERSION] - YYYY-MM-DD` (today's date)
4. Insert a new empty `## [Unreleased]` section above it

### Step 5: Update the marketing site version

Edit `site/src/pages/index.astro`. Find the line:
```js
const APP_VERSION = "...";
```
Replace the version string with the new version. The comment on that line must stay intact:
```js
const APP_VERSION = "<VERSION>"; // ← release skill updates this line on each release
```

### Step 6: Commit pre-release changes

```bash
git add CHANGELOG.md site/src/pages/index.astro
git commit -m "chore: update site + changelog for v<VERSION>"
git push origin main
```

### Step 7: Run the release script

```bash
bash scripts/release.sh <VERSION>
```

This handles: xcodegen → archive → export → DMG → notarize → staple → git tag → appcast → GitHub Release.

The script automatically bumps both `MARKETING_VERSION` (e.g. `1.0.2`) and `CURRENT_PROJECT_VERSION` (the build number Sparkle uses for update comparisons) in `project.yml`. Never skip or manually set these — the script increments the build number so Sparkle can detect the update.

Let it run to completion. If it fails, report the error output to the user and stop. Do NOT retry automatically.

### Step 8: Report

Tell the user:
- The version that was released
- GitHub Release URL: `https://github.com/c0/just-months/releases/tag/v<VERSION>`
- Whether the appcast at `site/public/appcast.xml` was updated (it should be — the script does it)
- Reminder: deploy the marketing site if it isn't on auto-deploy (`npm run build` from `site/`)

## Important Rules

- ALWAYS confirm the version with the user before proceeding (Step 3 is non-negotiable)
- NEVER run the release script if `.env` is missing or the working tree is dirty
- NEVER skip the CHANGELOG or site version update
- NEVER modify `JustMonthsWidget` sources as part of a release
- If the release script fails, do NOT retry — report the error and stop
- The release script handles git tagging and GitHub Release creation — do not duplicate those steps

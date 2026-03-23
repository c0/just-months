# Changelog

All notable changes to Just Months will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2026-03-23

### Fixed
- Auto-update now works correctly (the update feed URL was pointing to the wrong address)
- Installer disk image uses a smaller, cleaner drag arrow

## [1.0.1] - 2026-03-23

### Changed
- App is now named "Just Months" in Finder, Spotlight, and Launchpad

### Fixed
- Installer disk image now shows a drag-to-install arrow

## [1.0.0] - 2026-03-22

### Added
- macOS menu bar calendar widget showing multiple months at a time
- Today highlighted with coral accent block cursor
- Retro terminal aesthetic: monospace, dark navy, cyan phosphor text
- WidgetKit extension for desktop and Notification Center placement
- Light and dark mode support
- Sparkle auto-updater

### Fixed
- Today highlight renders as bold text on desktop (vibrant rendering mode remaps colors by luminance, making the coral block invisible)

[1.0.1]: https://github.com/c0/just-months/releases/tag/v1.0.1
[1.0.0]: https://github.com/c0/just-months/releases/tag/v1.0.0

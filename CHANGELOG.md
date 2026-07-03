# Changelog

All notable changes to PortPilot are documented here.

## Unreleased

## 0.1.5 - 2026-07-03

### Changed

- Updated the landing page product mock to match the current menu bar UI, including real process icons, fallback CLI icons, PID metadata, runtime sorting, and current scope labels.
- Replaced the website browser tab favicon with the PortPilot app icon.
- Tightened the menu bar popover footer spacing for a more balanced bottom edge.

## 0.1.4 - 2026-07-03

### Added

- Added real per-process icons in menu bar rows, with lazy loading and caching outside the scan path.
- Added lightweight hover tooltips for row actions.
- Added PID metadata to each menu bar row.

### Changed

- Refined the menu bar popover surfaces, spacing, scrollbar layout, and sort dropdown styling.
- Reworked fallback CLI icons to better match real macOS app icons.
- Improved icon resolution for helper processes by resolving nested helper apps back to their host app bundle.
- Renamed port exposure labels to "Local only", "All interfaces", and "Specific IP" for clearer networking semantics.
- Changed the default sort to runtime ascending.

## 0.1.3 - 2026-07-01

### Changed

- Refined the menu bar popover background with a calmer layered surface treatment.
- Improved list item surfaces, selected-row contrast, and hover depth.
- Added a dedicated scroll gutter so the scrollbar no longer sits tight against rows.
- Renamed the process sort label to "Process name" / "进程名" for clearer meaning.

## 0.1.2 - 2026-07-01

### Added

- Integrated Sparkle for native update checks, downloads, installation, cancellation, and relaunch.
- Added a Sparkle appcast feed and generation helper script.

### Changed

- Replaced the previous GitHub Releases link-out update check with Sparkle's native updater UI.
- Tightened the menu bar popover width and spacing.

## 0.1.1 - 2026-07-01

### Changed

- Split the Swift source into focused files for models, scanning, state, menu bar UI, components, styles, and app entry.
- Added the app icon to the English and Chinese README files.
- Reworked the footer update check into a lightweight inline action.
- Changed the About action to open the GitHub repository directly.
- Tightened footer spacing and button sizing for a calmer menu bar popover.

## 0.1.0 - 2026-07-01

### Added

- Native macOS menu bar popover for monitoring local listening ports.
- TCP `LISTEN` port scanning via `lsof`.
- Process metadata via `ps`, including runtime, CPU, and memory.
- Search by port, PID, process, command, URL, scope, and resource labels.
- Sorting by port, runtime, CPU, memory, and process, with ascending / descending direction.
- Manual refresh and refresh-on-open behavior.
- Row actions for opening localhost URLs, copying URLs, and terminating processes with confirmation.
- Copy success feedback with icon swap animation.
- Empty state, sorting popover, and footer spacing polish.
- Generated macOS app icon and menu bar icon.
- GitHub Releases update check.
- Chinese / English UI based on the system language.

### Notes

- PortPilot does not auto-refresh in the background.
- The release asset is an ad-hoc signed macOS app bundle zip.

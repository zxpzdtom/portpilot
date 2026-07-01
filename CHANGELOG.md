# Changelog

All notable changes to PortPilot are documented here.

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
- No release artifacts are attached yet; build locally with `./build.sh`.

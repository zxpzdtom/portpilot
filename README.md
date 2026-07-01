# PortPilot

Native macOS menu bar port monitor for local development.

[中文文档](README.zh-CN.md) · [Changelog](CHANGELOG.md)

PortPilot helps you see which local TCP ports are listening, which process owns each port, how long the process has been running, and its current CPU / memory footprint. It is designed for vibe coding sessions where dev servers, proxies, and helper processes come and go quickly.

## Highlights

- Native macOS menu bar app with a compact popover.
- Lists TCP `LISTEN` ports using the system `lsof` command.
- Shows port, scope, process, runtime, CPU, and memory usage.
- Search by port, PID, process name, command, URL, or resource labels.
- Sort by port, runtime, CPU, memory, or process, with ascending / descending direction.
- Refreshes when opened and when you click refresh. No automatic polling.
- Open `http://localhost:<port>` in the browser.
- Copy localhost URLs with inline success feedback.
- Terminate a process only after confirmation.
- Check for updates from GitHub Releases.
- Chinese / English UI, defaulting to the macOS language.

## Screens and entry points

PortPilot runs as an accessory app:

- Menu bar icon: opens the port popover.
- Refresh button: rescans listening ports.
- Sort control: chooses field and direction.
- Row actions: open URL, copy URL, or terminate after confirmation.
- Footer update button: checks GitHub Releases for a newer version.

## Requirements

- macOS 14.0 or later.
- Apple Silicon build target by default (`arm64-apple-macosx14.0`).
- Xcode Command Line Tools with `swiftc`.

## Build

```bash
./build.sh
```

The app bundle is written to:

```text
dist/PortPilot.app
```

To choose a custom output path:

```bash
APP_DIR="$PWD/PortPilot.app" ./build.sh
```

## Update checks

PortPilot checks:

```text
https://api.github.com/repos/zxpzdtom/portpilot/releases/latest
```

If a release newer than the bundled `CFBundleShortVersionString` is found, the footer status changes and the update button opens the release page. If the repository has no releases yet, PortPilot reports that gracefully.

## Project structure

```text
Sources/PortPilot/main.swift   Native SwiftUI / AppKit app
Assets/PortPilot.icns         App icon
Icon.iconset/                 Icon source set
Info.plist                    App bundle metadata
build.sh                      Local build script
```

## Notes

- PortPilot does not require administrator privileges for normal listing.
- Terminating a process sends `TERM` after an explicit confirmation.
- CPU and memory are read from `ps`; port ownership is read from `lsof`.
- The app does not auto-refresh in the background.

## License

MIT

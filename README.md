# PortPilot

<p align="center">
  <img src="Assets/PortPilotIcon.png" alt="PortPilot app icon" width="96" height="96">
</p>

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
- Check, download, and install updates with Sparkle.
- Chinese / English UI, defaulting to the macOS language.

## Screens and entry points

PortPilot runs as an accessory app:

- Menu bar icon: opens the port popover.
- Refresh button: rescans listening ports.
- Sort control: chooses field and direction.
- Row actions: open URL, copy URL, or terminate after confirmation.
- Footer update button: opens Sparkle's native update flow.

## Requirements

- macOS 14.0 or later.
- Apple Silicon build target by default (`arm64-apple-macosx14.0`).
- Xcode Command Line Tools with `swiftc`.

## Download

Download signed development builds from [GitHub Releases](https://github.com/zxpzdtom/portpilot/releases), or build locally with the steps below.

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

## Updates

PortPilot uses [Sparkle](https://sparkle-project.org/) for updates. Automatic background checks are disabled, so updates only run when you click the footer update button. Sparkle handles the native update window, download progress, cancellation, installation, and relaunch.

The appcast feed is configured in `Info.plist`:

```text
https://raw.githubusercontent.com/zxpzdtom/portpilot/refs/heads/main/appcast.xml
```

The bundled `SUPublicEDKey` verifies signed update archives. Keep the matching Sparkle private key in your macOS Keychain and never commit it.

After building a release zip and uploading it to GitHub Releases, regenerate the appcast:

```bash
RELEASE_TAG=v0.1.2 Scripts/generate_appcast.sh dist/releases
```

`dist/releases` should contain the release archive, for example `PortPilot-0.1.2.zip`.

## Project structure

```text
Sources/PortPilot/AppSupport.swift          Shared copy, links, motion, image helpers
Sources/PortPilot/Models.swift              Port, scope, and sort models
Sources/PortPilot/PortScanner.swift         lsof / ps scanning
Sources/PortPilot/PortListModel.swift       App state, sorting, update checks
Sources/PortPilot/MenuBarPopoverView.swift  Menu bar popover UI
Sources/PortPilot/MenuBarPortRow.swift      Menu bar list rows and row actions
Sources/PortPilot/MenuBarMetrics.swift      Menu bar metric cards
Sources/PortPilot/SortControls.swift        Sort trigger and sort options panel
Sources/PortPilot/Components.swift          Reusable SwiftUI components
Sources/PortPilot/EmptyStates.swift         Empty list states
Sources/PortPilot/FullWindowComponents.swift Legacy full-window components
Sources/PortPilot/Styles.swift              Button styles and view modifiers
Sources/PortPilot/PortPilotApp.swift        App entry point and AppKit delegate
Assets/PortPilot.icns                       App icon
Icon.iconset/                               Icon source set
Info.plist                                  App bundle metadata
appcast.xml                                 Sparkle update feed
build.sh                                    Local build script
Scripts/generate_appcast.sh                 Sparkle appcast generation helper
```

## Notes

- PortPilot does not require administrator privileges for normal listing.
- Terminating a process sends `TERM` after an explicit confirmation.
- CPU and memory are read from `ps`; port ownership is read from `lsof`.
- The app does not auto-refresh in the background.
- Update checks are manual; Sparkle only runs when you click the update button.

## License

MIT

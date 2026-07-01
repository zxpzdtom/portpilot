import AppKit
import Foundation
import SwiftUI

@MainActor
final class PortListModel: ObservableObject {
    @Published var entries: [PortEntry] = []
    @Published var query = ""
    @Published var sortMode: SortMode = .port
    @Published var sortDirection: SortDirection = .ascending
    @Published var selectedID: PortEntry.ID?
    @Published var isScanning = false
    @Published var statusMessage = AppCopy.text("就绪", "Ready")
    @Published var lastUpdated: Date?
    @Published var errorMessage: String?
    @Published var isCheckingUpdates = false
    @Published var updateMessage: String?
    @Published var updateReleaseURL: URL?

    init() {
        refresh()
    }

    var filteredEntries: [PortEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filtered: [PortEntry]
        if trimmed.isEmpty {
            filtered = entries
        } else {
            filtered = entries.filter { entry in
            "\(entry.port) \(entry.address) \(entry.pid) \(entry.processName) \(entry.command) \(entry.appHint) \(entry.cpuLabel) \(entry.memoryLabel) \(entry.runtimeLabel)"
                .lowercased()
                .contains(trimmed)
            }
        }

        return filtered.sorted { lhs, rhs in
            orderedBefore(lhs, rhs)
        }
    }

    var selectedEntry: PortEntry? {
        guard let selectedID else { return filteredEntries.first }
        return entries.first { $0.id == selectedID }
    }

    var footerMessage: String {
        if let updateMessage {
            return updateMessage
        }
        guard let lastUpdated else {
            return AppCopy.text("尚未刷新", "Not refreshed yet")
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return AppCopy.text("上次刷新 \(formatter.string(from: lastUpdated))", "Last refreshed \(formatter.string(from: lastUpdated))")
    }

    func setSortMode(_ mode: SortMode) {
        if sortMode == mode {
            return
        }
        sortMode = mode
        sortDirection = mode.defaultDirection
    }

    private func orderedBefore(_ lhs: PortEntry, _ rhs: PortEntry) -> Bool {
        switch sortMode {
        case .port:
            return compare(lhs.port, rhs.port, tie: lhs.pid < rhs.pid)
        case .runtime:
            return compare(lhs.runtimeSeconds, rhs.runtimeSeconds, tie: lhs.port < rhs.port)
        case .cpu:
            return compare(lhs.cpuPercent, rhs.cpuPercent, tie: lhs.port < rhs.port)
        case .memory:
            return compare(lhs.memoryBytes, rhs.memoryBytes, tie: lhs.port < rhs.port)
        case .process:
            let result = lhs.processName.localizedStandardCompare(rhs.processName)
            if result == .orderedSame {
                return lhs.port < rhs.port
            }
            return sortDirection == .ascending ? result == .orderedAscending : result == .orderedDescending
        }
    }

    private func compare<T: Comparable>(_ lhs: T, _ rhs: T, tie: @autoclosure () -> Bool) -> Bool {
        if lhs == rhs {
            return tie()
        }
        return sortDirection == .ascending ? lhs < rhs : lhs > rhs
    }

    func refresh() {
        guard !isScanning else { return }
        isScanning = true
        statusMessage = AppCopy.text("正在扫描...", "Scanning...")
        updateMessage = nil

        Task {
            do {
                let scanned = try await Task.detached(priority: .userInitiated) {
                    try PortScanner.scan()
                }.value

                withAnimation(Motion.smoothOut(Motion.fast)) {
                    entries = scanned
                    if let selectedID, !scanned.contains(where: { $0.id == selectedID }) {
                        self.selectedID = scanned.first?.id
                    } else if selectedID == nil {
                        self.selectedID = scanned.first?.id
                    }
                }
                lastUpdated = Date()
                statusMessage = AppCopy.text("\(scanned.count) 个监听端口", "\(scanned.count) listening ports")
                errorMessage = nil
            } catch {
                statusMessage = AppCopy.text("扫描失败", "Scan failed")
                errorMessage = error.localizedDescription
            }
            isScanning = false
        }
    }

    func checkForUpdates() {
        if let updateReleaseURL {
            NSWorkspace.shared.open(updateReleaseURL)
            return
        }

        guard !isCheckingUpdates else { return }
        guard let url = URL(string: AppLinks.latestReleaseAPI) else { return }

        isCheckingUpdates = true
        updateMessage = AppCopy.text("正在检查更新...", "Checking for updates...")

        Task {
            do {
                var request = URLRequest(url: url)
                request.setValue("PortPilot", forHTTPHeaderField: "User-Agent")
                request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

                let (data, response) = try await URLSession.shared.data(for: request)
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0

                guard status != 404 else {
                    updateMessage = AppCopy.text("还没有发布版本", "No releases yet")
                    updateReleaseURL = URL(string: AppLinks.releases)
                    isCheckingUpdates = false
                    return
                }

                guard (200..<300).contains(status) else {
                    throw NSError(domain: "PortPilot.Update", code: status, userInfo: [NSLocalizedDescriptionKey: "HTTP \(status)"])
                }

                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                let latestVersion = release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

                if Self.compareVersions(latestVersion, currentVersion) == .orderedDescending {
                    updateReleaseURL = URL(string: release.htmlURL)
                    updateMessage = AppCopy.text("发现新版本 \(release.tagName)", "New version \(release.tagName) available")
                } else {
                    updateReleaseURL = nil
                    updateMessage = AppCopy.text("已经是最新版本", "You're up to date")
                }
            } catch {
                updateReleaseURL = nil
                updateMessage = AppCopy.text("检查更新失败", "Update check failed")
            }

            isCheckingUpdates = false
        }
    }

    func terminateSelected(force: Bool = false) {
        guard let entry = selectedEntry else { return }
        terminate(entry: entry, force: force)
    }

    func terminate(entry: PortEntry, force: Bool = false) {
        Task {
            do {
                try await Task.detached(priority: .userInitiated) {
                    try PortScanner.terminate(pid: entry.pid, force: force)
                }.value
                statusMessage = AppCopy.text(
                    "已向 \(entry.processName) (\(entry.pid)) 发送 \(force ? "KILL" : "TERM")",
                    "Sent \(force ? "KILL" : "TERM") to \(entry.processName) (\(entry.pid))"
                )
                try? await Task.sleep(nanoseconds: 450_000_000)
                refresh()
            } catch {
                errorMessage = error.localizedDescription
                statusMessage = AppCopy.text("无法结束进程", "Could not terminate process")
            }
        }
    }

    private static func compareVersions(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let left = lhs.split(separator: ".").map { Int($0.filter(\.isNumber)) ?? 0 }
        let right = rhs.split(separator: ".").map { Int($0.filter(\.isNumber)) ?? 0 }
        let count = max(left.count, right.count)

        for index in 0..<count {
            let l = index < left.count ? left[index] : 0
            let r = index < right.count ? right[index] : 0
            if l < r { return .orderedAscending }
            if l > r { return .orderedDescending }
        }

        return .orderedSame
    }
}

struct GitHubRelease: Decodable {
    let tagName: String
    let htmlURL: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
    }
}

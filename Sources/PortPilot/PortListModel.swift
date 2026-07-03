import AppKit
import Foundation
import SwiftUI

@MainActor
final class PortListModel: ObservableObject {
    @Published var entries: [PortEntry] = []
    @Published var query = ""
    @Published var sortMode: SortMode = .runtime
    @Published var sortDirection: SortDirection = .ascending
    @Published var selectedID: PortEntry.ID?
    @Published var isScanning = false
    @Published var statusMessage = AppCopy.text("就绪", "Ready")
    @Published var lastUpdated: Date?
    @Published var errorMessage: String?

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
}

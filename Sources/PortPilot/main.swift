import AppKit
import Combine
import Foundation
import SwiftUI

struct PortEntry: Identifiable, Hashable {
    let id: String
    let port: Int
    let address: String
    let pid: Int32
    let processName: String
    let command: String
    let cpuPercent: Double
    let memoryBytes: Int64
    let runtime: String
    let runtimeSeconds: Int

    var url: String {
        "http://localhost:\(port)"
    }

    var scope: PortScope {
        if address.hasPrefix("127.0.0.1") || address.hasPrefix("localhost") || address.hasPrefix("[::1]") {
            return .local
        }
        if address.hasPrefix("*") || address.hasPrefix("[::]") {
            return .all
        }
        return .host
    }

    var scopeLabel: String {
        scope.label
    }

    var appHint: String {
        let text = "\(processName) \(command)".lowercased()
        if text.contains("vite") { return "Vite" }
        if text.contains("next") { return "Next.js" }
        if text.contains("nuxt") { return "Nuxt" }
        if text.contains("webpack") { return "Webpack" }
        if text.contains("expo") { return "Expo" }
        if text.contains("rails") { return "Rails" }
        if text.contains("django") { return "Django" }
        if text.contains("flask") { return "Flask" }
        if text.contains("uvicorn") { return "Uvicorn" }
        if text.contains("node") { return "Node" }
        if text.contains("bun") { return "Bun" }
        if text.contains("deno") { return "Deno" }
        if text.contains("python") { return "Python" }
        if text.contains("ruby") { return "Ruby" }
        if text.contains("java") { return "Java" }
        return processName
    }

    var cpuLabel: String {
        String(format: "%.1f%%", cpuPercent)
    }

    var memoryLabel: String {
        ByteCountFormatter.string(fromByteCount: memoryBytes, countStyle: .memory)
    }

    var runtimeLabel: String {
        runtime.isEmpty ? AppCopy.text("未知", "Unknown") : runtime
    }
}

enum PortScope: String, Hashable {
    case local
    case all
    case host

    var label: String {
        switch self {
        case .local:
            return AppCopy.text("本机", "Local")
        case .all:
            return AppCopy.text("全部", "All")
        case .host:
            return AppCopy.text("主机", "Host")
        }
    }
}

struct PortProcessInfo {
    let command: String
    let cpuPercent: Double
    let memoryBytes: Int64
    let runtime: String
    let runtimeSeconds: Int
}

enum SortMode: String, CaseIterable, Identifiable {
    case port
    case runtime
    case cpu
    case memory
    case process

    var id: String { rawValue }

    var label: String {
        switch self {
        case .port:
            return AppCopy.text("端口", "Port")
        case .runtime:
            return AppCopy.text("运行时长", "Runtime")
        case .cpu:
            return "CPU"
        case .memory:
            return AppCopy.text("内存", "Memory")
        case .process:
            return AppCopy.text("进程", "Process")
        }
    }

    var systemImage: String {
        switch self {
        case .port:
            return "number"
        case .runtime:
            return "timer"
        case .cpu:
            return "speedometer"
        case .memory:
            return "memorychip"
        case .process:
            return "app.dashed"
        }
    }

    var defaultDirection: SortDirection {
        switch self {
        case .port, .process:
            return .ascending
        case .runtime, .cpu, .memory:
            return .descending
        }
    }
}

enum SortDirection: String, CaseIterable, Identifiable {
    case ascending
    case descending

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ascending:
            return AppCopy.text("升序", "Asc")
        case .descending:
            return AppCopy.text("降序", "Desc")
        }
    }

    var shortLabel: String {
        switch self {
        case .ascending:
            return AppCopy.text("升", "Asc")
        case .descending:
            return AppCopy.text("降", "Desc")
        }
    }

    var systemImage: String {
        switch self {
        case .ascending:
            return "arrow.up"
        case .descending:
            return "arrow.down"
        }
    }
}

enum AppCopy {
    static var isChinese: Bool {
        Locale.preferredLanguages.first?.lowercased().hasPrefix("zh") == true
    }

    static func text(_ zh: String, _ en: String) -> String {
        isChinese ? zh : en
    }
}

enum AppLinks {
    static let repository = "https://github.com/zxpzdtom/portpilot"
    static let releases = "https://github.com/zxpzdtom/portpilot/releases"
    static let latestReleaseAPI = "https://api.github.com/repos/zxpzdtom/portpilot/releases/latest"
}

enum Motion {
    static let micro = 0.08
    static let quick = 0.15
    static let fast = 0.25
    static let medium = 0.35
    static let verySlow = 0.50
    static let stagger = 0.04
    static let iconStartScale: CGFloat = 0.25
    static let dropdownPreScale: CGFloat = 0.97
    static let dropdownCloseScale: CGFloat = 0.99
    static let pressScale: CGFloat = 0.96
    static let smallBlur: CGFloat = 2
    static let mediumBlur: CGFloat = 3

    static func smoothOut(_ duration: Double = fast) -> Animation {
        .timingCurve(0.22, 1, 0.36, 1, duration: duration)
    }

    static func iconSwap(_ duration: Double = fast) -> Animation {
        .easeInOut(duration: duration)
    }

    static func linear(_ duration: Double) -> Animation {
        .linear(duration: duration)
    }
}

enum PortScanner {
    static func scan() throws -> [PortEntry] {
        let lsofOutput = try run("/usr/sbin/lsof", arguments: ["-nP", "-iTCP", "-sTCP:LISTEN", "-F", "pcn"]).output
        var entries: [PortEntry] = []
        var seenIDs = Set<String>()
        var processInfoByPID: [Int32: PortProcessInfo] = [:]
        var currentPID: Int32?
        var currentProcess = ""

        for rawLine in lsofOutput.split(separator: "\n", omittingEmptySubsequences: true) {
            let line = String(rawLine)
            guard let field = line.first else { continue }
            let value = String(line.dropFirst())

            switch field {
            case "p":
                currentPID = Int32(value)
                currentProcess = ""
            case "c":
                currentProcess = value
            case "n":
                guard let pid = currentPID, let parsed = parseAddressAndPort(value) else { continue }
                let processInfo = processInfoByPID[pid] ?? processInfo(pid: pid)
                processInfoByPID[pid] = processInfo
                let id = "\(pid)-\(parsed.port)-\(parsed.address)"
                guard !seenIDs.contains(id) else { continue }
                seenIDs.insert(id)
                entries.append(
                    PortEntry(
                        id: id,
                        port: parsed.port,
                        address: parsed.address,
                        pid: pid,
                        processName: currentProcess.isEmpty ? "Unknown" : currentProcess,
                        command: processInfo.command,
                        cpuPercent: processInfo.cpuPercent,
                        memoryBytes: processInfo.memoryBytes,
                        runtime: processInfo.runtime,
                        runtimeSeconds: processInfo.runtimeSeconds
                    )
                )
            default:
                continue
            }
        }

        return entries.sorted {
            if $0.port == $1.port {
                return $0.pid < $1.pid
            }
            return $0.port < $1.port
        }
    }

    static func terminate(pid: Int32, force: Bool = false) throws {
        let signal = force ? "-KILL" : "-TERM"
        _ = try run("/bin/kill", arguments: [signal, "\(pid)"])
    }

    private static func parseAddressAndPort(_ value: String) -> (address: String, port: Int)? {
        let cleaned = value.replacingOccurrences(of: " (LISTEN)", with: "")
        guard let separator = cleaned.lastIndex(of: ":") else { return nil }
        let address = String(cleaned[..<separator])
        let portText = String(cleaned[cleaned.index(after: separator)...])
        guard let port = Int(portText) else { return nil }
        return (address, port)
    }

    private static func processInfo(pid: Int32) -> PortProcessInfo {
        let output = (try? run("/bin/ps", arguments: ["-p", "\(pid)", "-o", "%cpu=", "-o", "rss=", "-o", "etime=", "-o", "command="]).output.trimmingCharacters(in: .whitespacesAndNewlines)) ?? ""
        let parts = output.split(maxSplits: 3, omittingEmptySubsequences: true, whereSeparator: { $0.isWhitespace }).map(String.init)
        guard parts.count >= 4 else {
            return PortProcessInfo(command: "", cpuPercent: 0, memoryBytes: 0, runtime: "", runtimeSeconds: 0)
        }

        let cpu = Double(parts[0]) ?? 0
        let rssKilobytes = Int64(parts[1]) ?? 0
        let elapsedTime = parts[2]
        return PortProcessInfo(
            command: parts[3],
            cpuPercent: cpu,
            memoryBytes: rssKilobytes * 1024,
            runtime: normalizeElapsedTime(elapsedTime),
            runtimeSeconds: elapsedSeconds(elapsedTime)
        )
    }

    private static func normalizeElapsedTime(_ etime: String) -> String {
        if etime.contains("-") {
            let chunks = etime.split(separator: "-", maxSplits: 1).map(String.init)
            guard chunks.count == 2 else { return etime }
            let days = Int(chunks[0]) ?? 0
            let timeParts = chunks[1].split(separator: ":").map(String.init)
            if timeParts.count >= 2 {
                return AppCopy.text("\(days)天\(timeParts[0]):\(timeParts[1])", "\(days)d \(timeParts[0]):\(timeParts[1])")
            }
            return AppCopy.text("\(days)天", "\(days)d")
        }
        return etime
    }

    private static func elapsedSeconds(_ etime: String) -> Int {
        let daySplit = etime.split(separator: "-", maxSplits: 1).map(String.init)
        let days: Int
        let timeText: String

        if daySplit.count == 2 {
            days = Int(daySplit[0]) ?? 0
            timeText = daySplit[1]
        } else {
            days = 0
            timeText = etime
        }

        let timeParts = timeText.split(separator: ":").compactMap { Int($0) }
        let timeSeconds: Int
        switch timeParts.count {
        case 3:
            timeSeconds = (timeParts[0] * 3600) + (timeParts[1] * 60) + timeParts[2]
        case 2:
            timeSeconds = (timeParts[0] * 60) + timeParts[1]
        case 1:
            timeSeconds = timeParts[0]
        default:
            timeSeconds = 0
        }

        return (days * 86_400) + timeSeconds
    }

    private static func run(_ executable: String, arguments: [String]) throws -> (output: String, status: Int32) {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""

        guard process.terminationStatus == 0 || !output.isEmpty else {
            throw NSError(
                domain: "PortPilot.Command",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: error.isEmpty ? "Command failed: \(executable)" : error]
            )
        }

        return (output, process.terminationStatus)
    }
}

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

struct ContentView: View {
    @ObservedObject private var model: PortListModel
    @State private var showTerminateConfirmation = false
    @State private var didAppear = false

    init(model: PortListModel) {
        self.model = model
    }

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header
                HStack(spacing: 0) {
                    listPane
                        .frame(minWidth: 620)
                    Divider()
                        .opacity(0.55)
                    detailPane
                        .frame(width: 380)
                }
                footer
            }
        }
        .frame(minWidth: 1020, minHeight: 660)
        .onAppear {
            withAnimation(.easeOut(duration: 0.36)) {
                didAppear = true
            }
        }
        .alert(AppCopy.text("结束这个进程？", "Terminate this process?"), isPresented: $showTerminateConfirmation) {
            Button(AppCopy.text("取消", "Cancel"), role: .cancel) {}
            Button(AppCopy.text("结束进程", "Terminate"), role: .destructive) {
                model.terminateSelected()
            }
        } message: {
            if let entry = model.selectedEntry {
                Text(AppCopy.text(
                    "\(entry.processName) (\(entry.pid)) 正在监听端口 \(entry.port)。确认后会向该进程发送 TERM。",
                    "\(entry.processName) (\(entry.pid)) is listening on port \(entry.port). PortPilot will send TERM after confirmation."
                ))
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            AppIconTile(size: 44, cornerRadius: 8)
            .frame(width: 44, height: 44)
            .scaleEffect(didAppear ? 1 : 0.96)
            .opacity(didAppear ? 1 : 0)
            .animation(.easeOut(duration: 0.28), value: didAppear)

            VStack(alignment: .leading, spacing: 3) {
                Text("PortPilot")
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(AppCopy.text("看清端口占用，处理本地开发服务", "See and manage local development ports"))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .offset(y: didAppear ? 0 : 5)
            .opacity(didAppear ? 1 : 0)
            .animation(.easeOut(duration: 0.32).delay(0.04), value: didAppear)

            Spacer()

            SearchField(text: $model.query)
                .frame(width: 340)

            Button {
                model.refresh()
            } label: {
                HStack(spacing: 7) {
                    RefreshIcon(isScanning: model.isScanning)
                    Text(AppCopy.text("刷新", "Refresh"))
                }
            }
            .buttonStyle(AppButtonStyle(kind: .quiet))
            .keyboardShortcut("r", modifiers: .command)
            .disabled(model.isScanning)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .padding(.top, 36)
        .background(.bar)
    }

    private var listPane: some View {
        VStack(spacing: 0) {
            SummaryStrip(entries: model.entries)
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 12)

            columnHeader
                .padding(.horizontal, 18)
                .padding(.bottom, 7)

            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(Array(model.filteredEntries.enumerated()), id: \.element.id) { index, entry in
                        PortRow(
                            entry: entry,
                            isSelected: model.selectedID == entry.id,
                            onOpen: { open(entry.url) },
                            onCopy: { copy(entry.url) }
                        )
                        .id(entry.id)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.18)) {
                                model.selectedID = entry.id
                            }
                        }
                        .contextMenu {
                            Button(AppCopy.text("打开 \(entry.url)", "Open \(entry.url)")) { open(entry.url) }
                            Button(AppCopy.text("复制 URL", "Copy URL")) { copy(entry.url) }
                            Button(AppCopy.text("复制命令", "Copy command")) { copy(entry.command) }
                        }
                        .staggeredAppear(delay: min(Double(index) * 0.018, 0.18))
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                    }

                    if model.filteredEntries.isEmpty {
                        EmptyListState(
                            hasQuery: !model.query.isEmpty,
                            queryText: model.query,
                            onClear: {
                                withAnimation(Motion.smoothOut(Motion.quick)) {
                                    model.query = ""
                                }
                            }
                        )
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
    }

    private var columnHeader: some View {
        HStack(spacing: 10) {
            Text(AppCopy.text("端口", "Port"))
                .frame(width: 96, alignment: .leading)
            Text(AppCopy.text("进程", "Process"))
                .frame(width: 140, alignment: .leading)
            Text("PID")
                .frame(width: 72, alignment: .leading)
            Text(AppCopy.text("时长", "Runtime"))
                .frame(width: 96, alignment: .leading)
            Text("CPU")
                .frame(width: 62, alignment: .leading)
            Text(AppCopy.text("内存", "Memory"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .textCase(.uppercase)
        .tracking(0.4)
    }

    private var detailPane: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let entry = model.selectedEntry {
                DetailHero(entry: entry, isScanning: model.isScanning)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))

                HStack(spacing: 10) {
                    Button {
                        open(entry.url)
                    } label: {
                        Label(AppCopy.text("打开", "Open"), systemImage: "safari")
                    }
                    .buttonStyle(AppButtonStyle(kind: .primary))

                    Button {
                        copy(entry.url)
                    } label: {
                        Label(AppCopy.text("复制", "Copy"), systemImage: "doc.on.doc")
                    }
                    .buttonStyle(AppButtonStyle(kind: .quiet))
                }

                InfoGroup {
                    DetailLine(title: "PID", value: "\(entry.pid)", systemImage: "number")
                    DetailLine(title: AppCopy.text("进程", "Process"), value: entry.processName, systemImage: "app.dashed")
                    DetailLine(title: AppCopy.text("范围", "Scope"), value: entry.scopeLabel, systemImage: "scope")
                    DetailLine(title: AppCopy.text("地址", "Address"), value: entry.address, systemImage: "network")
                    DetailLine(title: AppCopy.text("时长", "Runtime"), value: entry.runtimeLabel, systemImage: "timer")
                    DetailLine(title: "CPU", value: entry.cpuLabel, systemImage: "speedometer")
                    DetailLine(title: AppCopy.text("内存", "Memory"), value: entry.memoryLabel, systemImage: "memorychip")
                }

                CommandBlock(command: entry.command)

                Spacer()

                Button(role: .destructive) {
                    showTerminateConfirmation = true
                } label: {
                    Label(AppCopy.text("结束进程", "Terminate"), systemImage: "xmark.octagon")
                }
                .buttonStyle(AppButtonStyle(kind: .danger))
            } else {
                Spacer()
                EmptyDetailState()
                Spacer()
            }
        }
        .padding(20)
        .animation(.easeOut(duration: 0.2), value: model.selectedEntry?.id)
        .background(.ultraThinMaterial)
    }

    private var footer: some View {
        HStack(spacing: 9) {
            PulseDot(isActive: model.isScanning, hasError: model.errorMessage != nil)
            Text(model.statusMessage)
                .foregroundStyle(model.errorMessage == nil ? Color.secondary : Color.red)
                .contentTransition(.opacity)
            if let error = model.errorMessage {
                Text(error)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(.red)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            Spacer()
            if let updated = model.lastUpdated {
                Text(AppCopy.text("更新于 \(timeFormatter.string(from: updated))", "Updated \(timeFormatter.string(from: updated))"))
                    .foregroundStyle(.secondary)
            }
        }
        .font(.caption)
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(.bar)
    }

    private func open(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    private func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

struct MenuBarPopoverView: View {
    @ObservedObject var model: PortListModel
    let quit: () -> Void

    @State private var pendingTerminateEntry: PortEntry?
    @State private var didAppear = false
    @State private var isSortPanelVisible = false

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(.thinMaterial)
                        .frame(height: 96)
                }

            VStack(spacing: 10) {
                menuHeader
                    .staggeredAppear(delay: 0)

                SearchField(text: $model.query)
                    .staggeredAppear(delay: 0.04)

                MenuBarStatsStrip(entries: model.entries)
                    .staggeredAppear(delay: 0.08)

                portList
                    .staggeredAppear(delay: 0.12)

                footer
            }
            .padding(14)
            .padding(.top, 8)
        }
        .frame(width: 440, height: 524)
        .onAppear {
            withAnimation(Motion.smoothOut(Motion.fast)) {
                didAppear = true
            }
        }
        .alert(AppCopy.text("结束这个进程？", "Terminate this process?"), isPresented: Binding(
            get: { pendingTerminateEntry != nil },
            set: { if !$0 { pendingTerminateEntry = nil } }
        )) {
            Button(AppCopy.text("取消", "Cancel"), role: .cancel) {}
            Button(AppCopy.text("结束进程", "Terminate"), role: .destructive) {
                if let entry = pendingTerminateEntry {
                    model.terminate(entry: entry)
                    pendingTerminateEntry = nil
                }
            }
        } message: {
            if let entry = pendingTerminateEntry {
                Text(AppCopy.text(
                    "\(entry.processName) (\(entry.pid)) 正在监听端口 \(entry.port)。确认后会向该进程发送 TERM。",
                    "\(entry.processName) (\(entry.pid)) is listening on port \(entry.port). PortPilot will send TERM after confirmation."
                ))
            }
        }
    }

    private var menuHeader: some View {
        HStack(spacing: 12) {
            AppIconTile(size: 42, cornerRadius: 9)
            .frame(width: 42, height: 42)
            .scaleEffect(didAppear ? 1 : 0.94)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Text("PortPilot")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    PulseDot(isActive: model.isScanning, hasError: model.errorMessage != nil)
                }
                Text(model.errorMessage == nil ? model.statusMessage : AppCopy.text("扫描失败", "Scan failed"))
                    .font(.caption)
                    .foregroundStyle(model.errorMessage == nil ? Color.secondary : Color.red)
                    .contentTransition(.opacity)
                    .animation(Motion.smoothOut(Motion.quick), value: model.statusMessage)
            }

            Spacer()

            Button {
                model.refresh()
            } label: {
                RefreshIcon(isScanning: model.isScanning)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(RowIconButtonStyle())
            .disabled(model.isScanning)
            .help(AppCopy.text("刷新", "Refresh"))
        }
    }

    private var portList: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(AppCopy.text("监听端口", "Listening ports"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.4)
                Spacer()
                HStack(spacing: 8) {
                    Text(AppCopy.text("打开时刷新", "Refresh on open"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    SortControl(
                        sortMode: model.sortMode,
                        sortDirection: model.sortDirection,
                        isExpanded: isSortPanelVisible,
                        onTap: {
                            withAnimation(Motion.smoothOut(Motion.fast)) {
                                isSortPanelVisible.toggle()
                            }
                        }
                    )
                }
            }
            .padding(.trailing, 2)

            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(Array(model.filteredEntries.enumerated()), id: \.element.id) { index, entry in
                        MenuBarPortRow(
                            entry: entry,
                            isSelected: model.selectedID == entry.id,
                            onOpen: { open(entry.url) },
                            onCopy: { copy(entry.url) },
                            onTerminate: {
                                model.selectedID = entry.id
                                pendingTerminateEntry = entry
                            }
                        )
                            .onTapGesture {
                                withAnimation(Motion.smoothOut(Motion.quick)) {
                                    model.selectedID = entry.id
                                }
                            }
                            .contextMenu {
                                Button(AppCopy.text("打开 \(entry.url)", "Open \(entry.url)")) { open(entry.url) }
                                Button(AppCopy.text("复制 URL", "Copy URL")) { copy(entry.url) }
                                Button(AppCopy.text("复制命令", "Copy command")) { copy(entry.command) }
                                Button(AppCopy.text("结束进程", "Terminate"), role: .destructive) {
                                    pendingTerminateEntry = entry
                                }
                            }
                            .staggeredAppear(delay: min(Double(index) * Motion.stagger * 0.35, Motion.stagger * 3))
                    }

                    if model.filteredEntries.isEmpty {
                        EmptyListState(
                            hasQuery: !model.query.isEmpty,
                            queryText: model.query,
                            compact: true,
                            onClear: {
                                withAnimation(Motion.smoothOut(Motion.quick)) {
                                    model.query = ""
                                }
                            }
                        )
                            .frame(maxWidth: .infinity)
                            .padding(.top, 28)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 18)
                    }
                }
                .padding(.top, 1)
                .padding(.bottom, 1)
                .padding(.trailing, 6)
            }
            .frame(height: 276)
            .padding(.trailing, -8)
        }
        .overlay(alignment: .topTrailing) {
            if isSortPanelVisible {
                ZStack(alignment: .topTrailing) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(Motion.smoothOut(Motion.quick)) {
                                isSortPanelVisible = false
                            }
                        }

                    SortOptionsPanel(
                        selectedMode: model.sortMode,
                        selectedDirection: model.sortDirection,
                        onSelectMode: { mode in
                            withAnimation(Motion.smoothOut(Motion.fast)) {
                                model.setSortMode(mode)
                            }
                        },
                        onSelectDirection: { direction in
                            withAnimation(Motion.smoothOut(Motion.fast)) {
                                model.sortDirection = direction
                            }
                        }
                    )
                    .padding(.top, 30)
                    .padding(.trailing, 0)
                    .transition(.opacity.combined(with: .scale(scale: Motion.dropdownPreScale, anchor: .topTrailing)))
                }
                .zIndex(20)
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Text(model.footerMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            Button {
                model.checkForUpdates()
            } label: {
                RefreshIcon(isScanning: model.isCheckingUpdates)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(RowIconButtonStyle())
            .disabled(model.isCheckingUpdates)
            .help(model.updateReleaseURL == nil ? AppCopy.text("检查更新", "Check for updates") : AppCopy.text("打开新版本", "Open new version"))

            Button {
                quit()
            } label: {
                HStack(spacing: 6) {
                    Text(AppCopy.text("退出", "Quit"))
                    Text("⌘Q")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(FooterQuitButtonStyle())
        }
        .frame(height: 28)
        .offset(y: -2)
        .staggeredAppear(delay: 0.2)
    }

    private func open(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    private func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

struct SortControl: View {
    let sortMode: SortMode
    let sortDirection: SortDirection
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: sortDirection.systemImage)
                    .font(.system(size: 9, weight: .bold))
                    .frame(width: 10)
                Text(sortMode.label)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Text(sortDirection.shortLabel)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.tertiary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .bold))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 8)
            .frame(height: 24)
        }
        .buttonStyle(SortControlButtonStyle(isExpanded: isExpanded))
        .help(AppCopy.text("排序", "Sort"))
    }
}

struct SortOptionsPanel: View {
    let selectedMode: SortMode
    let selectedDirection: SortDirection
    let onSelectMode: (SortMode) -> Void
    let onSelectDirection: (SortDirection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(spacing: 3) {
                ForEach(SortMode.allCases) { mode in
                    Button {
                        onSelectMode(mode)
                    } label: {
                        SortOptionRow(
                            mode: mode,
                            isSelected: selectedMode == mode
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()
                .opacity(0.45)

            HStack(spacing: 5) {
                ForEach(SortDirection.allCases) { direction in
                    Button {
                        onSelectDirection(direction)
                    } label: {
                        Label(direction.label, systemImage: direction.systemImage)
                            .font(.system(size: 11, weight: .semibold))
                            .labelStyle(.titleAndIcon)
                            .frame(maxWidth: .infinity)
                            .frame(height: 27)
                    }
                    .buttonStyle(SortDirectionButtonStyle(isSelected: selectedDirection == direction))
                }
            }
        }
        .padding(7)
        .frame(width: 170)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.14), radius: 18, x: 0, y: 10)
    }
}

struct SortOptionRow: View {
    let mode: SortMode
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.14) : Color.primary.opacity(0.045))
                Image(systemName: mode.systemImage)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }
            .frame(width: 24, height: 24)

            Text(mode.label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)

            Spacer(minLength: 6)

            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.accentColor)
                .opacity(isSelected ? 1 : 0)
                .scaleEffect(isSelected ? 1 : Motion.iconStartScale)
                .blur(radius: isSelected ? 0 : Motion.smallBlur)
                .animation(Motion.iconSwap(), value: isSelected)
        }
        .padding(.leading, 5)
        .padding(.trailing, 8)
        .frame(height: 32)
        .background(isSelected ? Color.accentColor.opacity(0.09) : Color.clear, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct MenuBarStatsStrip: View {
    let entries: [PortEntry]

    private var uniqueProcessEntries: [PortEntry] {
        var seen = Set<Int32>()
        return entries.filter { entry in
            guard !seen.contains(entry.pid) else { return false }
            seen.insert(entry.pid)
            return true
        }
    }

    private var totalCPU: Double {
        uniqueProcessEntries.reduce(0) { $0 + $1.cpuPercent }
    }

    private var totalMemory: Int64 {
        uniqueProcessEntries.reduce(0) { $0 + $1.memoryBytes }
    }

    var body: some View {
        HStack(spacing: 7) {
            CompactMetric(title: AppCopy.text("端口", "Ports"), value: "\(entries.count)", systemImage: "dot.radiowaves.left.and.right", tint: .blue)
            CompactMetric(title: "CPU", value: String(format: "%.1f%%", totalCPU), systemImage: "speedometer", tint: .orange)
            CompactMetric(title: AppCopy.text("内存", "Memory"), value: ByteCountFormatter.string(fromByteCount: totalMemory, countStyle: .memory), systemImage: "memorychip", tint: .purple)
        }
    }
}

struct CompactMetric: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 7, x: 0, y: 2)
    }
}

struct MenuBarPortRow: View {
    let entry: PortEntry
    let isSelected: Bool
    let onOpen: () -> Void
    let onCopy: () -> Void
    let onTerminate: () -> Void

    @State private var isHovering = false

    private var showsActions: Bool {
        isHovering || isSelected
    }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Image(systemName: iconName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(scopeColor)
                        .frame(width: 16)
                    Text(verbatim: "\(entry.port)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                }

                HStack(spacing: 5) {
                    Circle()
                        .fill(scopeColor)
                        .frame(width: 6, height: 6)
                    Text(entry.scopeLabel)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(scopeColor)
                }
                .padding(.leading, 23)
            }
            .frame(width: 82, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.processName)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                Text(entry.runtimeLabel)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            ZStack(alignment: .trailing) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(entry.cpuLabel)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(entry.cpuPercent >= 20 ? .orange : .secondary)
                    Text(entry.memoryLabel)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.purple)
                }
                .monospacedDigit()
                .opacity(showsActions ? 0 : 1)
                .blur(radius: showsActions ? Motion.smallBlur : 0)
                .scaleEffect(showsActions ? Motion.iconStartScale : 1, anchor: .trailing)

                MenuBarRowActions(
                    onOpen: onOpen,
                    onCopy: onCopy,
                    onTerminate: onTerminate
                )
                .opacity(showsActions ? 1 : 0)
                .blur(radius: showsActions ? 0 : Motion.smallBlur)
                .scaleEffect(showsActions ? 1 : Motion.iconStartScale, anchor: .trailing)
            }
            .frame(width: 92, alignment: .trailing)
            .animation(Motion.iconSwap(), value: showsActions)
        }
        .padding(.horizontal, 10)
        .frame(height: 50)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(scopeColor)
                .frame(width: 3, height: isSelected ? 26 : 0)
                .padding(.leading, 2)
        }
        .shadow(color: .black.opacity(isSelected ? 0.09 : 0.035), radius: isSelected ? 9 : 3, x: 0, y: isSelected ? 4 : 1)
        .contentShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .onHover { hovering in
            withAnimation(Motion.smoothOut(Motion.quick)) {
                isHovering = hovering
            }
        }
        .animation(Motion.smoothOut(Motion.quick), value: isSelected)
    }

    private var rowBackground: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(Color.accentColor.opacity(0.15))
        }
        if isHovering {
            return AnyShapeStyle(Color.primary.opacity(0.055))
        }
        return AnyShapeStyle(.thinMaterial)
    }

    private var scopeColor: Color {
        switch entry.scope {
        case .local:
            return .green
        case .all:
            return .orange
        case .host:
            return .blue
        }
    }

    private var iconName: String {
        switch entry.appHint {
        case "Vite", "Next.js", "Nuxt", "Webpack":
            return "bolt.fill"
        case "Expo":
            return "iphone"
        case "Python", "Django", "Flask", "Uvicorn":
            return "terminal"
        case "Rails", "Ruby":
            return "diamond"
        default:
            return "network"
        }
    }
}

struct MenuBarRowActions: View {
    let onOpen: () -> Void
    let onCopy: () -> Void
    let onTerminate: () -> Void

    @State private var didCopy = false
    @State private var copyFeedbackID = UUID()

    var body: some View {
        HStack(spacing: 3) {
            Button(action: onOpen) {
                Image(systemName: "safari")
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(RowIconButtonStyle())
            .help(AppCopy.text("打开 localhost", "Open localhost"))

            Button(action: copyWithFeedback) {
                ZStack {
                    Image(systemName: "doc.on.doc")
                        .opacity(didCopy ? 0 : 1)
                        .blur(radius: didCopy ? Motion.smallBlur : 0)
                        .scaleEffect(didCopy ? Motion.iconStartScale : 1)

                    Image(systemName: "checkmark.circle.fill")
                        .opacity(didCopy ? 1 : 0)
                        .blur(radius: didCopy ? 0 : Motion.smallBlur)
                        .scaleEffect(didCopy ? 1 : Motion.iconStartScale)
                }
                .frame(width: 26, height: 26)
                .animation(Motion.iconSwap(), value: didCopy)
            }
            .buttonStyle(CopyFeedbackButtonStyle(isCopied: didCopy))
            .help(didCopy ? AppCopy.text("已复制", "Copied") : AppCopy.text("复制 URL", "Copy URL"))

            Button(action: onTerminate) {
                Image(systemName: "xmark.octagon")
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(RowDangerIconButtonStyle())
            .help(AppCopy.text("结束进程（需确认）", "Terminate process (confirmation required)"))
        }
    }

    private func copyWithFeedback() {
        onCopy()
        let feedbackID = UUID()
        copyFeedbackID = feedbackID

        withAnimation(Motion.iconSwap()) {
            didCopy = true
        }

        Task {
            try? await Task.sleep(nanoseconds: 1_050_000_000)
            await MainActor.run {
                guard copyFeedbackID == feedbackID else { return }
                withAnimation(Motion.iconSwap()) {
                    didCopy = false
                }
            }
        }
    }
}

struct ResourceMini: View {
    let label: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.76)
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct AppBackground: View {
    var body: some View {
        Rectangle()
            .fill(Color(nsColor: .windowBackgroundColor))
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.thinMaterial)
                    .frame(height: 92)
            }
            .ignoresSafeArea()
    }
}

struct AppIconTile: View {
    let size: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        Image(nsImage: NSApp.applicationIconImage)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .blue.opacity(0.22), radius: 12, x: 0, y: 6)
    }
}

struct SearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18)

            TextField(AppCopy.text("搜索端口、PID、进程、命令", "Search port, PID, process, command"), text: $text)
                .textFieldStyle(.plain)

            if !text.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.16)) {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

struct SummaryStrip: View {
    let entries: [PortEntry]

    private var localCount: Int {
        entries.filter { $0.scope == .local }.count
    }

    private var uniqueProcessEntries: [PortEntry] {
        var seen = Set<Int32>()
        return entries.filter { entry in
            guard !seen.contains(entry.pid) else { return false }
            seen.insert(entry.pid)
            return true
        }
    }

    private var totalCPU: Double {
        uniqueProcessEntries.reduce(0) { $0 + $1.cpuPercent }
    }

    private var totalMemory: Int64 {
        uniqueProcessEntries.reduce(0) { $0 + $1.memoryBytes }
    }

    var body: some View {
        HStack(spacing: 8) {
            SummaryMetric(title: AppCopy.text("监听中", "Listening"), value: "\(entries.count)", systemImage: "dot.radiowaves.left.and.right", tint: .blue)
            SummaryMetric(title: AppCopy.text("仅本机", "Local only"), value: "\(localCount)", systemImage: "lock", tint: .green)
            SummaryMetric(title: "CPU", value: String(format: "%.1f%%", totalCPU), systemImage: "speedometer", tint: .orange)
            SummaryMetric(title: AppCopy.text("内存", "Memory"), value: ByteCountFormatter.string(fromByteCount: totalMemory, countStyle: .memory), systemImage: "memorychip", tint: .purple)
        }
    }
}

struct SummaryMetric: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 7, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .contentTransition(.numericText())
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 11)
        .frame(height: 54)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 7, x: 0, y: 2)
    }
}

struct PortRow: View {
    let entry: PortEntry
    let isSelected: Bool
    let onOpen: () -> Void
    let onCopy: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Image(systemName: iconName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(scopeColor)
                        .frame(width: 18)
                    Text(verbatim: "\(entry.port)")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .contentTransition(.numericText())
                }
                HStack(spacing: 5) {
                    Circle()
                        .fill(scopeColor)
                        .frame(width: 6, height: 6)
                    Text(entry.scopeLabel)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(scopeColor)
                }
                .padding(.leading, 25)
            }
            .frame(width: 96, alignment: .leading)

            Text(entry.processName)
                .lineLimit(1)
                .frame(width: 140, alignment: .leading)

            Text(verbatim: "\(entry.pid)")
                .font(.system(.body, design: .monospaced))
                .monospacedDigit()
                .lineLimit(1)
                .foregroundStyle(.secondary)
                .frame(width: 72, alignment: .leading)

            LabelValuePill(value: entry.runtimeLabel, tint: .blue)
                .frame(width: 96, alignment: .leading)

            LabelValuePill(value: entry.cpuLabel, tint: entry.cpuPercent >= 20 ? .orange : .secondary)
                .frame(width: 62, alignment: .leading)

            LabelValuePill(value: entry.memoryLabel, tint: .purple)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                Button(action: onOpen) {
                    Image(systemName: "safari")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(RowIconButtonStyle())
                .help(AppCopy.text("打开 localhost", "Open localhost"))

                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(RowIconButtonStyle())
                .help(AppCopy.text("复制 URL", "Copy URL"))
            }
            .opacity(isHovering || isSelected ? 1 : 0)
            .scaleEffect(isHovering || isSelected ? 1 : 0.96)
            .animation(.easeOut(duration: 0.16), value: isHovering)
            .animation(.easeOut(duration: 0.16), value: isSelected)
        }
        .padding(.horizontal, 10)
        .frame(height: 52)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(scopeColor)
                .frame(width: 3, height: isSelected ? 28 : 0)
                .padding(.leading, 2)
                .animation(.easeOut(duration: 0.18), value: isSelected)
        }
        .shadow(color: .black.opacity(isSelected ? 0.10 : 0.04), radius: isSelected ? 10 : 3, x: 0, y: isSelected ? 4 : 1)
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.16)) {
                isHovering = hovering
            }
        }
    }

    private var rowBackground: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(Color.accentColor.opacity(0.15))
        }
        if isHovering {
            return AnyShapeStyle(Color.primary.opacity(0.055))
        }
        return AnyShapeStyle(.thinMaterial)
    }

    private var scopeColor: Color {
        switch entry.scope {
        case .local:
            return .green
        case .all:
            return .orange
        case .host:
            return .blue
        }
    }

    private var iconName: String {
        switch entry.appHint {
        case "Vite", "Next.js", "Nuxt", "Webpack":
            return "bolt.fill"
        case "Expo":
            return "iphone"
        case "Python", "Django", "Flask", "Uvicorn":
            return "terminal"
        case "Rails", "Ruby":
            return "diamond"
        default:
            return "network"
        }
    }
}

struct LabelValuePill: View {
    let value: String
    let tint: Color

    var body: some View {
        Text(value)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .foregroundStyle(tint)
            .padding(.horizontal, 7)
            .frame(height: 26)
            .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

struct DetailLine: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 46, alignment: .leading)
            Text(value)
                .textSelection(.enabled)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 28)
    }
}

struct DetailHero: View {
    let entry: PortEntry
    let isScanning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: ":\(entry.port)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .contentTransition(.numericText())
                    Text(entry.appHint)
                        .font(.title3.weight(.semibold))
                }

                Spacer()

                ScopeBadge(scope: entry.scope)
            }

            HStack(spacing: 8) {
                PulseDot(isActive: isScanning, hasError: false)
                Text(entry.url)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
    }
}

struct ScopeBadge: View {
    let scope: PortScope

    private var tint: Color {
        switch scope {
        case .local:
            return .green
        case .all:
            return .orange
        case .host:
            return .blue
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(tint)
                .frame(width: 7, height: 7)
            Text(scope.label)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 9)
        .frame(height: 26)
        .background(tint.opacity(0.12), in: Capsule())
    }
}

struct InfoGroup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 7) {
            content
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 7, x: 0, y: 2)
    }
}

struct CommandBlock: View {
    let command: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                    Label(AppCopy.text("启动命令", "Launch command"), systemImage: "terminal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(command.isEmpty ? AppCopy.text("不可用", "Unavailable") : command)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .textSelection(.enabled)
                .lineLimit(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(11)
                .background(Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 7, x: 0, y: 2)
    }
}

struct EmptyListState: View {
    let hasQuery: Bool
    var queryText: String = ""
    var compact = false
    var onClear: (() -> Void)?

    @State private var didAppear = false

    var body: some View {
        VStack(spacing: compact ? 12 : 14) {
            emptyIcon
                .scaleEffect(didAppear ? 1 : 0.94)
                .opacity(didAppear ? 1 : 0)
                .animation(Motion.smoothOut(Motion.fast), value: didAppear)

            VStack(spacing: compact ? 4 : 5) {
                Text(hasQuery ? AppCopy.text("没有匹配结果", "No matches") : AppCopy.text("当前没有监听端口", "No listening ports"))
                    .font(.system(size: compact ? 13 : 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(message)
                    .font(.system(size: compact ? 11 : 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
            }
            .offset(y: didAppear ? 0 : 4)
            .opacity(didAppear ? 1 : 0)
            .animation(Motion.smoothOut(Motion.fast).delay(0.04), value: didAppear)

            if hasQuery, let onClear {
                Button(action: onClear) {
                    Label(AppCopy.text("清除搜索", "Clear search"), systemImage: "xmark.circle")
                        .font(.system(size: compact ? 11 : 12, weight: .semibold))
                        .frame(height: compact ? 28 : 32)
                        .padding(.horizontal, 10)
                }
                .buttonStyle(CompactClearButtonStyle())
                .transition(.opacity.combined(with: .scale(scale: 0.94)))
            }
        }
        .padding(.horizontal, compact ? 16 : 22)
        .padding(.vertical, compact ? 18 : 24)
        .frame(maxWidth: compact ? 260 : 320)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: compact ? 14 : 16, style: .continuous))
        .shadow(color: .black.opacity(0.055), radius: 12, x: 0, y: 5)
        .overlay {
            RoundedRectangle(cornerRadius: compact ? 14 : 16, style: .continuous)
                .stroke(Color.primary.opacity(0.035), lineWidth: 1)
        }
        .onAppear {
            withAnimation(Motion.smoothOut(Motion.fast)) {
                didAppear = true
            }
        }
    }

    private var emptyIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: compact ? 12 : 14, style: .continuous)
                .fill(Color.accentColor.opacity(0.10))
                .frame(width: compact ? 44 : 54, height: compact ? 44 : 54)

            RoundedRectangle(cornerRadius: compact ? 8 : 10, style: .continuous)
                .stroke(Color.accentColor.opacity(0.18), lineWidth: 1)
                .frame(width: compact ? 28 : 34, height: compact ? 28 : 34)

            Image(systemName: hasQuery ? "magnifyingglass" : "dot.radiowaves.left.and.right")
                .font(.system(size: compact ? 18 : 22, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .symbolEffect(.pulse, value: didAppear)
        }
    }

    private var message: String {
        if hasQuery {
            let trimmed = queryText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return AppCopy.text("没有端口匹配当前搜索", "No ports match the current search") }
            return AppCopy.text("“\(trimmed)” 未匹配任何监听端口", "\"\(trimmed)\" did not match any listening port")
        }
        return AppCopy.text("本机没有可显示的 LISTEN 端口", "No visible LISTEN ports on this Mac")
    }
}

struct CompactClearButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.accentColor)
            .background(Color.accentColor.opacity(configuration.isPressed ? 0.16 : 0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
    }
}

struct SortControlButtonStyle: ButtonStyle {
    let isExpanded: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isExpanded ? Color.accentColor : Color.secondary)
            .background(background(configuration: configuration), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
            .animation(Motion.smoothOut(Motion.fast), value: isExpanded)
    }

    private func background(configuration: Configuration) -> Color {
        if isExpanded {
            return Color.accentColor.opacity(configuration.isPressed ? 0.16 : 0.10)
        }
        return Color.primary.opacity(configuration.isPressed ? 0.09 : 0.045)
    }
}

struct SortDirectionButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            .background(background(configuration: configuration), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
            .animation(Motion.smoothOut(Motion.quick), value: isSelected)
    }

    private func background(configuration: Configuration) -> Color {
        if isSelected {
            return Color.accentColor.opacity(configuration.isPressed ? 0.17 : 0.11)
        }
        return Color.primary.opacity(configuration.isPressed ? 0.08 : 0.035)
    }
}

struct EmptyDetailState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sidebar.right")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(AppCopy.text("选择一个端口", "Select a port"))
                .font(.headline)
            Text(AppCopy.text("这里会显示 PID、命令和快捷操作。", "PID, command, and quick actions appear here."))
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PulseDot: View {
    let isActive: Bool
    let hasError: Bool

    private var tint: Color {
        if hasError { return .red }
        return isActive ? .blue : .green
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(isActive ? 0.20 : 0))
                .frame(width: 18, height: 18)
                .scaleEffect(isActive ? 1.18 : 0.8)
                .opacity(isActive ? 1 : 0)
                .animation(isActive ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true) : .easeOut(duration: 0.16), value: isActive)
            Circle()
                .fill(tint)
                .frame(width: 7, height: 7)
        }
        .frame(width: 18, height: 18)
    }
}

struct RefreshIcon: View {
    let isScanning: Bool

    var body: some View {
        Image(systemName: "arrow.clockwise")
            .font(.system(size: 14, weight: .semibold))
            .rotationEffect(.degrees(isScanning ? 360 : 0))
            .animation(isScanning ? Motion.linear(0.8).repeatForever(autoreverses: false) : Motion.smoothOut(Motion.quick), value: isScanning)
    }
}

enum AppButtonKind {
    case primary
    case quiet
    case danger
}

struct AppButtonStyle: ButtonStyle {
    let kind: AppButtonKind
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 14)
            .frame(minHeight: 38)
            .foregroundStyle(foreground)
            .background(background(isPressed: configuration.isPressed), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: shadowColor, radius: configuration.isPressed ? 2 : 7, x: 0, y: configuration.isPressed ? 1 : 3)
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .opacity(isEnabled ? 1 : 0.55)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch kind {
        case .primary:
            return .white
        case .quiet:
            return .primary
        case .danger:
            return .red
        }
    }

    private var shadowColor: Color {
        switch kind {
        case .primary:
            return .accentColor.opacity(0.22)
        case .danger:
            return .red.opacity(0.10)
        case .quiet:
            return .black.opacity(0.07)
        }
    }

    private func background(isPressed: Bool) -> some ShapeStyle {
        switch kind {
        case .primary:
            return AnyShapeStyle(Color.accentColor.opacity(isPressed ? 0.82 : 1))
        case .quiet:
            return AnyShapeStyle(Color.primary.opacity(isPressed ? 0.10 : 0.065))
        case .danger:
            return AnyShapeStyle(Color.red.opacity(isPressed ? 0.16 : 0.10))
        }
    }
}

struct RowIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .background(Color.primary.opacity(configuration.isPressed ? 0.10 : 0.045), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
    }
}

struct CopyFeedbackButtonStyle: ButtonStyle {
    let isCopied: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isCopied ? Color.green : Color.secondary)
            .background(background(configuration: configuration), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
            .animation(Motion.iconSwap(), value: isCopied)
    }

    private func background(configuration: Configuration) -> Color {
        if isCopied {
            return Color.green.opacity(configuration.isPressed ? 0.20 : 0.12)
        }
        return Color.primary.opacity(configuration.isPressed ? 0.10 : 0.045)
    }
}

struct RowDangerIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.red)
            .background(Color.red.opacity(configuration.isPressed ? 0.16 : 0.085), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
    }
}

struct FooterQuitButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 9)
            .frame(height: 26)
            .background(Color.primary.opacity(configuration.isPressed ? 0.10 : 0.045), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
    }
}

struct StaggeredAppear: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (isVisible ? 0 : 12))
            .blur(radius: reduceMotion ? 0 : (isVisible ? 0 : Motion.mediumBlur))
            .onAppear {
                guard !isVisible else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(reduceMotion ? .linear(duration: 0.01) : Motion.smoothOut(Motion.verySlow)) {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {
    func staggeredAppear(delay: Double) -> some View {
        modifier(StaggeredAppear(delay: delay))
    }
}

@main
struct PortPilotApp: App {
    @NSApplicationDelegateAdaptor(PortPilotAppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appTermination) {
                Button(AppCopy.text("退出 PortPilot", "Quit PortPilot")) {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}

@MainActor
final class PortPilotAppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private let model = PortListModel()
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var cancellables = Set<AnyCancellable>()
    private var keyDownMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()
        configurePopover()
        configureKeyboardShortcuts()
        bindModel()
        updateStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
        }
        cancellables.removeAll()
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem?.button, let popover else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            model.refresh()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: 28)
        statusItem = item

        guard let button = item.button else { return }
        button.image = NSImage(systemSymbolName: "dot.radiowaves.left.and.right", accessibilityDescription: "PortPilot") ?? NSImage.portPilotMenuBarIcon()
        button.image?.isTemplate = true
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyDown
        button.title = ""
        button.action = #selector(togglePopover(_:))
        button.target = self
        button.toolTip = "PortPilot"
    }

    private func configurePopover() {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 440, height: 524)
        popover.delegate = self
        popover.contentViewController = NSHostingController(
            rootView: MenuBarPopoverView(
                model: model,
                quit: {
                    NSApp.terminate(nil)
                }
            )
        )
        self.popover = popover
    }

    private func configureKeyboardShortcuts() {
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command),
                  event.charactersIgnoringModifiers?.lowercased() == "q"
            else {
                return event
            }
            NSApp.terminate(nil)
            return nil
        }
    }

    private func bindModel() {
        model.$entries
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)

        model.$isScanning
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)

        model.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)
    }

    private func updateStatusItem() {
        guard let button = statusItem?.button else { return }
        button.title = ""
        button.contentTintColor = nil
        button.toolTip = model.entries.isEmpty ? "PortPilot" : AppCopy.text("PortPilot · \(model.entries.count) 个监听端口", "PortPilot · \(model.entries.count) listening ports")
    }

}

extension NSImage {
    static func portPilotMenuBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setStroke()
            NSColor.black.setFill()

            let path = NSBezierPath()
            path.lineWidth = 1.9
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            path.move(to: NSPoint(x: 5.2, y: 12.6))
            path.line(to: NSPoint(x: 8.7, y: 9.0))
            path.line(to: NSPoint(x: 12.8, y: 9.0))
            path.move(to: NSPoint(x: 5.2, y: 5.4))
            path.line(to: NSPoint(x: 8.7, y: 9.0))
            path.stroke()

            let nodeRadius: CGFloat = 1.9
            for point in [NSPoint(x: 5.2, y: 12.6), NSPoint(x: 5.2, y: 5.4), NSPoint(x: 12.8, y: 9.0)] {
                let nodeRect = NSRect(
                    x: point.x - nodeRadius,
                    y: point.y - nodeRadius,
                    width: nodeRadius * 2,
                    height: nodeRadius * 2
                )
                NSBezierPath(ovalIn: nodeRect).fill()
            }

            let pilotRect = NSRect(x: 10.8, y: 7.0, width: 4.0, height: 4.0)
            NSBezierPath(ovalIn: pilotRect).stroke()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "PortPilot"
        return image
    }
}

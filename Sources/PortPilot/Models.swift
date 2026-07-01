import Foundation

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
            return AppCopy.text("进程名", "Process")
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

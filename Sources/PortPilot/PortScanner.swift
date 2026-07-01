import Foundation

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

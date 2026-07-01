import AppKit
import SwiftUI

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

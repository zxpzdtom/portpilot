import AppKit
import Foundation
import SwiftUI

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
        HStack(spacing: 7) {
            HStack(spacing: 7) {
                Text(model.footerMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                if !model.isCheckingUpdates && (model.updateMessage == nil || model.updateReleaseURL != nil) {
                    UpdateStatusInlineButton(
                        hasRelease: model.updateReleaseURL != nil,
                        action: { model.checkForUpdates() }
                    )
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .animation(Motion.smoothOut(Motion.quick), value: model.isCheckingUpdates)
            .animation(Motion.smoothOut(Motion.quick), value: model.updateMessage)

            Spacer(minLength: 8)

            HStack(spacing: 5) {
                Button {
                    open(AppLinks.repository)
                } label: {
                    Text(AppCopy.text("关于", "About"))
                }
                .buttonStyle(FooterQuitButtonStyle())
                .help(AppCopy.text("打开 GitHub 仓库", "Open GitHub repository"))

                Button {
                    quit()
                } label: {
                    HStack(spacing: 5) {
                        Text(AppCopy.text("退出", "Quit"))
                        Text("⌘Q")
                            .font(.system(size: 8, weight: .semibold, design: .rounded))
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(FooterQuitButtonStyle())
            }
        }
        .frame(height: 26)
        .offset(y: -4)
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

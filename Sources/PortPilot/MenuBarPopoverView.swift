import AppKit
import Foundation
import SwiftUI

struct MenuBarPopoverView: View {
    @ObservedObject var model: PortListModel
    let checkForUpdates: () -> Void
    let quit: () -> Void

    @State private var pendingTerminateEntry: PortEntry?
    @State private var didAppear = false
    @State private var isSortPanelVisible = false
    private let popoverCornerRadius: CGFloat = 18
    private let shadowInset: CGFloat = 8

    var body: some View {
        ZStack {
            ZStack {
                MenuBarPopoverBackground()

                VStack(spacing: 8) {
                    menuHeader
                        .padding(.horizontal, 12)
                        .staggeredAppear(delay: 0)

                    SearchField(text: $model.query)
                        .padding(.horizontal, 12)
                        .staggeredAppear(delay: 0.04)

                    MenuBarStatsStrip(entries: model.entries)
                        .padding(.horizontal, 12)
                        .staggeredAppear(delay: 0.08)

                    portList
                        .staggeredAppear(delay: 0.12)

                    footer
                        .padding(.horizontal, 12)
                }
                .padding(.vertical, 14)
                .padding(.top, 8)
            }
            .frame(width: 408, height: 524)
            .clipShape(RoundedRectangle(cornerRadius: popoverCornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: popoverCornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.13), lineWidth: 0.8)
            }
        }
        .padding(shadowInset)
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
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(AppCopy.text("监听端口", "Listening ports"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.4)
                Spacer()
                HStack(spacing: 6) {
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
            .padding(.horizontal, 12)
            .padding(.trailing, 8)

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
                            },
                            tooltipPlacement: .above
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
                .padding(.top, 4)
                .padding(.bottom, 1)
                .padding(.horizontal, 12)
            }
            .frame(height: 276)
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
                    .padding(.trailing, 12)
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

                UpdateStatusInlineButton(
                    action: checkForUpdates
                )
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }

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
        .frame(height: 24)
        .padding(.top, -2)
        .offset(y: 1)
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

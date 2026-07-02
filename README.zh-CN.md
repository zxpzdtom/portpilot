# PortPilot

<p align="center">
  <img src="Assets/PortPilotIcon.png" alt="PortPilot app icon" width="96" height="96">
</p>

原生 macOS 菜单栏端口监控工具，面向本地开发和 Vibe Coding 场景。

[官网](https://portpilot.anyask.dev) · [English README](README.md) · [更新日志](CHANGELOG.md)

PortPilot 可以帮你快速看清本机有哪些 TCP 端口正在监听、每个端口属于哪个进程、进程运行了多久，以及当前 CPU / 内存占用。它适合处理本地开发时经常出现的 dev server、代理、辅助进程和临时服务。

## 功能亮点

- 原生 macOS 菜单栏 app，小巧 popover 入口。
- 使用系统 `lsof` 列出 TCP `LISTEN` 端口。
- 显示端口、监听范围、进程、运行时长、CPU、内存。
- 支持按端口、PID、进程名、命令、URL、资源标签搜索。
- 支持按端口、运行时长、CPU、内存、进程排序，并可切换升序 / 降序。
- 打开时刷新，也支持手动刷新；不会后台自动轮询。
- 一键打开 `http://localhost:<port>`。
- 复制 URL 后有勾选反馈。
- 结束进程前会二次确认。
- 使用 Sparkle 检查、下载并安装更新。
- 中英文 UI，根据 macOS 系统语言自动选择。

## 界面入口

PortPilot 作为 accessory app 运行：

- 菜单栏图标：打开端口 popover。
- 刷新按钮：重新扫描监听端口。
- 排序控件：选择字段和升序 / 降序。
- 行内操作：打开 URL、复制 URL、确认后结束进程。
- 底部更新按钮：打开 Sparkle 原生更新流程。

## 系统要求

- macOS 14.0 或更新版本。
- 默认构建 Apple Silicon 版本：`arm64-apple-macosx14.0`。
- 安装 Xcode Command Line Tools，并可使用 `swiftc`。

## 下载

可以从 [GitHub Releases](https://github.com/zxpzdtom/portpilot/releases) 下载开发签名构建，也可以按下面步骤本地构建。

## 构建

```bash
./build.sh
```

应用会生成到：

```text
dist/PortPilot.app
```

也可以指定输出路径：

```bash
APP_DIR="$PWD/PortPilot.app" ./build.sh
```

## 更新

PortPilot 使用 [Sparkle](https://sparkle-project.org/) 处理更新。后台自动检查已关闭，只有点击底部更新按钮时才会检查。Sparkle 会负责原生更新窗口、下载进度、取消、安装和重新打开 app。

Appcast 地址配置在 `Info.plist`：

```text
https://raw.githubusercontent.com/zxpzdtom/portpilot/refs/heads/main/appcast.xml
```

`SUPublicEDKey` 用于验证签名更新包。对应的 Sparkle 私钥保存在你的 macOS Keychain 里，不要提交到仓库。

构建 release zip 并上传到 GitHub Releases 后，重新生成 appcast：

```bash
RELEASE_TAG=v0.1.2 Scripts/generate_appcast.sh dist/releases
```

`dist/releases` 里应放置对应更新包，例如 `PortPilot-0.1.2.zip`。

## 项目结构

```text
Sources/PortPilot/AppSupport.swift          通用文案、链接、动效、图片辅助
Sources/PortPilot/Models.swift              端口、范围、排序模型
Sources/PortPilot/PortScanner.swift         lsof / ps 扫描逻辑
Sources/PortPilot/PortListModel.swift       App 状态、排序、检查更新
Sources/PortPilot/MenuBarPopoverView.swift  菜单栏 popover UI
Sources/PortPilot/MenuBarPortRow.swift      菜单栏列表行和行内操作
Sources/PortPilot/MenuBarMetrics.swift      菜单栏统计卡片
Sources/PortPilot/SortControls.swift        排序按钮和排序选项面板
Sources/PortPilot/Components.swift          可复用 SwiftUI 组件
Sources/PortPilot/EmptyStates.swift         空态组件
Sources/PortPilot/FullWindowComponents.swift 旧版完整窗口组件
Sources/PortPilot/Styles.swift              按钮样式和 ViewModifier
Sources/PortPilot/PortPilotApp.swift        App 入口和 AppKit delegate
Assets/PortPilot.icns                       应用图标
Icon.iconset/                               图标源文件
Info.plist                                  app bundle 元数据
appcast.xml                                 Sparkle 更新 feed
build.sh                                    本地构建脚本
Scripts/generate_appcast.sh                 Sparkle appcast 生成脚本
```

## 说明

- 正常列出端口不需要管理员权限。
- 结束进程会在确认后发送 `TERM`。
- CPU 和内存来自 `ps`；端口归属来自 `lsof`。
- App 不会在后台自动刷新。
- 更新检查也是手动触发；Sparkle 只会在点击更新按钮时运行。

## License

MIT

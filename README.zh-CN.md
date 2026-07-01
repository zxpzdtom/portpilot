# PortPilot

原生 macOS 菜单栏端口监控工具，面向本地开发和 Vibe Coding 场景。

[English README](README.md) · [更新日志](CHANGELOG.md)

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
- 支持通过 GitHub Releases 检查更新。
- 中英文 UI，根据 macOS 系统语言自动选择。

## 界面入口

PortPilot 作为 accessory app 运行：

- 菜单栏图标：打开端口 popover。
- 刷新按钮：重新扫描监听端口。
- 排序控件：选择字段和升序 / 降序。
- 行内操作：打开 URL、复制 URL、确认后结束进程。
- 底部更新按钮：检查 GitHub Releases 是否有新版本。

## 系统要求

- macOS 14.0 或更新版本。
- 默认构建 Apple Silicon 版本：`arm64-apple-macosx14.0`。
- 安装 Xcode Command Line Tools，并可使用 `swiftc`。

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

## 检查更新

PortPilot 会请求：

```text
https://api.github.com/repos/zxpzdtom/portpilot/releases/latest
```

如果发现比当前 `CFBundleShortVersionString` 更新的版本，底部状态会提示，更新按钮会打开对应 release 页面。如果仓库还没有发布 release，也会正常提示。

## 项目结构

```text
Sources/PortPilot/main.swift   SwiftUI / AppKit 原生 app
Assets/PortPilot.icns         应用图标
Icon.iconset/                 图标源文件
Info.plist                    app bundle 元数据
build.sh                      本地构建脚本
```

## 说明

- 正常列出端口不需要管理员权限。
- 结束进程会在确认后发送 `TERM`。
- CPU 和内存来自 `ps`；端口归属来自 `lsof`。
- App 不会在后台自动刷新。

## License

MIT

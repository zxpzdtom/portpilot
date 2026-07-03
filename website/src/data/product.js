import {
  Activity,
  BellDot,
  CircleStop,
  Code2,
  Globe2,
  MemoryStick,
  RefreshCcw,
  ShieldCheck,
  TerminalSquare,
  Timer,
} from 'lucide-react'

export const navItems = [
  { label: '能力', href: '#surface' },
  { label: '功能', href: '#features' },
  { label: '更新', href: '#updates' },
]

export const metrics = [
  { label: '端口', value: '24', icon: Activity, tone: 'blue' },
  { label: 'CPU', value: '13.3%', icon: Timer, tone: 'orange' },
  { label: '内存', value: '1.59 GB', icon: MemoryStick, tone: 'violet' },
]

export const ports = [
  { port: 9527, app: 'bun', pid: '37375', scope: '仅本机', runtime: '12:20:30', cpu: '0.1%', memory: '34 MB', tone: 'green', icon: 'bun' },
  { port: 54615, app: 'claude', pid: '85650', scope: '仅本机', runtime: '13:06:28', cpu: '0.0%', memory: '158.7 MB', tone: 'green', icon: 'claude' },
  { port: 54618, app: 'claude', pid: '85650', scope: '仅本机', runtime: '13:06:28', cpu: '0.0%', memory: '158.7 MB', tone: 'green', icon: 'claude' },
  { port: 44438, app: 'zed', pid: '54675', scope: '仅本机', runtime: '22:06', cpu: '0.0%', memory: '153.6 MB', tone: 'green', icon: 'zed' },
  { port: 40678, app: 'mgmcp', pid: '40421', scope: '全网卡', runtime: '6天01:07', cpu: '0.0%', memory: '9.2 MB', tone: 'orange', icon: 'exec' },
  { port: 26062, app: 'master-local-fonts-macos', pid: '40423', scope: '仅本机', runtime: '6天01:04', cpu: '0.0%', memory: '10 MB', tone: 'green', icon: 'exec' },
]

export const features = [
  { title: '菜单栏优先', body: '不用打开完整面板。点一下菜单栏，当前监听端口和进程立刻出现。', icon: Globe2 },
  { title: '真实进程图标', body: '按需读取并缓存 macOS 应用图标；CLI 进程会回退到一致的命令图标。', icon: TerminalSquare },
  { title: '资源感知', body: 'PID、运行时长、CPU、内存放在同一行里，找异常进程不再靠猜。', icon: MemoryStick },
  { title: '手动刷新', body: '打开时刷新，或者点击刷新。没有后台轮询，也不会悄悄打扰系统。', icon: RefreshCcw },
  { title: '确认后终止', body: '结束进程会弹出确认，适合处理 Vibe Coding 时遗留的本地服务。', icon: CircleStop },
  { title: '签名更新', body: 'Sparkle appcast 使用 EdDSA 签名，下载与安装走成熟更新链路。', icon: ShieldCheck },
  { title: '开源可审计', body: 'SwiftUI + AppKit 原生实现，扫描依赖系统 lsof 和 ps，逻辑透明。', icon: Code2 },
]

export const releaseFacts = [
  { label: 'Latest', value: 'v0.1.5' },
  { label: 'Platform', value: 'macOS 14+' },
  { label: 'Arch', value: 'Apple Silicon' },
]

export const updateEvents = [
  { label: 'Check appcast', value: 'signed' },
  { label: 'Download update', value: '3.2 MB' },
  { label: 'Install + relaunch', value: 'Sparkle' },
]

export const trustNotes = [
  { icon: TerminalSquare, text: 'Real process icons' },
  { icon: BellDot, text: 'No background polling' },
  { icon: ShieldCheck, text: 'Signed app updates' },
]

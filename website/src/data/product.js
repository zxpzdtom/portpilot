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
  { label: '端口', value: '25', icon: Activity, tone: 'blue' },
  { label: 'CPU', value: '15.4%', icon: Timer, tone: 'orange' },
  { label: '内存', value: '1.93 GB', icon: MemoryStick, tone: 'violet' },
]

export const ports = [
  { port: 9222, app: 'Google Chrome', pid: '55136', scope: '仅本机', runtime: '8天12:32', cpu: '0.7%', memory: '377.8 MB', tone: 'green', icon: 'chrome' },
  { port: 14013, app: 'Figma', pid: '42706', scope: '仅本机', runtime: '14天18:44', cpu: '1.0%', memory: '345.6 MB', tone: 'green', icon: 'figma' },
  { port: 26162, app: 'MasterGo Helper', pid: '40412', scope: '全网卡', runtime: '6天01:04', cpu: '0.0%', memory: '24.8 MB', tone: 'orange', icon: 'mastergo' },
  { port: 7777, app: 'ClashX Pro', pid: '3078', scope: '指定IP', runtime: '15天11:56', cpu: '2.3%', memory: '126.6 MB', tone: 'blue', icon: 'clash' },
  { port: 5173, app: 'node', pid: '56941', scope: '仅本机', runtime: '01:56', cpu: '0.0%', memory: '111.4 MB', tone: 'green', icon: 'node' },
  { port: 9527, app: 'bun', pid: '37375', scope: '仅本机', runtime: '13:29:57', cpu: '0.1%', memory: '35.1 MB', tone: 'green', icon: 'bun' },
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

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
  { port: 5000, app: 'ControlCenter', scope: '全部', time: '14天14:56', cpu: '0.0%', memory: '', tone: 'orange' },
  { port: 5173, app: 'node', scope: '本机', time: '21:08:57', cpu: '0.0%', memory: '38.2 MB', tone: 'green', hint: 'dev' },
  { port: 5174, app: 'node', scope: '本机', time: '02:16', cpu: '0.0%', memory: '146.2 MB', tone: 'green', hint: 'dev' },
  { port: 7000, app: 'ControlCenter', scope: '全部', time: '14天14:56', cpu: '9.6%', memory: '92.2 MB', tone: 'orange' },
  { port: 7265, app: 'Raycast', scope: '本机', time: '8天16:51', cpu: '0.0%', memory: '135.2 MB', tone: 'green' },
]

export const features = [
  { title: '菜单栏优先', body: '不用打开完整面板。点一下菜单栏，当前监听端口和进程立刻出现。', icon: Globe2 },
  { title: '资源感知', body: '运行时长、CPU、内存放在同一行里，找异常进程不再靠猜。', icon: MemoryStick },
  { title: '手动刷新', body: '打开时刷新，或者点击刷新。没有后台轮询，也不会悄悄打扰系统。', icon: RefreshCcw },
  { title: '确认后终止', body: '结束进程会弹出确认，适合处理 Vibe Coding 时遗留的本地服务。', icon: CircleStop },
  { title: '开源可审计', body: 'SwiftUI + AppKit 原生实现，扫描依赖系统 lsof 和 ps，逻辑透明。', icon: Code2 },
  { title: '签名更新', body: 'Sparkle appcast 使用 EdDSA 签名，下载与安装走成熟更新链路。', icon: ShieldCheck },
]

export const releaseFacts = [
  { label: 'Latest', value: 'v0.1.3' },
  { label: 'Platform', value: 'macOS 14+' },
  { label: 'Arch', value: 'Apple Silicon' },
]

export const updateEvents = [
  { label: 'Check appcast', value: 'signed' },
  { label: 'Download update', value: '3.2 MB' },
  { label: 'Install + relaunch', value: 'Sparkle' },
]

export const trustNotes = [
  { icon: TerminalSquare, text: 'Uses lsof / ps' },
  { icon: BellDot, text: 'No background polling' },
  { icon: ShieldCheck, text: 'Signed app updates' },
]

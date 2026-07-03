import { ArrowUp, Check, Copy, ExternalLink, RefreshCcw, Search, XCircle } from 'lucide-react'
import { metrics, ports } from '../data/product'

const toneMap = {
  blue: 'text-blue-500 bg-blue-500/10',
  orange: 'text-orange-500 bg-orange-500/10',
  violet: 'text-fuchsia-500 bg-fuchsia-500/10',
}

const scopeColor = {
  green: 'text-emerald-500',
  orange: 'text-orange-500',
  blue: 'text-blue-500',
}

export function PortPilotPopover({ activeStep = 'scan', className = '' }) {
  const sortedPorts =
    activeStep === 'sort'
      ? [...ports].sort((a, b) => runtimeToSeconds(a.runtime) - runtimeToSeconds(b.runtime) || a.port - b.port)
      : ports

  return (
    <div
      className={`w-full max-w-[392px] overflow-hidden rounded-[18px] border border-black/12 bg-[linear-gradient(135deg,rgba(247,251,255,0.96),rgba(237,243,247,0.94)_46%,rgba(250,252,253,0.97))] p-3 shadow-[0_18px_44px_rgba(15,23,42,0.16),0_1px_2px_rgba(15,23,42,0.14)] backdrop-blur-2xl ${className}`}
    >
      <div className="flex items-center gap-3 px-1 pb-3 pt-0.5">
        <img src="/assets/portpilot-icon.png" alt="" className="h-[40px] w-[40px] rounded-[9px] shadow-[0_8px_18px_rgba(37,99,235,0.22)] ring-1 ring-black/10" />
        <div>
          <div className="flex items-center gap-2">
            <div className="text-[20px] font-semibold tracking-[-0.03em] text-zinc-800">PortPilot</div>
            <span className="h-2 w-2 rounded-full bg-emerald-500 shadow-[0_0_0_4px_rgba(16,185,129,0.12)]" />
          </div>
          <div className="mt-0.5 text-[12px] font-medium text-zinc-500">24 个监听端口</div>
        </div>
        <button className="ml-auto grid h-[30px] w-[30px] place-items-center rounded-lg bg-zinc-900/[0.045] text-zinc-500 transition duration-200 hover:bg-zinc-900/[0.07] active:scale-[0.96]">
          <RefreshCcw className="h-[15px] w-[15px]" />
        </button>
      </div>

      <div className="flex h-[38px] items-center gap-2 rounded-lg bg-white/82 px-3 text-[14px] text-zinc-500 shadow-[0_6px_16px_rgba(15,23,42,0.04)] ring-1 ring-white/80">
        <Search className="h-4 w-4" />
        <span className={activeStep === 'scan' ? 'text-zinc-900' : ''}>搜索端口、PID、进程、命令</span>
      </div>

      <div className="mt-3 grid grid-cols-3 gap-1.5">
        {metrics.map((metric) => {
          const Icon = metric.icon
          return (
            <div key={metric.label} className="min-h-[58px] rounded-[9px] bg-white/68 px-2.5 py-2.5 shadow-[inset_0_0_0_0.5px_rgba(255,255,255,0.9),0_7px_18px_rgba(15,23,42,0.045)]">
              <div className="flex items-center gap-1.5 text-[11px] font-semibold text-zinc-500">
                <Icon className={`h-3.5 w-3.5 ${toneMap[metric.tone]?.split(' ')[0]}`} />
                {metric.label}
              </div>
              <div className="mt-2 whitespace-nowrap text-[17px] font-semibold tracking-[-0.03em] text-zinc-800">{metric.value}</div>
            </div>
          )
        })}
      </div>

      <div className="mt-2.5 flex items-center justify-between px-1 text-[11px] font-medium text-zinc-500">
        <span>监听端口</span>
        <button className="flex h-[24px] items-center gap-1 rounded-lg bg-zinc-900/[0.04] px-2 text-zinc-600 shadow-[inset_0_1px_0_rgba(255,255,255,0.52)]">
          <ArrowUp className="h-3 w-3" />
          <span>运行时长</span>
        </button>
      </div>

      <div className="mt-1 max-h-[282px] overflow-hidden">
        <div className="space-y-1.5">
          {sortedPorts.map((port, index) => (
            <PortRow key={`${port.port}-${port.app}`} port={port} selected={index === 0 || (activeStep === 'act' && index === 1)} activeStep={activeStep} />
          ))}
        </div>
      </div>

      <div className="mt-1.5 flex h-[22px] items-center justify-between px-1 text-[11px] text-zinc-500">
        <div className="flex items-center gap-2">
          <span>上次刷新 10:54</span>
          <button className="inline-flex h-[18px] items-center gap-1 rounded-md bg-zinc-900/[0.04] px-1.5 font-medium text-zinc-500">
            <Check className="h-3 w-3" />
            检查更新
          </button>
        </div>
        <div className="flex items-center gap-1.5">
          <button className="h-[22px] rounded-lg bg-zinc-900/[0.035] px-2 font-medium">关于</button>
          <button className="h-[22px] rounded-lg bg-zinc-900/[0.035] px-2 font-medium">退出 ⌘Q</button>
        </div>
      </div>
    </div>
  )
}

function PortRow({ port, selected, activeStep }) {
  const currentScopeColor = scopeColor[port.tone] ?? scopeColor.orange
  const showActions = activeStep === 'act' && selected

  return (
    <div
      className={`group/port-row relative z-0 flex h-[50px] items-center gap-2 rounded-[9px] px-2.5 shadow-[inset_0_0_0_0.5px_rgba(255,255,255,0.58),0_2px_7px_rgba(15,23,42,0.028)] transition-[background,transform,box-shadow] duration-200 hover:z-20 ${
        selected
          ? 'bg-[linear-gradient(90deg,rgba(255,139,36,0.12),rgba(255,255,255,0.72))] shadow-[0_7px_18px_rgba(251,146,60,0.08)]'
          : 'bg-white/66'
      }`}
    >
      {selected && <span className={`absolute left-0.5 h-[26px] w-[3px] rounded-full ${port.tone === 'green' ? 'bg-emerald-500' : port.tone === 'blue' ? 'bg-blue-500' : 'bg-orange-500'}`} />}
      <ProcessIcon kind={port.icon} />
      <div className="w-[70px]">
        <div className="font-mono text-lg font-semibold leading-5 tracking-[-0.04em] text-zinc-800">{port.port}</div>
        <div className={`mt-1 text-[11px] font-semibold ${currentScopeColor}`}>● {port.scope}</div>
      </div>
      <div className="min-w-0 flex-1">
        <div className="truncate text-[13px] font-semibold leading-4 text-zinc-800">{port.app}</div>
        <div className="mt-1 truncate font-mono text-[10.5px] font-medium text-zinc-500">PID {port.pid} · {port.runtime}</div>
      </div>
      <div className="relative flex w-[70px] justify-end">
        <div className={`text-right transition duration-200 group-hover/port-row:scale-95 group-hover/port-row:opacity-0 ${showActions ? 'scale-95 opacity-0' : 'opacity-100'}`}>
          <div className="font-mono text-[12px] font-semibold text-zinc-500">{port.cpu}</div>
          {port.memory && <div className="mt-1 font-mono text-[11px] font-bold text-fuchsia-500">{port.memory}</div>}
        </div>
        <div
          className={`absolute right-0 top-1/2 flex -translate-y-1/2 gap-1 transition duration-200 group-hover/port-row:scale-100 group-hover/port-row:opacity-100 ${
            showActions ? 'scale-100 opacity-100' : 'pointer-events-none scale-90 opacity-0 group-hover/port-row:pointer-events-auto'
          }`}
        >
          <ActionIcon label="打开">
            <ExternalLink className="h-3.5 w-3.5" />
          </ActionIcon>
          <ActionIcon label="复制">
            <Copy className="h-3.5 w-3.5" />
          </ActionIcon>
          <ActionIcon label="终止" danger>
            <XCircle className="h-3.5 w-3.5" />
          </ActionIcon>
        </div>
      </div>
    </div>
  )
}

function ActionIcon({ label, danger = false, children }) {
  return (
    <span
      className={`group/action relative grid h-7 w-7 place-items-center rounded-lg text-zinc-500 shadow-sm ring-1 transition-colors ${
        danger ? 'bg-rose-100 text-rose-500 ring-rose-200/70 hover:bg-rose-200' : 'bg-white/82 ring-black/5 hover:bg-white hover:text-blue-500'
      }`}
    >
      {children}
      <span className="pointer-events-none absolute bottom-[calc(100%+6px)] left-1/2 z-50 -translate-x-1/2 rounded-md bg-zinc-950/86 px-1.5 py-1 text-[10px] font-medium text-white opacity-0 shadow-lg transition duration-150 group-hover/action:translate-y-[-1px] group-hover/action:opacity-100">
        {label}
      </span>
    </span>
  )
}

function ProcessIcon({ kind }) {
  if (kind === 'claude') {
    return (
      <div className="grid h-[30px] w-[30px] place-items-center rounded-[8px] bg-zinc-950 shadow-[inset_0_0_0_1px_rgba(255,255,255,0.14),0_1px_3px_rgba(15,23,42,0.25)]">
        <span className="h-[21px] w-[21px] rounded-full bg-[conic-gradient(from_25deg,#ffca63,#6b4eff,#0b1020,#ff7b54,#ffca63)] shadow-[0_0_8px_rgba(255,151,75,0.34)]" />
      </div>
    )
  }

  if (kind === 'zed') {
    return (
      <div className="grid h-[30px] w-[30px] place-items-center rounded-[8px] bg-[#151719] font-mono text-[13px] font-bold text-zinc-100 shadow-[inset_0_0_0_1px_rgba(255,255,255,0.14),0_1px_3px_rgba(15,23,42,0.25)]">
        Z
      </div>
    )
  }

  if (kind === 'bun') {
    return (
      <div className="grid h-[30px] w-[30px] place-items-center rounded-[8px] bg-[#111] font-mono text-[8px] font-bold text-orange-400 shadow-[inset_0_0_0_1px_rgba(255,255,255,0.14),0_1px_3px_rgba(15,23,42,0.25)]">
        bun
      </div>
    )
  }

  return (
    <div className="grid h-[30px] w-[30px] place-items-center rounded-[8px] bg-[#111] font-mono text-[8px] font-bold text-emerald-400 shadow-[inset_0_0_0_1px_rgba(255,255,255,0.14),0_1px_3px_rgba(15,23,42,0.25)]">
      exec
    </div>
  )
}

function runtimeToSeconds(value) {
  const dayMatch = value.match(/(\d+)天/)
  const days = dayMatch ? Number(dayMatch[1]) : 0
  const clean = value.replace(/\d+天/, '')
  const parts = clean.split(':').map((part) => Number(part) || 0)
  if (parts.length === 3) return days * 86400 + parts[0] * 3600 + parts[1] * 60 + parts[2]
  if (parts.length === 2) return days * 86400 + parts[0] * 60 + parts[1]
  return days * 86400 + (parts[0] || 0)
}

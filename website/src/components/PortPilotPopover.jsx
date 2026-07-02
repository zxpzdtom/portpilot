import { ArrowUp, Bolt, Copy, ExternalLink, Globe2, Network, RefreshCcw, Search, XCircle } from 'lucide-react'
import { metrics, ports } from '../data/product'

const toneMap = {
  blue: 'text-blue-500 bg-blue-500/10',
  orange: 'text-orange-500 bg-orange-500/10',
  violet: 'text-fuchsia-500 bg-fuchsia-500/10',
}

export function PortPilotPopover({ activeStep = 'scan', className = '' }) {
  const sortedPorts = activeStep === 'sort' ? [...ports].sort((a, b) => a.app.localeCompare(b.app) || a.port - b.port) : ports

  return (
    <div
      className={`w-full max-w-[408px] overflow-hidden rounded-[18px] border border-black/10 bg-[linear-gradient(135deg,#f7fbff,#eef4f4_48%,#ffffff)] p-3 shadow-[0_28px_58px_rgba(0,0,0,0.20),0_2px_10px_rgba(0,0,0,0.10)] ${className}`}
    >
      <div className="flex items-center gap-3 px-1 pb-3 pt-0.5">
        <img src="/assets/portpilot-icon.png" alt="" className="h-[42px] w-[42px] rounded-[9px] shadow-[0_10px_24px_rgba(37,99,235,0.24)] ring-1 ring-black/10" />
        <div>
          <div className="flex items-center gap-2">
            <div className="text-[20px] font-semibold tracking-[-0.03em] text-zinc-700">PortPilot</div>
            <span className="h-2 w-2 rounded-full bg-emerald-500 shadow-[0_0_0_4px_rgba(16,185,129,0.12)]" />
          </div>
          <div className="mt-0.5 text-[12px] font-medium text-zinc-500">25 个监听端口</div>
        </div>
        <button className="ml-auto grid h-[30px] w-[30px] place-items-center rounded-lg bg-zinc-900/[0.035] text-zinc-500 transition-transform duration-200 active:scale-[0.96]">
          <RefreshCcw className="h-4 w-4" />
        </button>
      </div>

      <div className="flex h-[38px] items-center gap-2 rounded-lg bg-white/72 px-3 text-[14px] text-zinc-500 shadow-[0_8px_20px_rgba(15,23,42,0.035)]">
        <Search className="h-4 w-4" />
        <span className={activeStep === 'scan' ? 'text-zinc-900' : ''}>搜索端口、PID、进程、命令</span>
      </div>

      <div className="mt-3 grid grid-cols-3 gap-1.5">
        {metrics.map((metric) => {
          const Icon = metric.icon
          return (
            <div key={metric.label} className="min-h-[58px] rounded-[9px] bg-white/62 px-2.5 py-2.5 shadow-[inset_0_0_0_0.5px_rgba(255,255,255,0.8),0_7px_18px_rgba(15,23,42,0.045)]">
              <div className="flex items-center gap-1.5 text-[11px] font-semibold text-zinc-500">
                <Icon className={`h-3.5 w-3.5 ${toneMap[metric.tone]?.split(' ')[0]}`} />
                {metric.label}
              </div>
              <div className="mt-2 whitespace-nowrap text-[17px] font-semibold tracking-[-0.03em] text-zinc-800">{metric.value}</div>
            </div>
          )
        })}
      </div>

      <div className="mt-3 flex items-center justify-between px-1 text-[11px] font-medium text-zinc-500">
        <span>监听端口</span>
        <button className="flex h-[24px] items-center gap-1 rounded-lg bg-zinc-900/[0.035] px-2 text-zinc-600">
          <ArrowUp className="h-3 w-3" />
          <span>{activeStep === 'sort' ? '进程名' : '打开时刷新'}</span>
          <span className="text-zinc-400">升</span>
        </button>
      </div>

      <div className="mt-2 max-h-[284px] space-y-1.5 overflow-hidden">
        {sortedPorts.map((port, index) => (
          <PortRow key={`${port.port}-${port.app}`} port={port} selected={index === 0 || (activeStep === 'act' && index === 1)} activeStep={activeStep} />
        ))}
      </div>

      <div className="mt-3 flex items-center justify-between px-1 text-[11px] text-zinc-500">
        <span>上次刷新 14:29</span>
        <div className="flex items-center gap-2">
          <button className="rounded-lg bg-zinc-900/[0.035] px-2 py-1 font-medium">关于</button>
          <button className="rounded-lg bg-zinc-900/[0.035] px-2 py-1 font-medium">退出 ⌘Q</button>
        </div>
      </div>
    </div>
  )
}

function PortRow({ port, selected, activeStep }) {
  const scopeClass = port.tone === 'green' ? 'text-emerald-500' : port.tone === 'blue' ? 'text-blue-500' : 'text-orange-500'
  const showActions = activeStep === 'act' && selected

  return (
    <div
      className={`group/port-row relative flex h-[50px] items-center gap-2 rounded-[9px] px-3 shadow-[inset_0_0_0_0.5px_rgba(255,255,255,0.44),0_2px_8px_rgba(15,23,42,0.026)] transition-[background,transform,box-shadow] duration-200 ${
        selected ? 'bg-blue-100/72 shadow-[0_8px_22px_rgba(37,99,235,0.11)]' : 'bg-white/56'
      }`}
    >
      {selected && <span className={`absolute left-0.5 h-[26px] w-[3px] rounded-full ${port.tone === 'green' ? 'bg-emerald-500' : port.tone === 'blue' ? 'bg-blue-500' : 'bg-orange-500'}`} />}
      <div className="w-[76px]">
        <div className="flex items-center gap-2">
          {port.hint === 'dev' ? <Bolt className={`h-4 w-4 ${scopeClass}`} /> : port.tone === 'green' ? <Network className={`h-4 w-4 ${scopeClass}`} /> : <Globe2 className={`h-4 w-4 ${scopeClass}`} />}
          <span className="font-mono text-lg font-semibold tracking-[-0.04em] text-zinc-700">{port.port}</span>
        </div>
        <div className={`mt-0.5 pl-6 text-[11px] font-semibold ${scopeClass}`}>• {port.scope}</div>
      </div>
      <div className="min-w-0 flex-1">
        <div className="truncate text-[13px] font-semibold text-zinc-700">{port.app}</div>
        <div className="mt-0.5 font-mono text-[11px] text-zinc-500">{port.time}</div>
      </div>
      <div className="relative flex w-[78px] justify-end">
        <div className={`text-right transition duration-200 group-hover/port-row:scale-95 group-hover/port-row:opacity-0 ${showActions ? 'scale-95 opacity-0' : 'opacity-100'}`}>
          <div className="font-mono text-[12px] font-semibold text-zinc-500">{port.cpu}</div>
          {port.memory && <div className="mt-1 font-mono text-[11px] font-bold text-fuchsia-500">{port.memory}</div>}
        </div>
        <div
          className={`absolute right-0 top-1/2 flex -translate-y-1/2 gap-1 transition duration-200 group-hover/port-row:scale-100 group-hover/port-row:opacity-100 ${
            showActions ? 'scale-100 opacity-100' : 'pointer-events-none scale-90 opacity-0 group-hover/port-row:pointer-events-auto'
          }`}
        >
          <span className="grid h-7 w-7 place-items-center rounded-lg bg-white/80 text-zinc-500 shadow-sm ring-1 ring-black/5 transition-colors hover:bg-white hover:text-blue-500">
            <ExternalLink className="h-3.5 w-3.5" />
          </span>
          <span className="grid h-7 w-7 place-items-center rounded-lg bg-white/80 text-zinc-500 shadow-sm ring-1 ring-black/5 transition-colors hover:bg-white hover:text-emerald-500">
            <Copy className="h-3.5 w-3.5" />
          </span>
          <span className="grid h-7 w-7 place-items-center rounded-lg bg-rose-100 text-rose-500 shadow-sm ring-1 ring-rose-200/70 transition-colors hover:bg-rose-200">
            <XCircle className="h-3.5 w-3.5" />
          </span>
        </div>
      </div>
    </div>
  )
}

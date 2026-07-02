import { BatteryCharging, Bluetooth, Cloud, Radio, Search, Wifi } from 'lucide-react'
import { PortPilotPopover } from './PortPilotPopover'

export function PortRadarScene() {
  return (
    <div className="t-tilt group relative mx-auto w-full max-w-[1248px]">
      <div className="t-tilt-card relative overflow-hidden rounded-[22px] bg-[#111318] shadow-[0_50px_160px_rgba(0,0,0,0.55)] ring-1 ring-white/10">
        <MacMenuBar />

        <div className="relative min-h-[570px] overflow-hidden bg-[radial-gradient(circle_at_70%_8%,rgba(48,129,255,0.20),transparent_32%),linear-gradient(180deg,#111827,#080b12_58%,#05070d)] px-4 pb-7 pt-5 md:min-h-[600px] md:px-8">
          <div className="absolute inset-0 opacity-[0.16] [background-image:linear-gradient(rgba(255,255,255,0.055)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.055)_1px,transparent_1px)] [background-size:44px_44px]" />
          <div className="absolute left-8 top-8 hidden w-[360px] rounded-[18px] border border-white/10 bg-black/22 p-4 text-white/70 backdrop-blur-xl md:block">
            <div className="mb-3 flex items-center justify-between text-xs text-white/40">
              <span className="font-semibold uppercase tracking-[0.16em]">Local services</span>
              <span className="rounded-full bg-emerald-300/10 px-2 py-1 text-emerald-200">live</span>
            </div>
            <div className="space-y-2 font-mono text-sm">
              <ServiceRow port="3000" name="next dev" tone="text-orange-300" />
              <ServiceRow port="5173" name="vite preview" tone="text-cyan-300" />
              <ServiceRow port="7890" name="proxy helper" tone="text-fuchsia-300" />
            </div>
          </div>

          <div className="absolute left-1/2 top-3 z-30 w-[408px] max-w-[calc(100%-34px)] -translate-x-1/2 md:left-auto md:right-24 md:translate-x-0">
            <PortPilotPopover className="origin-top animate-popover-in" />
          </div>

          <div className="absolute inset-x-6 bottom-6 z-20 hidden items-center justify-between rounded-[18px] border border-white/10 bg-black/22 px-5 py-4 text-sm text-white/55 backdrop-blur-xl md:flex">
            <span>open from menu bar</span>
            <span>search by port, PID, process, command</span>
            <span>manual refresh only</span>
          </div>
        </div>

        <div className="t-tilt-glare" />
      </div>
    </div>
  )
}

function ServiceRow({ port, name, tone }) {
  return (
    <div className="flex items-center justify-between rounded-xl bg-white/[0.045] px-3 py-2">
      <span className={`font-semibold ${tone}`}>{port}</span>
      <span className="text-white/42">{name}</span>
    </div>
  )
}

function MacMenuBar() {
  return (
    <div className="mac-menubar relative z-40 flex h-7 items-center px-3 text-[13px] font-medium text-white/92">
      <div className="flex min-w-0 items-center gap-[17px]">
        <span className="-mt-px text-[15px] leading-none"></span>
        <span className="font-semibold text-white">PortPilot</span>
        <span className="hidden text-white/82 sm:inline">File</span>
        <span className="hidden text-white/82 sm:inline">Edit</span>
        <span className="hidden text-white/82 sm:inline">Window</span>
        <span className="hidden text-white/82 md:inline">Help</span>
      </div>
      <div className="ml-auto flex items-center gap-[10px] text-white/90">
        <Cloud className="hidden h-[13px] w-[13px] stroke-[2.2] sm:block" />
        <span className="hidden text-[12px] sm:inline">25°C</span>
        <Bluetooth className="hidden h-[13px] w-[13px] stroke-[2.2] md:block" />
        <BatteryCharging className="hidden h-[15px] w-[15px] stroke-[2.2] sm:block" />
        <Wifi className="h-[13px] w-[13px] stroke-[2.2]" />
        <StatusItem />
        <Search className="hidden h-[13px] w-[13px] stroke-[2.2] sm:block" />
        <span className="hidden tabular-nums text-[12px] sm:inline">7月2日 周四 14:35</span>
      </div>
    </div>
  )
}

function StatusItem() {
  return (
    <div className="grid h-[22px] w-[34px] place-items-center rounded-[6px] bg-black/20 text-white shadow-[inset_0_0_0_1px_rgba(255,255,255,0.10)]">
      <Radio className="h-[14px] w-[14px] stroke-[2.2]" />
    </div>
  )
}

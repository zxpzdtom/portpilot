import { CheckCircle2 } from 'lucide-react'
import { SectionHeader } from '../components/SectionHeader'
import { releaseFacts, updateEvents } from '../data/product'

export function Showcase() {
  return (
    <section id="surface" className="relative px-5 py-20 md:py-28 lg:px-8">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_78%_8%,rgba(16,185,129,0.10),transparent_30%),linear-gradient(180deg,#080b13,#05070d)]" />
      <div className="mx-auto max-w-7xl">
        <div className="relative z-10 grid gap-10 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
          <div>
            <SectionHeader
              align="left"
              eyebrow="Native surface"
              title="小窗口就是全部工作区。"
              body="PortPilot 不需要完整面板。打开菜单栏 popover，就能搜索、排序、复制、打开、结束进程和检查更新。"
            />
            <div className="mt-8 grid gap-3 sm:grid-cols-3">
              {releaseFacts.map((fact) => (
                <div key={fact.label} className="rounded-2xl border border-white/10 bg-white/[0.045] p-4">
                  <div className="text-xs font-semibold text-white/34">{fact.label}</div>
                  <div className="mt-2 font-mono text-lg font-semibold text-white">{fact.value}</div>
                </div>
              ))}
            </div>
          </div>

          <div id="updates" className="rounded-[32px] border border-white/10 bg-white/[0.055] p-5 text-white shadow-[0_30px_90px_rgba(0,0,0,0.25)] backdrop-blur-xl">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm font-semibold text-white/45">Sparkle update chain</div>
                <div className="mt-1 text-2xl font-semibold tracking-[-0.04em]">Signed updates, no guesswork.</div>
              </div>
              <CheckCircle2 className="h-8 w-8 text-emerald-300" />
            </div>
            <div className="mt-7 space-y-3">
              {updateEvents.map((event, index) => (
                <div key={event.label} className="flex items-center justify-between rounded-2xl bg-black/22 px-4 py-3 shadow-[inset_0_0_0_1px_rgba(255,255,255,0.07)]">
                  <div className="flex items-center gap-3">
                    <span className="grid h-7 w-7 place-items-center rounded-full bg-blue-400/15 font-mono text-xs font-semibold text-blue-200">{index + 1}</span>
                    <span className="font-semibold">{event.label}</span>
                  </div>
                  <span className="font-mono text-sm text-white/55">{event.value}</span>
                </div>
              ))}
            </div>
            <p className="mt-6 text-sm leading-6 text-white/55">PortPilot 使用 Sparkle appcast 和 EdDSA 签名。用户看到的是标准 macOS 更新窗口，下载进度、取消、安装和重新打开都在原生流程里完成。</p>
          </div>
        </div>

        <div className="relative z-10 mt-14 grid gap-4 md:grid-cols-3">
          {['Menu bar only', 'Hover actions', 'Manual refresh'].map((item, index) => (
            <div key={item} className="rounded-[28px] border border-white/10 bg-white/[0.045] p-6">
              <div className="font-mono text-xs text-cyan-200/70">0{index + 1}</div>
              <div className="mt-4 text-xl font-semibold tracking-[-0.035em] text-white">{item}</div>
              <p className="mt-3 text-sm leading-6 text-white/45">
                {index === 0 && '没有完整面板，所有核心操作都在菜单栏 popover 内完成。'}
                {index === 1 && '鼠标悬停端口行，打开、复制和终止操作会在行内出现。'}
                {index === 2 && '打开时刷新，也可以手动刷新；不会在后台持续轮询。'}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

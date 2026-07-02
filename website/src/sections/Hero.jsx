import { CheckCircle2 } from 'lucide-react'
import { DownloadButton, GithubButton } from '../components/Button'
import { PortRadarScene } from '../components/PortRadarScene'
import { trustNotes } from '../data/product'

export function Hero() {
  return (
    <section className="relative overflow-hidden px-5 pb-16 pt-12 md:pb-24 md:pt-18 lg:px-8">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_0%,rgba(34,211,238,0.16),transparent_34%),radial-gradient(circle_at_12%_24%,rgba(16,185,129,0.11),transparent_28%),linear-gradient(180deg,#07101d,#05070d_62%)]" />
      <div className="mx-auto max-w-7xl">
        <div className="t-stagger is-shown relative z-10 mx-auto max-w-4xl text-center">
          <div className="t-stagger-line t-stagger-inline t-stagger-line--1 mx-auto h-8 items-center gap-2 rounded-full border border-cyan-200/14 bg-white/[0.06] px-3 text-[13px] font-semibold text-white/70 shadow-[inset_0_0_0_1px_rgba(255,255,255,0.04),0_18px_60px_rgba(0,0,0,0.16)] backdrop-blur-xl">
            <CheckCircle2 className="h-4 w-4 text-emerald-500" />
            Local port radar for macOS
          </div>
          <h1 className="t-stagger-line t-stagger-line--2 mt-7 text-balance text-5xl font-semibold tracking-[-0.065em] text-white md:text-7xl">
            3000 被谁占了？
            <span className="block bg-gradient-to-r from-cyan-200 via-white to-emerald-200 bg-clip-text text-transparent">一眼看见。</span>
          </h1>
          <p className="t-stagger-line t-stagger-line--3 mx-auto mt-6 max-w-2xl text-pretty text-lg leading-8 text-white/60 md:text-xl">
            PortPilot 是藏在菜单栏里的本地端口雷达。打开、搜索、排序、复制、结束进程，Vibe Coding 时不用再翻终端找
            <span className="font-semibold text-cyan-200"> 3000</span>、
            <span className="font-semibold text-orange-200"> 5173</span>、
            <span className="font-semibold text-fuchsia-200"> 7890</span>。
          </p>
          <div className="t-stagger-line t-stagger-flex t-stagger-line--4 mt-8 flex-col justify-center gap-3 sm:flex-row">
            <DownloadButton />
            <GithubButton>View source</GithubButton>
          </div>
        </div>

        <div className="relative z-10 mt-14">
          <PortRadarScene />
        </div>

        <div className="relative z-10 mx-auto mt-8 grid max-w-3xl grid-cols-1 gap-3 sm:grid-cols-3">
          {trustNotes.map((item) => {
            const Icon = item.icon
            return (
              <div key={item.text} className="flex items-center justify-center gap-2 rounded-2xl border border-white/10 bg-white/[0.055] px-4 py-3 text-sm font-semibold text-white/62 backdrop-blur-xl">
                <Icon className="h-4 w-4 text-cyan-300" />
                {item.text}
              </div>
            )
          })}
        </div>

      </div>
    </section>
  )
}

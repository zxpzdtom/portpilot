import { BrandMark } from '../components/BrandMark'
import { DownloadButton, GithubButton } from '../components/Button'

export function DownloadCTA() {
  return (
    <section className="relative px-5 py-20 md:py-28 lg:px-8">
      <div className="absolute inset-0 bg-[linear-gradient(180deg,#05070d,#030407)]" />
      <div className="relative z-10 mx-auto max-w-6xl overflow-hidden rounded-[36px] border border-cyan-200/12 bg-[radial-gradient(circle_at_18%_0%,rgba(34,211,238,0.20),transparent_34%),linear-gradient(135deg,rgba(255,255,255,0.09),rgba(255,255,255,0.025))] p-8 text-white shadow-[0_35px_120px_rgba(0,0,0,0.42)] md:p-12">
        <div className="absolute inset-0 opacity-[0.20] [background-image:linear-gradient(rgba(255,255,255,0.08)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.08)_1px,transparent_1px)] [background-size:38px_38px]" />
        <div className="grid gap-10 md:grid-cols-[1fr_auto] md:items-center">
          <div className="relative">
            <div className="inline-flex rounded-2xl border border-white/10 bg-black/24 p-2">
              <BrandMark compact />
            </div>
            <h2 className="mt-8 max-w-2xl text-balance text-4xl font-semibold tracking-[-0.055em] md:text-6xl">把端口雷达放回菜单栏。</h2>
            <p className="mt-5 max-w-xl text-pretty text-lg leading-8 text-white/60">适合经常跑多个 dev server、代理、本地服务和临时工具的开发者。小、快、本地运行、可审计。</p>
          </div>
          <div className="relative flex flex-col gap-3 sm:flex-row md:flex-col">
            <DownloadButton />
            <GithubButton>Open source</GithubButton>
          </div>
        </div>
      </div>
    </section>
  )
}

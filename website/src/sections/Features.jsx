import { SectionHeader } from '../components/SectionHeader'
import { features } from '../data/product'

export function Features() {
  return (
    <section id="features" className="relative px-5 py-20 md:py-28 lg:px-8">
      <div className="absolute inset-0 bg-[linear-gradient(180deg,#05070d,#080b13)]" />
      <div className="mx-auto max-w-7xl">
        <div className="relative z-10">
          <SectionHeader
            eyebrow="What it handles"
            title="专心回答一个问题：谁在用这个端口？"
            body="不是通用系统监控，也不是复杂进程管理器。PortPilot 只处理本地开发里最烦的端口占用、资源异常和残留进程。"
          />
        </div>
        <div className="relative z-10 mt-12 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {features.map((feature) => {
            const Icon = feature.icon
            return (
              <article key={feature.title} className="rounded-[28px] border border-white/10 bg-white/[0.045] p-6 shadow-[0_16px_50px_rgba(0,0,0,0.16)] backdrop-blur-xl transition-[transform,box-shadow,border-color,background] duration-300 hover:-translate-y-1 hover:border-cyan-200/20 hover:bg-white/[0.07] hover:shadow-[0_24px_70px_rgba(34,211,238,0.08)]">
                <div className="grid h-12 w-12 place-items-center rounded-2xl bg-cyan-300/10 text-cyan-200">
                  <Icon className="h-5 w-5" />
                </div>
                <h3 className="mt-5 text-xl font-semibold tracking-[-0.035em] text-white">{feature.title}</h3>
                <p className="mt-3 text-sm leading-6 text-white/48">{feature.body}</p>
              </article>
            )
          })}
        </div>
      </div>
    </section>
  )
}

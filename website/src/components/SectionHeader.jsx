export function SectionHeader({ eyebrow, title, body, align = 'center' }) {
  const isCenter = align === 'center'
  return (
    <div className={isCenter ? 'mx-auto max-w-3xl text-center' : 'max-w-2xl'}>
      <div className="text-sm font-semibold text-cyan-300">{eyebrow}</div>
      <h2 className="mt-3 text-balance text-3xl font-semibold tracking-[-0.045em] text-white md:text-5xl">{title}</h2>
      <p className="mt-4 text-pretty text-base leading-7 text-white/55 md:text-lg">{body}</p>
    </div>
  )
}

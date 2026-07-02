import { ArrowDownToLine, Code2 } from 'lucide-react'

const base =
  'group inline-flex items-center justify-center rounded-full font-semibold transition-[transform,box-shadow,background,color,border-color] duration-300 ease-[cubic-bezier(0.22,1,0.36,1)] active:scale-[0.97]'

const sizes = {
  md: 'h-12 gap-2 px-5 text-sm',
  sm: 'h-9 gap-1.5 px-3.5 text-[13px]',
}

export function DownloadButton({ variant = 'primary', size = 'md', showIcon = true, children = 'Download for Mac' }) {
  const styles =
    variant === 'primary'
      ? 'bg-white text-zinc-950 shadow-[0_18px_60px_rgba(255,255,255,0.16)] hover:bg-cyan-100 hover:shadow-[0_22px_70px_rgba(34,211,238,0.22)]'
      : 'border border-white/12 bg-white/[0.06] text-white shadow-[inset_0_0_0_1px_rgba(255,255,255,0.04)] hover:border-cyan-200/35 hover:bg-white/[0.10]'

  return (
    <a className={`${base} ${sizes[size]} ${styles}`} href="https://github.com/zxpzdtom/portpilot/releases/latest">
      {showIcon && <ArrowDownToLine className="h-4 w-4 transition-transform duration-300 group-hover:translate-y-0.5" />}
      {children}
    </a>
  )
}

export function GithubButton({ size = 'md', showIcon = true, children = 'GitHub' }) {
  return (
    <a
      className={`${base} ${sizes[size]} border border-white/12 bg-white/[0.06] text-white shadow-[inset_0_0_0_1px_rgba(255,255,255,0.04)] hover:border-cyan-200/35 hover:bg-white/[0.10]`}
      href="https://github.com/zxpzdtom/portpilot"
    >
      {showIcon && <Code2 className="h-4 w-4 transition-transform duration-300 group-hover:-rotate-6" />}
      {children}
    </a>
  )
}

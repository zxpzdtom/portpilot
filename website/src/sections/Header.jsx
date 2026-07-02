import { BrandMark } from '../components/BrandMark'
import { DownloadButton, GithubButton } from '../components/Button'
import { navItems } from '../data/product'

export function Header() {
  return (
    <header className="sticky top-0 z-50 border-b border-white/10 bg-[#05070d]/72 backdrop-blur-2xl">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-5 lg:px-8">
        <BrandMark />
        <nav className="hidden items-center gap-8 md:flex">
          {navItems.map((item) => (
            <a key={item.href} href={item.href} className="text-sm font-semibold text-white/50 transition-colors hover:text-white">
              {item.label}
            </a>
          ))}
        </nav>
        <div className="hidden items-center gap-2 sm:flex">
          <GithubButton size="sm" showIcon={false} />
          <DownloadButton size="sm" showIcon={false} />
        </div>
      </div>
    </header>
  )
}

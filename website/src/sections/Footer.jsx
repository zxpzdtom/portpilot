export function Footer() {
  return (
    <footer className="bg-[#030407] px-5 pb-10 lg:px-8">
      <div className="mx-auto flex max-w-7xl flex-col items-center justify-between gap-4 border-t border-white/10 pt-8 text-sm text-white/42 sm:flex-row">
        <p>PortPilot is open source under MIT.</p>
        <div className="flex gap-5">
          <a className="font-semibold transition-colors hover:text-white" href="https://github.com/zxpzdtom/portpilot/releases">
            Releases
          </a>
          <a className="font-semibold transition-colors hover:text-white" href="https://github.com/zxpzdtom/portpilot">
            GitHub
          </a>
        </div>
      </div>
    </footer>
  )
}

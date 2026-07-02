export function BrandMark({ compact = false }) {
  return (
    <a href="#" className="group flex items-center gap-3" aria-label="PortPilot home">
      <img
        src="/assets/portpilot-icon.png"
        alt="PortPilot app icon"
        className="h-10 w-10 rounded-[10px] shadow-[0_14px_35px_rgba(30,118,255,0.24)] ring-1 ring-black/10 transition-transform duration-300 group-hover:scale-[1.04]"
      />
      {!compact && (
        <div className="leading-none">
          <div className="text-[15px] font-semibold tracking-[-0.01em] text-white">PortPilot</div>
          <div className="mt-1 text-[11px] font-medium text-white/45">Local port radar</div>
        </div>
      )}
    </a>
  )
}

const nav = [
  { label: "Committed capital", value: "$412.8M" },
  { label: "Net IRR", value: "18.4%", positive: true },
  { label: "Unfunded", value: "$96.1M" },
  { label: "DPI", value: "0.74x" },
];

const holdings = [
  { name: "Meridian Credit Fund II", weight: "24.1%", value: "$99.4M", delta: "+1.9%", up: true },
  { name: "Sovereign IG Ladder", weight: "18.7%", value: "$77.2M", delta: "+0.4%", up: true },
  { name: "Harbour Growth SPV", weight: "15.2%", value: "$62.7M", delta: "-0.8%", up: false },
  { name: "Short-duration Treasuries", weight: "12.9%", value: "$53.2M", delta: "+0.2%", up: true },
];

// Monthly NAV index, rebased to 100.
const series = [100, 103, 101, 108, 112, 110, 118, 124, 121, 130, 136, 142];

function Sparkline() {
  const w = 560;
  const h = 140;
  const min = Math.min(...series);
  const max = Math.max(...series);
  const pts = series.map((v, i) => {
    const x = (i / (series.length - 1)) * w;
    const y = h - ((v - min) / (max - min)) * (h - 12) - 6;
    return [x, y] as const;
  });
  const line = pts.map(([x, y], i) => `${i === 0 ? "M" : "L"}${x.toFixed(1)} ${y.toFixed(1)}`).join(" ");
  const area = `${line} L${w} ${h} L0 ${h} Z`;

  return (
    <svg viewBox={`0 0 ${w} ${h}`} className="h-36 w-full" role="img" aria-label="Fund NAV trending up over twelve months">
      <defs>
        <linearGradient id="navFill" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#4ade80" stopOpacity="0.28" />
          <stop offset="100%" stopColor="#4ade80" stopOpacity="0" />
        </linearGradient>
      </defs>
      <path d={area} fill="url(#navFill)" />
      <path d={line} fill="none" stroke="#4ade80" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export function DashboardPreview() {
  return (
    <div className="rounded-2xl border border-line bg-card p-2 shadow-2xl shadow-black/40">
      <div className="rounded-xl border border-line bg-background p-5 sm:p-6">
        <div className="flex items-center justify-between gap-4 border-b border-line pb-4">
          <div>
            <p className="text-sm font-medium">Meridian Partners — all funds</p>
            <p className="mt-0.5 font-mono text-xs text-muted">Positions synced 4 minutes ago</p>
          </div>
          <span className="hidden rounded-full border border-accent/30 bg-accent/10 px-2.5 py-1 font-mono text-[11px] text-accent sm:block">
            LIVE
          </span>
        </div>

        <dl className="grid grid-cols-2 gap-px overflow-hidden border-b border-line pb-6 pt-6 sm:grid-cols-4">
          {nav.map((k) => (
            <div key={k.label}>
              <dt className="text-xs text-muted">{k.label}</dt>
              <dd className={`mt-1 font-mono text-lg ${k.positive ? "text-accent" : ""}`}>{k.value}</dd>
            </div>
          ))}
        </dl>

        <div className="pt-6">
          <p className="mb-1 text-xs text-muted">NAV index, trailing 12 months</p>
          <Sparkline />
        </div>

        <table className="mt-4 w-full border-t border-line text-sm">
          <tbody>
            {holdings.map((h) => (
              <tr key={h.name} className="border-b border-line/70 last:border-0">
                <td className="py-2.5 pr-3">{h.name}</td>
                <td className="hidden py-2.5 pr-3 text-right font-mono text-xs text-muted sm:table-cell">{h.weight}</td>
                <td className="py-2.5 pr-3 text-right font-mono text-xs">{h.value}</td>
                <td className={`py-2.5 text-right font-mono text-xs ${h.up ? "text-accent" : "text-red-400"}`}>
                  {h.delta}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

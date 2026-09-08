import Link from "next/link";

const links = [
  { href: "#features", label: "Product" },
  { href: "#workflow", label: "How it works" },
  { href: "#proof", label: "Customers" },
  { href: "#pricing", label: "Pricing" },
];

export function Nav() {
  return (
    <header className="sticky top-0 z-50 border-b border-line/80 bg-background/80 backdrop-blur">
      <nav className="mx-auto flex h-16 max-w-6xl items-center justify-between px-6">
        <Link href="/" className="flex items-center gap-2.5">
          <span className="grid h-7 w-7 place-items-center rounded-md bg-accent font-mono text-sm font-bold text-background">
            B
          </span>
          <span className="text-[15px] font-semibold tracking-tight">BondTrack</span>
        </Link>
        <ul className="hidden items-center gap-8 md:flex">
          {links.map((l) => (
            <li key={l.href}>
              <a href={l.href} className="text-sm text-muted transition-colors hover:text-foreground">
                {l.label}
              </a>
            </li>
          ))}
        </ul>
        <div className="flex items-center gap-3">
          <a href="#cta" className="hidden text-sm text-muted transition-colors hover:text-foreground sm:block">
            Sign in
          </a>
          <a
            href="#cta"
            className="rounded-lg bg-foreground px-4 py-2 text-sm font-medium text-background transition-opacity hover:opacity-90"
          >
            Book a demo
          </a>
        </div>
      </nav>
    </header>
  );
}

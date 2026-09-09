import { Nav } from "@/components/Nav";
import { Section } from "@/components/Section";
import { DashboardPreview } from "@/components/DashboardPreview";

const features = [
  {
    title: "One position book",
    body:
      "Custodians, brokers, admins and SPV spreadsheets consolidate into a single holdings view — priced daily, reconciled automatically, broken out by fund, strategy or mandate.",
  },
  {
    title: "Capital accounts that close themselves",
    body:
      "Calls, distributions, management fees and carry are calculated per LP from the waterfall you configure once. Statements generate in a click, not a week.",
  },
  {
    title: "Performance you can defend",
    body:
      "Gross and net IRR, TVPI, DPI, MOIC and time-weighted returns computed from the underlying cash flows — with the full audit trail behind every number.",
  },
  {
    title: "Exposure and risk in real time",
    body:
      "Concentration, duration, sector and counterparty exposure update as positions move. Set limits and get alerted before a breach, not at quarter end.",
  },
  {
    title: "An LP portal they'll actually use",
    body:
      "Investors log in for their own statements, capital notices, K-1s and documents. Fewer inbox requests for your team, more transparency for theirs.",
  },
  {
    title: "Built for audit day",
    body:
      "Every value is traceable to a source document and every change is versioned with who, when and why. Export the whole trail for your auditors.",
  },
];

const workflow = [
  {
    step: "01",
    title: "Connect your sources",
    body: "Link custodians and fund admins, or upload the statements and spreadsheets you already keep. Onboarding is measured in days.",
  },
  {
    step: "02",
    title: "Map funds once",
    body: "Define your structures, fee terms and waterfalls. BondTrack applies them consistently across every period from then on.",
  },
  {
    step: "03",
    title: "Run the fund from one screen",
    body: "Daily NAV, exposure, LP capital accounts and reporting stay current on their own — you review instead of rebuild.",
  },
];

const stats = [
  { value: "9 hrs", label: "saved per week on reconciliation, per fund" },
  { value: "T+1", label: "position and NAV refresh, not T+30" },
  { value: "$4.1B", label: "in fund assets tracked on BondTrack" },
];

export default function Home() {
  return (
    <div className="min-h-screen">
      <Nav />

      <main>
        {/* Hero */}
        <section className="relative overflow-hidden px-6 pb-20 pt-20 sm:pt-28">
          <div
            aria-hidden
            className="pointer-events-none absolute left-1/2 top-[-14rem] h-[32rem] w-[62rem] -translate-x-1/2 rounded-full bg-accent/10 blur-[130px]"
          />
          <div className="relative mx-auto max-w-6xl">
            <div className="mx-auto max-w-3xl text-center">
              <span className="inline-flex items-center gap-2 rounded-full border border-line bg-card px-3 py-1 font-mono text-xs text-muted">
                <span className="h-1.5 w-1.5 rounded-full bg-accent" />
                Purpose-built for fund managers
              </span>
              <h1 className="mt-6 text-4xl font-semibold leading-[1.08] tracking-tight sm:text-6xl">
                Stop running your fund
                <br />
                out of a spreadsheet.
              </h1>
              <p className="mx-auto mt-6 max-w-xl text-lg leading-relaxed text-muted">
                BondTrack gives fund managers one live view of positions, cash flows, investor
                capital and performance — reconciled daily, traceable to the source, ready for
                the LP call.
              </p>
              <div className="mt-9 flex flex-col items-center justify-center gap-3 sm:flex-row">
                <a
                  href="#cta"
                  className="w-full rounded-lg bg-accent px-6 py-3 text-sm font-semibold text-background transition-opacity hover:opacity-90 sm:w-auto"
                >
                  Book a 20-minute demo
                </a>
                <a
                  href="#features"
                  className="w-full rounded-lg border border-line px-6 py-3 text-sm font-medium text-foreground transition-colors hover:border-muted sm:w-auto"
                >
                  See the product
                </a>
              </div>
              <p className="mt-4 font-mono text-xs text-muted">
                SOC 2 Type II · No custody of assets · Migrate in under two weeks
              </p>
            </div>

            <div className="mt-16 sm:mt-20">
              <DashboardPreview />
            </div>
          </div>
        </section>

        {/* Problem */}
        <Section
          eyebrow="The problem"
          title="Your numbers are right. Getting to them costs you a week a month."
          lead="Positions live at the custodian, cash flows at the admin, LP terms in a side letter, and the truth in a workbook only one person on the team can open. Every quarter close is a rebuild — and every LP question is a fire drill."
        >
          <div className="grid gap-6 sm:grid-cols-3">
            {stats.map((s) => (
              <div key={s.label} className="rounded-xl border border-line bg-card p-6">
                <p className="font-mono text-3xl text-accent">{s.value}</p>
                <p className="mt-2 text-sm leading-relaxed text-muted">{s.label}</p>
              </div>
            ))}
          </div>
        </Section>

        {/* Features */}
        <Section
          id="features"
          eyebrow="The product"
          title="Everything a fund manager tracks, in one system of record."
          lead="Not a generic portfolio tool bolted onto fund structures. BondTrack models funds, LPs, waterfalls and capital accounts natively."
        >
          <div className="grid gap-px overflow-hidden rounded-xl border border-line bg-line sm:grid-cols-2 lg:grid-cols-3">
            {features.map((f) => (
              <div key={f.title} className="bg-card p-7">
                <h3 className="text-base font-semibold tracking-tight">{f.title}</h3>
                <p className="mt-3 text-sm leading-relaxed text-muted">{f.body}</p>
              </div>
            ))}
          </div>
        </Section>

        {/* Workflow */}
        <Section
          id="workflow"
          eyebrow="How it works"
          title="Live in weeks, not quarters."
          lead="No data team required. Most funds are reporting out of BondTrack before their next quarter close."
        >
          <ol className="grid gap-8 sm:grid-cols-3">
            {workflow.map((w) => (
              <li key={w.step}>
                <p className="font-mono text-sm text-accent">{w.step}</p>
                <h3 className="mt-3 text-lg font-semibold tracking-tight">{w.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted">{w.body}</p>
              </li>
            ))}
          </ol>
        </Section>

        {/* Proof */}
        <Section id="proof" eyebrow="Customers" title="Trusted by managers who report to real LPs.">
          <div className="grid gap-6 lg:grid-cols-2">
            <figure className="rounded-xl border border-line bg-card p-8">
              <blockquote className="text-lg leading-relaxed">
                “We closed our last quarter in two days instead of two weeks. The capital accounts
                were already right — we just reviewed them.”
              </blockquote>
              <figcaption className="mt-5 text-sm text-muted">
                CFO · $610M credit manager
              </figcaption>
            </figure>
            <figure className="rounded-xl border border-line bg-card p-8">
              <blockquote className="text-lg leading-relaxed">
                “Our LPs stopped emailing us for statements. That alone paid for it.”
              </blockquote>
              <figcaption className="mt-5 text-sm text-muted">
                Managing Partner · multi-strategy fund
              </figcaption>
            </figure>
          </div>
        </Section>

        {/* Pricing */}
        <Section
          id="pricing"
          eyebrow="Pricing"
          title="Priced per fund, not per seat."
          lead="Invite your whole team, your admin and your auditors at no extra cost."
        >
          <div className="grid gap-6 lg:grid-cols-3">
            {[
              {
                name: "Emerging",
                price: "$1,200",
                unit: "/fund / month",
                body: "For first- and second-fund managers up to $100M AUM.",
                items: ["1 fund", "Daily position sync", "Capital accounts & statements", "LP portal"],
              },
              {
                name: "Established",
                price: "$3,400",
                unit: "/fund / month",
                body: "For multi-fund managers with an in-house finance team.",
                items: [
                  "Unlimited funds & SPVs",
                  "Custom waterfalls & fee terms",
                  "Exposure limits and alerts",
                  "Audit exports",
                ],
                featured: true,
              },
              {
                name: "Institutional",
                price: "Custom",
                unit: "",
                body: "For platforms with bespoke structures and integrations.",
                items: ["Dedicated environment", "API & data warehouse sync", "SSO / SCIM", "Named success team"],
              },
            ].map((p) => (
              <div
                key={p.name}
                className={`rounded-xl border p-7 ${
                  p.featured ? "border-accent/40 bg-accent/[0.04]" : "border-line bg-card"
                }`}
              >
                <div className="flex items-center justify-between">
                  <h3 className="text-base font-semibold tracking-tight">{p.name}</h3>
                  {p.featured && (
                    <span className="rounded-full bg-accent px-2 py-0.5 font-mono text-[10px] uppercase text-background">
                      Popular
                    </span>
                  )}
                </div>
                <p className="mt-4 font-mono text-3xl">
                  {p.price}
                  <span className="text-sm text-muted">{p.unit}</span>
                </p>
                <p className="mt-3 text-sm leading-relaxed text-muted">{p.body}</p>
                <ul className="mt-6 space-y-2.5 text-sm">
                  {p.items.map((i) => (
                    <li key={i} className="flex gap-2.5">
                      <span aria-hidden className="text-accent">
                        ✓
                      </span>
                      <span className="text-muted">{i}</span>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </Section>

        {/* CTA */}
        <section id="cta" className="border-t border-line px-6 py-24">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-semibold tracking-tight sm:text-4xl">
              See your own fund in BondTrack.
            </h2>
            <p className="mt-4 text-lg leading-relaxed text-muted">
              Send us one custodian statement and a term sheet. We&apos;ll show you your positions,
              capital accounts and performance running live in the demo.
            </p>
            <form className="mx-auto mt-8 flex max-w-md flex-col gap-3 sm:flex-row">
              <label htmlFor="email" className="sr-only">
                Work email
              </label>
              <input
                id="email"
                type="email"
                required
                placeholder="you@yourfund.com"
                className="w-full rounded-lg border border-line bg-card px-4 py-3 text-sm outline-none placeholder:text-muted focus:border-accent"
              />
              <button
                type="submit"
                className="whitespace-nowrap rounded-lg bg-accent px-5 py-3 text-sm font-semibold text-background transition-opacity hover:opacity-90"
              >
                Book a demo
              </button>
            </form>
            <p className="mt-3 font-mono text-xs text-muted">No obligation. We&apos;ll never share your data.</p>
          </div>
        </section>
      </main>

      <footer className="border-t border-line px-6 py-10">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 text-sm text-muted sm:flex-row">
          <p>
            © {new Date().getFullYear()} BondTrack. All rights reserved.{" "}
            <span className="font-mono text-xs text-accent">build 3</span>
          </p>
          <p className="font-mono text-xs">
            BondTrack is a reporting platform and does not provide investment advice or custody assets.
          </p>
        </div>
      </footer>
    </div>
  );
}

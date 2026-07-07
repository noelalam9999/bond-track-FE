import SwiftUI

struct InvestorTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house") }
            MarketView()
                .tabItem { Label("Market", systemImage: "arrow.left.arrow.right") }
            RequestsView()
                .tabItem { Label("Requests", systemImage: "envelope") }
        }
    }
}

struct RequestsView: View {
    @EnvironmentObject var app: AppState
    var body: some View {
        NavigationStack {
            List {
                if app.sentRequests.isEmpty {
                    Text("No requests yet. When a bond nears maturity you can ask fund managers to reallocate it.")
                        .font(.system(size: 13)).foregroundStyle(BT.sub)
                } else {
                    ForEach(app.sentRequests) { r in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(Format.taka(r.amount)) · \(r.maturingBond)")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Sent to all verified fund managers · expires \(Format.date(r.expires))")
                                .font(.system(size: 12)).foregroundStyle(BT.sub)
                        }
                    }
                }
            }
            .navigationTitle("Requests")
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            Group {
                if app.holdings.isEmpty {
                    EmptyPortfolioView()
                } else {
                    portfolio
                }
            }
            .background(BT.bg)
            .navigationTitle("Good morning, \(app.userName.split(separator: " ").first.map(String.init) ?? "")")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var portfolio: some View {
        ScrollView {
            VStack(spacing: 12) {
                portfolioCard
                LiveYieldStrip()
                upcoming
                maturingSoon
            }
            .padding(20)
        }
    }

    private var portfolioCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("PORTFOLIO VALUE").font(.system(size: 10.5, weight: .semibold)).kerning(1.5)
                    .foregroundStyle(BT.cream.opacity(0.6))
                Spacer()
                Label("BB feed · live", systemImage: "circle.fill")
                    .font(.system(size: 10.5))
                    .foregroundStyle(Color(hex: 0x5FCB8A))
            }
            Text(Format.taka(app.portfolioEquity))
                .font(.system(size: 30, weight: .bold)).foregroundStyle(BT.cream)
            HStack(spacing: 8) {
                pill("\(app.holdings.count) bond\(app.holdings.count == 1 ? "" : "s")")
                pill("Wtd yield \(Format.percent(app.weightedYield))")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(BT.green)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var upcoming: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Upcoming coupons").font(.system(size: 15, weight: .semibold))
            VStack(spacing: 0) {
                ForEach(Array(app.upcomingCoupons.prefix(3).enumerated()), id: \.1.1.id) { i, pair in
                    if i > 0 { Divider() }
                    NavigationLink(destination: BondDetailView(holding: pair.0)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pair.0.instrument.name)
                                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(BT.ink)
                                Text(Format.date(pair.1.date))
                                    .font(.system(size: 11.5)).foregroundStyle(BT.sub)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(Format.taka(pair.1.net))
                                    .font(.system(size: 13.5, weight: .semibold)).foregroundStyle(BT.green)
                                Text("net of \(Int(pair.0.tdsRate * 100))% TDS")
                                    .font(.system(size: 10)).foregroundStyle(BT.sub)
                            }
                        }
                        .padding(.vertical, 11)
                    }
                }
            }
            .padding(.horizontal, 14)
            .card(padding: 4)
        }
    }

    @ViewBuilder
    private var maturingSoon: some View {
        if let h = app.holdings.min(by: { $0.daysToMaturity < $1.daysToMaturity }),
           h.daysToMaturity < 90 {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "hourglass").foregroundStyle(BT.gold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Maturing in \(h.daysToMaturity) days")
                            .font(.system(size: 13.5, weight: .semibold)).foregroundStyle(Color(hex: 0x6B5410))
                        Text("\(h.instrument.name) — \(Format.taka(h.faceValue)) face value")
                            .font(.system(size: 12)).foregroundStyle(Color(hex: 0x8A7430))
                    }
                }
                NavigationLink(destination: ReallocationRequestView(holding: h)) {
                    Text("Request reallocation →")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.vertical, 10).padding(.horizontal, 16)
                        .background(BT.gold).foregroundStyle(BT.deep)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card(padding: 14, fill: BT.cream)
        }
    }

    private func pill(_ text: String) -> some View {
        Text(text).font(.system(size: 12, weight: .medium))
            .padding(.vertical, 7).padding(.horizontal, 13)
            .background(Color(hex: 0x1E4A38)).foregroundStyle(BT.cream.opacity(0.9))
            .clipShape(Capsule())
    }
}

struct LiveYieldStrip: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Live BGTB yields").font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("Bangladesh Bank API").font(.system(size: 10.5, weight: .medium)).foregroundStyle(BT.sub)
            }
            HStack(spacing: 8) {
                ForEach([5, 10, 15, 20], id: \.self) { tenor in
                    VStack(spacing: 3) {
                        Text("\(tenor)Y").font(.system(size: 11, weight: .semibold)).foregroundStyle(BT.sub)
                        Text(Format.percent(app.liveYields[tenor] ?? 0))
                            .font(.system(size: 14, weight: .bold)).foregroundStyle(BT.ink)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .card(padding: 0)
                }
            }
        }
    }
}

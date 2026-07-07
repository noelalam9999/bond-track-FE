import SwiftUI

struct BondDetailView: View {
    @EnvironmentObject var app: AppState
    let holding: Holding

    var body: some View {
        let schedule = CouponCalculator.schedule(for: holding)
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header
                maturityCard
                Text("Coupon schedule").font(.system(size: 15, weight: .semibold))
                scheduleCard(schedule)
                NavigationLink(destination: ReallocationRequestView(holding: holding)) {
                    Text("Request reallocation")
                }
                .buttonStyle(PrimaryButton())
            }
            .padding(20)
        }
        .background(BT.bg)
        .navigationTitle("Bond details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(holding.instrument.name)
                .font(.system(size: 19, weight: .bold)).foregroundStyle(BT.cream)
            Text("ISIN \(holding.instrument.isin)\(holding.custodian.map { " · Held at \($0)" } ?? "")")
                .font(.system(size: 11.5)).foregroundStyle(BT.cream.opacity(0.6))
            HStack(spacing: 8) {
                stat("Face value", Format.taka(holding.faceValue))
                stat("Coupon", Format.percent(holding.instrument.couponRate))
                stat("Live YTM", Format.percent(holding.instrument.marketYield))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(BT.green)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var maturityCard: some View {
        let total = holding.instrument.maturityDate.timeIntervalSince(holding.instrument.issueDate)
        let done = Date.now.timeIntervalSince(holding.instrument.issueDate)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Time to maturity").font(.system(size: 13.5, weight: .semibold))
                Spacer()
                Text(String(format: "%.1f yrs left", Double(holding.daysToMaturity) / 365))
                    .font(.system(size: 12.5, weight: .semibold)).foregroundStyle(BT.green2)
            }
            ProgressView(value: min(max(done / total, 0), 1)).tint(BT.gold)
            HStack {
                Text("Issued \(Format.date(holding.instrument.issueDate))")
                Spacer()
                Text("Matures \(Format.date(holding.instrument.maturityDate))")
            }
            .font(.system(size: 11)).foregroundStyle(BT.sub)
            Divider()
            kv("Opening equity", Format.taka(holding.openingEquity))
            kv("TDS on coupons", "\(Int(holding.tdsRate * 100))%")
            kv("Net annual coupon income",
               Format.taka(CouponCalculator.netAnnualIncome(for: holding)), color: BT.green)
        }
        .card()
    }

    private func scheduleCard(_ schedule: [CouponPayment]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(schedule.enumerated()), id: \.1.id) { i, p in
                if i > 0 { Divider() }
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Format.date(p.date)).font(.system(size: 13, weight: .semibold))
                        Text("\(Format.taka(p.gross)) gross · −\(Format.taka(p.tds)) TDS")
                            .font(.system(size: 11)).foregroundStyle(BT.sub)
                    }
                    Spacer()
                    if p.isPaid {
                        Text("Paid ✓").font(.system(size: 12, weight: .semibold)).foregroundStyle(BT.up)
                    } else {
                        Text(Format.taka(p.net) + " net")
                            .font(.system(size: 12.5, weight: .semibold)).foregroundStyle(BT.green)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 14)
        .card(padding: 4)
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.system(size: 10.5)).foregroundStyle(BT.cream.opacity(0.6))
            Text(value).font(.system(size: 14, weight: .semibold)).foregroundStyle(BT.cream)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(hex: 0x1E4A38))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func kv(_ key: String, _ value: String, color: Color = BT.ink) -> some View {
        HStack {
            Text(key).font(.system(size: 13)).foregroundStyle(BT.sub)
            Spacer()
            Text(value).font(.system(size: 13.5, weight: .semibold)).foregroundStyle(color)
        }
    }
}

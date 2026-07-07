import SwiftUI

/// Add-a-bond flow: instrument is picked from the BB bond master via a
/// searchable ISIN sheet; coupon, market yield and maturity are auto-filled
/// and locked; the disbursement schedule (gross / TDS / net) is generated live.
struct AddBondView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var instrument: BondInstrument?
    @State private var showPicker = false
    @State private var purchaseDate: Date = .now
    @State private var faceValue: Double = 1_500_000
    @State private var openingEquity: Double = 1_542_300
    @State private var tdsPercent: Double = 10
    @State private var custodian = ""
    @State private var added = false

    private var previewHolding: Holding? {
        guard let instrument else { return nil }
        return Holding(instrument: instrument, purchaseDate: purchaseDate,
                       faceValue: faceValue, openingEquity: openingEquity,
                       tdsRate: tdsPercent / 100,
                       custodian: custodian.isEmpty ? nil : custodian)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                instrumentPickerField
                if let instrument { autoFilled(instrument) }
                yourInvestment
                tdsField
                if let h = previewHolding { SchedulePreview(holding: h) }
                Button("Add bond to portfolio") {
                    if let h = previewHolding {
                        app.addHolding(h)
                        added = true
                    }
                }
                .buttonStyle(PrimaryButton())
                .disabled(instrument == nil)
            }
            .padding(20)
        }
        .background(BT.bg)
        .navigationTitle("Add a bond")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPicker) {
            InstrumentPickerView(selected: $instrument)
        }
        .alert("Bond added!", isPresented: $added) {
            Button("Go to my portfolio") { dismiss() }
        } message: {
            Text("\(instrument?.name ?? "") is now being tracked. Its coupon calendar was generated automatically.")
        }
    }

    private var instrumentPickerField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Instrument · Bangladesh Bank bond master")
                .font(.system(size: 12.5, weight: .medium)).foregroundStyle(BT.sub)
            Button { showPicker = true } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(instrument?.name ?? "Search by ISIN, tenor or coupon…")
                            .font(.system(size: 14.5, weight: instrument == nil ? .regular : .semibold))
                            .foregroundStyle(instrument == nil ? BT.sub : BT.ink)
                        if let instrument {
                            Text("ISIN \(instrument.isin)")
                                .font(.system(size: 11)).foregroundStyle(BT.sub)
                        }
                    }
                    Spacer()
                    Image(systemName: "magnifyingglass").foregroundStyle(BT.green)
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(instrument == nil ? BT.line : BT.green, lineWidth: 1.5))
            }
        }
    }

    private func autoFilled(_ inst: BondInstrument) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Auto-filled from Bangladesh Bank")
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(BT.green)
                Spacer()
                Label("live", systemImage: "circle.fill")
                    .font(.system(size: 10)).foregroundStyle(BT.up)
            }
            HStack(spacing: 8) {
                stat("Coupon rate", Format.percent(inst.couponRate))
                stat("Market yield", Format.percent(inst.marketYield))
                stat("Maturity date", Format.date(inst.maturityDate))
            }
            Text("Locked · pulled from the BB feed for this ISIN.")
                .font(.system(size: 10.5)).foregroundStyle(Color(hex: 0x3C5547))
        }
        .card(fill: BT.mint)
    }

    private var yourInvestment: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your investment").font(.system(size: 14.5, weight: .semibold))
            DatePicker("Purchase / settlement date", selection: $purchaseDate, displayedComponents: .date)
                .font(.system(size: 13))
            money("Face value", value: $faceValue)
            VStack(alignment: .leading, spacing: 6) {
                money("Opening equity (total settlement paid)", value: $openingEquity,
                      badge: openingEquity > faceValue ? "> primary value" : nil)
                Text("Includes premium and accrued interest — typically above the bond's primary market value of \(Format.taka(faceValue)).")
                    .font(.system(size: 10.5)).foregroundStyle(BT.sub)
            }
        }
        .card()
    }

    private var tdsField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tax deducted at source — on coupons")
                .font(.system(size: 12.5, weight: .medium)).foregroundStyle(BT.sub)
            HStack {
                Text("\(Int(tdsPercent))%").font(.system(size: 14.5, weight: .semibold))
                if tdsPercent == 10 {
                    Text("default").font(.system(size: 10, weight: .semibold))
                        .padding(.vertical, 3).padding(.horizontal, 8)
                        .background(BT.mint).foregroundStyle(BT.green2)
                        .clipShape(Capsule())
                }
                Spacer()
                Stepper("", value: $tdsPercent, in: 0...30, step: 2.5).labelsHidden()
            }
            .padding(14).background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(BT.line, lineWidth: 1))
            Text("Applied automatically to every coupon unless you change it.")
                .font(.system(size: 10.5)).foregroundStyle(BT.sub)
        }
    }

    private func money(_ label: String, value: Binding<Double>, badge: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 12.5, weight: .medium)).foregroundStyle(BT.sub)
            HStack {
                TextField("0", value: value, format: .number)
                    .keyboardType(.numberPad)
                    .font(.system(size: 14.5, weight: .semibold))
                if let badge {
                    Text(badge).font(.system(size: 10, weight: .semibold))
                        .padding(.vertical, 3).padding(.horizontal, 8)
                        .background(BT.cream).foregroundStyle(Color(hex: 0x8A7430))
                        .clipShape(Capsule())
                }
            }
            .padding(14).background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(BT.line, lineWidth: 1))
        }
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.system(size: 10)).foregroundStyle(BT.sub)
            Text(value).font(.system(size: 13, weight: .semibold)).foregroundStyle(BT.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10).background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Auto-calculated disbursement table shown at creation time.
struct SchedulePreview: View {
    let holding: Holding

    var body: some View {
        let schedule = CouponCalculator.upcoming(for: holding)
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Coupon disbursements").font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("auto-calculated").font(.system(size: 10, weight: .semibold))
                    .padding(.vertical, 3).padding(.horizontal, 8)
                    .background(BT.cream).foregroundStyle(Color(hex: 0x8A7430))
                    .clipShape(Capsule())
            }
            HStack {
                Text("Date"); Spacer(); Text("Gross"); Spacer()
                Text("TDS \(Int(holding.tdsRate * 100))%"); Spacer(); Text("Net payout")
            }
            .font(.system(size: 10.5, weight: .semibold)).foregroundStyle(BT.sub)
            Divider()
            ForEach(schedule.prefix(3)) { p in
                HStack {
                    Text(Format.date(p.date)).font(.system(size: 12, weight: .medium))
                    Spacer()
                    Text(Format.taka(p.gross)).font(.system(size: 12)).foregroundStyle(BT.sub)
                    Spacer()
                    Text("−" + Format.taka(p.tds)).font(.system(size: 12)).foregroundStyle(BT.red)
                    Spacer()
                    Text(Format.taka(p.net)).font(.system(size: 12.5, weight: .semibold)).foregroundStyle(BT.green)
                }
                .padding(.vertical, 4)
            }
            if schedule.count > 3 {
                Divider()
                Text("+ \(schedule.count - 3) more · every 6 months until \(Format.date(holding.instrument.maturityDate))")
                    .font(.system(size: 11)).foregroundStyle(BT.sub)
            }
            HStack {
                Text("Net per year").font(.system(size: 11.5, weight: .semibold))
                Spacer()
                Text("\(Format.taka(CouponCalculator.netAnnualIncome(for: holding))) after TDS")
                    .font(.system(size: 11.5, weight: .bold)).foregroundStyle(BT.green)
            }
        }
        .card(padding: 14)
    }
}

import SwiftUI

struct FMTabView: View {
    var body: some View {
        TabView {
            FMDashboardView()
                .tabItem { Label("Desk", systemImage: "house") }
            FMRequestsInboxView()
                .tabItem { Label("Requests", systemImage: "envelope") }
        }
    }
}

struct FMDashboardView: View {
    @EnvironmentObject var app: AppState
    @State private var showNewListing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        kpi("Active listings", "\(app.listings.count)", "৳3.2 Cr face")
                        kpi("New inquiries", "12", "5 unread")
                        kpi("Realloc. requests", "\(app.inboundRequests.count)", "expiring soon")
                    }
                    Button("＋  List a bond on the market") { showNewListing = true }
                        .buttonStyle(PrimaryButton())
                    Text("My listings").font(.system(size: 15, weight: .semibold))
                    VStack(spacing: 0) {
                        ForEach(Array(app.listings.enumerated()), id: \.1.id) { i, l in
                            if i > 0 { Divider() }
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(l.instrument.name).font(.system(size: 13, weight: .semibold))
                                    Text("\(Format.taka(l.availableFace)) available · \(Format.percent(l.impliedYTM)) YTM")
                                        .font(.system(size: 11.5)).foregroundStyle(BT.sub)
                                }
                                Spacer()
                                Text(l.status.rawValue)
                                    .font(.system(size: 10.5, weight: .semibold))
                                    .padding(.vertical, 4).padding(.horizontal, 9)
                                    .background(l.status == .live ? BT.mint : BT.cream)
                                    .foregroundStyle(l.status == .live ? BT.up : Color(hex: 0xB08A1E))
                                    .clipShape(Capsule())
                            }
                            .padding(.vertical, 11)
                        }
                    }
                    .padding(.horizontal, 14)
                    .card(padding: 4)
                }
                .padding(20)
            }
            .background(BT.bg)
            .navigationTitle("Sadia Rahman · IDLC")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showNewListing) { NewListingView() }
        }
    }

    private func kpi(_ label: String, _ value: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.system(size: 10.5)).foregroundStyle(BT.sub)
            Text(value).font(.system(size: 20, weight: .bold)).foregroundStyle(BT.green)
            Text(detail).font(.system(size: 10, weight: .medium)).foregroundStyle(BT.sub)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 12)
    }
}

struct NewListingView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var instrument: BondInstrument?
    @State private var showPicker = false
    @State private var face: Double = 5_000_000
    @State private var minLot: Double = 500_000
    @State private var ask: Double = 100.20

    var body: some View {
        NavigationStack {
            Form {
                Section("Bond") {
                    Button {
                        showPicker = true
                    } label: {
                        Text(instrument.map { "\($0.name) · \($0.isin)" } ?? "Select from BB bond master…")
                            .foregroundStyle(instrument == nil ? BT.sub : BT.ink)
                    }
                }
                Section("Terms") {
                    HStack { Text("Face value to list"); Spacer()
                        TextField("0", value: $face, format: .number).multilineTextAlignment(.trailing) }
                    HStack { Text("Minimum lot"); Spacer()
                        TextField("0", value: $minLot, format: .number).multilineTextAlignment(.trailing) }
                    HStack { Text("Ask price / ৳100"); Spacer()
                        TextField("100", value: $ask, format: .number).multilineTextAlignment(.trailing) }
                    if let inst = instrument {
                        LabeledContent("Implied YTM (auto)",
                                       value: Format.percent(inst.marketYield + (100 - ask) / 100 * 0.02 + 0.0038))
                        LabeledContent("BB benchmark \(inst.tenorYears)Y today",
                                       value: Format.percent(inst.marketYield))
                    }
                }
                Section {
                    Text("New listings are screened by the Super Admin before going live.")
                        .font(.system(size: 12)).foregroundStyle(BT.sub)
                    Button("Publish listing") {
                        if let inst = instrument {
                            app.listings.append(MarketListing(
                                instrument: inst, sellerName: "Sadia Rahman",
                                institution: "IDLC Investments Ltd.", verified: true,
                                askPricePer100: ask, availableFace: face, minLot: minLot,
                                settlement: "T+2 via MI module", status: .inReview))
                        }
                        dismiss()
                    }
                    .disabled(instrument == nil)
                }
            }
            .navigationTitle("List a bond")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPicker) { InstrumentPickerView(selected: $instrument) }
        }
    }
}

struct FMRequestsInboxView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(app.inboundRequests) { r in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                Circle().fill(BT.gold).frame(width: 44, height: 44)
                                    .overlay(Text(String(r.investorName.prefix(1)))
                                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(BT.cream))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(r.investorName).font(.system(size: 14, weight: .semibold))
                                    Text("\(Format.taka(r.amount)) maturing \(Format.date(r.maturesOn))")
                                        .font(.system(size: 12)).foregroundStyle(BT.sub)
                                }
                                Spacer()
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "target").font(.system(size: 11)).foregroundStyle(BT.green)
                                Text(prefs(r)).font(.system(size: 11.5, weight: .medium))
                            }
                            .padding(8).frame(maxWidth: .infinity, alignment: .leading)
                            .background(BT.bg).clipShape(RoundedRectangle(cornerRadius: 10))
                            HStack(spacing: 8) {
                                Button("Propose allocation") {}
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.vertical, 10).padding(.horizontal, 16)
                                    .background(BT.green).foregroundStyle(BT.cream)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                Button("Message") {}
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.vertical, 10).padding(.horizontal, 16)
                                    .foregroundStyle(BT.green)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(BT.green, lineWidth: 1.2))
                            }
                        }
                        .card()
                    }
                }
                .padding(20)
            }
            .background(BT.bg)
            .navigationTitle("Requests")
        }
    }

    private func prefs(_ r: ReallocationRequest) -> String {
        let tenors = r.preferredTenors.isEmpty ? "Any tenor"
            : "Prefers " + r.preferredTenors.map { "\($0)Y" }.joined(separator: " / ")
        let yield = r.targetYield.map { " · target ≥ " + Format.percent($0) } ?? ""
        return tenors + yield
    }
}

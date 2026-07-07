import SwiftUI

/// Secondary market: listings from verified fund managers, with ISIN,
/// tenor / yield / lot filters and yield sorting.
struct MarketView: View {
    @EnvironmentObject var app: AppState

    @State private var query = ""
    @State private var tenor: Int?
    @State private var minYield: Double = 0
    @State private var maxLot: Double?
    @State private var showFilters = false

    private var filtered: [MarketListing] {
        var pool = app.listings
        if let tenor { pool = pool.filter { $0.instrument.tenorYears == tenor } }
        if minYield > 0 { pool = pool.filter { $0.impliedYTM >= minYield } }
        if let maxLot { pool = pool.filter { $0.minLot <= maxLot } }
        let q = query.trimmingCharacters(in: .whitespaces).uppercased()
        if !q.isEmpty {
            pool = pool.filter {
                $0.instrument.isin.contains(q) || $0.instrument.name.uppercased().contains(q)
                || $0.institution.uppercased().contains(q)
            }
        }
        return pool.sorted { $0.impliedYTM > $1.impliedYTM }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    filterRow
                    HStack {
                        Text("\(filtered.count) listings · verified fund managers")
                            .font(.system(size: 11.5, weight: .medium)).foregroundStyle(BT.sub)
                        Spacer()
                        Text("Sort: Yield ↓")
                            .font(.system(size: 11.5, weight: .semibold)).foregroundStyle(BT.green2)
                    }
                    ForEach(filtered) { listing in
                        NavigationLink(destination: ListingDetailView(listing: listing)) {
                            ListingCard(listing: listing)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(BT.bg)
            .searchable(text: $query, prompt: "Search ISIN, tenor, coupon…")
            .navigationTitle("Secondary market")
            .sheet(isPresented: $showFilters) {
                FilterSheet(tenor: $tenor, minYield: $minYield, maxLot: $maxLot)
                    .presentationDetents([.medium])
            }
        }
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button { showFilters = true } label: {
                    Label("Filters", systemImage: "slider.horizontal.3")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.vertical, 7).padding(.horizontal, 13)
                        .foregroundStyle(BT.green)
                        .overlay(Capsule().stroke(BT.green, lineWidth: 1))
                }
                chip("All", isOn: tenor == nil) { tenor = nil }
                ForEach([5, 10, 15, 20], id: \.self) { t in
                    chip("\(t)Y", isOn: tenor == t) { tenor = t }
                }
                chip("Yield ≥ 11.5%", isOn: minYield > 0) {
                    minYield = minYield > 0 ? 0 : 0.115
                }
            }
        }
    }

    private func chip(_ label: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 12, weight: .medium))
                .padding(.vertical, 7).padding(.horizontal, 13)
                .background(isOn ? BT.green : BT.paper)
                .foregroundStyle(isOn ? BT.cream : BT.ink)
                .clipShape(Capsule())
        }
    }
}

struct ListingCard: View {
    let listing: MarketListing

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(listing.instrument.name).font(.system(size: 14.5, weight: .semibold))
                    HStack(spacing: 5) {
                        Text("ISIN").font(.system(size: 9.5, weight: .bold)).foregroundStyle(BT.sub)
                        Text(listing.instrument.isin)
                            .font(.system(size: 11.5, weight: .medium)).foregroundStyle(BT.green2)
                    }
                }
                Spacer()
                Text("\(Format.percent(listing.impliedYTM)) YTM")
                    .font(.system(size: 11.5, weight: .semibold)).foregroundStyle(BT.green)
                    .padding(.vertical, 4).padding(.horizontal, 9)
                    .background(BT.mint).clipShape(RoundedRectangle(cornerRadius: 8))
            }
            HStack(spacing: 8) {
                Image(systemName: "building.columns").font(.system(size: 11)).foregroundStyle(BT.sub)
                Text("\(listing.institution) · \(listing.sellerName)")
                    .font(.system(size: 12)).foregroundStyle(BT.sub)
                if listing.verified {
                    Text("✓ Verified").font(.system(size: 10, weight: .semibold))
                        .padding(.vertical, 2).padding(.horizontal, 7)
                        .background(BT.paper).foregroundStyle(BT.green2)
                        .clipShape(Capsule())
                }
            }
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ask ৳\(String(format: "%.2f", listing.askPricePer100)) per ৳100")
                        .font(.system(size: 12.5, weight: .semibold))
                    Text("\(Format.taka(listing.minLot)) min")
                        .font(.system(size: 11)).foregroundStyle(BT.sub)
                }
                Spacer()
                Text("Contact FM")
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.vertical, 10).padding(.horizontal, 16)
                    .background(BT.green).foregroundStyle(BT.cream)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .card()
    }
}

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var tenor: Int?
    @Binding var minYield: Double
    @Binding var maxLot: Double?

    var body: some View {
        NavigationStack {
            Form {
                Section("Tenor") {
                    Picker("Tenor", selection: $tenor) {
                        Text("Any").tag(Int?.none)
                        ForEach([2, 5, 10, 15, 20], id: \.self) { Text("\($0)Y").tag(Int?.some($0)) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Minimum yield (YTM)") {
                    Slider(value: $minYield, in: 0...0.13, step: 0.0025)
                    Text(minYield == 0 ? "Any" : "≥ " + Format.percent(minYield))
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(BT.green2)
                }
                Section("Maximum lot size") {
                    Picker("Max lot", selection: $maxLot) {
                        Text("Any").tag(Double?.none)
                        Text("≤ ৳2L").tag(Double?.some(200_000))
                        Text("≤ ৳5L").tag(Double?.some(500_000))
                        Text("≤ ৳10L").tag(Double?.some(1_000_000))
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") { tenor = nil; minYield = 0; maxLot = nil }
                }
            }
        }
    }
}

struct ListingDetailView: View {
    let listing: MarketListing
    @State private var contacted = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(listing.instrument.name).font(.system(size: 17, weight: .bold))
                        Spacer()
                        Text("\(Format.percent(listing.impliedYTM)) YTM")
                            .font(.system(size: 12, weight: .semibold)).foregroundStyle(BT.green)
                            .padding(.vertical, 5).padding(.horizontal, 10)
                            .background(BT.mint).clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    Text("ISIN \(listing.instrument.isin) · Semi-annual coupon")
                        .font(.system(size: 11.5)).foregroundStyle(BT.sub)
                    Divider()
                    kv("Ask price", "৳\(String(format: "%.2f", listing.askPricePer100)) per ৳100")
                    kv("Available face value", Format.taka(listing.availableFace))
                    kv("Minimum lot", Format.taka(listing.minLot))
                    kv("Settlement", listing.settlement)
                }
                .card()

                Text("Listed by").font(.system(size: 14, weight: .semibold))
                HStack(spacing: 12) {
                    Circle().fill(BT.green).frame(width: 44, height: 44)
                        .overlay(Text(String(listing.sellerName.prefix(1)))
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(BT.cream))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(listing.sellerName).font(.system(size: 14.5, weight: .semibold))
                        Text("Fund Manager · \(listing.institution)")
                            .font(.system(size: 12)).foregroundStyle(BT.sub)
                        Text("✓ Verified by Super Admin")
                            .font(.system(size: 10.5, weight: .semibold)).foregroundStyle(BT.green2)
                    }
                    Spacer()
                }
                .card()

                Button("✉  Contact fund manager") { contacted = true }
                    .buttonStyle(PrimaryButton())
            }
            .padding(20)
        }
        .background(BT.bg)
        .navigationTitle("Listing")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Message sent", isPresented: $contacted) {
            Button("OK") {}
        } message: {
            Text("\(listing.sellerName) at \(listing.institution) typically replies within ~2h. You'll be notified in Requests.")
        }
    }

    private func kv(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key).font(.system(size: 13)).foregroundStyle(BT.sub)
            Spacer()
            Text(value).font(.system(size: 13.5, weight: .semibold))
        }
    }
}

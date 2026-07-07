import SwiftUI

/// Searchable ISIN dropdown backed by the locally cached BB bond master.
/// Matching is prefix + fuzzy across ISIN, tenor, coupon and maturity year.
struct InstrumentPickerView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: BondInstrument?

    @State private var query = ""
    @State private var tenorFilter: Int?

    private var results: [BondInstrument] {
        var pool = app.bondMaster
        if let tenorFilter { pool = pool.filter { $0.tenorYears == tenorFilter } }
        let q = query.trimmingCharacters(in: .whitespaces).uppercased()
        guard !q.isEmpty else { return pool }
        return pool.filter { inst in
            inst.isin.uppercased().contains(q)
            || inst.name.uppercased().contains(q)
            || "\(inst.tenorYears)Y".contains(q)
            || Format.percent(inst.couponRate).contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Search by ISIN, tenor, coupon or year — e.g. “BD0933”, “10Y”, “11.60”")
                    .font(.system(size: 10.5)).foregroundStyle(BT.sub)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        chip("All", isOn: tenorFilter == nil) { tenorFilter = nil }
                        ForEach([2, 5, 10, 15, 20], id: \.self) { t in
                            chip("\(t)Y", isOn: tenorFilter == t) { tenorFilter = t }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                HStack {
                    Text("\(results.count) match\(results.count == 1 ? "" : "es")")
                        .font(.system(size: 11.5, weight: .semibold))
                    Spacer()
                    Label("BB bond master · synced 2 min ago", systemImage: "circle.fill")
                        .font(.system(size: 10.5)).foregroundStyle(BT.sub)
                }
                .padding(.horizontal, 20)

                List(results) { inst in
                    Button {
                        selected = inst
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                highlightedISIN(inst.isin)
                                Text("\(inst.name) · matures \(Format.date(inst.maturityDate))")
                                    .font(.system(size: 11.5)).foregroundStyle(BT.sub)
                            }
                            Spacer()
                            Text("\(Format.percent(inst.marketYield)) yld")
                                .font(.system(size: 10.5, weight: .semibold)).foregroundStyle(BT.green)
                                .padding(.vertical, 3).padding(.horizontal, 8)
                                .background(BT.paper).clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .listStyle(.plain)
            }
            .padding(.top, 4)
            .background(BT.bg)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "ISIN, tenor, coupon…")
            .navigationTitle("Select instrument")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    /// Bold-green highlight on the portion of the ISIN matching the query.
    private func highlightedISIN(_ isin: String) -> Text {
        let q = query.trimmingCharacters(in: .whitespaces).uppercased()
        guard !q.isEmpty, let range = isin.uppercased().range(of: q) else {
            return Text(isin).font(.system(size: 13.5, weight: .semibold)).foregroundColor(BT.ink)
        }
        let pre = String(isin[..<range.lowerBound])
        let hit = String(isin[range])
        let post = String(isin[range.upperBound...])
        return Text(pre).font(.system(size: 13.5, weight: .semibold)).foregroundColor(BT.ink)
            + Text(hit).font(.system(size: 13.5, weight: .bold)).foregroundColor(BT.green2)
            + Text(post).font(.system(size: 13.5, weight: .semibold)).foregroundColor(BT.ink)
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

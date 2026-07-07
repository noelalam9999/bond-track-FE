import SwiftUI

struct AdminTabView: View {
    var body: some View {
        TabView {
            AdminOverviewView()
                .tabItem { Label("Overview", systemImage: "house") }
        }
    }
}

struct AdminOverviewView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        kpi("Investors", "4,218", "+126 this wk")
                        kpi("Fund managers", "37", "\(app.pendingApprovals.count) pending")
                        kpi("Live listings", "\(app.listings.count)", "৳48 Cr face")
                    }
                    apiHealthCard
                    Text("Pending FM approvals")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    ForEach(app.pendingApprovals) { a in
                        approvalCard(a)
                    }
                }
                .padding(20)
            }
            .background(BT.deep)
            .navigationTitle("Platform overview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    @ViewBuilder
    private var apiHealthCard: some View {
        if let h = app.apiHealth {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Bangladesh Bank yield API")
                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    Spacer()
                    Label(h.operational ? "Operational" : "Degraded", systemImage: "circle.fill")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(h.operational ? Color(hex: 0x5FCB8A) : BT.red)
                }
                HStack {
                    stat("Uptime 30d", Format.percent(h.uptime30d))
                    Spacer()
                    stat("Latency p95", "\(h.latencyP95ms) ms")
                    Spacer()
                    stat("Last sync", h.lastSync.formatted(.relative(presentation: .named)))
                }
            }
            .padding(16)
            .background(Color(hex: 0x1B4634))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func approvalCard(_ a: PendingFMApproval) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Circle().fill(BT.green).frame(width: 44, height: 44)
                    .overlay(Text(String(a.name.prefix(1)))
                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(BT.cream))
                VStack(alignment: .leading, spacing: 2) {
                    Text(a.name).font(.system(size: 14, weight: .semibold))
                    Text("\(a.institution) · \(a.licence)")
                        .font(.system(size: 11.5)).foregroundStyle(BT.sub)
                }
                Spacer()
                if a.docsComplete {
                    Text("Docs 3/3 ✓").font(.system(size: 11, weight: .semibold)).foregroundStyle(BT.up)
                }
            }
            HStack(spacing: 8) {
                actionButton("Approve", bg: BT.mint, fg: BT.up) { remove(a) }
                actionButton("Reject", bg: Color(hex: 0xF7E4DF), fg: BT.red) { remove(a) }
            }
        }
        .card()
    }

    private func remove(_ a: PendingFMApproval) {
        app.pendingApprovals.removeAll { $0.id == a.id }
    }

    private func actionButton(_ label: String, bg: Color, fg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 12.5, weight: .semibold))
                .padding(.vertical, 9).padding(.horizontal, 14)
                .background(bg).foregroundStyle(fg)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func kpi(_ label: String, _ value: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.system(size: 10.5)).foregroundStyle(BT.cream.opacity(0.6))
            Text(value).font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
            Text(detail).font(.system(size: 10, weight: .medium)).foregroundStyle(BT.cream.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(hex: 0x1B4634))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

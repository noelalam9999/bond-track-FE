import SwiftUI

/// First-login experience: setup checklist + guided add-first-bond.
struct EmptyPortfolioView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                checklist
                emptyHero
                LiveYieldStrip()
            }
            .padding(20)
        }
    }

    private var checklist: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Finish setting up").font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("1 of 3 done").font(.system(size: 11.5, weight: .semibold)).foregroundStyle(BT.green2)
            }
            ProgressView(value: 1, total: 3).tint(BT.green)
            row(done: true, "Verify mobile number")
            row(done: false, "Add your first bond")
            row(done: false, "Set coupon payout alerts")
        }
        .card()
    }

    private var emptyHero: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(BT.cream).frame(width: 64, height: 64)
                Text("৳").font(.system(size: 24, weight: .bold)).foregroundStyle(BT.gold)
            }
            Text("No bonds tracked yet").font(.system(size: 16, weight: .semibold))
            Text("Add a bond you hold and we'll build its full coupon calendar, maturity countdown and live yield — automatically.")
                .font(.system(size: 12.5)).foregroundStyle(BT.sub)
                .multilineTextAlignment(.center)
            NavigationLink(destination: AddBondView()) {
                Text("＋  Add your first bond")
            }
            .buttonStyle(PrimaryButton())
            Text("Takes under a minute · just 3 fields")
                .font(.system(size: 11, weight: .medium)).foregroundStyle(BT.sub)
        }
        .padding(.vertical, 12)
        .card()
    }

    private func row(done: Bool, _ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? BT.up : BT.sub)
            Text(text)
                .font(.system(size: 12.5, weight: done ? .regular : .medium))
                .foregroundStyle(done ? BT.sub : BT.ink)
        }
    }
}

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var app: AppState
    @State private var showSignIn = false
    @State private var pendingRole: UserRole = .investor

    var body: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 30)
            ZStack {
                Circle().stroke(BT.gold, lineWidth: 2).frame(width: 78, height: 78)
                Text("৳").font(.system(size: 30, weight: .bold)).foregroundStyle(BT.gold)
            }
            Text("BondTrack")
                .font(.system(size: 32, weight: .bold)).foregroundStyle(BT.cream)
            Text("Track, trade & reinvest Bangladesh\nGovernment Treasury Bonds")
                .multilineTextAlignment(.center)
                .font(.system(size: 14)).foregroundStyle(BT.cream.opacity(0.75))

            VStack(spacing: 10) {
                feature("clock", "Coupon & maturity calendar for every BGTB you hold")
                feature("chart.line.uptrend.xyaxis", "Live yields streamed from the Bangladesh Bank API")
                feature("arrow.left.arrow.right", "Buy bonds listed by verified fund managers")
            }
            .padding(.top, 8)

            Spacer()

            Text("CONTINUE AS")
                .font(.system(size: 11, weight: .semibold)).kerning(2)
                .foregroundStyle(BT.cream.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Investor · Track my bonds") { start(.investor) }
                .buttonStyle(PrimaryButton(fill: BT.gold, foreground: BT.deep))
            Button("Fund Manager · Sell to the market") { start(.fundManager) }
                .buttonStyle(PrimaryButton(fill: BT.green2, foreground: BT.cream))
            Button("Super Admin console →") { start(.superAdmin) }
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(BT.cream.opacity(0.6))
                .padding(.bottom, 10)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BT.green)
        .sheet(isPresented: $showSignIn) {
            SignInView(role: pendingRole)
        }
    }

    private func start(_ role: UserRole) {
        pendingRole = role
        showSignIn = true
    }

    private func feature(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(BT.gold)
            Text(text).font(.system(size: 13)).foregroundStyle(BT.cream.opacity(0.85))
            Spacer()
        }
        .padding(13)
        .background(Color(hex: 0x1B4634))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

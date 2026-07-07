import SwiftUI

@main
struct BondTrackApp: App {
    @StateObject private var app = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
                .tint(BT.green)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        switch app.session {
        case .loggedOut:
            WelcomeView()
        case .investor:
            InvestorTabView()
        case .fundManager:
            FMTabView()
        case .superAdmin:
            AdminTabView()
        }
    }
}

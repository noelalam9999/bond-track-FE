import SwiftUI

struct SignInView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    let role: UserRole

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome back").font(.system(size: 26, weight: .bold)).foregroundStyle(BT.ink)
                Text("Sign in to view your portfolio, coupon calendar and the secondary market.")
                    .font(.system(size: 13.5)).foregroundStyle(BT.sub)

                labelled("Email or mobile") {
                    TextField("you@example.com", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                labelled("Password") {
                    SecureField("••••••••••", text: $password)
                }

                HStack {
                    Text("Use OTP instead").font(.system(size: 12.5, weight: .semibold)).foregroundStyle(BT.green2)
                    Spacer()
                    Text("Forgot password?").font(.system(size: 12.5)).foregroundStyle(BT.sub)
                }

                Button("Sign in") {
                    switch role {
                    case .investor: app.session = .investor
                    case .fundManager: app.session = .fundManager
                    case .superAdmin: app.session = .superAdmin
                    }
                    dismiss()
                }
                .buttonStyle(PrimaryButton())

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("ⓘ Role-based access")
                        .font(.system(size: 12.5, weight: .semibold)).foregroundStyle(BT.green)
                    Text("Fund Manager accounts require institutional onboarding and Super Admin approval before listings go live.")
                        .font(.system(size: 12.5)).foregroundStyle(Color(hex: 0x3C5547))
                }
                .card(fill: BT.mint)
            }
            .padding(20)
            .background(BT.bg)
            .navigationTitle("Sign in")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func labelled<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 12.5, weight: .medium)).foregroundStyle(BT.sub)
            content()
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(BT.line, lineWidth: 1))
        }
    }
}

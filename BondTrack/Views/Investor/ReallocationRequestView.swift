import SwiftUI

/// Broadcast a request to all verified fund managers to reallocate
/// a soon-to-mature holding into new BGTBs.
struct ReallocationRequestView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    let holding: Holding

    @State private var amount: Double = 0
    @State private var tenors: Set<Int> = [10, 15]
    @State private var targetYield: Double = 0.1175
    @State private var note = ""
    @State private var sent = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Put your maturing bond back to work")
                    .font(.system(size: 18, weight: .bold))
                Text("Broadcast a request to verified fund managers to re-allocate your soon-to-mature holdings into new BGTBs.")
                    .font(.system(size: 12.5)).foregroundStyle(BT.sub)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(holding.instrument.name).font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Image(systemName: "smallcircle.filled.circle").foregroundStyle(BT.green)
                    }
                    Text("Matures \(Format.date(holding.instrument.maturityDate)) · in \(holding.daysToMaturity) days · \(Format.taka(holding.faceValue)) face value")
                        .font(.system(size: 11.5)).foregroundStyle(BT.sub)
                }
                .card()
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(BT.green, lineWidth: 1.5))

                VStack(alignment: .leading, spacing: 6) {
                    Text("Amount to reallocate").font(.system(size: 12.5, weight: .medium)).foregroundStyle(BT.sub)
                    TextField("0", value: $amount, format: .number)
                        .keyboardType(.numberPad)
                        .padding(14).background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(BT.line, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred new tenor").font(.system(size: 12.5, weight: .medium)).foregroundStyle(BT.sub)
                    HStack(spacing: 8) {
                        ForEach([5, 10, 15, 20], id: \.self) { t in
                            let on = tenors.contains(t)
                            Button {
                                if on { tenors.remove(t) } else { tenors.insert(t) }
                            } label: {
                                Text("\(t)Y").font(.system(size: 12, weight: .medium))
                                    .padding(.vertical, 7).padding(.horizontal, 13)
                                    .background(on ? BT.green : BT.paper)
                                    .foregroundStyle(on ? BT.cream : BT.ink)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Target yield · \(Format.percent(targetYield))")
                        .font(.system(size: 12.5, weight: .medium)).foregroundStyle(BT.sub)
                    Slider(value: $targetYield, in: 0.10...0.13, step: 0.0025).tint(BT.green)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Note to fund managers").font(.system(size: 12.5, weight: .medium)).foregroundStyle(BT.sub)
                    TextField("Prefer semi-annual coupons…", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                        .padding(14).background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(BT.line, lineWidth: 1))
                }

                Label("Sent to all verified FMs. You'll receive proposals in Requests and can accept one.",
                      systemImage: "info.circle")
                    .font(.system(size: 11.5)).foregroundStyle(Color(hex: 0x3C5547))
                    .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                    .background(BT.mint).clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Send request to fund managers") {
                    app.send(ReallocationRequest(
                        investorName: app.userName,
                        amount: amount == 0 ? holding.faceValue : amount,
                        maturingBond: holding.instrument.name,
                        maturesOn: holding.instrument.maturityDate,
                        preferredTenors: Array(tenors).sorted(),
                        targetYield: targetYield,
                        note: note,
                        expires: .now.addingTimeInterval(86400 * 7)))
                    sent = true
                }
                .buttonStyle(PrimaryButton())
            }
            .padding(20)
        }
        .background(BT.bg)
        .navigationTitle("Reallocation request")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if amount == 0 { amount = holding.faceValue } }
        .alert("Request sent", isPresented: $sent) {
            Button("Done") { dismiss() }
        } message: {
            Text("All verified fund managers have been notified. Proposals will appear in your Requests tab.")
        }
    }
}

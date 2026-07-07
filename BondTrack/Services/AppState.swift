import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {

    let bb: BangladeshBankService = MockBangladeshBankService()

    @Published var session: Session = .loggedOut
    @Published var userName = "Noel Alam"

    // Investor
    @Published var holdings: [Holding] = []
    @Published var liveYields: [Int: Double] = [:]
    @Published var bondMaster: [BondInstrument] = []
    @Published var listings: [MarketListing] = []
    @Published var sentRequests: [ReallocationRequest] = []

    // Fund manager
    @Published var fmApproved = true
    @Published var inboundRequests: [ReallocationRequest] = []

    // Admin
    @Published var pendingApprovals: [PendingFMApproval] = []
    @Published var apiHealth: APIHealth?

    init() {
        Task { await bootstrap() }
    }

    func bootstrap() async {
        bondMaster = (try? await bb.bondMaster()) ?? []
        liveYields = (try? await bb.liveYields()) ?? [:]
        apiHealth = try? await bb.health()
        loadMockContent()
    }

    var portfolioFace: Double { holdings.reduce(0) { $0 + $1.faceValue } }
    var portfolioEquity: Double { holdings.reduce(0) { $0 + $1.openingEquity } }

    var weightedYield: Double {
        guard portfolioFace > 0 else { return 0 }
        return holdings.reduce(0) { $0 + $1.instrument.marketYield * $1.faceValue } / portfolioFace
    }

    var upcomingCoupons: [(Holding, CouponPayment)] {
        holdings.flatMap { h in CouponCalculator.upcoming(for: h).prefix(2).map { (h, $0) } }
            .sorted { $0.1.date < $1.1.date }
    }

    func addHolding(_ h: Holding) {
        holdings.append(h)
    }

    func send(_ request: ReallocationRequest) {
        sentRequests.append(request)
        inboundRequests.append(request)   // demo: appears in FM inbox
    }

    private func loadMockContent() {
        guard let m0 = bondMaster.first(where: { $0.isin == "BD0935072210" }),
              let m1 = bondMaster.first(where: { $0.isin == "BD0940115538" }),
              let m2 = bondMaster.first(where: { $0.isin == "BD0930298417" }) else { return }

        listings = [
            MarketListing(instrument: m0, sellerName: "Sadia Rahman", institution: "IDLC Investments Ltd.",
                          verified: true, askPricePer100: 100.20, availableFace: 5_000_000,
                          minLot: 500_000, settlement: "T+2 via MI module"),
            MarketListing(instrument: m1, sellerName: "F. Karim", institution: "City Bank Capital",
                          verified: true, askPricePer100: 100.55, availableFace: 12_000_000,
                          minLot: 1_000_000, settlement: "T+2 via MI module"),
            MarketListing(instrument: m2, sellerName: "A. Hasan", institution: "Prime Bank Investment PLC",
                          verified: true, askPricePer100: 99.75, availableFace: 3_000_000,
                          minLot: 200_000, settlement: "T+2 via MI module")
        ]

        inboundRequests = [
            ReallocationRequest(investorName: "R. Chowdhury", amount: 800_000,
                                maturingBond: "5Y BGTB 11.18% · 2029",
                                maturesOn: .now.addingTimeInterval(86400 * 57),
                                preferredTenors: [], targetYield: nil,
                                note: "Any tenor · income focus",
                                expires: .now.addingTimeInterval(86400 * 12))
        ]

        pendingApprovals = [
            PendingFMApproval(name: "Sadia Rahman", institution: "IDLC Investments",
                              licence: "MB-042/2019", docsComplete: true),
            PendingFMApproval(name: "M. Kabir", institution: "City Bank Capital",
                              licence: "MB-017/2016", docsComplete: true)
        ]
    }
}

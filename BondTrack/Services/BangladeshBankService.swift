import Foundation

/// Abstraction over the Bangladesh Bank data feed.
/// The app searches a locally cached copy of the bond master (it's small —
/// a few hundred instruments), and refreshes yields periodically.
///
/// Swap `MockBangladeshBankService` for a real HTTP client to go live.
protocol BangladeshBankService {
    func bondMaster() async throws -> [BondInstrument]
    /// Live benchmark yields keyed by tenor in years.
    func liveYields() async throws -> [Int: Double]
    func health() async throws -> APIHealth
}

struct MockBangladeshBankService: BangladeshBankService {

    func bondMaster() async throws -> [BondInstrument] {
        try? await Task.sleep(nanoseconds: 200_000_000) // simulate latency
        return Self.master
    }

    func liveYields() async throws -> [Int: Double] {
        [2: 0.1062, 5: 0.1105, 10: 0.1148, 15: 0.1172, 20: 0.1190]
    }

    func health() async throws -> APIHealth {
        APIHealth(operational: true, uptime30d: 0.9996, latencyP95ms: 240,
                  lastSync: .now.addingTimeInterval(-120))
    }

    static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: y, month: m, day: d))!
    }

    static let master: [BondInstrument] = [
        BondInstrument(isin: "BD0933101126", tenorYears: 10, couponRate: 0.1160,
                       issueDate: date(2023, 3, 14), maturityDate: date(2033, 3, 14), marketYield: 0.1148),
        BondInstrument(isin: "BD0933085537", tenorYears: 10, couponRate: 0.1135,
                       issueDate: date(2023, 1, 9), maturityDate: date(2033, 1, 9), marketYield: 0.1146),
        BondInstrument(isin: "BD0933412209", tenorYears: 15, couponRate: 0.1205,
                       issueDate: date(2018, 11, 22), maturityDate: date(2033, 11, 22), marketYield: 0.1171),
        BondInstrument(isin: "BD0935072210", tenorYears: 10, couponRate: 0.1190,
                       issueDate: date(2025, 5, 4), maturityDate: date(2035, 5, 4), marketYield: 0.1148),
        BondInstrument(isin: "BD0940115538", tenorYears: 15, couponRate: 0.1210,
                       issueDate: date(2025, 2, 17), maturityDate: date(2040, 2, 17), marketYield: 0.1172),
        BondInstrument(isin: "BD0930298417", tenorYears: 5, couponRate: 0.1125,
                       issueDate: date(2025, 8, 30), maturityDate: date(2030, 8, 30), marketYield: 0.1105),
        BondInstrument(isin: "BD0930481058", tenorYears: 5, couponRate: 0.1118,
                       issueDate: date(2024, 6, 12), maturityDate: date(2029, 6, 12), marketYield: 0.1104),
        BondInstrument(isin: "BD0927471021", tenorYears: 2, couponRate: 0.1055,
                       issueDate: date(2025, 10, 1), maturityDate: date(2027, 10, 1), marketYield: 0.1062),
        BondInstrument(isin: "BD0945220037", tenorYears: 20, couponRate: 0.1230,
                       issueDate: date(2025, 9, 8), maturityDate: date(2045, 9, 8), marketYield: 0.1190)
    ]
}

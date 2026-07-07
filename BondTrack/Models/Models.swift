import Foundation

// MARK: - Roles & session

enum UserRole: String, CaseIterable, Codable {
    case investor, fundManager, superAdmin
}

enum Session {
    case loggedOut
    case investor
    case fundManager
    case superAdmin
}

// MARK: - Bond master (from Bangladesh Bank)

/// One instrument in the Bangladesh Bank bond master. Coupon rate,
/// market yield and maturity date are authoritative from the BB feed
/// and are never entered by the user.
struct BondInstrument: Identifiable, Hashable {
    var id: String { isin }
    let isin: String
    let tenorYears: Int
    let couponRate: Double            // e.g. 0.1160
    let issueDate: Date
    let maturityDate: Date
    var marketYield: Double           // live YTM from BB
    var couponFrequencyMonths: Int = 6

    var name: String {
        "\(tenorYears)Y BGTB \(Format.percent(couponRate, decimals: 2)) · \(Calendar.current.component(.year, from: maturityDate))"
    }
}

// MARK: - Investor holdings

struct Holding: Identifiable {
    let id = UUID()
    let instrument: BondInstrument
    let purchaseDate: Date
    let faceValue: Double
    /// Total settlement paid — includes premium and accrued interest,
    /// typically greater than the bond's primary market (face) value.
    let openingEquity: Double
    /// Tax deducted at source on coupons. Defaults to 10%.
    var tdsRate: Double = 0.10
    let custodian: String?

    var daysToMaturity: Int {
        Calendar.current.dateComponents([.day], from: .now, to: instrument.maturityDate).day ?? 0
    }
}

struct CouponPayment: Identifiable {
    let id = UUID()
    let date: Date
    let gross: Double
    let tds: Double
    let isPaid: Bool
    var net: Double { gross - tds }
}

// MARK: - Secondary market

struct MarketListing: Identifiable {
    let id = UUID()
    let instrument: BondInstrument
    let sellerName: String
    let institution: String
    let verified: Bool
    let askPricePer100: Double
    let availableFace: Double
    let minLot: Double
    let settlement: String
    var status: ListingStatus = .live

    var impliedYTM: Double {
        // Simplified: market yield adjusted by price premium/discount.
        instrument.marketYield + (100 - askPricePer100) / 100 * 0.02 + 0.0038
    }
}

enum ListingStatus: String {
    case live = "Live"
    case inReview = "In review"
    case closed = "Closed"
}

// MARK: - Reallocation requests

struct ReallocationRequest: Identifiable {
    let id = UUID()
    let investorName: String
    let amount: Double
    let maturingBond: String
    let maturesOn: Date
    let preferredTenors: [Int]        // years; empty = any
    let targetYield: Double?
    let note: String
    let expires: Date
}

// MARK: - Admin

struct PendingFMApproval: Identifiable {
    let id = UUID()
    let name: String
    let institution: String
    let licence: String
    let docsComplete: Bool
}

struct APIHealth {
    let operational: Bool
    let uptime30d: Double
    let latencyP95ms: Int
    let lastSync: Date
}

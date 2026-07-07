import Foundation

/// Pure schedule generation: semi-annual coupons from issue date to maturity,
/// TDS applied per payment. Shown to the user at bond-creation time.
enum CouponCalculator {

    static func schedule(for holding: Holding, asOf now: Date = .now) -> [CouponPayment] {
        var payments: [CouponPayment] = []
        let cal = Calendar.current
        let inst = holding.instrument
        let perPeriod = holding.faceValue * inst.couponRate
            * Double(inst.couponFrequencyMonths) / 12.0
        var d = inst.issueDate
        while d < inst.maturityDate {
            guard let next = cal.date(byAdding: .month, value: inst.couponFrequencyMonths, to: d) else { break }
            d = min(next, inst.maturityDate)
            let tds = perPeriod * holding.tdsRate
            payments.append(CouponPayment(date: d, gross: perPeriod, tds: tds, isPaid: d < now))
        }
        return payments
    }

    static func upcoming(for holding: Holding, asOf now: Date = .now) -> [CouponPayment] {
        schedule(for: holding, asOf: now).filter { !$0.isPaid }
    }

    static func netAnnualIncome(for holding: Holding) -> Double {
        holding.faceValue * holding.instrument.couponRate * (1 - holding.tdsRate)
    }
}

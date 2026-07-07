import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}

/// BondTrack design tokens — mirrors the Figma treasury palette.
enum BT {
    static let bg     = Color(hex: 0xF6F4EE)
    static let green  = Color(hex: 0x12382A)
    static let green2 = Color(hex: 0x1C5A40)
    static let deep   = Color(hex: 0x10241B)
    static let gold   = Color(hex: 0xC19A2B)
    static let ink    = Color(hex: 0x161B17)
    static let sub    = Color(hex: 0x68716B)
    static let line   = Color(hex: 0xE3DED1)
    static let mint   = Color(hex: 0xE3EEE6)
    static let cream  = Color(hex: 0xF8F1DD)
    static let paper  = Color(hex: 0xEDE7D8)
    static let red    = Color(hex: 0xA83A2A)
    static let up     = Color(hex: 0x1E7A4C)
}

struct Card: ViewModifier {
    var padding: CGFloat = 16
    var fill: Color = .white
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(BT.line, lineWidth: 1))
    }
}

extension View {
    func card(padding: CGFloat = 16, fill: Color = .white) -> some View {
        modifier(Card(padding: padding, fill: fill))
    }
}

struct PrimaryButton: ButtonStyle {
    var fill: Color = BT.green
    var foreground: Color = BT.cream
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(fill)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct GhostButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(BT.green)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(BT.green, lineWidth: 1.2))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

enum Format {
    /// Bangladeshi lakh/crore digit grouping, e.g. ৳15,00,000
    static func taka(_ value: Double, decimals: Int = 0) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = decimals
        f.groupingSeparator = ","
        let raw = f.string(from: NSNumber(value: value)) ?? "\(value)"
        let parts = raw.split(separator: ".", maxSplits: 1).map(String.init)
        var digits = parts[0].replacingOccurrences(of: ",", with: "")
        var sign = ""
        if digits.hasPrefix("-") { sign = "-"; digits.removeFirst() }
        var grouped = digits
        let chars = Array(digits)
        if chars.count > 3 {
            let last3 = String(chars.suffix(3))
            var head = String(chars.dropLast(3))
            var headGroups: [String] = []
            while head.count > 2 {
                headGroups.insert(String(head.suffix(2)), at: 0)
                head = String(head.dropLast(2))
            }
            if !head.isEmpty { headGroups.insert(head, at: 0) }
            grouped = headGroups.joined(separator: ",") + "," + last3
        }
        let dec = parts.count > 1 ? "." + parts[1] : ""
        return "৳" + sign + grouped + dec
    }

    static func percent(_ value: Double, decimals: Int = 2) -> String {
        String(format: "%.\(decimals)f%%", value * 100)
    }

    static func date(_ d: Date) -> String {
        d.formatted(.dateTime.day().month(.abbreviated).year())
    }
}

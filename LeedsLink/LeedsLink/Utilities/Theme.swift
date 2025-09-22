import SwiftUI

extension Color {
    // Brand Colors
    static let royalBlue = Color(hex: "003399")
    static let goldenYellow = Color(hex: "FFD43B")
    static let neutralGray = Color(hex: "6B7280")
    
    // Semantic Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    
    // Background Colors
    static let cardBackground = Color(UIColor.systemBackground)
    static let screenBackground = Color(UIColor.secondarySystemBackground)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Custom View Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}

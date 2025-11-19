//
//  Color+Extensions.swift
//  Noema
//
//  Created on January 18, 2025.
//

import SwiftUI

extension Color {
    // MARK: - Emotion Colors (Based on Valence/Arousal)

    /// Get color for emotion based on valence and arousal
    public static func forEmotion(valence: Double, arousal: Double) -> Color {
        // Valence: -1 (negative) to 1 (positive)
        // Arousal: -1 (low energy) to 1 (high energy)

        // High arousal, positive valence -> Bright warm colors (joy, excitement)
        if valence > 0 && arousal > 0 {
            let hue = 0.1 + (valence * 0.15) // Yellow to orange range
            let saturation = 0.6 + (arousal * 0.3)
            let brightness = 0.85 + (arousal * 0.15)
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        }

        // Low arousal, positive valence -> Soft warm colors (contentment, peace)
        if valence > 0 && arousal <= 0 {
            let hue = 0.55 + (valence * 0.1) // Blue-green range
            let saturation = 0.3 + (abs(arousal) * 0.2)
            let brightness = 0.7 + (abs(arousal) * 0.2)
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        }

        // High arousal, negative valence -> Intense cool colors (anger, anxiety)
        if valence < 0 && arousal > 0 {
            let hue = 0.0 + (abs(valence) * 0.05) // Red range
            let saturation = 0.7 + (arousal * 0.2)
            let brightness = 0.6 + (arousal * 0.2)
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        }

        // Low arousal, negative valence -> Dark muted colors (sadness, melancholy)
        let hue = 0.6 // Blue range
        let saturation = 0.4 + (abs(arousal) * 0.2)
        let brightness = 0.4 + (abs(arousal) * 0.3)
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    // MARK: - App Theme Colors

    public static let noemaPrimary = Color("NoemaPrimary", bundle: nil)
    public static let noemaSecondary = Color("NoemaSecondary", bundle: nil)
    public static let noemaAccent = Color("NoemaAccent", bundle: nil)

    public static let noemaBackground = Color("NoemaBackground", bundle: nil)
    public static let noemaCardBackground = Color("NoemaCardBackground", bundle: nil)

    public static let noemaTextPrimary = Color("NoemaTextPrimary", bundle: nil)
    public static let noemaTextSecondary = Color("NoemaTextSecondary", bundle: nil)

    // MARK: - Emotion Type Colors

    public static let joyColor = Color(hue: 0.15, saturation: 0.8, brightness: 0.95)
    public static let sadnessColor = Color(hue: 0.6, saturation: 0.6, brightness: 0.5)
    public static let angerColor = Color(hue: 0.0, saturation: 0.85, brightness: 0.75)
    public static let fearColor = Color(hue: 0.8, saturation: 0.7, brightness: 0.6)
    public static let anxietyColor = Color(hue: 0.05, saturation: 0.65, brightness: 0.85)
    public static let contentmentColor = Color(hue: 0.55, saturation: 0.4, brightness: 0.8)
    public static let excitementColor = Color(hue: 0.1, saturation: 0.9, brightness: 1.0)
    public static let peacefulColor = Color(hue: 0.5, saturation: 0.3, brightness: 0.75)

    // MARK: - Gamification Colors

    public static let xpGold = Color(hue: 0.13, saturation: 0.85, brightness: 0.95)
    public static let achievementBronze = Color(hue: 0.08, saturation: 0.65, brightness: 0.7)
    public static let achievementSilver = Color(hue: 0.0, saturation: 0.0, brightness: 0.75)
    public static let achievementGold = Color(hue: 0.13, saturation: 0.85, brightness: 0.95)
    public static let achievementEpic = Color(hue: 0.75, saturation: 0.8, brightness: 0.9)
    public static let achievementLegendary = Color(hue: 0.05, saturation: 0.9, brightness: 1.0)

    // MARK: - Utility Methods

    /// Lighten color by percentage
    public func lighter(by percentage: Double = 0.2) -> Color {
        return self.adjust(brightness: 1 + percentage)
    }

    /// Darken color by percentage
    public func darker(by percentage: Double = 0.2) -> Color {
        return self.adjust(brightness: 1 - percentage)
    }

    /// Adjust color brightness
    private func adjust(brightness: Double) -> Color {
        #if os(iOS)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var currentBrightness: CGFloat = 0
        var alpha: CGFloat = 0

        if UIColor(self).getHue(&hue, saturation: &saturation, brightness: &currentBrightness, alpha: &alpha) {
            return Color(hue: Double(hue), saturation: Double(saturation), brightness: Double(currentBrightness) * brightness, opacity: Double(alpha))
        }
        #endif
        return self
    }

    /// Convert to hex string
    public func toHex() -> String? {
        #if os(iOS)
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        #else
        return nil
        #endif
    }

    /// Initialize from hex string
    public init(hex: String) {
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
            (a, r, g, b) = (255, 0, 0, 0)
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

#if os(iOS)
extension UIColor {
    /// Convert to SwiftUI Color
    public var swiftUIColor: Color {
        return Color(self)
    }
}
#endif

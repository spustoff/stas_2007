//
//  ColorScheme.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct AppColors {
    // Primary colors from specification
    static let primaryBackground = Color(hex: "3e4464")
    static let accentYellow = Color(hex: "fcc418")
    static let accentGreen = Color(hex: "3cc45b")
    
    // Glassmorphism colors
    static let glassBackground = Color.white.opacity(0.1)
    static let glassStroke = Color.white.opacity(0.2)
    static let glassShadow = Color.black.opacity(0.1)
    
    // Text colors
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let tertiaryText = Color.white.opacity(0.5)
    
    // Status colors
    static let successGreen = Color(hex: "3cc45b")
    static let warningYellow = Color(hex: "fcc418")
    static let errorRed = Color(hex: "ff6b6b")
    static let infoBlue = Color(hex: "4ecdc4")
    
    // Category colors
    static let workBlue = Color(hex: "4a90e2")
    static let personalGreen = Color(hex: "3cc45b")
    static let healthRed = Color(hex: "ff6b6b")
    static let learningPurple = Color(hex: "9b59b6")
    static let financeOrange = Color(hex: "f39c12")
    static let otherGray = Color(hex: "95a5a6")
}

extension Color {
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

// Glassmorphism modifier
struct GlassmorphismModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.glassStroke, lineWidth: 1)
                    )
                    .shadow(color: AppColors.glassShadow, radius: 10, x: 0, y: 5)
            )
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

extension View {
    func glassmorphism() -> some View {
        modifier(GlassmorphismModifier())
    }
}

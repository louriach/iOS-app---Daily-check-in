//
//  AppTheme.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct AppTheme {
    // Typography scale
    static let headingFont = Font.system(.title3, design: .monospaced).weight(.medium)
    static let font = Font.system(.subheadline, design: .monospaced)
    static let captionFont = Font.system(.caption, design: .monospaced)
    static let labelFont = Font.system(.caption2, design: .monospaced)

    // Legacy aliases
    static let titleFont = captionFont
    static let headlineFont = captionFont

    // Corner radius scale
    static let cornerRadiusSmall: CGFloat = 10
    static let cornerRadiusMedium: CGFloat = 14
    static let cornerRadiusLarge: CGFloat = 20
    
    // Dark mode colors
    static let backgroundColor = Color(red: 0.05, green: 0.05, blue: 0.05)
    static let surfaceColor = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let primaryTextColor = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let secondaryTextColor = Color(red: 0.6, green: 0.6, blue: 0.6)
    static let accentColor = Color(red: 0.3, green: 0.7, blue: 0.3)
    static let borderColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    // Mood colors (desaturated for minimal aesthetic)
    static let moodRed = Color(red: 0.75, green: 0.4, blue: 0.4)
    static let moodYellow = Color(red: 0.7, green: 0.65, blue: 0.4)
    static let moodGreen = Color(red: 0.4, green: 0.65, blue: 0.5)

    // Mood border colors (unpressed state)
    static let moodRedBorder = Color(hex: "6D3738")
    static let moodYellowBorder = Color(hex: "625935")
    static let moodGreenBorder = Color(hex: "2F5B45")

    // Mood text colors (unpressed state)
    static let moodRedText = Color(hex: "F52B2F")
    static let moodYellowText = Color(hex: "C9A30B")
    static let moodGreenText = Color(hex: "17B968")
    
    // Minimal button style
    static let buttonStyle = MinimalButtonStyle()
}

struct MinimalButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.captionFont)
            .foregroundColor(AppTheme.primaryTextColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                    .fill(AppTheme.surfaceColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                            .stroke(AppTheme.borderColor, lineWidth: 1)
                    )
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct MinimalCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .fill(AppTheme.surfaceColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                            .stroke(AppTheme.borderColor, lineWidth: 1)
                    )
            )
    }
}

extension View {
    func minimalCard() -> some View {
        modifier(MinimalCardStyle())
    }
}


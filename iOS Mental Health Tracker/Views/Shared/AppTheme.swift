//
//  AppTheme.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct AppTheme {
    // Monospaced font - all text uses caption size
    static let font = Font.system(.caption, design: .monospaced)
    static let titleFont = Font.system(.caption, design: .monospaced)
    static let headlineFont = Font.system(.caption, design: .monospaced)
    static let captionFont = Font.system(.caption, design: .monospaced)
    
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
    
    // Minimal button style
    static let buttonStyle = MinimalButtonStyle()
}

struct MinimalButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.font)
            .foregroundColor(AppTheme.primaryTextColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.surfaceColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
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
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.surfaceColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
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


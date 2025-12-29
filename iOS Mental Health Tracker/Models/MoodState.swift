//
//  MoodState.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import Foundation
import SwiftUI

enum MoodState: String, CaseIterable, Identifiable {
    case red = "red"
    case yellow = "yellow"
    case green = "green"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .red:
            return "Poor"
        case .yellow:
            return "Okay"
        case .green:
            return "Good"
        }
    }
    
    var color: Color {
        switch self {
        case .red:
            return Color(red: 0.75, green: 0.4, blue: 0.4)  // Desaturated red
        case .yellow:
            return Color(red: 0.7, green: 0.65, blue: 0.4)   // Desaturated yellow/amber
        case .green:
            return Color(red: 0.4, green: 0.65, blue: 0.5)  // Desaturated green
        }
    }
    
    // Light tint for buttons/backgrounds (10% opacity)
    var lightTint: Color {
        color.opacity(0.1)
    }
    
    // Medium tint for borders/accents (30% opacity)
    var mediumTint: Color {
        color.opacity(0.3)
    }
    
    // Border color for unpressed state
    var borderColor: Color {
        switch self {
        case .red:
            return Color(hex: "6D3738")
        case .yellow:
            return Color(hex: "625935")
        case .green:
            return Color(hex: "2F5B45")
        }
    }
    
    // Text color for unpressed state
    var unpressedTextColor: Color {
        switch self {
        case .red:
            return Color(hex: "F52B2F")
        case .yellow:
            return Color(hex: "C9A30B")
        case .green:
            return Color(hex: "17B968")
        }
    }
    
    var systemImage: String {
        switch self {
        case .red:
            return "circle.fill"
        case .yellow:
            return "circle.fill"
        case .green:
            return "circle.fill"
        }
    }
}


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
        case .red: return AppTheme.moodRed
        case .yellow: return AppTheme.moodYellow
        case .green: return AppTheme.moodGreen
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
        case .red: return AppTheme.moodRedBorder
        case .yellow: return AppTheme.moodYellowBorder
        case .green: return AppTheme.moodGreenBorder
        }
    }

    // Text color for unpressed state
    var unpressedTextColor: Color {
        switch self {
        case .red: return AppTheme.moodRedText
        case .yellow: return AppTheme.moodYellowText
        case .green: return AppTheme.moodGreenText
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


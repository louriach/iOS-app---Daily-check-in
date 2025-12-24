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
            return "Struggling"
        case .yellow:
            return "Okay"
        case .green:
            return "Good"
        }
    }
    
    var color: Color {
        switch self {
        case .red:
            return .red
        case .yellow:
            return .yellow
        case .green:
            return .green
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


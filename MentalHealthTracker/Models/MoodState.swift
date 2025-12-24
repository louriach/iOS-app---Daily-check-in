import SwiftUI

enum MoodState: String, CaseIterable, Codable {
    case red = "red"
    case yellow = "yellow"
    case green = "green"
    
    var color: Color {
        switch self {
        case .red: return Color(red: 1.0, green: 0.23, blue: 0.19)
        case .yellow: return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .green: return Color(red: 0.2, green: 0.78, blue: 0.35)
        }
    }
    
    var displayName: String {
        switch self {
        case .red: return "Struggling"
        case .yellow: return "Okay"
        case .green: return "Good"
        }
    }
}


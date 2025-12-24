//
//  CalendarViewModel.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import Foundation
import CoreData
import Combine

class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var zoomLevel: ZoomLevel = .month
    @Published var entries: [MoodEntry] = []
    @Published var zoomScale: Double = 1.0 // Continuous zoom scale for pinch gesture
    
    enum ZoomLevel: Double, CaseIterable {
        case year = 0.0
        case month = 1.0
        case week = 2.0
        case day = 3.0
        
        var next: ZoomLevel? {
            switch self {
            case .year: return .month
            case .month: return .week
            case .week: return .day
            case .day: return nil
            }
        }
        
        var previous: ZoomLevel? {
            switch self {
            case .year: return nil
            case .month: return .year
            case .week: return .month
            case .day: return .week
            }
        }
    }
    
    func updateZoomLevel(from scale: Double) {
        // Map scale to zoom level with wider thresholds for less sensitivity
        // Scale thresholds (wider ranges for smoother transitions):
        // < 0.5: year (zoomed out)
        // 0.5 - 1.0: month
        // 1.0 - 1.5: week
        // > 1.5: day (zoomed in)
        
        let newLevel: ZoomLevel
        if scale < 0.5 {
            newLevel = .year
        } else if scale < 1.0 {
            newLevel = .month
        } else if scale < 1.5 {
            newLevel = .week
        } else {
            newLevel = .day
        }
        
        // Only update if different to avoid unnecessary animations
        if newLevel != zoomLevel {
            zoomLevel = newLevel
        }
    }
    
    private let dataService: DataService
    
    init(dataService: DataService) {
        self.dataService = dataService
        loadEntries()
    }
    
    func loadEntries() {
        entries = dataService.getAllMoodEntries()
    }
    
    func getMoodEntry(for date: Date) -> MoodEntry? {
        return entries.first { entry in
            guard let entryDate = entry.date else { return false }
            return Calendar.current.isDate(entryDate, inSameDayAs: date)
        }
    }
    
    func getMoodState(for date: Date) -> MoodState? {
        guard let entry = getMoodEntry(for: date),
              let moodString = entry.moodState else {
            return nil
        }
        return MoodState(rawValue: moodString)
    }
}


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
    
    enum ZoomLevel {
        case year
        case month
        case week
        case day
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


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
    @Published var entries: [MoodEntry] = []

    // Day-keyed lookup so getMoodEntry/getMoodState are O(1) instead of O(n)
    private var entriesByDay: [Date: MoodEntry] = [:]

    private let dataService: DataService
    private let calendar = Calendar.current

    init(dataService: DataService) {
        self.dataService = dataService
        loadEntries()
    }

    func loadEntries() {
        entries = dataService.getAllMoodEntries()
        rebuildIndex()
    }

    @MainActor
    func loadEntriesAsync() async {
        // Small delay to allow UI to render first
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        entries = dataService.getAllMoodEntries()
        rebuildIndex()
    }

    func getMoodEntry(for date: Date) -> MoodEntry? {
        entriesByDay[startOfDay(date)]
    }

    func getMoodState(for date: Date) -> MoodState? {
        guard let moodString = getMoodEntry(for: date)?.moodState else { return nil }
        return MoodState(rawValue: moodString)
    }

    // MARK: - Private

    private func rebuildIndex() {
        entriesByDay = Dictionary(
            uniqueKeysWithValues: entries.compactMap { entry in
                guard let date = entry.date else { return nil }
                return (startOfDay(date), entry)
            }
        )
    }

    private func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
}


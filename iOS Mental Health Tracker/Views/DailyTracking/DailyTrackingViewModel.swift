//
//  DailyTrackingViewModel.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import Foundation
import CoreData
import Combine

class DailyTrackingViewModel: ObservableObject {
    @Published var selectedMood: MoodState?
    @Published var textNote: String = ""
    @Published var voiceNoteURL: URL?
    @Published var voiceNoteDuration: Double = 0
    @Published var existingEntry: MoodEntry?
    
    private let dataService: DataService
    
    init(dataService: DataService, date: Date = Date()) {
        self.dataService = dataService
        loadEntry(for: date)
    }
    
    func loadEntry(for date: Date) {
        if let entry = dataService.getMoodEntry(for: date) {
            existingEntry = entry
            selectedMood = MoodState(rawValue: entry.moodState ?? "red")
            textNote = entry.textNote ?? ""
            if let urlString = entry.voiceNoteURL, !urlString.isEmpty {
                voiceNoteURL = URL(fileURLWithPath: urlString)
                voiceNoteDuration = entry.voiceNoteDuration
            } else {
                voiceNoteURL = nil
                voiceNoteDuration = 0
            }
        } else {
            existingEntry = nil
            selectedMood = nil
            textNote = ""
            voiceNoteURL = nil
            voiceNoteDuration = 0
        }
    }
    
    func saveEntry(for date: Date) {
        guard let mood = selectedMood else { return }
        
        let noteText = textNote.count > 240 ? String(textNote.prefix(240)) : textNote
        let voiceURLString = voiceNoteURL?.path
        
        if let entry = existingEntry {
            dataService.updateMoodEntry(
                entry,
                moodState: mood,
                textNote: noteText.isEmpty ? nil : noteText,
                voiceNoteURL: voiceURLString,
                voiceNoteDuration: voiceNoteDuration > 0 ? voiceNoteDuration : nil
            )
        } else {
            dataService.createMoodEntry(
                date: date,
                moodState: mood,
                textNote: noteText.isEmpty ? nil : noteText,
                voiceNoteURL: voiceURLString,
                voiceNoteDuration: voiceNoteDuration > 0 ? voiceNoteDuration : nil
            )
        }
    }
    
}


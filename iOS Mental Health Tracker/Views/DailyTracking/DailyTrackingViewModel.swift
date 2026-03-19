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
            selectedMood = MoodState(rawValue: entry.moodState ?? MoodState.red.rawValue)
            textNote = entry.textNote ?? ""
            if let urlString = entry.voiceNoteURL, !urlString.isEmpty {
                // Resolve against the current Documents directory so paths survive
                // app updates (iOS reassigns the container UUID on each update,
                // invalidating any stored absolute path).
                voiceNoteURL = Self.resolveVoiceNoteURL(from: urlString)
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
        // Store only the filename, not the full path — the container UUID changes
        // on every app update, making absolute paths stale.
        let voiceURLString = voiceNoteURL?.lastPathComponent
        
        if let entry = existingEntry {
            dataService.updateMoodEntry(
                entry,
                moodState: mood,
                textNote: noteText.isEmpty ? nil : noteText,
                voiceNoteURL: voiceURLString,
                voiceNoteDuration: voiceNoteDuration > 0 ? voiceNoteDuration : nil
            )
        } else {
            _ = dataService.createMoodEntry(
                date: date,
                moodState: mood,
                textNote: noteText.isEmpty ? nil : noteText,
                voiceNoteURL: voiceURLString,
                voiceNoteDuration: voiceNoteDuration > 0 ? voiceNoteDuration : nil
            )
        }
    }

    // Rebuild a full URL from whatever is stored — handles both legacy absolute
    // paths and the current bare-filename format.
    static func resolveVoiceNoteURL(from stored: String) -> URL {
        let filename = URL(fileURLWithPath: stored).lastPathComponent
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(filename)
    }
}


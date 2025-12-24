//
//  DataService.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import CoreData
import Foundation
import Combine

class DataService: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func createMoodEntry(date: Date, moodState: MoodState, textNote: String? = nil, voiceNoteURL: String? = nil, voiceNoteDuration: Double? = nil) -> MoodEntry {
        let entry = MoodEntry(context: viewContext)
        // awakeFromInsert sets defaults for id, date (if nil), moodState, createdAt, updatedAt
        // We override the date and moodState with our specific values
        entry.date = date
        entry.moodState = moodState.rawValue
        
        // Optional fields
        if let textNote = textNote {
            entry.textNote = textNote
        }
        if let voiceNoteURL = voiceNoteURL {
            entry.voiceNoteURL = voiceNoteURL
        }
        entry.voiceNoteDuration = voiceNoteDuration ?? 0
        
        // Update timestamps (awakeFromInsert already set them, but ensure they're current)
        let now = Date()
        entry.updatedAt = now

        saveContext()
        return entry
    }
    
    func updateMoodEntry(_ entry: MoodEntry, moodState: MoodState? = nil, textNote: String? = nil, voiceNoteURL: String? = nil, voiceNoteDuration: Double? = nil) {
        if let moodState = moodState {
            entry.moodState = moodState.rawValue
        }
        if let textNote = textNote {
            entry.textNote = textNote
        }
        if let voiceNoteURL = voiceNoteURL {
            entry.voiceNoteURL = voiceNoteURL
        }
        if let voiceNoteDuration = voiceNoteDuration {
            entry.voiceNoteDuration = voiceNoteDuration
        }
        entry.updatedAt = Date()
        
        saveContext()
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) {
        // Delete voice note file if it exists
        if let voiceNoteURL = entry.voiceNoteURL {
            let fileURL = URL(fileURLWithPath: voiceNoteURL)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        viewContext.delete(entry)
        saveContext()
    }
    
    func getMoodEntry(for date: Date) -> MoodEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.fetchLimit = 1
        
        return try? viewContext.fetch(request).first
    }
    
    func getAllMoodEntries() -> [MoodEntry] {
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: false)]
        
        return (try? viewContext.fetch(request)) ?? []
    }
    
    func getMoodEntries(in range: ClosedRange<Date>) -> [MoodEntry] {
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", range.lowerBound as NSDate, range.upperBound as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: true)]
        
        return (try? viewContext.fetch(request)) ?? []
    }
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}


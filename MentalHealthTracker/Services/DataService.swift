import CoreData
import Foundation

class DataService: ObservableObject {
    static let shared = DataService()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MentalHealthTracker")
        
        // Configure CloudKit (optional sync)
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - CRUD Operations
    
    func fetchEntry(for date: Date) -> MoodEntry? {
        let normalizedDate = date.startOfDay()
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", normalizedDate as NSDate)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            return results.first
        } catch {
            print("Error fetching entry: \(error)")
            return nil
        }
    }
    
    func fetchEntries(from startDate: Date, to endDate: Date) -> [MoodEntry] {
        let normalizedStart = startDate.startOfDay()
        let normalizedEnd = endDate.startOfDay()
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", normalizedStart as NSDate, normalizedEnd as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }
    
    func fetchAllEntries() -> [MoodEntry] {
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching all entries: \(error)")
            return []
        }
    }
    
    func saveEntry(moodState: MoodState, textNote: String?, voiceNoteURL: URL?, voiceNoteDuration: Double?) -> MoodEntry? {
        let context = persistentContainer.newBackgroundContext()
        
        return context.performAndWait {
            let normalizedDate = Date().startOfDay()
            
            // Check for existing entry
            let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
            request.predicate = NSPredicate(format: "date == %@", normalizedDate as NSDate)
            request.fetchLimit = 1
            
            let entry: MoodEntry
            if let existing = try? context.fetch(request).first {
                entry = existing
            } else {
                entry = MoodEntry(context: context)
                entry.id = UUID()
                entry.date = normalizedDate
                entry.createdAt = Date()
            }
            
            entry.moodState = moodState.rawValue
            entry.textNote = textNote?.isEmpty == false ? textNote : nil
            entry.voiceNoteURL = voiceNoteURL?.path
            entry.voiceNoteDuration = voiceNoteDuration
            entry.updatedAt = Date()
            
            do {
                try context.save()
                
                // Merge changes to main context
                DispatchQueue.main.async {
                    self.viewContext.refreshAllObjects()
                }
                
                return entry
            } catch {
                print("Error saving entry: \(error)")
                return nil
            }
        }
    }
    
    func updateEntry(_ entry: MoodEntry, moodState: MoodState?, textNote: String?, voiceNoteURL: URL?, voiceNoteDuration: Double?) {
        let context = persistentContainer.newBackgroundContext()
        
        context.performAndWait {
            guard let objectID = entry.objectID.uriRepresentation().absoluteString as String?,
                  let managedEntry = try? context.existingObject(with: entry.objectID) as? MoodEntry else {
                return
            }
            
            if let moodState = moodState {
                managedEntry.moodState = moodState.rawValue
            }
            managedEntry.textNote = textNote?.isEmpty == false ? textNote : nil
            managedEntry.voiceNoteURL = voiceNoteURL?.path
            managedEntry.voiceNoteDuration = voiceNoteDuration
            managedEntry.updatedAt = Date()
            
            do {
                try context.save()
                
                DispatchQueue.main.async {
                    self.viewContext.refreshAllObjects()
                }
            } catch {
                print("Error updating entry: \(error)")
            }
        }
    }
    
    func deleteEntry(_ entry: MoodEntry) {
        let context = persistentContainer.newBackgroundContext()
        
        context.performAndWait {
            guard let managedEntry = try? context.existingObject(with: entry.objectID) as? MoodEntry else {
                return
            }
            
            // Delete voice note file if exists
            if let voiceNotePath = managedEntry.voiceNoteURL {
                let fileURL = URL(fileURLWithPath: voiceNotePath)
                try? FileManager.default.removeItem(at: fileURL)
            }
            
            context.delete(managedEntry)
            
            do {
                try context.save()
                
                DispatchQueue.main.async {
                    self.viewContext.refreshAllObjects()
                }
            } catch {
                print("Error deleting entry: \(error)")
            }
        }
    }
    
    func saveContext() {
        let context = viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}


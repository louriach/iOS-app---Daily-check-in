import Foundation
import SwiftUI
import CoreData

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var zoomLevel: ZoomLevel = .month
    @Published var currentDate: Date = Date()
    @Published var entries: [Date: MoodEntry] = [:]
    @Published var isLoading: Bool = false
    
    private let dataService = DataService.shared
    
    enum ZoomLevel: Int, CaseIterable {
        case year = 0
        case month = 1
        case week = 2
        case day = 3
        
        var displayName: String {
            switch self {
            case .year: return "Year"
            case .month: return "Month"
            case .week: return "Week"
            case .day: return "Day"
            }
        }
    }
    
    init() {
        loadEntriesForCurrentView()
    }
    
    func changeZoomLevel(_ level: ZoomLevel) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            zoomLevel = level
            loadEntriesForCurrentView()
        }
    }
    
    func navigateToDate(_ date: Date) {
        withAnimation {
            currentDate = date
            loadEntriesForCurrentView()
        }
    }
    
    func loadEntriesForCurrentView() {
        isLoading = true
        
        let dateRange: (start: Date, end: Date)
        
        switch zoomLevel {
        case .year:
            dateRange = (currentDate.startOfYear(), currentDate.endOfYear())
        case .month:
            dateRange = (currentDate.startOfMonth(), currentDate.endOfMonth())
        case .week:
            dateRange = (currentDate.startOfWeek(), currentDate.endOfWeek())
        case .day:
            dateRange = (currentDate.startOfDay(), currentDate.startOfDay())
        }
        
        // Fetch entries (already optimized with indexed date field in Core Data)
        // Using async to avoid blocking UI thread
        Task {
            let fetchedEntries = dataService.fetchEntries(from: dateRange.start, to: dateRange.end)
            
            // Convert to dictionary keyed by normalized date
            var entriesDict: [Date: MoodEntry] = [:]
            for entry in fetchedEntries {
                if let entryDate = entry.date {
                    let normalizedDate = entryDate.startOfDay()
                    entriesDict[normalizedDate] = entry
                }
            }
            
            await MainActor.run {
                entries = entriesDict
                isLoading = false
            }
        }
    }
    
    func getEntry(for date: Date) -> MoodEntry? {
        let normalizedDate = date.startOfDay()
        return entries[normalizedDate]
    }
    
    func getMoodColor(for date: Date) -> Color {
        guard let entry = getEntry(for: date),
              let moodStateString = entry.moodState,
              let moodState = MoodState(rawValue: moodStateString) else {
            return .noEntryGray
        }
        return moodState.color
    }
    
    func getHeaderTitle() -> String {
        switch zoomLevel {
        case .year:
            return currentDate.formattedYear()
        case .month:
            return currentDate.formattedMonthYear()
        case .week:
            return currentDate.formattedWeek()
        case .day:
            return currentDate.formattedFullDate()
        }
    }
}


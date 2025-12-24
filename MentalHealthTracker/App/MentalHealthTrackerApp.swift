import SwiftUI

@main
struct MentalHealthTrackerApp: App {
    @StateObject private var dataService = DataService.shared
    @State private var showOnboarding = !NotificationSettings.hasCompletedOnboarding
    @State private var navigateToTracking = false
    
    init() {
        // Configure notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                NotificationTimePickerView(onComplete: {
                    showOnboarding = false
                })
            } else {
                ContentView()
                    .environment(\.managedObjectContext, dataService.viewContext)
            }
        }
    }
}

// MARK: - Content View Router

struct ContentView: View {
    @StateObject private var dataService = DataService.shared
    @State private var selectedView: AppView = .calendar
    
    enum AppView {
        case tracking
        case calendar
    }
    
    var body: some View {
        Group {
            switch selectedView {
            case .tracking:
                DailyTrackingView(onSave: {
                    selectedView = .calendar
                })
            case .calendar:
                CalendarGridView(onSelectDate: { date in
                    // Navigate to tracking view for selected date
                    selectedView = .tracking
                })
            }
        }
        .onAppear {
            // Check if there's an entry for today
            let today = Date().startOfDay()
            if dataService.fetchEntry(for: today) == nil {
                // No entry today, show tracking view
                selectedView = .tracking
            }
        }
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap - navigate to tracking view
        if response.notification.request.identifier == NotificationSettings.notificationIdentifier {
            // Post notification to trigger navigation
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToTracking"), object: nil)
        }
        completionHandler()
    }
}


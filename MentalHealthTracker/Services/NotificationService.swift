import UserNotifications
import Foundation

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private let notificationIdentifier = NotificationSettings.notificationIdentifier
    
    private init() {}
    
    // MARK: - Permissions
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Scheduling
    
    func scheduleDailyNotification() async {
        // Cancel existing notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        
        // Request permission if needed
        let status = await checkAuthorizationStatus()
        if status != .authorized {
            let granted = await requestAuthorization()
            if !granted {
                return
            }
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to check in"
        content.body = "How are you feeling today?"
        content.sound = .default
        content.categoryIdentifier = "MOOD_CHECKIN"
        
        // Create trigger for daily notification
        let components = NotificationSettings.notificationTime
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Daily notification scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    func rescheduleNotification() async {
        await scheduleDailyNotification()
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }
    
    // MARK: - Deep Linking
    
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        // This will be handled by the app delegate/scene delegate
        // The app will navigate to DailyTrackingView when notification is tapped
    }
}


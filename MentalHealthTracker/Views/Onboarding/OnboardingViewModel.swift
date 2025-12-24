import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var selectedTime: Date
    @Published var isSaving = false
    @Published var errorMessage: String?
    
    private let notificationService = NotificationService.shared
    
    init() {
        // Default to 9:00 PM
        let components = NotificationSettings.notificationTime
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour ?? 21
        dateComponents.minute = components.minute ?? 0
        self.selectedTime = calendar.date(from: dateComponents) ?? Date()
    }
    
    func completeOnboarding() async {
        isSaving = true
        errorMessage = nil
        
        // Extract time components
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        // Save to UserDefaults
        NotificationSettings.notificationTime = DateComponents(hour: components.hour, minute: components.minute)
        
        // Request notification permission and schedule
        let granted = await notificationService.requestAuthorization()
        if granted {
            await notificationService.scheduleDailyNotification()
            NotificationSettings.hasCompletedOnboarding = true
        } else {
            // Still mark onboarding as complete, but show in-app reminder option
            NotificationSettings.hasCompletedOnboarding = true
            errorMessage = "Notification permission was denied. You can enable it in Settings."
        }
        
        isSaving = false
    }
}


//
//  NotificationSettings.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import Foundation
import Combine

class NotificationSettings: ObservableObject {
    private let notificationTimeKey = "notificationTime"
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    @Published var notificationTime: Date {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: notificationTimeKey)
        }
    }
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: hasCompletedOnboardingKey)
        }
    }
    
    init() {
        // Default to 9 PM
        let defaultTime = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date()) ?? Date()
        self.notificationTime = UserDefaults.standard.object(forKey: notificationTimeKey) as? Date ?? defaultTime
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
    }
}


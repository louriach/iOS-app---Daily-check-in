//
//  NotificationService.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private let notificationIdentifier = "dailyCheckIn"
    private let yearInReviewIdentifier = "yearInReview"

    /// userInfo key/value that tells the notification delegate where a tap should go
    nonisolated static let destinationKey = "destination"
    nonisolated static let yearInReviewDestination = "yearInReview"

    private init() {}

    /// Repeats every 31 December at 6 PM and deep links to the year-in-review stats.
    func scheduleYearInReviewNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [yearInReviewIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Your year in review"
        content.body = "See how your year went: days checked in and your traffic-light split."
        content.sound = .default
        content.userInfo = [Self.destinationKey: Self.yearInReviewDestination]

        var dateComponents = DateComponents()
        dateComponents.month = 12
        dateComponents.day = 31
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: yearInReviewIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling year in review notification: \(error)")
            }
        }
    }
    
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func scheduleDailyNotification(at time: Date) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "How are you feeling today?"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }
}


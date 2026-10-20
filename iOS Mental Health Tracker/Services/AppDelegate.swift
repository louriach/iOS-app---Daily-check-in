//
//  AppDelegate.swift
//  iOS Mental Health Tracker
//

import UIKit
import UserNotifications

/// Becomes the notification delegate at launch, so taps that cold-launch the app are
/// still routed.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let destination = response.notification.request.content.userInfo[NotificationService.destinationKey] as? String
        guard destination == NotificationService.yearInReviewDestination else { return }
        await MainActor.run {
            AppRouter.shared.openYearInReview()
        }
    }
}

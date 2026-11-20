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

    // Use the completion-handler form on the main actor, not the async form: the async
    // form hops off the main thread before completing, and when a tap cold-launches the
    // app that left the window blank until the app was backgrounded and reopened.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let destination = response.notification.request.content.userInfo[NotificationService.destinationKey] as? String
        if destination == NotificationService.yearInReviewDestination {
            AppRouter.shared.openYearInReview()
        }
        completionHandler()
    }
}

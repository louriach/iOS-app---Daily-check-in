//
//  AppRouter.swift
//  iOS Mental Health Tracker
//

import Foundation
import Combine

/// App-wide navigation state that notification taps can drive.
class AppRouter: ObservableObject {
    static let shared = AppRouter()

    @Published var showStats = false
    @Published var statsYear = Calendar.current.component(.year, from: Date())

    private init() {}

    /// Opens the stats panel. A tap in early January shows the year that just ended.
    func openYearInReview(now: Date = Date()) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        statsYear = calendar.component(.month, from: now) == 1 ? year - 1 : year
        showStats = true
    }
}

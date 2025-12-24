//
//  MoodEntry+Defaults.swift
//  iOS Mental Health Tracker
//
//  Created by Assistant on 24/12/2025.
//

import Foundation
import CoreData

extension MoodEntry {
    @objc public override nonisolated func awakeFromInsert() {
        super.awakeFromInsert()
        let now = Date()
        // Provide defaults for required non-optional fields
        // These are set programmatically since Core Data can't express "now" as a model default
        // Use MainActor.assumeIsolated to access main actor-isolated properties
        MainActor.assumeIsolated {
            if self.id == nil {
                self.id = UUID()
            }
            if self.date == nil {
                self.date = now
            }
            if self.moodState == nil || self.moodState!.isEmpty {
                self.moodState = MoodState.red.rawValue
            }
            if self.createdAt == nil {
                self.createdAt = now
            }
            if self.updatedAt == nil {
                self.updatedAt = now
            }
        }
    }
}

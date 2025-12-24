//
//  NotificationTimePickerView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct NotificationTimePickerView: View {
    @ObservedObject var settings: NotificationSettings
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("When would you like to be reminded to check in?")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                DatePicker("Notification Time", selection: $settings.notificationTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                
                Button(action: {
                    Task {
                        let authorized = await NotificationService.shared.requestAuthorization()
                        if authorized {
                            NotificationService.shared.scheduleDailyNotification(at: settings.notificationTime)
                            settings.hasCompletedOnboarding = true
                            isPresented = false
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


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
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("SET REMINDER TIME")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryTextColor)
                        .tracking(2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    DatePicker("", selection: $settings.notificationTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .font(AppTheme.captionFont)
                        .labelsHidden()
                        .padding()
                        .minimalCard()
                    
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
                        Text("CONTINUE")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.primaryTextColor)
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.accentColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(AppTheme.borderColor, lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: 600) // Center content on iPad, full width on iPhone
            }
            .navigationTitle("SETUP")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .navigationViewStyle(.stack) // Force single column on iPad
        }
    }
}


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
    @State private var showPermissionSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                HStack {
                    Spacer()
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
                            showPermissionSheet = true
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
                    .frame(maxWidth: 600) // Constrain width on iPad
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("SETUP")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .frame(maxWidth: .infinity)
            .sheet(isPresented: $showPermissionSheet) {
                NotificationPermissionSheet(
                    isPresented: $showPermissionSheet,
                    onAccept: {
                        Task {
                            let authorized = await NotificationService.shared.requestAuthorization()
                            if authorized {
                                NotificationService.shared.scheduleDailyNotification(at: settings.notificationTime)
                                settings.hasCompletedOnboarding = true
                                isPresented = false
                            } else {
                                // User declined native permission - show message that notifications are required
                                // For now, we'll still complete onboarding but they won't get notifications
                                // You could show an alert here if you want to be more strict
                                settings.hasCompletedOnboarding = true
                                isPresented = false
                            }
                        }
                    },
                    onDecline: {
                        // User declined - they can't use the app without notifications
                        // You could show an alert here explaining that notifications are required
                        // For now, we'll allow them to continue but they won't get notifications
                        settings.hasCompletedOnboarding = true
                        isPresented = false
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCompactAdaptation(.sheet) // Ensure half-sheet renders on iPad, not a popover
            }
        }
        .frame(maxWidth: .infinity)
    }
}


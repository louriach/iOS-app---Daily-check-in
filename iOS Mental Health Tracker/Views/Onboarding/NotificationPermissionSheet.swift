//
//  NotificationPermissionSheet.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct NotificationPermissionSheet: View {
    @Binding var isPresented: Bool
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Notifications Required")
                    .font(.system(size: 20, design: .monospaced))
                    .foregroundColor(AppTheme.primaryTextColor)
                
                Text("This app requires notifications to send you daily reminders to check in with your mood. Without notifications, you won't receive reminders to track your mental health.")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    isPresented = false
                    onAccept()
                }) {
                    Text("Yes, Enable Notifications")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                        .tracking(2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(AppTheme.surfaceColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(AppTheme.borderColor, lineWidth: 1)
                                )
                        )
                }
                
                Button(action: {
                    isPresented = false
                    onDecline()
                }) {
                    Text("No, Skip")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryTextColor)
                        .tracking(2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: 600) // Center content on iPad
        .background(AppTheme.backgroundColor)
        .preferredColorScheme(.dark)
    }
}


//
//  PulsatingMicView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct PulsatingMicView: View {
    @State private var pulseScale1: CGFloat = 1.0
    @State private var pulseScale2: CGFloat = 1.0
    @State private var pulseScale3: CGFloat = 1.0
    @State private var pulseOpacity1: Double = 0.6
    @State private var pulseOpacity2: Double = 0.6
    @State private var pulseOpacity3: Double = 0.6
    
    var body: some View {
        ZStack {
            // Pulsating circles - three layers
            Circle()
                .stroke(AppTheme.moodRed.opacity(0.4), lineWidth: 2)
                .frame(width: 120, height: 120)
                .scaleEffect(pulseScale1)
                .opacity(pulseOpacity1)
            
            Circle()
                .stroke(AppTheme.moodRed.opacity(0.3), lineWidth: 2)
                .frame(width: 120, height: 120)
                .scaleEffect(pulseScale2)
                .opacity(pulseOpacity2)
            
            Circle()
                .stroke(AppTheme.moodRed.opacity(0.2), lineWidth: 2)
                .frame(width: 120, height: 120)
                .scaleEffect(pulseScale3)
                .opacity(pulseOpacity3)
            
            // Microphone icon
            Image(systemName: "mic.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.moodRed)
        }
        .frame(width: 120, height: 120)
        .onAppear {
            // Animate first circle
            withAnimation(
                Animation.easeOut(duration: 1.2)
                    .repeatForever(autoreverses: false)
            ) {
                pulseScale1 = 1.8
                pulseOpacity1 = 0.0
            }
            
            // Animate second circle with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(
                    Animation.easeOut(duration: 1.2)
                        .repeatForever(autoreverses: false)
                ) {
                    pulseScale2 = 1.8
                    pulseOpacity2 = 0.0
                }
            }
            
            // Animate third circle with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(
                    Animation.easeOut(duration: 1.2)
                        .repeatForever(autoreverses: false)
                ) {
                    pulseScale3 = 1.8
                    pulseOpacity3 = 0.0
                }
            }
        }
    }
}


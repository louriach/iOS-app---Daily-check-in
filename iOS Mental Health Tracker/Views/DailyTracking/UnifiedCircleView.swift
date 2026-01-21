//
//  UnifiedCircleView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct UnifiedCircleView: View {
    let isRecording: Bool
    let isPlaying: Bool
    let hasRecording: Bool
    let recordingDuration: Double
    let playbackTime: Double
    let totalDuration: Double
    let onPlay: () -> Void
    let onStop: (() -> Void)?
    
    @State private var pulseScale1: CGFloat = 1.0
    @State private var pulseScale2: CGFloat = 1.0
    @State private var pulseScale3: CGFloat = 1.0
    @State private var pulseOpacity1: Double = 0.6
    @State private var pulseOpacity2: Double = 0.6
    @State private var pulseOpacity3: Double = 0.6
    
    var body: some View {
        ZStack {
            // Base circle - always present for consistent layout
            // Only show border when there's a saved recording (matches filled note icon style)
            // No border in idle state or during recording
            if hasRecording {
                Circle()
                    .fill(AppTheme.surfaceColor)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.primaryTextColor, lineWidth: 1.5)
                    )
            } else {
                Circle()
                    .fill(AppTheme.surfaceColor)
            }
            
            // Pulsating circles (only when recording or playing)
            if isRecording || isPlaying {
                // First pulsating circle
                Circle()
                    .stroke((isRecording ? AppTheme.moodRed : AppTheme.primaryTextColor).opacity(0.4), lineWidth: 2)
                    .scaleEffect(pulseScale1)
                    .opacity(pulseOpacity1)
                
                // Second pulsating circle
                Circle()
                    .stroke((isRecording ? AppTheme.moodRed : AppTheme.primaryTextColor).opacity(0.3), lineWidth: 2)
                    .scaleEffect(pulseScale2)
                    .opacity(pulseOpacity2)
                
                // Third pulsating circle
                Circle()
                    .stroke((isRecording ? AppTheme.moodRed : AppTheme.primaryTextColor).opacity(0.2), lineWidth: 2)
                    .scaleEffect(pulseScale3)
                    .opacity(pulseOpacity3)
            }
            
            // Content based on state
            if isRecording {
                // Recording: show time inside circle
                Text(String(format: "%.1f", recordingDuration))
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.moodRed)
                    .allowsHitTesting(false)
            } else if hasRecording {
                if isPlaying {
                    // Playing: show stop icon
                    Button(action: {
                        onStop?()
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.primaryTextColor)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                } else {
                    // Recorded but not playing: show play button
                    Button(action: {
                        onPlay()
                    }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.primaryTextColor)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                }
            } else {
                // Idle: show microphone icon
                Image(systemName: "mic.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.secondaryTextColor)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: 120, height: 120)
        .onChange(of: isRecording) { oldValue, newValue in
            if newValue {
                startPulsing()
            } else {
                stopPulsing()
            }
        }
        .onChange(of: isPlaying) { oldValue, newValue in
            if newValue {
                startPulsing()
            } else {
                stopPulsing()
            }
        }
        .onAppear {
            if isRecording || isPlaying {
                startPulsing()
            }
        }
    }
    
    private func startPulsing() {
        // Reset to initial state
        pulseScale1 = 1.0
        pulseScale2 = 1.0
        pulseScale3 = 1.0
        pulseOpacity1 = 0.6
        pulseOpacity2 = 0.6
        pulseOpacity3 = 0.6
        
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
    
    private func stopPulsing() {
        // Stop animations by removing them
        withAnimation(.linear(duration: 0.1)) {
            pulseScale1 = 1.0
            pulseScale2 = 1.0
            pulseScale3 = 1.0
            pulseOpacity1 = 0.0
            pulseOpacity2 = 0.0
            pulseOpacity3 = 0.0
        }
    }
}


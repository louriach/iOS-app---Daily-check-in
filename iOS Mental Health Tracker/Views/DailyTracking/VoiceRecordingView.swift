//
//  VoiceRecordingView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI
import AVFoundation

struct VoiceRecordingView: View {
    @ObservedObject var audioService: AudioRecordingService
    @Binding var recordingURL: URL?
    @Binding var recordingDuration: Double
    @State private var hasPermission = false
    @State private var isPressing = false
    
    var body: some View {
        VStack(spacing: 32) {
            if !hasPermission {
                Button("REQUEST PERMISSION") {
                    Task {
                        hasPermission = await audioService.requestMicrophonePermission()
                    }
                }
                .buttonStyle(MinimalButtonStyle())
            } else {
                VStack(spacing: 24) {
                    if audioService.isRecording {
                        // Recording state with pulsating effect
                        PulsatingMicView()
                        
                        Text(String(format: "%.1f", audioService.recordingDuration))
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.primaryTextColor)
                            .onChange(of: audioService.recordingDuration) { oldValue, newValue in
                                recordingDuration = newValue
                            }
                        
                        Text("RELEASE TO STOP")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                            .tracking(2)
                    } else if let url = recordingURL, FileManager.default.fileExists(atPath: url.path) {
                        // Show existing recording indicator
                        Image(systemName: "waveform")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.primaryTextColor)
                        
                        Text("RECORDING SAVED")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                            .tracking(2)
                    } else {
                        // Idle state - press and hold to record
                        Image(systemName: "mic.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.secondaryTextColor)
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .fill(AppTheme.surfaceColor)
                                    .overlay(
                                        Circle()
                                            .stroke(AppTheme.borderColor, lineWidth: 1)
                                    )
                            )
                            .scaleEffect(isPressing ? 0.95 : 1.0)
                        
                        Text("HOLD TO RECORD")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                            .tracking(2)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressing && !audioService.isRecording {
                                isPressing = true
                                recordingURL = audioService.startRecording()
                            }
                        }
                        .onEnded { _ in
                            isPressing = false
                            if audioService.isRecording {
                                audioService.stopRecording()
                                // Small delay to ensure file is saved
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    recordingURL = audioService.getRecordingURL()
                                    recordingDuration = audioService.recordingDuration
                                }
                            }
                        }
                )
            }
        }
        .padding()
        .onAppear {
            Task {
                hasPermission = await audioService.requestMicrophonePermission()
            }
        }
        .onChange(of: audioService.isRecording) { oldValue, newValue in
            if !newValue {
                isPressing = false
            }
        }
    }
}


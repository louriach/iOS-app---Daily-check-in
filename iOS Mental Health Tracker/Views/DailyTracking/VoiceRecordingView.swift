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
    
    var body: some View {
        VStack(spacing: 20) {
            if !hasPermission {
                Button("REQUEST PERMISSION") {
                    Task {
                        hasPermission = await audioService.requestMicrophonePermission()
                    }
                }
                .buttonStyle(MinimalButtonStyle())
            } else {
                if audioService.isRecording {
                    VStack(spacing: 16) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.moodRed)
                        
                        Text(String(format: "%.1f", audioService.recordingDuration))
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.primaryTextColor)
                            .onChange(of: audioService.recordingDuration) { oldValue, newValue in
                                recordingDuration = newValue
                            }
                        
                        Text("RECORDING...")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                            .tracking(2)
                        
                        Button("STOP") {
                            audioService.stopRecording()
                            recordingURL = audioService.getRecordingURL()
                            recordingDuration = audioService.recordingDuration
                        }
                        .buttonStyle(MinimalButtonStyle())
                        .foregroundColor(AppTheme.moodRed)
                    }
                } else {
                    if let url = recordingURL {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "waveform")
                                Text("RECORDED (\(Int(recordingDuration))S)")
                            }
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                            
                            Button("RECORD AGAIN") {
                                recordingURL = nil
                                recordingDuration = 0
                                recordingURL = audioService.startRecording()
                            }
                            .buttonStyle(MinimalButtonStyle())
                        }
                    } else {
                        Button(action: {
                            recordingURL = audioService.startRecording()
                        }) {
                            HStack {
                                Image(systemName: "mic.fill")
                                Text("RECORD")
                            }
                            .font(AppTheme.headlineFont)
                            .foregroundColor(AppTheme.primaryTextColor)
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.surfaceColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(AppTheme.borderColor, lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                hasPermission = await audioService.requestMicrophonePermission()
            }
        }
    }
}


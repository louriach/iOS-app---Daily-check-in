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
    var onDelete: (() -> Void)?
    
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
                    // Unified circle container - single structure that swaps content based on state
                    let hasRecording = recordingURL != nil && FileManager.default.fileExists(atPath: recordingURL!.path)
                    
                    let circleView = UnifiedCircleView(
                        isRecording: audioService.isRecording,
                        isPlaying: audioService.isPlaying,
                        hasRecording: hasRecording,
                        recordingDuration: audioService.recordingDuration,
                        playbackTime: audioService.playbackTime,
                        totalDuration: recordingDuration,
                        onPlay: {
                            if let url = recordingURL {
                                audioService.playRecording(url: url)
                            }
                        },
                        onStop: {
                            audioService.stopPlayback()
                        }
                    )
                    .frame(width: 120, height: 120)
                    .onChange(of: audioService.recordingDuration) { oldValue, newValue in
                        recordingDuration = newValue
                    }
                    
                    // Apply gesture when idle (to start recording) or during recording (to stop on release)
                    // But NOT when there's a saved recording and we're not recording (so play button works)
                    if !hasRecording || audioService.isRecording {
                        circleView
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
                    } else {
                        circleView
                    }
                    
                    // Always render text area to reserve space and prevent layout shifts
                    // This adapts to accessibility text sizes automatically
                    VStack(spacing: 8) {
                        // Always show text element (instruction or duration)
                        if audioService.isRecording {
                            Text("RELEASE TO STOP")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.secondaryTextColor)
                                .tracking(2)
                                .onChange(of: audioService.recordingDuration) { oldValue, newValue in
                                    recordingDuration = newValue
                                }
                        } else if let url = recordingURL, FileManager.default.fileExists(atPath: url.path) {
                            // Show duration when recording exists
                            HStack(spacing: 4) {
                                Text(audioService.isPlaying ? String(format: "%.1f", audioService.playbackTime) : "0.0")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.primaryTextColor)
                                
                                Text(" / ")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.secondaryTextColor)
                                
                                Text(String(format: "%.1f", recordingDuration))
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.secondaryTextColor)
                            }
                        } else {
                            Text("HOLD TO RECORD")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.secondaryTextColor)
                                .tracking(2)
                        }
                        
                        // Reserve space to keep layout consistent (empty when not needed)
                        Color.clear
                            .frame(height: 44)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
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


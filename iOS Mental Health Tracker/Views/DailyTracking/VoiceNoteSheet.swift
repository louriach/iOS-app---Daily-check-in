//
//  VoiceNoteSheet.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct VoiceNoteSheet: View {
    @ObservedObject var audioService: AudioRecordingService
    @Binding var voiceNoteURL: URL?
    @Binding var voiceNoteDuration: Double
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Recording section
                    VoiceRecordingView(
                        audioService: audioService,
                        recordingURL: $voiceNoteURL,
                        recordingDuration: $voiceNoteDuration
                    )
                    .onChange(of: voiceNoteURL) { oldValue, newValue in
                        // When recording finishes and URL is set, ensure it's saved
                        if let url = newValue, FileManager.default.fileExists(atPath: url.path) {
                            // Recording is complete and saved
                        }
                    }
                    
                    // Playback section (only show if we have an existing recording and not currently recording)
                    if let url = voiceNoteURL,
                       !audioService.isRecording,
                       FileManager.default.fileExists(atPath: url.path) {
                        VStack(spacing: 20) {
                            Divider()
                                .background(AppTheme.borderColor)
                            
                            Text("PLAYBACK")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.secondaryTextColor)
                                .tracking(2)
                            
                            if audioService.isPlaying {
                                VStack(spacing: 16) {
                                    Text(String(format: "%.1f", audioService.playbackTime))
                                        .font(AppTheme.titleFont)
                                        .foregroundColor(AppTheme.primaryTextColor)
                                    
                                    Text("PLAYING...")
                                        .font(AppTheme.captionFont)
                                        .foregroundColor(AppTheme.secondaryTextColor)
                                        .tracking(2)
                                    
                                    Button("STOP") {
                                        audioService.stopPlayback()
                                    }
                                    .buttonStyle(MinimalButtonStyle())
                                }
                            } else {
                                Button(action: {
                                    audioService.playRecording(url: url)
                                }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("PLAY")
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
                            
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("DELETE")
                                }
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.moodRed)
                                .tracking(2)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppTheme.surfaceColor)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(AppTheme.moodRed.opacity(0.5), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding()
                        .minimalCard()
                    }
                }
                .padding()
            }
            .navigationTitle("VOICE NOTE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("DONE") {
                        audioService.stopPlayback()
                        dismiss()
                    }
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.primaryTextColor)
                }
            }
            .preferredColorScheme(.dark)
            .alert("DELETE RECORDING?", isPresented: $showDeleteConfirmation) {
                Button("CANCEL", role: .cancel) { }
                Button("DELETE", role: .destructive) {
                    if let url = voiceNoteURL {
                        audioService.deleteRecording(url: url)
                        voiceNoteURL = nil
                        voiceNoteDuration = 0
                    }
                }
            } message: {
                Text("THIS CANNOT BE UNDONE")
            }
        }
    }
}


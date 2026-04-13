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
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Recording section with integrated playback controls
                    VoiceRecordingView(
                        audioService: audioService,
                        recordingURL: $voiceNoteURL,
                        recordingDuration: $voiceNoteDuration,
                        onDelete: {
                            showDeleteConfirmation = true
                        }
                    )
                }
                .padding()
                .frame(maxWidth: 600) // Center content on iPad, full width on iPhone
            }
            .navigationTitle("Voice note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Delete button in top left (only show if recording exists)
                if let url = voiceNoteURL,
                   !audioService.isRecording,
                   FileManager.default.fileExists(atPath: url.path) {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.moodRed)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        audioService.stopPlayback()
                        dismiss()
                    }
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.primaryTextColor)
                }
            }
            .preferredColorScheme(.dark)
            .navigationViewStyle(.stack) // Force single column on iPad
            .alert("Delete recording?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let url = voiceNoteURL {
                        audioService.deleteRecording(url: url)
                        voiceNoteURL = nil
                        voiceNoteDuration = 0
                    }
                }
            } message: {
                Text("This can't be undone.")
            }
        }
    }
}


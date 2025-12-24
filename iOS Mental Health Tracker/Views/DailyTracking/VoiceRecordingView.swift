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
                Button("Request Microphone Permission") {
                    Task {
                        hasPermission = await audioService.requestMicrophonePermission()
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                if audioService.isRecording {
                    VStack(spacing: 10) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text(String(format: "%.1f", audioService.recordingDuration))
                            .font(.title2)
                            .monospacedDigit()
                            .onChange(of: audioService.recordingDuration) { oldValue, newValue in
                                recordingDuration = newValue
                            }
                        
                        Text("Recording...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Stop Recording") {
                            audioService.stopRecording()
                            recordingURL = audioService.getRecordingURL()
                            recordingDuration = audioService.recordingDuration
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                } else {
                    if let url = recordingURL {
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "waveform")
                                Text("Voice note recorded (\(Int(recordingDuration))s)")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Button("Record Again") {
                                recordingURL = nil
                                recordingDuration = 0
                                recordingURL = audioService.startRecording()
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        Button(action: {
                            recordingURL = audioService.startRecording()
                        }) {
                            HStack {
                                Image(systemName: "mic.fill")
                                Text("Record Voice Note")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
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


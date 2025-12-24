import SwiftUI

struct VoiceRecordingView: View {
    @ObservedObject var viewModel: DailyTrackingViewModel
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isRecording {
                // Recording state
                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            await viewModel.stopRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 60, height: 60)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Stop recording")
                    
                    Text(formatDuration(viewModel.recordingDuration))
                        .font(.title2)
                        .monospacedDigit()
                        .foregroundColor(.primary)
                    
                    Text("Tap to stop")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if let _ = viewModel.voiceNoteURL {
                // Recorded state
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        Button(action: {
                            if isPlaying {
                                viewModel.stopPlayback()
                                isPlaying = false
                            } else {
                                viewModel.playRecording()
                                isPlaying = true
                            }
                        }) {
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel(isPlaying ? "Stop playback" : "Play recording")
                        
                        Button(action: {
                            viewModel.deleteRecording()
                            isPlaying = false
                        }) {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundColor(.red)
                                .frame(width: 50, height: 50)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Delete recording")
                    }
                    
                    if let url = viewModel.voiceNoteURL,
                       let duration = AudioRecordingService.shared.getRecordingDuration(url: url) {
                        Text(formatDuration(duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                // Idle state
                Button(action: {
                    Task {
                        await viewModel.startRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Start recording")
                .accessibilityHint("Record up to 30 seconds")
                
                Text("Tap to record")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .onChange(of: AudioRecordingService.shared.isPlaying) { playing in
            isPlaying = playing
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


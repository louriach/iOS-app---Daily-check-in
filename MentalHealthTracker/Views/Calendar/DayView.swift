import SwiftUI

struct DayView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let date: Date
    let onEdit: () -> Void
    
    private var entry: MoodEntry? {
        viewModel.getEntry(for: date)
    }
    
    private var moodState: MoodState? {
        guard let entry = entry,
              let moodStateString = entry.moodState else {
            return nil
        }
        return MoodState(rawValue: moodStateString)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Date header
            Text(date.formattedFullDate())
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top)
            
            // Mood indicator
            if let moodState = moodState {
                VStack(spacing: 16) {
                    Circle()
                        .fill(moodState.color)
                        .frame(width: 120, height: 120)
                        .shadow(color: moodState.color.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Text(moodState.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.noEntryGray)
                        .frame(width: 120, height: 120)
                    
                    Text("No entry")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 40)
            }
            
            // Note preview
            if let entry = entry {
                VStack(alignment: .leading, spacing: 12) {
                    if let textNote = entry.textNote, !textNote.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(textNote)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                    }
                    
                    if let voiceNotePath = entry.voiceNoteURL {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Voice Note")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "waveform")
                                    .foregroundColor(.accentColor)
                                
                                if let duration = entry.voiceNoteDuration {
                                    Text(formatDuration(duration))
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Edit button
            Button(action: onEdit) {
                Text(entry != nil ? "Edit Entry" : "Add Entry")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
            .accessibilityLabel(entry != nil ? "Edit entry" : "Add entry")
            .accessibilityHint("Tap to \(entry != nil ? "edit" : "add") mood entry for this date")
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: entry != nil)
        }
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


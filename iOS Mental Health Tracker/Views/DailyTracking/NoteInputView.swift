//
//  NoteInputView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct NoteInputView: View {
    @Binding var textNote: String
    @ObservedObject var audioService: AudioRecordingService
    @Binding var voiceNoteURL: URL?
    @Binding var voiceNoteDuration: Double
    @State private var noteType: NoteType = .text
    
    enum NoteType {
        case text
        case voice
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("NOTE")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryTextColor)
                .tracking(2)
            
            Picker("", selection: $noteType) {
                Text("TEXT").tag(NoteType.text)
                Text("VOICE").tag(NoteType.voice)
            }
            .pickerStyle(.segmented)
            .font(AppTheme.captionFont)
            
            if noteType == .text {
                ZStack(alignment: .topLeading) {
                    if textNote.isEmpty {
                        Text("TYPE YOUR NOTE HERE...")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $textNote)
                        .font(AppTheme.font)
                        .foregroundColor(AppTheme.primaryTextColor)
                        .frame(height: 120)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .onChange(of: textNote) { oldValue, newValue in
                            if newValue.count > 240 {
                                textNote = String(newValue.prefix(240))
                            }
                        }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AppTheme.borderColor, lineWidth: 1)
                )
                .background(AppTheme.surfaceColor)
                .cornerRadius(4)
                
                Text("\(textNote.count)/240")
                    .font(AppTheme.captionFont)
                    .foregroundColor(textNote.count > 240 ? AppTheme.moodRed : AppTheme.secondaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                VoiceRecordingView(audioService: audioService, recordingURL: $voiceNoteURL, recordingDuration: $voiceNoteDuration)
            }
        }
        .minimalCard()
    }
}


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
        VStack(alignment: .leading, spacing: 15) {
            Text("Add a note (optional)")
                .font(.headline)
            
            Picker("Note Type", selection: $noteType) {
                Text("Text").tag(NoteType.text)
                Text("Voice").tag(NoteType.voice)
            }
            .pickerStyle(.segmented)
            
            if noteType == .text {
                TextEditor(text: $textNote)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onChange(of: textNote) { newValue in
                        if newValue.count > 240 {
                            textNote = String(newValue.prefix(240))
                        }
                    }
                
                Text("\(textNote.count)/240 characters")
                    .font(.caption)
                    .foregroundColor(textNote.count > 240 ? .red : .secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                VoiceRecordingView(audioService: audioService, recordingURL: $voiceNoteURL, recordingDuration: $voiceNoteDuration)
            }
        }
        .padding()
    }
}


//
//  TrafficLightView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct TrafficLightView<NoteButtons: View>: View {
    @Binding var selectedMood: MoodState?
    let onSelect: (MoodState) -> Void
    let noteButtons: (() -> NoteButtons)?
    
    init(selectedMood: Binding<MoodState?>, onSelect: @escaping (MoodState) -> Void, noteButtons: (() -> NoteButtons)? = nil) {
        self._selectedMood = selectedMood
        self.onSelect = onSelect
        self.noteButtons = noteButtons
    }
    
    init(selectedMood: Binding<MoodState?>, onSelect: @escaping (MoodState) -> Void, @ViewBuilder noteButtons: @escaping () -> NoteButtons) {
        self._selectedMood = selectedMood
        self.onSelect = onSelect
        self.noteButtons = noteButtons
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(MoodState.allCases.reversed()) { mood in
                ZStack(alignment: .trailing) {
                    Button(action: {
                        selectedMood = mood
                        onSelect(mood)
                    }) {
                        HStack {
                            Text(mood.displayName)
                                .font(AppTheme.captionFont)
                                .foregroundColor(mood.unpressedTextColor)
                            
                            Spacer()
                            
                            // Always reserve space for icon buttons to maintain consistent sizing
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 44, height: 44)
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 44, height: 44)
                            }
                            .padding(.trailing, 16)
                            .opacity(selectedMood == mood ? 1 : 0)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(selectedMood == mood ? mood.unpressedTextColor : mood.borderColor, lineWidth: selectedMood == mood ? 2 : 1)
                                )
                        )
                    }
                    
                    if selectedMood == mood, let noteButtons = noteButtons {
                        noteButtons()
                            .padding(.trailing, 16)
                            .padding(.vertical, 20)
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}


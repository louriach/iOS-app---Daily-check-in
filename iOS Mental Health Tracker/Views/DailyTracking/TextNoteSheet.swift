//
//  TextNoteSheet.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct TextNoteSheet: View {
    @Binding var textNote: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("TEXT NOTE")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryTextColor)
                        .tracking(2)
                    
                    ZStack(alignment: .topLeading) {
                        if textNote.isEmpty {
                            Text("TYPE YOUR NOTE HERE...")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.secondaryTextColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                        }
                        
                        TextEditor(text: $textNote)
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.primaryTextColor)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .onChange(of: textNote) { oldValue, newValue in
                                if newValue.count > 240 {
                                    textNote = String(newValue.prefix(240))
                                }
                            }
                    }
                    .frame(minHeight: 200)
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
                }
                .padding()
            }
            .navigationTitle("TEXT NOTE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("DONE") {
                        dismiss()
                    }
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.primaryTextColor)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}


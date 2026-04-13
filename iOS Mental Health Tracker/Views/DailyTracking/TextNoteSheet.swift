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
                    ZStack(alignment: .topLeading) {
                        if textNote.isEmpty {
                            Text("Type your note here…")
                                .font(AppTheme.font)
                                .foregroundColor(AppTheme.secondaryTextColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                        }

                        TextEditor(text: $textNote)
                            .font(AppTheme.font)
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
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                            .stroke(AppTheme.borderColor, lineWidth: 1)
                    )
                    .background(AppTheme.surfaceColor)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                    
                    Text("\(textNote.count)/240")
                        .font(AppTheme.captionFont)
                        .foregroundColor(textNote.count > 240 ? AppTheme.moodRed : AppTheme.secondaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .frame(maxWidth: 600) // Center content on iPad, full width on iPhone
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.primaryTextColor)
                }
            }
            .preferredColorScheme(.dark)
            .navigationViewStyle(.stack) // Force single column on iPad
        }
    }
}


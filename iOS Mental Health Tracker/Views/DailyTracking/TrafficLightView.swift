//
//  TrafficLightView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct TrafficLightView: View {
    @Binding var selectedMood: MoodState?
    let onSelect: (MoodState) -> Void
    
    var body: some View {
        HStack(spacing: 32) {
            ForEach(MoodState.allCases) { mood in
                Button(action: {
                    selectedMood = mood
                    onSelect(mood)
                }) {
                    VStack(spacing: 12) {
                        Circle()
                            .fill(mood.color)
                            .frame(width: 64, height: 64)
                            .overlay(
                                Circle()
                                    .stroke(selectedMood == mood ? AppTheme.primaryTextColor : Color.clear, lineWidth: 2)
                            )
                        
                        Text(mood.displayName)
                            .font(AppTheme.captionFont)
                            .foregroundColor(selectedMood == mood ? AppTheme.primaryTextColor : AppTheme.secondaryTextColor)
                    }
                }
            }
        }
        .padding()
    }
}


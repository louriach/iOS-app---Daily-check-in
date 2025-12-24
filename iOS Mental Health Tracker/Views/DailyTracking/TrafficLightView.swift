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
        VStack(spacing: 20) {
            Text("How are you feeling?")
                .font(.title2)
                .padding(.top)
            
            HStack(spacing: 40) {
                ForEach(MoodState.allCases) { mood in
                    Button(action: {
                        selectedMood = mood
                        onSelect(mood)
                    }) {
                        VStack(spacing: 8) {
                            Circle()
                                .fill(mood.color)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle()
                                        .stroke(selectedMood == mood ? Color.primary : Color.clear, lineWidth: 4)
                                )
                            
                            Text(mood.displayName)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding()
        }
    }
}


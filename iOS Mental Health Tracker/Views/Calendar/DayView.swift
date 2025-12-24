//
//  DayView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct DayView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var selectedDate: Date
    @State private var currentDay: Date = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DayCellView(viewModel: viewModel, date: currentDay, selectedDate: $selectedDate, size: .extraLarge)
                    .padding()
                
                if let entry = viewModel.getMoodEntry(for: currentDay) {
                    VStack(alignment: .leading, spacing: 15) {
                        if let moodString = entry.moodState, let mood = MoodState(rawValue: moodString) {
                            HStack {
                                Circle()
                                    .fill(mood.color)
                                    .frame(width: 30, height: 30)
                                Text(mood.displayName)
                                    .font(.title2)
                            }
                        }
                        
                        if let textNote = entry.textNote, !textNote.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Text Note")
                                    .font(.headline)
                                Text(textNote)
                                    .font(.body)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if let voiceNoteURL = entry.voiceNoteURL, !voiceNoteURL.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Voice Note")
                                    .font(.headline)
                                Text("Duration: \(Int(entry.voiceNoteDuration)) seconds")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if let createdAt = entry.createdAt {
                            Text("Created: \(createdAt, formatter: dateTimeFormatter)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                } else {
                    Text("No entry for this day")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(dayFormatter.string(from: currentDay))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Previous Day") {
                    currentDay = currentDay.addingDays(-1)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next Day") {
                    currentDay = currentDay.addingDays(1)
                }
            }
        }
    }
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()
    
    private let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

struct DayCellView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let date: Date
    @Binding var selectedDate: Date
    let size: CellSize
    
    enum CellSize {
        case small
        case medium
        case large
        case extraLarge
        
        var height: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 50
            case .large: return 100
            case .extraLarge: return 200
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .body
            case .extraLarge: return .title
            }
        }
        
        var dotSize: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 8
            case .large: return 16
            case .extraLarge: return 40
            }
        }
    }
    
    private let calendar = Calendar.current
    
    var body: some View {
        let moodState = viewModel.getMoodState(for: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        
        Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(size.font)
                    .fontWeight(isToday ? .bold : .regular)
                
                if let mood = moodState {
                    Circle()
                        .fill(mood.color)
                        .frame(width: size.dotSize, height: size.dotSize)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: size.dotSize, height: size.dotSize)
                }
            }
            .frame(height: size.height)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}


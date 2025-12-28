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
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    DayCellView(viewModel: viewModel, date: currentDay, selectedDate: $selectedDate, size: .extraLarge)
                        .padding()
                    
                    if let entry = viewModel.getMoodEntry(for: currentDay) {
                        VStack(alignment: .leading, spacing: 16) {
                            if let moodString = entry.moodState, let mood = MoodState(rawValue: moodString) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(mood.color)
                                        .frame(width: 24, height: 24)
                                    Text(mood.displayName.uppercased())
                                        .font(AppTheme.headlineFont)
                                        .foregroundColor(AppTheme.primaryTextColor)
                                        .tracking(2)
                                }
                            }
                            
                            if let textNote = entry.textNote, !textNote.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("NOTE")
                                        .font(AppTheme.captionFont)
                                        .foregroundColor(AppTheme.secondaryTextColor)
                                        .tracking(2)
                                    Text(textNote)
                                        .font(AppTheme.font)
                                        .foregroundColor(AppTheme.primaryTextColor)
                                }
                                .minimalCard()
                            }
                            
                            if let voiceNoteURL = entry.voiceNoteURL, !voiceNoteURL.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VOICE")
                                        .font(AppTheme.captionFont)
                                        .foregroundColor(AppTheme.secondaryTextColor)
                                        .tracking(2)
                                    Text("\(Int(entry.voiceNoteDuration))S")
                                        .font(AppTheme.font)
                                        .foregroundColor(AppTheme.secondaryTextColor)
                                }
                                .minimalCard()
                            }
                            
                            if let createdAt = entry.createdAt {
                                Text("CREATED: \(createdAt, formatter: dateTimeFormatter)")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.secondaryTextColor)
                            }
                        }
                        .padding()
                    } else {
                        Text("NO ENTRY")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                            .tracking(2)
                            .padding()
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(dayFormatter.string(from: currentDay))
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                    
                    Spacer()
                    
                    Text(yearFormatter.string(from: currentDay))
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                }
                .frame(maxWidth: .infinity)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("PREV") {
                    currentDay = currentDay.addingDays(-1)
                }
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryTextColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("NEXT") {
                    currentDay = currentDay.addingDays(1)
                }
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryTextColor)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
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
            case .small: return AppTheme.captionFont
            case .medium: return AppTheme.captionFont
            case .large: return AppTheme.font
            case .extraLarge: return AppTheme.titleFont
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
                    .foregroundColor(isToday ? AppTheme.primaryTextColor : AppTheme.secondaryTextColor)
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
            .background(isSelected ? AppTheme.accentColor.opacity(0.2) : AppTheme.surfaceColor)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isToday ? AppTheme.accentColor : (isSelected ? AppTheme.borderColor : Color.clear), lineWidth: isToday ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}


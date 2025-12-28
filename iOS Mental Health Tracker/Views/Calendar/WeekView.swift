//
//  WeekView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct WeekView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var selectedDate: Date
    @State private var currentWeek: Date = Date()
    
    private let calendar = Calendar.current
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                let days = getDaysInWeek(currentWeek)
                ForEach(days, id: \.self) { date in
                    WeekDayRow(
                        viewModel: viewModel,
                        date: date,
                        selectedDate: $selectedDate
                    )
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(monthFormatter.string(from: currentWeek.startOfWeek))
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                    
                    Spacer()
                    
                    Text(yearFormatter.string(from: currentWeek.startOfWeek))
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                }
                .frame(maxWidth: .infinity)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("PREV") {
                    currentWeek = currentWeek.addingDays(-7)
                }
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryTextColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("NEXT") {
                    currentWeek = currentWeek.addingDays(7)
                }
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryTextColor)
            }
        }
    }
    
    private func getDaysInWeek(_ date: Date) -> [Date] {
        let startOfWeek = date.startOfWeek
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}

struct WeekDayRow: View {
    @ObservedObject var viewModel: CalendarViewModel
    let date: Date
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        let moodState = viewModel.getMoodState(for: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        
        Button(action: {
            selectedDate = date
        }) {
            HStack {
                Text(weekdayFormatter.string(from: date))
                    .font(AppTheme.font)
                    .foregroundColor(AppTheme.primaryTextColor)
                
                Spacer()
                
                Text(dayFormatter.string(from: date))
                    .font(AppTheme.font)
                    .foregroundColor(AppTheme.primaryTextColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Group {
                    if let mood = moodState {
                        mood.color.opacity(0.3)
                    } else {
                        AppTheme.surfaceColor
                    }
                }
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? AppTheme.accentColor : AppTheme.borderColor, lineWidth: isToday ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}


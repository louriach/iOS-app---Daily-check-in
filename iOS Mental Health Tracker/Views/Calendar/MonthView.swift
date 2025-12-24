//
//  MonthView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct MonthDayInfo: Hashable {
    let date: Date?
    let isCurrentMonth: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date?.timeIntervalSince1970 ?? 0)
        hasher.combine(isCurrentMonth)
    }
    
    static func == (lhs: MonthDayInfo, rhs: MonthDayInfo) -> Bool {
        lhs.date == rhs.date && lhs.isCurrentMonth == rhs.isCurrentMonth
    }
}

struct MonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
    
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Month and year header
                HStack {
                    Text(monthFormatter.string(from: currentMonth))
                        .font(AppTheme.font)
                        .foregroundColor(AppTheme.primaryTextColor)
                    
                    Spacer()
                    
                    Text(yearFormatter.string(from: currentMonth))
                        .font(AppTheme.font)
                        .foregroundColor(AppTheme.primaryTextColor)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                // Weekday headers
                HStack(spacing: 0) {
                    ForEach(weekdays, id: \.self) { weekday in
                        Text(weekday)
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Calendar grid
                let days = getDaysInMonth(currentMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(days, id: \.self) { dayInfo in
                        MonthDayCell(
                            viewModel: viewModel,
                            dayInfo: dayInfo,
                            selectedDate: $selectedDate,
                            currentMonth: currentMonth
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(monthFormatter.string(from: currentMonth).uppercased())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("PREV") {
                    currentMonth = currentMonth.addingMonths(-1)
                }
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryTextColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("NEXT") {
                    currentMonth = currentMonth.addingMonths(1)
                }
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryTextColor)
            }
        }
    }
    
    private func getDaysInMonth(_ date: Date) -> [MonthDayInfo] {
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstDay = date.startOfMonth
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysInMonth = range.count
        
        var days: [MonthDayInfo] = []
        
        // Add days from previous month
        let daysBeforeMonth = firstWeekday - 1
        for i in (1...daysBeforeMonth).reversed() {
            if let prevDate = calendar.date(byAdding: .day, value: -i, to: firstDay) {
                days.append(MonthDayInfo(date: prevDate, isCurrentMonth: false))
            } else {
                days.append(MonthDayInfo(date: nil, isCurrentMonth: false))
            }
        }
        
        // Add all days in the current month
        for day in 1...daysInMonth {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(MonthDayInfo(date: dayDate, isCurrentMonth: true))
            }
        }
        
        // Add days from next month to fill the grid (6 rows = 42 cells)
        let remainingCells = 42 - days.count
        for i in 1...remainingCells {
            if let nextDate = calendar.date(byAdding: .day, value: i, to: date.endOfMonth) {
                days.append(MonthDayInfo(date: nextDate, isCurrentMonth: false))
            } else {
                days.append(MonthDayInfo(date: nil, isCurrentMonth: false))
            }
        }
        
        return days
    }
}

struct MonthDayCell: View {
    @ObservedObject var viewModel: CalendarViewModel
    let dayInfo: MonthDayInfo
    @Binding var selectedDate: Date
    let currentMonth: Date
    
    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        if let date = dayInfo.date {
            let moodState = viewModel.getMoodState(for: date)
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            let isToday = calendar.isDateInToday(date)
            let hasEntry = moodState != nil
            
            Button(action: {
                selectedDate = date
            }) {
                Text(dayFormatter.string(from: date))
                    .font(AppTheme.captionFont)
                    .foregroundColor(
                        dayInfo.isCurrentMonth
                            ? (isToday ? AppTheme.primaryTextColor : AppTheme.secondaryTextColor)
                            : AppTheme.secondaryTextColor.opacity(0.5)
                    )
                    .fontWeight(isToday ? .bold : .regular)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        Group {
                            if hasEntry && dayInfo.isCurrentMonth {
                                moodState!.color.opacity(0.3)
                            } else if !dayInfo.isCurrentMonth {
                                AppTheme.surfaceColor.opacity(0.5)
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                isToday ? AppTheme.accentColor : (isSelected ? AppTheme.borderColor : Color.clear),
                                lineWidth: isToday ? 2 : 1
                            )
                    )
            }
            .buttonStyle(.plain)
        } else {
            Color.clear
                .frame(height: 40)
        }
    }
}


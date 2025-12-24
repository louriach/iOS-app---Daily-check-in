//
//  YearView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct YearView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var selectedDate: Date
    @State private var currentYear: Date = Date()
    
    private let calendar = Calendar.current
    private let columnsPerRow = 7 // Days per week
    
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            let days = getAllDaysInYear(currentYear)
            let padding: CGFloat = 8
            let gap: CGFloat = 2
            let availableWidth = geometry.size.width - (padding * 2)
            
            // Calculate dot size to fill horizontal space: (width - gaps) / 7
            let totalGapWidth = gap * CGFloat(columnsPerRow - 1)
            let dotSize = (availableWidth - totalGapWidth) / CGFloat(columnsPerRow)
            
            ScrollView {
                VStack(spacing: gap) {
                    // Group days into rows of 7
                    ForEach(Array(stride(from: 0, to: days.count, by: columnsPerRow)), id: \.self) { rowStart in
                        let rowEnd = min(rowStart + columnsPerRow, days.count)
                        
                        HStack(spacing: gap) {
                            // Add dots for this row
                            ForEach(rowStart..<rowEnd, id: \.self) { dayIndex in
                                YearDot(
                                    viewModel: viewModel,
                                    date: days[dayIndex],
                                    selectedDate: $selectedDate,
                                    dotSize: dotSize
                                )
                                .frame(width: dotSize, height: dotSize)
                            }
                            
                            // Fill remaining cells if row is incomplete
                            if rowEnd - rowStart < columnsPerRow {
                                ForEach(0..<(columnsPerRow - (rowEnd - rowStart)), id: \.self) { _ in
                                    Color.clear
                                        .frame(width: dotSize, height: dotSize)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, padding)
                .padding(.vertical, padding)
            }
        }
        .navigationTitle(yearFormatter.string(from: currentYear))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("PREV") {
                    currentYear = currentYear.addingYears(-1)
                }
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryTextColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("NEXT") {
                    currentYear = currentYear.addingYears(1)
                }
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryTextColor)
            }
        }
    }
    
    private func getAllDaysInYear(_ date: Date) -> [Date] {
        let startOfYear = date.startOfYear
        let year = calendar.component(.year, from: date)
        let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        let daysInYear = isLeapYear ? 366 : 365
        
        return (0..<daysInYear).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfYear)
        }
    }
}

struct YearDot: View {
    @ObservedObject var viewModel: CalendarViewModel
    let date: Date
    @Binding var selectedDate: Date
    let dotSize: CGFloat
    
    private let calendar = Calendar.current
    
    var body: some View {
        let moodState = viewModel.getMoodState(for: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        
        Button(action: {
            selectedDate = date
        }) {
            Circle()
                .fill(
                    moodState?.color ?? AppTheme.borderColor
                )
                .frame(width: dotSize, height: dotSize)
                .overlay(
                    Circle()
                        .stroke(
                            isToday ? AppTheme.accentColor : (isSelected ? AppTheme.primaryTextColor : Color.clear),
                            lineWidth: isToday ? 2 : 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

struct MonthCellView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let monthDate: Date
    @Binding var selectedDate: Date
    var daySize: DayCellView.CellSize = .small
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(monthDate, formatter: monthFormatter)
                .font(daySize == .small ? AppTheme.captionFont : AppTheme.font)
                .foregroundColor(AppTheme.primaryTextColor)
                .fontWeight(.semibold)
            
            let days = getDaysInMonth(monthDate)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: daySize == .small ? 2 : 4), count: 7), spacing: daySize == .small ? 2 : 4) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DayCellView(viewModel: viewModel, date: date, selectedDate: $selectedDate, size: daySize)
                    } else {
                        Color.clear
                            .frame(height: daySize == .small ? 20 : 40)
                    }
                }
            }
        }
        .padding(daySize == .small ? 8 : 12)
        .background(AppTheme.surfaceColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.borderColor, lineWidth: 1)
        )
    }
    
    private func getDaysInMonth(_ date: Date) -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstDay = date.startOfMonth
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysInMonth = range.count
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in the month
        for day in 1...daysInMonth {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(dayDate)
            }
        }
        
        return days
    }
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
}


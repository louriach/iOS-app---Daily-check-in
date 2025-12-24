//
//  MonthView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct MonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            
            // Calendar grid
            let days = getDaysInMonth(currentMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DayCellView(viewModel: viewModel, date: date, selectedDate: $selectedDate, size: .medium)
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
        }
        .navigationTitle(monthYearFormatter.string(from: currentMonth))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Previous") {
                    currentMonth = currentMonth.addingMonths(-1)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next") {
                    currentMonth = currentMonth.addingMonths(1)
                }
            }
        }
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
    
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}


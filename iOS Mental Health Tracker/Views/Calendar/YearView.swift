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
    private let monthsPerRow = 3
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: monthsPerRow), spacing: 10) {
                ForEach(0..<12, id: \.self) { monthIndex in
                    let monthDate = calendar.date(byAdding: .month, value: monthIndex, to: currentYear.startOfYear) ?? currentYear
                    MonthCellView(viewModel: viewModel, monthDate: monthDate, selectedDate: $selectedDate)
                }
            }
            .padding()
        }
        .navigationTitle("\(calendar.component(.year, from: currentYear))")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Previous Year") {
                    currentYear = currentYear.addingYears(-1)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next Year") {
                    currentYear = currentYear.addingYears(1)
                }
            }
        }
    }
}

struct MonthCellView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let monthDate: Date
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(monthDate, formatter: monthFormatter)
                .font(.caption)
                .fontWeight(.semibold)
            
            let days = getDaysInMonth(monthDate)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DayCellView(viewModel: viewModel, date: date, selectedDate: $selectedDate, size: .small)
                    } else {
                        Color.clear
                            .frame(height: 20)
                    }
                }
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
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


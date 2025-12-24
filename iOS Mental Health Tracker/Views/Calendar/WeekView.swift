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
            
            // Week grid
            let days = getDaysInWeek(currentWeek)
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { date in
                    DayCellView(viewModel: viewModel, date: date, selectedDate: $selectedDate, size: .large)
                }
            }
        }
        .navigationTitle(weekRangeFormatter.string(from: currentWeek.startOfWeek))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Previous Week") {
                    currentWeek = currentWeek.addingDays(-7)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next Week") {
                    currentWeek = currentWeek.addingDays(7)
                }
            }
        }
    }
    
    private func getDaysInWeek(_ date: Date) -> [Date] {
        let startOfWeek = date.startOfWeek
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    private let weekRangeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}


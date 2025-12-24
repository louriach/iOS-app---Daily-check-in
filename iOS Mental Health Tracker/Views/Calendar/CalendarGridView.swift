//
//  CalendarGridView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                VStack {
                    Picker("", selection: $viewModel.zoomLevel) {
                        Text("YEAR").tag(CalendarViewModel.ZoomLevel.year)
                        Text("MONTH").tag(CalendarViewModel.ZoomLevel.month)
                        Text("WEEK").tag(CalendarViewModel.ZoomLevel.week)
                        Text("DAY").tag(CalendarViewModel.ZoomLevel.day)
                    }
                    .pickerStyle(.segmented)
                    .font(AppTheme.captionFont)
                    .padding()
                    
                    switch viewModel.zoomLevel {
                    case .year:
                        YearView(viewModel: viewModel, selectedDate: $selectedDate)
                    case .month:
                        MonthView(viewModel: viewModel, selectedDate: $selectedDate)
                    case .week:
                        WeekView(viewModel: viewModel, selectedDate: $selectedDate)
                    case .day:
                        DayView(viewModel: viewModel, selectedDate: $selectedDate)
                    }
                }
            }
            .navigationTitle("CALENDAR")
            .preferredColorScheme(.dark)
            .onAppear {
                viewModel.loadEntries()
            }
        }
    }
}


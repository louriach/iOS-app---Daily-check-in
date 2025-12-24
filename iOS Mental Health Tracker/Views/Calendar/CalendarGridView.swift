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
            VStack {
                Picker("Zoom Level", selection: $viewModel.zoomLevel) {
                    Text("Year").tag(CalendarViewModel.ZoomLevel.year)
                    Text("Month").tag(CalendarViewModel.ZoomLevel.month)
                    Text("Week").tag(CalendarViewModel.ZoomLevel.week)
                    Text("Day").tag(CalendarViewModel.ZoomLevel.day)
                }
                .pickerStyle(.segmented)
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
            .navigationTitle("Calendar")
            .onAppear {
                viewModel.loadEntries()
            }
        }
    }
}


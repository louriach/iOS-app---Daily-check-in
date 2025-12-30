//
//  CalendarGridView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        NavigationView {
            YearView(viewModel: viewModel, selectedDate: $viewModel.selectedDate)
                .background(AppTheme.backgroundColor.ignoresSafeArea())
                .navigationTitle("CALENDAR")
                .preferredColorScheme(.dark)
                .task {
                    // Load entries asynchronously to prevent blocking
                    await viewModel.loadEntriesAsync()
                }
        }
        .navigationViewStyle(.stack) // Force single column on iPad - must be on NavigationView
    }
}


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
        NavigationStack {
            YearView(viewModel: viewModel, selectedDate: $viewModel.selectedDate)
                .background(AppTheme.backgroundColor.ignoresSafeArea())
                .navigationTitle("Calendar")
                .preferredColorScheme(.dark)
                .task {
                    // Load entries asynchronously to prevent blocking
                    await viewModel.loadEntriesAsync()
                }
        }
    }
}


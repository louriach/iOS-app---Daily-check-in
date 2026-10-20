//
//  CalendarGridView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var showStats: Bool
    @Binding var statsYear: Int

    var body: some View {
        // Swipe right on the calendar to reveal the year-in-review stats
        SwipeRevealContainer(isRevealed: $showStats) {
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
        } panel: {
            StatsView(viewModel: viewModel, year: $statsYear) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    showStats = false
                }
            }
        }
    }
}


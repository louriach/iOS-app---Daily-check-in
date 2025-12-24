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
            VStack(spacing: 0) {
                // Calendar view
                Group {
                    switch viewModel.zoomLevel {
                    case .year:
                        YearView(viewModel: viewModel, selectedDate: $viewModel.selectedDate)
                            .transition(.opacity.combined(with: .scale))
                    case .month:
                        MonthView(viewModel: viewModel, selectedDate: $viewModel.selectedDate)
                            .transition(.opacity.combined(with: .scale))
                    case .week:
                        WeekView(viewModel: viewModel, selectedDate: $viewModel.selectedDate)
                            .transition(.opacity.combined(with: .scale))
                    case .day:
                        DayView(viewModel: viewModel, selectedDate: $viewModel.selectedDate)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .id(viewModel.zoomLevel) // Force view refresh on zoom level change
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.zoomLevel)
                
                // Bottom menu
                ZoomLevelMenu(zoomLevel: $viewModel.zoomLevel)
            }
            .background(AppTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("CALENDAR")
            .preferredColorScheme(.dark)
            .onAppear {
                viewModel.loadEntries()
            }
        }
    }
}

struct ZoomLevelMenu: View {
    @Binding var zoomLevel: CalendarViewModel.ZoomLevel
    
    private let levels: [CalendarViewModel.ZoomLevel] = [.day, .week, .month, .year]
    private let levelLabels = ["DAY", "WEEK", "MONTH", "YEAR"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(levels.enumerated()), id: \.element) { index, level in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        zoomLevel = level
                    }
                }) {
                    // Vertical text
                    Text(levelLabels[index])
                        .font(AppTheme.captionFont)
                        .foregroundColor(level == zoomLevel ? AppTheme.primaryTextColor : AppTheme.secondaryTextColor)
                        .tracking(1)
                        .rotationEffect(.degrees(90))
                        .frame(width: 80, height: 40)
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                }
                .buttonStyle(.plain)
            }
        }
        .background(AppTheme.surfaceColor)
        .overlay(
            Rectangle()
                .fill(AppTheme.borderColor)
                .frame(height: 1),
            alignment: .top
        )
    }
}


//
//  ContentView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var notificationSettings = NotificationSettings()
    @State private var selectedTab = 0
    @State private var calendarViewModel: CalendarViewModel?
    
    private var dataService: DataService {
        DataService(viewContext: viewContext)
    }
    
    var body: some View {
        Group {
            if !notificationSettings.hasCompletedOnboarding {
                NotificationTimePickerView(settings: notificationSettings, isPresented: .constant(true))
            } else {
                Group {
                    if let calendarVM = calendarViewModel {
                        TabView(selection: $selectedTab) {
                            DailyTrackingView(
                                dataService: dataService,
                                selectedTab: $selectedTab,
                                calendarViewModel: calendarVM
                            )
                            .tabItem {
                                Label("Check-In", systemImage: "plus.circle")
                            }
                            .tag(0)
                            
                            CalendarGridView(viewModel: calendarVM)
                                .tabItem {
                                    Label("Calendar", systemImage: "calendar")
                                }
                                .tag(1)
                        }
                    } else {
                        // Loading state - initialize calendar view model
                        AppTheme.backgroundColor
                            .ignoresSafeArea()
                            .task {
                                calendarViewModel = CalendarViewModel(dataService: dataService)
                            }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .background(AppTheme.backgroundColor)
        .onAppear {
            if notificationSettings.hasCompletedOnboarding {
                NotificationService.shared.scheduleDailyNotification(at: notificationSettings.notificationTime)
            }
        }
        .task {
            // Initialize calendar view model when view context is available
            if notificationSettings.hasCompletedOnboarding && calendarViewModel == nil {
                calendarViewModel = CalendarViewModel(dataService: dataService)
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

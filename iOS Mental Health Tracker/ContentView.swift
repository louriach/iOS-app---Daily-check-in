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
    
    private var dataService: DataService {
        DataService(viewContext: viewContext)
    }
    
    var body: some View {
        Group {
            if !notificationSettings.hasCompletedOnboarding {
                NotificationTimePickerView(settings: notificationSettings, isPresented: .constant(true))
            } else {
                TabView(selection: $selectedTab) {
                    DailyTrackingView(dataService: dataService)
                        .tabItem {
                            Label("Check-In", systemImage: "plus.circle")
                        }
                        .tag(0)
                    
                    CalendarGridView(viewModel: CalendarViewModel(dataService: dataService))
                        .tabItem {
                            Label("Calendar", systemImage: "calendar")
                        }
                        .tag(1)
                }
            }
        }
        .onAppear {
            if notificationSettings.hasCompletedOnboarding {
                NotificationService.shared.scheduleDailyNotification(at: notificationSettings.notificationTime)
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

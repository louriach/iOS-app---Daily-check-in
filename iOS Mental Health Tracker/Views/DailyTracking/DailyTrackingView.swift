//
//  DailyTrackingView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI
import CoreData

struct DailyTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: DailyTrackingViewModel
    @State private var selectedDate: Date
    @State private var showTextNoteSheet = false
    @State private var showVoiceNoteSheet = false
    @State private var showDatePicker = false
    @StateObject private var audioService = AudioRecordingService()
    @Binding var selectedTab: Int
    @ObservedObject var calendarViewModel: CalendarViewModel
    
    init(date: Date = Date(), dataService: DataService, selectedTab: Binding<Int>, calendarViewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: DailyTrackingViewModel(dataService: dataService, date: date))
        _selectedDate = State(initialValue: Calendar.current.startOfDay(for: date))
        _selectedTab = selectedTab
        self.calendarViewModel = calendarViewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        TrafficLightView(selectedMood: $viewModel.selectedMood) { mood in
                            viewModel.selectedMood = mood
                        }
                        
                        if viewModel.selectedMood != nil {
                            HStack(spacing: 16) {
                                Button(action: {
                                    showTextNoteSheet = true
                                }) {
                                    Image(systemName: viewModel.textNote.isEmpty ? "text.bubble" : "text.bubble.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(viewModel.textNote.isEmpty ? AppTheme.secondaryTextColor : AppTheme.primaryTextColor)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(AppTheme.surfaceColor)
                                                .overlay(
                                                    Circle()
                                                        .stroke(viewModel.textNote.isEmpty ? AppTheme.borderColor : AppTheme.primaryTextColor, lineWidth: viewModel.textNote.isEmpty ? 1 : 1.5)
                                                )
                                        )
                                }
                                
                                Button(action: {
                                    showVoiceNoteSheet = true
                                }) {
                                    Image(systemName: viewModel.voiceNoteURL == nil ? "mic" : "mic.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(viewModel.voiceNoteURL == nil ? AppTheme.secondaryTextColor : AppTheme.primaryTextColor)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(AppTheme.surfaceColor)
                                                .overlay(
                                                    Circle()
                                                        .stroke(viewModel.voiceNoteURL == nil ? AppTheme.borderColor : AppTheme.primaryTextColor, lineWidth: viewModel.voiceNoteURL == nil ? 1 : 1.5)
                                                )
                                        )
                                }
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                viewModel.saveEntry(for: selectedDate)
                                // Navigate to calendar view
                                calendarViewModel.selectedDate = selectedDate
                                calendarViewModel.loadEntries()
                                selectedTab = 1
                            }) {
                                Text("LOG IT")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.primaryTextColor)
                                    .tracking(2)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(AppTheme.surfaceColor)
                                            if let mood = viewModel.selectedMood {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(mood.lightTint)
                                            }
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(viewModel.selectedMood?.mediumTint ?? AppTheme.borderColor, lineWidth: 1)
                                        }
                                    )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(dateFormatter.string(from: selectedDate).uppercased())
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showDatePicker = true
                    }) {
                        Image(systemName: "calendar")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showDatePicker) {
                NavigationView {
                    ZStack {
                        AppTheme.backgroundColor.ignoresSafeArea()
                        
                        VStack {
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .font(AppTheme.captionFont)
                                .labelsHidden()
                                .padding()
                        }
                        .navigationTitle("SELECT DATE")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("DONE") {
                                    showDatePicker = false
                                }
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.primaryTextColor)
                            }
                        }
                        .preferredColorScheme(.dark)
                    }
                }
            }
            .onChange(of: selectedDate) { oldValue, newDate in
                viewModel.loadEntry(for: newDate)
            }
            .sheet(isPresented: $showTextNoteSheet) {
                TextNoteSheet(textNote: $viewModel.textNote)
            }
            .sheet(isPresented: $showVoiceNoteSheet) {
                VoiceNoteSheet(
                    audioService: audioService,
                    voiceNoteURL: $viewModel.voiceNoteURL,
                    voiceNoteDuration: $viewModel.voiceNoteDuration
                )
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyyy"
        return formatter
    }()
}


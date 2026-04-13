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
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                HStack {
                    Spacer()
                    ScrollView {
                        VStack(spacing: 40) {
                            Spacer()

                            Text("How are you feeling?")
                                .font(AppTheme.headingFont)
                                .foregroundColor(AppTheme.primaryTextColor)
                                .padding(.horizontal)
                            
                            // Mood selection - full width, vertical stack
                            TrafficLightView(
                                selectedMood: $viewModel.selectedMood,
                                onSelect: { mood in
                                    viewModel.selectedMood = mood
                                },
                                noteButtons: {
                                    HStack(spacing: 12) {
                                        if let mood = viewModel.selectedMood {
                                            Button(action: {
                                                showTextNoteSheet = true
                                            }) {
                                                Image(systemName: viewModel.textNote.isEmpty ? "text.bubble" : "text.bubble.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(mood.unpressedTextColor)
                                                    .frame(width: 44, height: 44)
                                                    .background(
                                                        Circle()
                                                            .fill(mood.color.opacity(0.2))
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(viewModel.textNote.isEmpty ? mood.borderColor : mood.unpressedTextColor, lineWidth: viewModel.textNote.isEmpty ? 1 : 1.5)
                                                            )
                                                    )
                                            }
                                            
                                            Button(action: {
                                                showVoiceNoteSheet = true
                                            }) {
                                                Image(systemName: viewModel.voiceNoteURL == nil ? "mic" : "mic.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(mood.unpressedTextColor)
                                                    .frame(width: 44, height: 44)
                                                    .background(
                                                        Circle()
                                                            .fill(mood.color.opacity(0.2))
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(viewModel.voiceNoteURL == nil ? mood.borderColor : mood.unpressedTextColor, lineWidth: viewModel.voiceNoteURL == nil ? 1 : 1.5)
                                                            )
                                                    )
                                            }
                                        }
                                    }
                                }
                            )
                            
                            if viewModel.selectedMood != nil {
                                // LOG IT button - centered
                                Button(action: {
                                    viewModel.saveEntry(for: selectedDate)
                                    // Navigate to calendar view
                                    calendarViewModel.selectedDate = selectedDate
                                    calendarViewModel.loadEntries()
                                    selectedTab = 1
                                }) {
                                    Text("Log today's mood")
                                        .font(AppTheme.font)
                                        .foregroundColor(AppTheme.primaryTextColor)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 20)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            ZStack {
                                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                                                    .fill(AppTheme.surfaceColor)
                                                if let mood = viewModel.selectedMood {
                                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                                                        .fill(mood.lightTint)
                                                }
                                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                                                    .stroke(viewModel.selectedMood?.mediumTint ?? AppTheme.borderColor, lineWidth: 1)
                                            }
                                        )
                                }
                                .padding(.horizontal)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    .frame(maxWidth: 600) // Constrain width on iPad
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(dateFormatter.string(from: selectedDate))
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
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationStack {
                ZStack {
                    AppTheme.backgroundColor.ignoresSafeArea()

                    VStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .font(AppTheme.captionFont)
                            .labelsHidden()
                            .padding()
                    }
                }
                .navigationTitle("Select date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showDatePicker = false
                        }
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                    }
                }
                .preferredColorScheme(.dark)
            }
            .presentationDetents([.medium])
            .presentationCompactAdaptation(.sheet) // Ensure half-sheet on iPad, not a popover
        }
        .onChange(of: selectedDate) { oldValue, newDate in
            viewModel.loadEntry(for: newDate)
        }
        .sheet(isPresented: $showTextNoteSheet) {
            TextNoteSheet(textNote: $viewModel.textNote)
                .presentationCompactAdaptation(.sheet) // Ensure sheet on iPad, not a popover
        }
        .sheet(isPresented: $showVoiceNoteSheet) {
            VoiceNoteSheet(
                audioService: audioService,
                voiceNoteURL: $viewModel.voiceNoteURL,
                voiceNoteDuration: $viewModel.voiceNoteDuration
            )
            .presentationCompactAdaptation(.sheet) // Ensure sheet on iPad, not a popover
        }
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyyy"
        return formatter
    }()
}


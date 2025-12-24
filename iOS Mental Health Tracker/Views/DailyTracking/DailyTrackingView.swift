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
    @State private var showNoteInput = false
    @State private var showDatePicker = false
    @StateObject private var audioService = AudioRecordingService()
    
    init(date: Date = Date(), dataService: DataService) {
        _viewModel = StateObject(wrappedValue: DailyTrackingViewModel(dataService: dataService, date: date))
        _selectedDate = State(initialValue: date)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        HStack {
                            Text(dateFormatter.string(from: selectedDate).uppercased())
                                .font(AppTheme.font)
                                .foregroundColor(AppTheme.primaryTextColor)
                            
                            Spacer()
                            
                            Button(action: {
                                showDatePicker = true
                            }) {
                                Image(systemName: "calendar")
                                    .font(AppTheme.font)
                                    .foregroundColor(AppTheme.secondaryTextColor)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(AppTheme.surfaceColor)
                                            .overlay(
                                                Circle()
                                                    .stroke(AppTheme.borderColor, lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .padding()
                        .minimalCard()
                        
                        TrafficLightView(selectedMood: $viewModel.selectedMood) { mood in
                            viewModel.selectedMood = mood
                        }
                        
                        if viewModel.selectedMood != nil {
                            Button(action: {
                                showNoteInput.toggle()
                            }) {
                                HStack {
                                    Text(showNoteInput ? "HIDE NOTE" : "ADD NOTE (OPTIONAL)")
                                        .font(AppTheme.captionFont)
                                        .tracking(1)
                                    Image(systemName: showNoteInput ? "chevron.up" : "chevron.down")
                                        .font(AppTheme.captionFont)
                                }
                                .foregroundColor(AppTheme.secondaryTextColor)
                            }
                            .buttonStyle(MinimalButtonStyle())
                            
                            if showNoteInput {
                                NoteInputView(
                                    textNote: $viewModel.textNote,
                                    audioService: audioService,
                                    voiceNoteURL: $viewModel.voiceNoteURL,
                                    voiceNoteDuration: $viewModel.voiceNoteDuration
                                )
                            }
                            
                            Button(action: {
                                viewModel.saveEntry(for: selectedDate)
                            }) {
                                Text((viewModel.existingEntry != nil ? "UPDATE" : "SAVE").uppercased())
                                    .font(AppTheme.headlineFont)
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
            .navigationTitle("CHECK-IN")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showDatePicker) {
                NavigationView {
                    ZStack {
                        AppTheme.backgroundColor.ignoresSafeArea()
                        
                        VStack {
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .font(AppTheme.font)
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
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
}


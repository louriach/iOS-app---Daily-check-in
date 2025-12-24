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
    @StateObject private var audioService = AudioRecordingService()
    
    init(date: Date = Date(), dataService: DataService) {
        _viewModel = StateObject(wrappedValue: DailyTrackingViewModel(dataService: dataService, date: date))
        _selectedDate = State(initialValue: date)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .onChange(of: selectedDate) { oldValue, newDate in
                            viewModel.loadEntry(for: newDate)
                        }
                    
                    TrafficLightView(selectedMood: $viewModel.selectedMood) { mood in
                        viewModel.selectedMood = mood
                    }
                    
                    if viewModel.selectedMood != nil {
                        Button(action: {
                            showNoteInput.toggle()
                        }) {
                            HStack {
                                Image(systemName: showNoteInput ? "chevron.up" : "chevron.down")
                                Text(showNoteInput ? "Hide Note" : "Add Note (Optional)")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                        }
                        .padding()
                        
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
                            Text(viewModel.existingEntry != nil ? "Update Entry" : "Save Entry")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.selectedMood?.color ?? .gray)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


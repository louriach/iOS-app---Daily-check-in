import SwiftUI

struct DailyTrackingView: View {
    @StateObject private var viewModel: DailyTrackingViewModel
    @Environment(\.managedObjectContext) private var viewContext
    let onSave: () -> Void
    
    init(existingEntry: MoodEntry? = nil, onSave: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: DailyTrackingViewModel(existingEntry: existingEntry))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("How are you feeling today?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .accessibilityAddTraits(.isHeader)
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        
                        Text(Date().formattedDayMonth())
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Today's date: \(Date().formattedDayMonth())")
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    }
                    .padding(.top, 20)
                    
                    // Traffic Light
                    TrafficLightView(selectedMood: $viewModel.selectedMood) { mood in
                        // Selection handled by binding
                    }
                    .padding(.horizontal)
                    
                    // Context Section (appears after selection)
                    if viewModel.selectedMood != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Add context (optional)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if viewModel.noteType == .text {
                                NoteInputView(
                                    noteType: $viewModel.noteType,
                                    textNote: $viewModel.textNote
                                )
                            } else {
                                VoiceRecordingView(viewModel: viewModel)
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    Task {
                        await viewModel.saveEntry()
                        if viewModel.errorMessage == nil {
                            onSave()
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(viewModel.isSaving ? "Saving..." : "Save")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                    .background(viewModel.canSave ? Color.accentColor : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.canSave || viewModel.isSaving)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .accessibilityLabel("Save entry")
                .accessibilityHint(viewModel.canSave ? "Save your mood entry" : "Select a mood to save")
                .accessibilityAddTraits(viewModel.canSave ? [] : .isNotEnabled)
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}


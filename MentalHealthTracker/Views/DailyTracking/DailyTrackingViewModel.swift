import Foundation
import SwiftUI
import CoreData

@MainActor
class DailyTrackingViewModel: ObservableObject {
    @Published var selectedMood: MoodState?
    @Published var noteType: NoteType = .text
    @Published var textNote: String = ""
    @Published var isRecording: Bool = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var voiceNoteURL: URL?
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    
    private let dataService = DataService.shared
    private let audioService = AudioRecordingService.shared
    private var entryID: UUID = UUID()
    private var existingEntry: MoodEntry?
    
    enum NoteType {
        case text
        case voice
    }
    
    init(existingEntry: MoodEntry? = nil) {
        self.existingEntry = existingEntry
        if let entry = existingEntry {
            // Pre-populate with existing data
            if let moodStateString = entry.moodState,
               let moodState = MoodState(rawValue: moodStateString) {
                self.selectedMood = moodState
            }
            self.textNote = entry.textNote ?? ""
            if let voiceNotePath = entry.voiceNoteURL {
                self.voiceNoteURL = URL(fileURLWithPath: voiceNotePath)
                self.noteType = .voice
            } else if !(entry.textNote?.isEmpty ?? true) {
                self.noteType = .text
            }
            if let id = entry.id {
                self.entryID = id
            }
        }
    }
    
    var canSave: Bool {
        selectedMood != nil
    }
    
    var textNoteCharacterCount: Int {
        textNote.count
    }
    
    var isTextNoteValid: Bool {
        textNote.count <= 240
    }
    
    func startRecording() async {
        // Check microphone permission first
        let hasPermission = await audioService.requestMicrophonePermission()
        guard hasPermission else {
            errorMessage = "Microphone permission is required to record voice notes. Please enable it in Settings."
            return
        }
        
        do {
            try await audioService.startRecording(entryID: entryID)
            isRecording = true
            recordingDuration = 0
            
            // Observe recording duration
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                self.recordingDuration = self.audioService.recordingDuration
                
                if !self.isRecording {
                    timer.invalidate()
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            isRecording = false
        }
    }
    
    func stopRecording() async {
        await audioService.stopRecording()
        isRecording = false
        voiceNoteURL = audioService.getRecordingURL()
    }
    
    func deleteRecording() {
        audioService.deleteRecording()
        voiceNoteURL = nil
        recordingDuration = 0
    }
    
    func playRecording() {
        guard let url = voiceNoteURL else { return }
        do {
            try audioService.playRecording(url: url)
        } catch {
            errorMessage = "Failed to play recording"
        }
    }
    
    func stopPlayback() {
        audioService.stopPlayback()
    }
    
    func saveEntry() async {
        guard let moodState = selectedMood else { return }
        
        // Validate text note length
        if noteType == .text && textNote.count > 240 {
            errorMessage = "Text note cannot exceed 240 characters. Current: \(textNote.count)"
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        // Prepare note data
        let finalTextNote = noteType == .text && !textNote.isEmpty ? textNote : nil
        var finalVoiceNoteURL: URL? = voiceNoteURL
        var finalVoiceNoteDuration: Double? = nil
        
        // If switching from voice to text, delete voice note
        if noteType == .text && voiceNoteURL != nil {
            audioService.deleteRecording()
            finalVoiceNoteURL = nil
        }
        
        // Get voice note duration if exists
        if let url = finalVoiceNoteURL {
            finalVoiceNoteDuration = audioService.getRecordingDuration(url: url)
        }
        
        // Save to Core Data
        do {
            if let savedEntry = dataService.saveEntry(
                moodState: moodState,
                textNote: finalTextNote,
                voiceNoteURL: finalVoiceNoteURL,
                voiceNoteDuration: finalVoiceNoteDuration
            ) {
                isSaving = false
            } else {
                errorMessage = "Failed to save entry. Please check your storage and try again."
                isSaving = false
            }
        } catch {
            errorMessage = "An error occurred while saving: \(error.localizedDescription)"
            isSaving = false
        }
    }
}


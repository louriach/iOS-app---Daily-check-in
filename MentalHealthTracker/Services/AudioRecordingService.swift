import AVFoundation
import Foundation
import Combine

class AudioRecordingService: NSObject, ObservableObject {
    static let shared = AudioRecordingService()
    
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var playbackProgress: TimeInterval = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    private var currentRecordingURL: URL?
    private let maxDuration: TimeInterval = 30.0
    
    private override init() {
        super.init()
    }
    
    // MARK: - Permissions
    
    func requestMicrophonePermission() async -> Bool {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            return await AVAudioSession.sharedInstance().requestRecordPermission()
        @unknown default:
            return false
        }
    }
    
    func checkMicrophonePermission() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }
    
    // MARK: - Recording
    
    func startRecording(entryID: UUID) async throws {
        // Request permission if needed
        let hasPermission = await requestMicrophonePermission()
        guard hasPermission else {
            throw AudioError.microphonePermissionDenied
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default)
        try audioSession.setActive(true)
        
        // Create file URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let voiceNotesPath = documentsPath.appendingPathComponent("voiceNotes")
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: voiceNotesPath, withIntermediateDirectories: true)
        
        let fileName = "\(entryID.uuidString).m4a"
        let fileURL = voiceNotesPath.appendingPathComponent(fileName)
        currentRecordingURL = fileURL
        
        // Configure recorder
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
        
        isRecording = true
        recordingDuration = 0
        
        // Start timer
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingDuration += 0.1
            
            if self.recordingDuration >= self.maxDuration {
                Task { @MainActor in
                    await self.stopRecording()
                }
            }
        }
    }
    
    func stopRecording() async {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func deleteRecording() {
        if let url = currentRecordingURL {
            try? FileManager.default.removeItem(at: url)
            currentRecordingURL = nil
        }
        recordingDuration = 0
    }
    
    func getRecordingURL() -> URL? {
        return currentRecordingURL
    }
    
    // MARK: - Playback
    
    func playRecording(url: URL) throws {
        // Stop any current playback
        stopPlayback()
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.play()
        
        isPlaying = true
        playbackProgress = 0
        
        // Start progress timer
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.playbackProgress = player.currentTime
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        playbackTimer?.invalidate()
        playbackTimer = nil
        isPlaying = false
        playbackProgress = 0
        
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func getRecordingDuration(url: URL) -> TimeInterval? {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            return player.duration
        } catch {
            return nil
        }
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording finished unsuccessfully")
            deleteRecording()
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioRecordingService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlayback()
    }
}

// MARK: - Errors

enum AudioError: LocalizedError {
    case microphonePermissionDenied
    case recordingFailed
    case playbackFailed
    
    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone permission is required to record voice notes."
        case .recordingFailed:
            return "Failed to start recording."
        case .playbackFailed:
            return "Failed to play recording."
        }
    }
}


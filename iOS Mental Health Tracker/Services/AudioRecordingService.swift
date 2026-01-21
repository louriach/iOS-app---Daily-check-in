//
//  AudioRecordingService.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import Foundation
import AVFoundation
import Combine

class AudioRecordingService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var isPlaying = false
    @Published var playbackTime: TimeInterval = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    private var recordingURL: URL?
    private let maxDuration: TimeInterval = 30.0 // 30 seconds max
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            // Use options that work better on iPad - defaultToSpeaker ensures audio plays through speakers
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func requestMicrophonePermission() async -> Bool {
        if #available(iOS 17.0, *) {
            return await AVAudioApplication.requestRecordPermission()
        } else {
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    func startRecording() -> URL? {
        guard !isRecording else { return nil }
        
        // Ensure audio session is active and properly configured
        do {
            // Reconfigure audio session for recording with iPad-friendly options
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
            return nil
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            
            // Prepare to record
            guard audioRecorder?.prepareToRecord() == true else {
                print("Failed to prepare recorder")
                return nil
            }
            
            // Start recording
            guard audioRecorder?.record() == true else {
                print("Failed to start recording")
                return nil
            }
            
            recordingURL = audioFilename
            isRecording = true
            recordingDuration = 0
            
            // Use RunLoop to ensure timer works on main thread
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                DispatchQueue.main.async {
                    self.recordingDuration += 0.1
                    
                    if self.recordingDuration >= self.maxDuration {
                        self.stopRecording()
                    }
                }
            }
            
            return audioFilename
        } catch {
            print("Failed to start recording: \(error)")
            return nil
        }
    }
    
    func stopRecording() {
        guard let recorder = audioRecorder else {
            isRecording = false
            return
        }
        
        let url = recorder.url
        recorder.stop()
        
        // Ensure we're on main thread for state updates
        DispatchQueue.main.async { [weak self] in
            self?.audioRecorder = nil
            self?.recordingTimer?.invalidate()
            self?.recordingTimer = nil
            self?.isRecording = false
            
            // Verify the file was created with a small delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if FileManager.default.fileExists(atPath: url.path) {
                    print("Recording saved to: \(url.path)")
                    self?.recordingURL = url
                } else {
                    print("Warning: Recording file not found at: \(url.path)")
                    self?.recordingURL = nil
                }
            }
        }
    }
    
    func getRecordingURL() -> URL? {
        // Return stored URL if available, otherwise check recorder
        if let url = recordingURL, FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        if let url = audioRecorder?.url, FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return nil
    }
    
    func clearRecording() {
        stopPlayback()
        recordingURL = nil
        recordingDuration = 0
        playbackTime = 0
    }
    
    // MARK: - Playback
    
    func playRecording(url: URL) {
        guard !isRecording else { return }
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Error: Audio file does not exist at \(url.path)")
            return
        }
        
        // Stop any current playback
        stopPlayback()
        
        do {
            // Use playAndRecord to allow both playback and recording
            // defaultToSpeaker ensures audio plays through speakers on iPad
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            guard audioPlayer?.prepareToPlay() == true else {
                print("Failed to prepare audio player")
                return
            }
            
            guard audioPlayer?.play() == true else {
                print("Failed to start playback")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.isPlaying = true
                self?.playbackTime = 0
            }
            
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self, let player = self.audioPlayer else {
                    timer.invalidate()
                    return
                }
                DispatchQueue.main.async {
                    self.playbackTime = player.currentTime
                    if !player.isPlaying && self.isPlaying {
                        self.stopPlayback()
                    }
                }
            }
        } catch {
            print("Failed to play recording: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.isPlaying = false
            }
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        playbackTimer?.invalidate()
        playbackTimer = nil
        isPlaying = false
        playbackTime = 0
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func deleteRecording(url: URL) {
        stopPlayback()
        try? FileManager.default.removeItem(at: url)
        if recordingURL == url {
            clearRecording()
        }
    }
}

extension AudioRecordingService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlayback()
    }
}

extension AudioRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording finished unsuccessfully")
        }
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
}


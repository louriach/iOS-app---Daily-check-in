//
//  YearView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

// MARK: - YearView

struct YearView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var selectedDate: Date

    @State private var viewingYear: Int = Calendar.current.component(.year, from: Date())
    @State private var committedScale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var selectedEntryDate: Date?
    @State private var showEntrySheet = false

    private let calendar = Calendar.current
    private let cols = 7
    private let rows = 53   // ceil(366 / 7) — covers any year
    private let gap: CGFloat = 2
    private let padding: CGFloat = 8

    /// Live scale, clamped between 1× (fit-to-screen) and 8×.
    private var scale: CGFloat {
        (committedScale * gestureScale).clamped(to: 1...8)
    }

    private var days: [Date] { allDays(in: viewingYear) }

    var body: some View {
        GeometryReader { geo in
            let dotSize  = baseDotSize(in: geo.size) * scale
            let gridW    = CGFloat(cols) * dotSize + CGFloat(cols - 1) * gap
            let gridH    = CGFloat(rows) * dotSize + CGFloat(rows - 1) * gap
            let totalW   = gridW + padding * 2
            let totalH   = gridH + padding * 2

            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(dotSize), spacing: gap), count: cols),
                    spacing: gap
                ) {
                    ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                        YearDot(
                            viewModel: viewModel,
                            date: date,
                            selectedDate: $selectedDate,
                            dotSize: dotSize,
                            onTap: { tapped in
                                selectedEntryDate = tapped
                                showEntrySheet = true
                            }
                        )
                    }
                }
                .padding(padding)
                // Keep the frame at least as large as the viewport so content
                // stays pinned top-left when it's smaller than the screen.
                .frame(
                    width:  max(totalW, geo.size.width),
                    height: max(totalH, geo.size.height),
                    alignment: .topLeading
                )
            }
            .gesture(
                MagnificationGesture()
                    .updating($gestureScale) { value, state, _ in
                        // Prevent zooming below 1× regardless of committed scale
                        state = max(1 / committedScale, value)
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            committedScale = (committedScale * value).clamped(to: 1...8)
                        }
                    }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewingYear    -= 1
                        committedScale  = 1.0
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(String(viewingYear))
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.primaryTextColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewingYear    += 1
                        committedScale  = 1.0
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }
            }
        }
        .sheet(isPresented: $showEntrySheet) {
            if let date = selectedEntryDate {
                YearEntrySheet(viewModel: viewModel, date: date)
            }
        }
    }

    // MARK: Helpers

    /// The dot size at which all `rows × cols` dots exactly fill the available area at scale 1×.
    private func baseDotSize(in size: CGSize) -> CGFloat {
        let w = (size.width  - padding * 2 - gap * CGFloat(cols - 1)) / CGFloat(cols)
        let h = (size.height - padding * 2 - gap * CGFloat(rows - 1)) / CGFloat(rows)
        return max(1, min(w, h))
    }

    private func allDays(in year: Int) -> [Date] {
        guard let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) else { return [] }
        let isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        return (0..<(isLeap ? 366 : 365)).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }
}

// MARK: - YearDot

struct YearDot: View {
    @ObservedObject var viewModel: CalendarViewModel
    let date: Date
    @Binding var selectedDate: Date
    let dotSize: CGFloat
    let onTap: (Date) -> Void

    private let calendar = Calendar.current

    private var dayOfYear: Int {
        calendar.ordinality(of: .day, in: .year, for: date) ?? 1
    }

    var body: some View {
        let moodState = viewModel.getMoodState(for: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday    = calendar.isDateInToday(date)

        Button {
            selectedDate = date
            onTap(date)
        } label: {
            ZStack {
                Circle()
                    .fill(moodState?.color ?? AppTheme.borderColor)

                // Only render the label once dots are large enough to read
                if dotSize >= 14 {
                    Text("\(dayOfYear)")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.backgroundColor)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
            }
            .overlay(
                Circle().stroke(
                    isToday    ? AppTheme.accentColor      :
                    isSelected ? AppTheme.primaryTextColor :
                                 Color.clear,
                    lineWidth: isToday ? 2 : 1
                )
            )
        }
        .buttonStyle(.plain)
        .frame(width: dotSize, height: dotSize)
    }
}

// MARK: - Comparable + clamped helper

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - YearEntrySheet

struct YearEntrySheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    let date: Date
    @Environment(\.dismiss) var dismiss
    @StateObject private var audioService = AudioRecordingService()

    private let calendar = Calendar.current

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f
    }()

    private let dateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if let entry = viewModel.getMoodEntry(for: date) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(dateFormatter.string(from: date))
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.primaryTextColor)
                                    .padding(.bottom, 8)

                                if let moodString = entry.moodState,
                                   let mood = MoodState(rawValue: moodString) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(mood.color)
                                            .frame(width: 24, height: 24)
                                        Text(mood.displayName)
                                            .font(AppTheme.font)
                                            .foregroundColor(AppTheme.primaryTextColor)
                                    }
                                }

                                if let textNote = entry.textNote, !textNote.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("NOTE")
                                            .font(AppTheme.labelFont)
                                            .foregroundColor(AppTheme.secondaryTextColor)
                                            .tracking(2)
                                        Text(textNote)
                                            .font(AppTheme.font)
                                            .foregroundColor(AppTheme.primaryTextColor)
                                    }
                                    .minimalCard()
                                }

                                if let voiceNoteURLString = entry.voiceNoteURL,
                                   !voiceNoteURLString.isEmpty {
                                    VoiceNotePlaybackView(
                                        audioService: audioService,
                                        voiceNoteURLString: voiceNoteURLString,
                                        duration: entry.voiceNoteDuration
                                    )
                                }

                                if let createdAt = entry.createdAt {
                                    Text("CREATED: \(createdAt, formatter: dateTimeFormatter)")
                                        .font(AppTheme.labelFont)
                                        .foregroundColor(AppTheme.secondaryTextColor)
                                        .tracking(1)
                                }
                            }
                            .padding()
                        } else {
                            VStack(spacing: 16) {
                                Text("No entry")
                                    .font(AppTheme.font)
                                    .foregroundColor(AppTheme.secondaryTextColor)
                                Text(dateFormatter.string(from: date))
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.secondaryTextColor)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        audioService.stopPlayback()
                        dismiss()
                    }
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryTextColor)
                }
            }
            .onDisappear { audioService.stopPlayback() }
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - VoiceNotePlaybackView

struct VoiceNotePlaybackView: View {
    @ObservedObject var audioService: AudioRecordingService
    let voiceNoteURLString: String
    let duration: Double

    private var voiceNoteURL: URL {
        DailyTrackingViewModel.resolveVoiceNoteURL(from: voiceNoteURLString)
    }

    private var fileExists: Bool {
        FileManager.default.fileExists(atPath: voiceNoteURL.path)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VOICE")
                .font(AppTheme.labelFont)
                .foregroundColor(AppTheme.secondaryTextColor)
                .tracking(2)

            if fileExists {
                if audioService.isPlaying {
                    VStack(spacing: 16) {
                        Text(String(format: "%.1f", audioService.playbackTime))
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.primaryTextColor)
                        Text("Playing…")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                        Button("Stop") { audioService.stopPlayback() }
                            .buttonStyle(MinimalButtonStyle())
                    }
                } else {
                    Button {
                        audioService.playRecording(url: voiceNoteURL)
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play")
                            Text("(\(Int(duration))s)")
                                .foregroundColor(AppTheme.secondaryTextColor)
                        }
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                                .fill(AppTheme.surfaceColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                                        .stroke(AppTheme.borderColor, lineWidth: 1)
                                )
                        )
                    }
                }
            } else {
                Text("File not found")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }
        }
        .minimalCard()
    }
}

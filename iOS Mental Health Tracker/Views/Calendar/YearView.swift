//
//  YearView.swift
//  iOS Mental Health Tracker
//
//  Created by Luis Ouriach on 24/12/2025.
//

import SwiftUI

struct YearLabelPositionPreference: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

struct YearView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var selectedDate: Date
    @State private var selectedEntryDate: Date?
    @State private var showEntrySheet = false
    @State private var visibleYear: Int = Calendar.current.component(.year, from: Date())
    @State private var updateTask: Task<Void, Never>?

    private let calendar = Calendar.current
    private let columnsPerRow = 7 // Days per week

    // Show years centered around today's year (± 5 years)
    private var years: [Int] {
        let currentYear = calendar.component(.year, from: Date())
        return Array((currentYear - 5)...(currentYear + 5))
    }

    var body: some View {
        // Computed once per render instead of once per day cell
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: selectedDate)

        GeometryReader { geometry in
            let padding: CGFloat = 8
            let gap: CGFloat = 2
            let availableWidth = geometry.size.width - (padding * 2)

            // Calculate dot size to fill horizontal space: (width - gaps) / 7
            // Clamp to 0 — GeometryReader briefly reports width=0 during layout,
            // which produces a negative dotSize and an "invalid frame dimension" warning.
            let totalGapWidth = gap * CGFloat(columnsPerRow - 1)
            let dotSize = max(0, (availableWidth - totalGapWidth) / CGFloat(columnsPerRow))

            ScrollViewReader { proxy in
                ScrollView {
                    // Lazy and flat (headers and rows are siblings) so only the rows on
                    // screen are built — 11 years is ~4,000 day cells — and scrollTo can
                    // reach any row by its id.
                    LazyVStack(alignment: .leading, spacing: gap) {
                        ForEach(years, id: \.self) { year in
                            yearHeader(year, padding: padding)
                                .padding(.top, year == years.first ? 0 : 48 - gap)
                                .padding(.bottom, 12 - gap)
                                .id(year)

                            let days = YearDays.days(in: year)
                            ForEach(Array(stride(from: 0, to: days.count, by: columnsPerRow)), id: \.self) { rowStart in
                                let rowEnd = min(rowStart + columnsPerRow, days.count)

                                HStack(spacing: gap) {
                                    ForEach(rowStart..<rowEnd, id: \.self) { dayIndex in
                                        let date = days[dayIndex]
                                        YearDot(
                                            date: date,
                                            dayOfYear: dayIndex + 1,
                                            moodState: viewModel.getMoodState(for: date),
                                            isToday: date == today,
                                            isSelected: date == selectedDay,
                                            dotSize: dotSize,
                                            onTap: { date in
                                                selectedDate = date
                                                selectedEntryDate = date
                                                showEntrySheet = true
                                            }
                                        )
                                        .equatable()
                                        .frame(width: dotSize, height: dotSize)
                                    }

                                    // Fill remaining cells if row is incomplete
                                    if rowEnd - rowStart < columnsPerRow {
                                        ForEach(0..<(columnsPerRow - (rowEnd - rowStart)), id: \.self) { _ in
                                            Color.clear
                                                .frame(width: dotSize, height: dotSize)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, padding)
                                .id("\(year)-row-\(rowStart / columnsPerRow)")
                            }
                        }
                    }
                    .padding(.bottom, 24)
                    .padding(.vertical, padding)
                    .onPreferenceChange(YearLabelPositionPreference.self) { yearPositions in
                        // Find the year whose label has most recently passed the top (threshold)
                        let threshold: CGFloat = 100
                        let passedYears = yearPositions.filter { $0.value <= threshold }

                        let newYear: Int?
                        if let activeYear = passedYears.max(by: { $0.value < $1.value })?.key {
                            newYear = activeYear
                        } else if let closestYear = yearPositions.min(by: {
                            abs($0.value - threshold) < abs($1.value - threshold)
                        })?.key {
                            newYear = closestYear
                        } else {
                            newYear = nil
                        }

                        // Update immediately to stay in sync with scroll position
                        if let newYear = newYear, newYear != visibleYear {
                            // Cancel any pending update
                            updateTask?.cancel()

                            // Update immediately on next run loop to prevent blocking
                            Task { @MainActor in
                                // Check again in case it changed during the async dispatch
                                if newYear != visibleYear {
                                    // Use transaction to prevent animation interference
                                    var transaction = Transaction()
                                    transaction.disablesAnimations = true
                                    withTransaction(transaction) {
                                        visibleYear = newYear
                                    }
                                }
                            }
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                .task {
                    // Defer scroll animation slightly to allow initial render to complete
                    try? await Task.sleep(nanoseconds: 50_000_000) // 50ms

                    // Scroll to center around today's date
                    let today = Date()
                    let currentYear = calendar.component(.year, from: today)
                    visibleYear = currentYear

                    // Calculate day of year (1-indexed, then convert to 0-indexed)
                    let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
                    let dayIndex = dayOfYear - 1 // Convert to 0-indexed
                    // Calculate which row this day is in (0-indexed, 7 days per row)
                    let rowIndex = dayIndex / 7
                    let rowID = "\(currentYear)-row-\(rowIndex)"

                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(rowID, anchor: .center)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String(visibleYear))
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.primaryTextColor)
            }
        }
        .sheet(isPresented: $showEntrySheet) {
            if let date = selectedEntryDate {
                YearEntrySheet(viewModel: viewModel, date: date)
            }
        }
    }

    // Inline header with year
    private func yearHeader(_ year: Int, padding: CGFloat) -> some View {
        HStack {
            Text(String(year))
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.primaryTextColor)
        }
        .padding(.horizontal, padding)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: YearLabelPositionPreference.self, value: [year: geometry.frame(in: .named("scroll")).minY])
            }
        )
    }
}

/// The start-of-day dates in each year, built once and reused across renders.
private enum YearDays {
    private static var cache: [Int: [Date]] = [:]

    static func days(in year: Int) -> [Date] {
        if let days = cache[year] {
            return days
        }
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? Date()
        let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        let daysInYear = isLeapYear ? 366 : 365

        let days = (0..<daysInYear).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfYear)
        }
        cache[year] = days
        return days
    }
}

/// A single day cell. It takes plain values rather than observing the view model, and is
/// Equatable, so a data change only re-renders the cells whose values actually changed.
struct YearDot: View, Equatable {
    let date: Date
    let dayOfYear: Int
    let moodState: MoodState?
    let isToday: Bool
    let isSelected: Bool
    let dotSize: CGFloat
    let onTap: (Date) -> Void

    static func == (lhs: YearDot, rhs: YearDot) -> Bool {
        lhs.date == rhs.date &&
        lhs.moodState == rhs.moodState &&
        lhs.isToday == rhs.isToday &&
        lhs.isSelected == rhs.isSelected &&
        lhs.dotSize == rhs.dotSize
    }

    var body: some View {
        Button(action: {
            onTap(date)
        }) {
            ZStack {
                // Subtle background for today / selected
                if isToday {
                    RoundedRectangle(cornerRadius: dotSize * 0.2)
                        .fill(AppTheme.accentColor.opacity(0.15))
                } else if isSelected {
                    RoundedRectangle(cornerRadius: dotSize * 0.2)
                        .fill(AppTheme.primaryTextColor.opacity(0.08))
                }

                Text("\(dayOfYear)")
                    .font(.system(size: dotSize * 0.38, design: .monospaced)
                        .weight(isToday ? .semibold : .regular))
                    .foregroundColor(
                        isToday    ? AppTheme.accentColor :
                        moodState != nil ? moodState!.color :
                                     AppTheme.borderColor
                    )
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}


struct YearEntrySheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    let date: Date
    @Environment(\.dismiss) var dismiss
    @StateObject private var audioService = AudioRecordingService()
    
    private let calendar = Calendar.current
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()
    
    private let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if let entry = viewModel.getMoodEntry(for: date) {
                            VStack(alignment: .leading, spacing: 16) {
                                // Date header
                                Text(dateFormatter.string(from: date))
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.primaryTextColor)
                                    .padding(.bottom, 8)
                                
                                // Mood state
                                if let moodString = entry.moodState, let mood = MoodState(rawValue: moodString) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(mood.color)
                                            .frame(width: 24, height: 24)
                                        Text(mood.displayName)
                                            .font(AppTheme.font)
                                            .foregroundColor(AppTheme.primaryTextColor)
                                    }
                                }
                                
                                // Text note
                                if let textNote = entry.textNote, !textNote.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("NOTE")
                                            .font(AppTheme.captionFont)
                                            .foregroundColor(AppTheme.secondaryTextColor)
                                            .tracking(2)
                                        Text(textNote)
                                            .font(AppTheme.captionFont)
                                            .foregroundColor(AppTheme.primaryTextColor)
                                    }
                                    .minimalCard()
                                }
                                
                                // Voice note
                                if let voiceNoteURLString = entry.voiceNoteURL, !voiceNoteURLString.isEmpty {
                                    VoiceNotePlaybackView(
                                        audioService: audioService,
                                        voiceNoteURLString: voiceNoteURLString,
                                        duration: entry.voiceNoteDuration
                                    )
                                }
                                
                                // Created date
                                if let createdAt = entry.createdAt {
                                    Text("CREATED: \(createdAt, formatter: dateTimeFormatter)")
                                        .font(AppTheme.captionFont)
                                        .foregroundColor(AppTheme.secondaryTextColor)
                                }
                            }
                            .padding()
                        } else {
                            // No entry screen
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
            .onDisappear {
                audioService.stopPlayback()
            }
            .preferredColorScheme(.dark)
        }
    }
}

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
                .font(AppTheme.captionFont)
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

                        Button("Stop") {
                            audioService.stopPlayback()
                        }
                        .buttonStyle(MinimalButtonStyle())
                    }
                } else {
                    Button(action: {
                        audioService.playRecording(url: voiceNoteURL)
                    }) {
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
                Text("\(Int(duration))S")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryTextColor)
                Text("File not found")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }
        }
        .minimalCard()
    }
}


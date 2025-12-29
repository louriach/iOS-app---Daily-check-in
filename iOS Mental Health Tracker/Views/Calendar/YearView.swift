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
        GeometryReader { geometry in
            let padding: CGFloat = 8
            let gap: CGFloat = 2
            let availableWidth = geometry.size.width - (padding * 2)
            
            // Calculate dot size to fill horizontal space: (width - gaps) / 7
            let totalGapWidth = gap * CGFloat(columnsPerRow - 1)
            let dotSize = (availableWidth - totalGapWidth) / CGFloat(columnsPerRow)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(years, id: \.self) { year in
                            YearSection(
                                viewModel: viewModel,
                                selectedDate: $selectedDate,
                                year: year,
                                dotSize: dotSize,
                                gap: gap,
                                padding: padding,
                                onDotTapped: { date in
                                    selectedEntryDate = date
                                    showEntrySheet = true
                                }
                            )
                            .id(year)
                        }
                    }
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
                HStack {
                    Text("YEAR")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                    
                    Spacer()
                    
                    Text(String(visibleYear))
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showEntrySheet) {
            if let date = selectedEntryDate {
                YearEntrySheet(viewModel: viewModel, date: date)
            }
        }
    }
}

struct YearSection: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var selectedDate: Date
    let year: Int
    let dotSize: CGFloat
    let gap: CGFloat
    let padding: CGFloat
    let onDotTapped: (Date) -> Void
    
    private let calendar = Calendar.current
    private let columnsPerRow = 7
    
    var body: some View {
        let days = getAllDaysInYear(year)
        
        VStack(alignment: .leading, spacing: 12) {
            // Inline header with year
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
            
            // Year grid
            VStack(spacing: gap) {
                // Group days into rows of 7
                ForEach(Array(stride(from: 0, to: days.count, by: columnsPerRow)), id: \.self) { rowStart in
                    let rowEnd = min(rowStart + columnsPerRow, days.count)
                    let rowIndex = rowStart / columnsPerRow
                    let rowID = "\(year)-row-\(rowIndex)"
                    
                    HStack(spacing: gap) {
                        // Add dots for this row
                        ForEach(rowStart..<rowEnd, id: \.self) { dayIndex in
                            YearDot(
                                viewModel: viewModel,
                                date: days[dayIndex],
                                selectedDate: $selectedDate,
                                dotSize: dotSize,
                                onTap: onDotTapped
                            )
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
                    .id(rowID)
                }
            }
            .padding(.horizontal, padding)
        }
        .padding(.bottom, 24)
    }
    
    private func getAllDaysInYear(_ year: Int) -> [Date] {
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? Date()
        let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        let daysInYear = isLeapYear ? 366 : 365
        
        return (0..<daysInYear).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfYear)
        }
    }
}

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
        let isToday = calendar.isDateInToday(date)
        
        Button(action: {
            selectedDate = date
            onTap(date)
        }) {
            ZStack {
                Circle()
                    .fill(
                        moodState?.color ?? AppTheme.borderColor
                    )
                    .frame(width: dotSize, height: dotSize)
                
                Text("\(dayOfYear)")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.backgroundColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .overlay(
                Circle()
                    .stroke(
                        isToday ? AppTheme.accentColor : (isSelected ? AppTheme.primaryTextColor : Color.clear),
                        lineWidth: isToday ? 2 : 1
                    )
            )
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
        NavigationView {
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
                                        Text(mood.displayName.uppercased())
                                            .font(AppTheme.captionFont)
                                            .foregroundColor(AppTheme.primaryTextColor)
                                            .tracking(2)
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
                                Text("NO ENTRY")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.secondaryTextColor)
                                    .tracking(2)
                                
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
            .navigationTitle("ENTRY")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("DONE") {
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
        URL(fileURLWithPath: voiceNoteURLString)
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
                        
                        Text("PLAYING...")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                            .tracking(2)
                        
                        Button("STOP") {
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
                            Text("PLAY")
                            Text("(\(Int(duration))S)")
                                .foregroundColor(AppTheme.secondaryTextColor)
                        }
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                        .tracking(2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppTheme.surfaceColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
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


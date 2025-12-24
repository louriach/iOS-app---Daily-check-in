import SwiftUI

struct CalendarGridView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate: Date?
    @State private var showTrackingView = false
    @State private var editingEntry: MoodEntry?
    @GestureState private var magnification: CGFloat = 1.0
    
    let onSelectDate: ((Date) -> Void)?
    
    init(onSelectDate: ((Date) -> Void)? = nil) {
        self.onSelectDate = onSelectDate
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with title and zoom controls
                HStack {
                    Text(viewModel.getHeaderTitle())
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Zoom level buttons
                    HStack(spacing: 8) {
                        ForEach(CalendarViewModel.ZoomLevel.allCases, id: \.rawValue) { level in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.changeZoomLevel(level)
                        }
                    }) {
                        Text(level.displayName.prefix(1))
                            .font(.caption)
                            .fontWeight(viewModel.zoomLevel == level ? .bold : .regular)
                            .foregroundColor(viewModel.zoomLevel == level ? .white : .primary)
                            .frame(minWidth: 44, minHeight: 44)
                            .background(viewModel.zoomLevel == level ? Color.accentColor : Color(.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("\(level.displayName) view")
                    .accessibilityAddTraits(viewModel.zoomLevel == level ? .isSelected : [])
                    .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Calendar content with pinch gesture
                GeometryReader { geometry in
                    ZStack {
                        switch viewModel.zoomLevel {
                        case .year:
                            YearView(viewModel: viewModel) { date in
                                handleDateSelection(date)
                            }
                        case .month:
                            MonthView(viewModel: viewModel) { date in
                                handleDateSelection(date)
                            }
                        case .week:
                            WeekView(viewModel: viewModel) { date in
                                handleDateSelection(date)
                            }
                        case .day:
                            if let date = selectedDate ?? viewModel.currentDate {
                                DayView(viewModel: viewModel, date: date) {
                                    handleEditDate(date)
                                }
                            }
                        }
                    }
                    .scaleEffect(magnification)
                    .gesture(
                        MagnificationGesture()
                            .updating($magnification) { currentState, gestureState, _ in
                                gestureState = currentState
                            }
                            .onEnded { value in
                                handleZoomGesture(value)
                            }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        navigateToPrevious()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    .accessibilityLabel("Previous")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        navigateToNext()
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    .accessibilityLabel("Next")
                }
            }
            .sheet(isPresented: $showTrackingView) {
                if let entry = editingEntry {
                    DailyTrackingView(existingEntry: entry) {
                        showTrackingView = false
                        editingEntry = nil
                        viewModel.loadEntriesForCurrentView()
                    }
                } else if let date = selectedDate {
                    DailyTrackingView(existingEntry: viewModel.getEntry(for: date)) {
                        showTrackingView = false
                        selectedDate = nil
                        viewModel.loadEntriesForCurrentView()
                    }
                }
            }
            .onAppear {
                viewModel.loadEntriesForCurrentView()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToTracking"))) { _ in
                selectedDate = Date()
                showTrackingView = true
            }
        }
    }
    
    private func handleDateSelection(_ date: Date) {
        selectedDate = date
        
        if viewModel.zoomLevel == .day {
            // Already in day view, just update the date
            viewModel.navigateToDate(date)
        } else {
            // Switch to day view
            viewModel.changeZoomLevel(.day)
            viewModel.navigateToDate(date)
        }
        
        onSelectDate?(date)
    }
    
    private func handleEditDate(_ date: Date) {
        selectedDate = date
        editingEntry = viewModel.getEntry(for: date)
        showTrackingView = true
    }
    
    private func handleZoomGesture(_ value: CGFloat) {
        let currentLevel = viewModel.zoomLevel.rawValue
        
        if value > 1.2 && currentLevel < CalendarViewModel.ZoomLevel.allCases.count - 1 {
            // Zoom in
            let newLevel = CalendarViewModel.ZoomLevel(rawValue: currentLevel + 1) ?? viewModel.zoomLevel
            viewModel.changeZoomLevel(newLevel)
        } else if value < 0.8 && currentLevel > 0 {
            // Zoom out
            let newLevel = CalendarViewModel.ZoomLevel(rawValue: currentLevel - 1) ?? viewModel.zoomLevel
            viewModel.changeZoomLevel(newLevel)
        }
    }
    
    private func navigateToPrevious() {
        let calendar = Calendar.current
        var newDate: Date?
        
        switch viewModel.zoomLevel {
        case .year:
            newDate = calendar.date(byAdding: .year, value: -1, to: viewModel.currentDate)
        case .month:
            newDate = calendar.date(byAdding: .month, value: -1, to: viewModel.currentDate)
        case .week:
            newDate = calendar.date(byAdding: .weekOfYear, value: -1, to: viewModel.currentDate)
        case .day:
            newDate = calendar.date(byAdding: .day, value: -1, to: viewModel.currentDate)
        }
        
        if let newDate = newDate {
            viewModel.navigateToDate(newDate)
        }
    }
    
    private func navigateToNext() {
        let calendar = Calendar.current
        var newDate: Date?
        
        switch viewModel.zoomLevel {
        case .year:
            newDate = calendar.date(byAdding: .year, value: 1, to: viewModel.currentDate)
        case .month:
            newDate = calendar.date(byAdding: .month, value: 1, to: viewModel.currentDate)
        case .week:
            newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: viewModel.currentDate)
        case .day:
            newDate = calendar.date(byAdding: .day, value: 1, to: viewModel.currentDate)
        }
        
        if let newDate = newDate {
            viewModel.navigateToDate(newDate)
        }
    }
}


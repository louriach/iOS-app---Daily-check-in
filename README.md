# Mental Health Tracker iOS App

A simple iOS mental health tracker app that helps you track your daily mood using a traffic light system.

## Features

- **Daily Notifications**: Set a daily reminder time (default 9 PM) to check in with yourself
- **Traffic Light Mood System**: Quickly select how you're feeling (Red/Struggling, Yellow/Okay, Green/Good)
- **Optional Notes**: Add context with either:
  - Text note (up to 240 characters)
  - Voice note (up to 30 seconds)
- **Calendar View**: Visualize your mood history with a zoomable calendar grid
  - Year view: See the entire year at a glance
  - Month view: Standard calendar layout
  - Week view: Focus on a single week
  - Day view: Detailed view of a specific day
- **Edit Entries**: Update or modify previous entries

## Setup Instructions

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later
- macOS 12.0 or later (for development)

### Creating the Xcode Project

1. Open Xcode
2. Create a new project:
   - Choose "iOS" > "App"
   - Product Name: `MentalHealthTracker`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `Core Data` (check this box)
   - Minimum iOS: `15.0`

3. Replace the generated files with the files from this repository:
   - Copy all Swift files to their respective directories
   - Copy `MentalHealthTracker.xcdatamodeld` to the project
   - Copy `Info.plist` to the project

4. Configure Capabilities:
   - Select the project in Xcode
   - Go to "Signing & Capabilities"
   - Add "Push Notifications" capability
   - Add "Background Modes" capability and enable "Remote notifications"

5. Configure Info.plist:
   - Ensure `NSMicrophoneUsageDescription` is set (already included)
   - Ensure `UIBackgroundModes` includes `remote-notification` (already included)

6. Build and run the project

## Project Structure

```
MentalHealthTracker/
├── App/
│   └── MentalHealthTrackerApp.swift       # Main app entry point
├── Models/
│   ├── MoodState.swift                    # Mood state enum
│   └── NotificationSettings.swift        # UserDefaults wrapper
├── Views/
│   ├── Onboarding/
│   │   ├── NotificationTimePickerView.swift
│   │   └── OnboardingViewModel.swift
│   ├── DailyTracking/
│   │   ├── DailyTrackingView.swift
│   │   ├── DailyTrackingViewModel.swift
│   │   ├── TrafficLightView.swift
│   │   ├── NoteInputView.swift
│   │   └── VoiceRecordingView.swift
│   ├── Calendar/
│   │   ├── CalendarGridView.swift
│   │   ├── CalendarViewModel.swift
│   │   ├── YearView.swift
│   │   ├── MonthView.swift
│   │   ├── WeekView.swift
│   │   └── DayView.swift
│   └── Shared/
│       ├── DateExtensions.swift
│       └── ColorExtensions.swift
├── Services/
│   ├── DataService.swift                  # Core Data manager
│   ├── NotificationService.swift        # Notification handling
│   └── AudioRecordingService.swift      # Voice recording
└── ViewModels/
    └── CalendarViewModel.swift
```

## Architecture

The app follows MVVM (Model-View-ViewModel) architecture:

- **Models**: Data structures and business logic
- **Views**: SwiftUI views for UI
- **ViewModels**: Observable objects that manage view state
- **Services**: Reusable services for Core Data, notifications, and audio

## Core Data

The app uses Core Data with CloudKit for optional sync. The `MoodEntry` entity stores:
- `id`: UUID (primary key)
- `date`: Date (indexed for fast lookups)
- `moodState`: String (red/yellow/green)
- `textNote`: String? (optional, max 240 chars)
- `voiceNoteURL`: String? (optional, path to audio file)
- `voiceNoteDuration`: Double? (optional, seconds)
- `createdAt`: Date
- `updatedAt`: Date

## Permissions

The app requires:
- **Notifications**: For daily reminders
- **Microphone**: For voice note recording (optional)

## Privacy

- All data is stored locally on your device
- CloudKit sync is optional and can be disabled
- No analytics or tracking
- No network requests (except optional CloudKit sync)

## License

This project is provided as-is for educational and personal use.


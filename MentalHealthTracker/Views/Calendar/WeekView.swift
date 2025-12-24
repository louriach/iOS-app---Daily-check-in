import SwiftUI

struct WeekView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let onDateSelected: (Date) -> Void
    
    private var weekStart: Date {
        viewModel.currentDate.startOfWeek()
    }
    
    private var weekDays: [Date] {
        (0..<7).compactMap { dayOffset in
            Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart)
        }
    }
    
    private var dayLabels: [String] {
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Day labels
            HStack(spacing: 0) {
                ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, label in
                    VStack(spacing: 8) {
                        Text(label)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        let date = weekDays[index]
                        let color = viewModel.getMoodColor(for: date)
                        let dayNumber = Calendar.current.component(.day, from: date)
                        let isToday = Calendar.current.isDateInToday(date)
                        
                        Button(action: {
                            onDateSelected(date)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 50, height: 50)
                                
                                Text("\(dayNumber)")
                                    .font(.system(size: 16, weight: isToday ? .bold : .regular))
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .overlay(
                            Circle()
                                .stroke(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                        .accessibilityLabel("\(label), \(dayNumber)")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
    }
}


import SwiftUI

struct MonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let onDateSelected: (Date) -> Void
    
    private var firstDayOfMonth: Date {
        viewModel.currentDate.startOfMonth()
    }
    
    private var lastDayOfMonth: Date {
        viewModel.currentDate.endOfMonth()
    }
    
    private var firstWeekday: Int {
        let weekday = Calendar.current.component(.weekday, from: firstDayOfMonth)
        // Convert to 0-6 (Sunday = 0)
        return (weekday + 6) % 7
    }
    
    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 31
    }
    
    private var dayLabels: [String] {
        ["S", "M", "T", "W", "T", "F", "S"]
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Day labels
            HStack(spacing: 0) {
                ForEach(dayLabels, id: \.self) { label in
                    Text(label)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                // Empty cells for days before month starts
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                }
                
                // Days of the month
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) ?? firstDayOfMonth
                    let color = viewModel.getMoodColor(for: date)
                    let isToday = Calendar.current.isDateInToday(date)
                    
                    Button(action: {
                        onDateSelected(date)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(color)
                                .aspectRatio(1, contentMode: .fit)
                            
                            VStack(spacing: 2) {
                                Text("\(day)")
                                    .font(.system(size: 14, weight: isToday ? .bold : .regular))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
                    .accessibilityLabel("\(day), \(viewModel.currentDate.formattedMonthYear())")
                    .accessibilityHint(isToday ? "Today" : "Select this date")
                    .accessibilityAddTraits(isToday ? .isSelected : [])
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isToday)
                }
            }
            .padding(.horizontal)
        }
    }
}


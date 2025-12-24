import SwiftUI

struct YearView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let onDateSelected: (Date) -> Void
    
    private let monthsPerRow = 3
    private let daysPerMonth = 31
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: monthsPerRow), spacing: 8) {
                ForEach(0..<12, id: \.self) { monthIndex in
                    MonthGridView(
                        monthIndex: monthIndex,
                        year: Calendar.current.component(.year, from: viewModel.currentDate),
                        viewModel: viewModel,
                        onDateSelected: onDateSelected,
                        compact: true
                    )
                    .id("\(monthIndex)-\(Calendar.current.component(.year, from: viewModel.currentDate))")
                }
            }
            .padding()
        }
    }
}

struct MonthGridView: View {
    let monthIndex: Int
    let year: Int
    @ObservedObject var viewModel: CalendarViewModel
    let onDateSelected: (Date) -> Void
    let compact: Bool
    
    private var monthDate: Date {
        var components = DateComponents()
        components.year = year
        components.month = monthIndex + 1
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: monthDate)?.count ?? 31
    }
    
    private var columns: Int {
        compact ? 7 : 7
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if !compact {
                Text(monthDate.formattedMonthYear())
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: columns), spacing: 2) {
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = Calendar.current.date(byAdding: .day, value: day - 1, to: monthDate.startOfMonth()) ?? monthDate
                    let color = viewModel.getMoodColor(for: date)
                    
                    Button(action: {
                        onDateSelected(date)
                    }) {
                        if compact {
                            Rectangle()
                                .fill(color)
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(2)
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(color)
                                    .aspectRatio(1, contentMode: .fit)
                                    .cornerRadius(4)
                                
                                Text("\(day)")
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("\(day), \(monthDate.formattedMonthYear())")
                }
            }
        }
    }
}


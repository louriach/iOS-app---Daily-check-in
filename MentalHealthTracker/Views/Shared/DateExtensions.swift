import Foundation

extension Date {
    /// Normalizes a date to the start of day in the current calendar
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Formats date as "Monday, January 15"
    func formattedDayMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: self)
    }
    
    /// Formats date as "2024"
    func formattedYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    /// Formats date as "January 2024"
    func formattedMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
    
    /// Formats date as "Week of Jan 15"
    func formattedWeek() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "'Week of' MMM d"
        return formatter.string(from: self)
    }
    
    /// Formats date as "January 15, 2024"
    func formattedFullDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: self)
    }
    
    /// Returns the start of the week (Sunday)
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns the end of the week (Saturday)
    func endOfWeek() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        components.weekday = 7 // Saturday
        return calendar.date(from: components) ?? self
    }
    
    /// Returns the start of the month
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns the end of the month
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        components.month = (components.month ?? 0) + 1
        components.day = 0
        return calendar.date(from: components) ?? self
    }
    
    /// Returns the start of the year
    func startOfYear() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns the end of the year
    func endOfYear() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: self)
        components.year = (components.year ?? 0) + 1
        components.day = 0
        return calendar.date(from: components) ?? self
    }
    
    /// Returns all dates in a range
    static func dates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate.startOfDay()
        let end = endDate.startOfDay()
        
        while currentDate <= end {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? end
        }
        
        return dates
    }
}


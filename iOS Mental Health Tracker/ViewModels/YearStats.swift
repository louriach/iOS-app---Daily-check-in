//
//  YearStats.swift
//  iOS Mental Health Tracker
//

import Foundation

/// A summary of one calendar year of check-ins, built by walking each day of the year
/// up to today (or the whole year, for past years).
struct YearStats {
    struct MonthBucket: Identifiable {
        let month: Date
        let mood: MoodState
        let count: Int
        var id: String { "\(month.timeIntervalSinceReferenceDate)-\(mood.rawValue)" }
    }

    let year: Int
    let startOfYear: Date
    /// The first moment of the next year, so chart domains include all of December
    let endOfYear: Date
    /// Days of the year so far, including today. The whole year for past years, 0 for future ones.
    let daysSoFar: Int
    let daysLogged: Int
    let counts: [MoodState: Int]
    let monthly: [MonthBucket]

    var completion: Double {
        daysSoFar > 0 ? Double(daysLogged) / Double(daysSoFar) : 0
    }

    func share(of mood: MoodState) -> Double {
        daysLogged > 0 ? Double(counts[mood, default: 0]) / Double(daysLogged) : 0
    }

    init(year: Int, today: Date = Date(), calendar: Calendar = .current, moodFor: (Date) -> MoodState?) {
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? today
        let nextYear = calendar.date(byAdding: .year, value: 1, to: start) ?? today
        let total = calendar.dateComponents([.day], from: start, to: nextYear).day ?? 365
        let todayStart = calendar.startOfDay(for: today)

        let elapsed: Int
        if todayStart < start {
            elapsed = 0
        } else if todayStart >= nextYear {
            elapsed = total
        } else {
            elapsed = (calendar.dateComponents([.day], from: start, to: todayStart).day ?? 0) + 1
        }

        var counts: [MoodState: Int] = [:]
        var monthCounts: [Int: [MoodState: Int]] = [:]

        for offset in 0..<elapsed {
            guard let day = calendar.date(byAdding: .day, value: offset, to: start),
                  let mood = moodFor(day) else { continue }
            counts[mood, default: 0] += 1
            monthCounts[calendar.component(.month, from: day), default: [:]][mood, default: 0] += 1
        }

        let monthsSoFar = elapsed == 0 ? 0 : calendar.component(.month, from: calendar.date(byAdding: .day, value: elapsed - 1, to: start) ?? start)
        var monthly: [MonthBucket] = []
        for month in Array(1...12).prefix(monthsSoFar) {
            guard let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else { continue }
            for mood in MoodState.allCases {
                monthly.append(MonthBucket(month: monthStart, mood: mood, count: monthCounts[month]?[mood] ?? 0))
            }
        }

        self.year = year
        self.startOfYear = start
        self.endOfYear = nextYear
        self.daysSoFar = elapsed
        self.daysLogged = counts.values.reduce(0, +)
        self.counts = counts
        self.monthly = monthly
    }
}

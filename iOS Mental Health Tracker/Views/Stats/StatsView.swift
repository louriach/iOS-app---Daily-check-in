//
//  StatsView.swift
//  iOS Mental Health Tracker
//

import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var year: Int
    let onClose: () -> Void

    private let calendar = Calendar.current
    // Stack order for charts and the legend: good at the bottom, poor on top
    private let moodOrder: [MoodState] = [.green, .yellow, .red]

    private var currentYear: Int {
        calendar.component(.year, from: Date())
    }

    private var earliestYear: Int {
        let first = viewModel.entries.compactMap(\.date).min()
        return first.map { calendar.component(.year, from: $0) } ?? currentYear
    }

    var body: some View {
        let stats = YearStats(year: year) { viewModel.getMoodState(for: $0) }

        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    yearSwitcher

                    summary(stats)

                    if stats.daysLogged > 0 {
                        split(stats)
                        monthly(stats)
                    } else {
                        Text(stats.daysSoFar == 0 ? "\(String(year)) hasn't started yet" : "No check-ins in \(String(year)) yet")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .frame(maxWidth: 600) // Constrain width on iPad
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Year in review")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                    }
                    .accessibilityLabel("Back to calendar")
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Sections

    private var yearSwitcher: some View {
        HStack {
            Button {
                year -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 44, height: 44)
            }
            .disabled(year <= earliestYear)
            .accessibilityLabel("Previous year")

            Spacer()

            Text(String(year))
                .font(AppTheme.headingFont)
                .foregroundColor(AppTheme.primaryTextColor)
                .contentTransition(.numericText())

            Spacer()

            Button {
                year += 1
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 44, height: 44)
            }
            .disabled(year >= currentYear)
            .accessibilityLabel("Next year")
        }
        .font(AppTheme.captionFont)
        .foregroundColor(AppTheme.secondaryTextColor)
        .animation(.snappy, value: year)
    }

    private func summary(_ stats: YearStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("Days checked in")
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(stats.daysLogged)")
                    .font(.system(size: 44, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.primaryTextColor)
                Text("of \(stats.daysSoFar) days")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryTextColor)
                Spacer()
                Text(stats.completion, format: .percent.precision(.fractionLength(0)))
                    .font(AppTheme.font)
                    .foregroundColor(AppTheme.accentColor)
            }
            ProgressView(value: stats.completion)
                .tint(AppTheme.accentColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func split(_ stats: YearStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("How you felt")

            HStack(spacing: 24) {
                Chart(moodOrder) { mood in
                    SectorMark(
                        angle: .value("Days", stats.counts[mood, default: 0]),
                        innerRadius: .ratio(0.62),
                        angularInset: 1.5
                    )
                    .cornerRadius(3)
                    .foregroundStyle(mood.color)
                }
                .frame(width: 120, height: 120)
                .overlay {
                    VStack(spacing: 2) {
                        Text("\(stats.daysLogged)")
                            .font(AppTheme.font)
                            .foregroundColor(AppTheme.primaryTextColor)
                        Text("days")
                            .font(AppTheme.labelFont)
                            .foregroundColor(AppTheme.secondaryTextColor)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(moodOrder.map { "\($0.displayName) \(stats.counts[$0, default: 0]) days" }.joined(separator: ", "))

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(moodOrder) { mood in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(mood.color)
                                .frame(width: 10, height: 10)
                            Text(mood.displayName)
                                .foregroundColor(AppTheme.primaryTextColor)
                            Spacer()
                            Text("\(stats.counts[mood, default: 0])")
                                .foregroundColor(AppTheme.primaryTextColor)
                            Text(stats.share(of: mood), format: .percent.precision(.fractionLength(0)))
                                .foregroundColor(AppTheme.secondaryTextColor)
                                .frame(width: 44, alignment: .trailing)
                        }
                        .font(AppTheme.captionFont)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func monthly(_ stats: YearStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("Month by month")

            Chart(stats.monthly.sorted { moodOrder.firstIndex(of: $0.mood)! < moodOrder.firstIndex(of: $1.mood)! }) { bucket in
                BarMark(
                    x: .value("Month", bucket.month, unit: .month),
                    y: .value("Days", bucket.count)
                )
                .foregroundStyle(by: .value("Mood", bucket.mood.displayName))
                .cornerRadius(2)
            }
            .chartForegroundStyleScale(
                domain: moodOrder.map(\.displayName),
                range: moodOrder.map(\.color)
            )
            .chartLegend(.hidden)
            .chartXScale(domain: stats.startOfYear...stats.endOfYear)
            .chartXAxis { monthAxis }
            .chartYAxis { valueAxis }
            .frame(height: 160)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.captionFont)
            .foregroundColor(AppTheme.secondaryTextColor)
            .accessibilityAddTraits(.isHeader)
    }

    private var monthAxis: some AxisContent {
        AxisMarks(values: .stride(by: .month)) { _ in
            AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
                .font(AppTheme.labelFont)
                .foregroundStyle(AppTheme.secondaryTextColor)
        }
    }

    private var valueAxis: some AxisContent {
        AxisMarks(position: .leading) { _ in
            AxisGridLine()
                .foregroundStyle(AppTheme.borderColor)
            AxisValueLabel()
                .font(AppTheme.labelFont)
                .foregroundStyle(AppTheme.secondaryTextColor)
        }
    }
}

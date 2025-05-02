//
//  DashboardView.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/2/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var hk = HealthKitService.shared
    private let calendar = Calendar.current

    enum Period: String, CaseIterable, Identifiable {
        case week = "W", month = "M", year = "Y"
        var id: String { rawValue }
    }
    @State private var selectedPeriod: Period = .week
    @State private var selectedBucket: Date? = nil

    // MARK: – compute the date range
    private var dateRange: ClosedRange<Date> {
        let end = Date()
        let start: Date
        switch selectedPeriod {
        case .week:
            start = calendar.date(byAdding: .day, value: -6, to: end)!
        case .month:
            start = calendar.date(byAdding: .month, value: -1, to: end)!
        case .year:
            start = calendar.date(byAdding: .year, value: -1, to: end)!
        }
        return start...end
    }

    // MARK: – raw grouping
    private var rawGroupedWindows: [SleepWindowGroup] {
        let filtered = hk.sleepSamples.filter { dateRange.contains($0.start) }
        if selectedPeriod == .year {
            let byMonth = Dictionary(grouping: filtered) { sample in
                calendar.date(from: DateComponents(
                    year:  calendar.component(.year,  from: sample.start),
                    month: calendar.component(.month, from: sample.start)
                ))!
            }
            return byMonth.map { monthStart, samples in
                let avgStart = samples
                    .map(\.start.timeIntervalSinceReferenceDate)
                    .reduce(0, +) / Double(samples.count)
                let avgEnd = samples
                    .map(\.end.timeIntervalSinceReferenceDate)
                    .reduce(0, +) / Double(samples.count)
                return SleepWindowGroup(
                    date: monthStart,
                    start: Date(timeIntervalSinceReferenceDate: avgStart),
                    end:   Date(timeIntervalSinceReferenceDate: avgEnd)
                )
            }
            .sorted { $0.date < $1.date }
        }
        return filtered.toGroupedSleepWindows(calendar: calendar)
    }

    // MARK: – skeleton buckets
    private var allBuckets: [Date] {
        switch selectedPeriod {
        case .year:
            var months: [Date] = []
            var current = calendar.date(
                from: calendar.dateComponents([.year, .month], from: dateRange.lowerBound)
            )!
            let end = calendar.date(
                from: calendar.dateComponents([.year, .month], from: dateRange.upperBound)
            )!
            while current <= end {
                months.append(current)
                current = calendar.date(byAdding: .month, value: 1, to: current)!
            }
            return months

        case .month, .week:
            var days: [Date] = []
            var current = calendar.startOfDay(for: dateRange.lowerBound)
            let end   = calendar.startOfDay(for: dateRange.upperBound)
            while current <= end {
                days.append(current)
                current = calendar.date(byAdding: .day, value: 1, to: current)!
            }
            return days
        }
    }

    // MARK: – merge real + empty
    private var displayWindows: [SleepWindowGroup] {
        let realDict = Dictionary(uniqueKeysWithValues: rawGroupedWindows.map { ($0.date, $0) })
        return allBuckets.map { date in
            if let g = realDict[date] { return g }
            // no data → zero‐length
            return SleepWindowGroup(date: date, start: date, end: date)
        }
    }

    // MARK: – averages for header
    private var avgSleepMinutes: Int {
        guard !rawGroupedWindows.isEmpty else { return 0 }
        let total = rawGroupedWindows.reduce(0.0) { $0 + $1.duration }
        return Int(total / Double(rawGroupedWindows.count))
    }

    private var formattedRange: String {
        let df = DateFormatter()
        df.dateFormat = "MMM d"
        return "\(df.string(from: dateRange.lowerBound)) – \(df.string(from: dateRange.upperBound))"
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker("", selection: $selectedPeriod) {
                ForEach(Period.allCases) { p in
                    Text(p.rawValue)
                        .frame(maxWidth: .infinity)
                        .tag(p)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 4) {
                Text("AVG. TIME ASLEEP")
                    .font(.caption).foregroundColor(.teal)
                Text("\(avgSleepMinutes/60) hr \(avgSleepMinutes%60) min")
                    .font(.title2.bold()).foregroundColor(.primary)
                Text(formattedRange)
                    .font(.caption2).foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Chart {
                ForEach(displayWindows) { g in
                    BarMark(
                        x: .value(selectedPeriod == .year ? "Month" : "Day",
                                  g.date,
                                  unit: selectedPeriod == .year ? .month : .day),
                        yStart: .value("Start", timeOfDay(g.start)),
                        yEnd:   .value("End",   timeOfDay(g.end))
                    )
                    .cornerRadius(5)
                    .foregroundStyle(.teal)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: yAxisHours) { val in
                    AxisGridLine()
                    AxisValueLabel(formatHour(val.as(Date.self)))
                }
            }
            .chartXAxis {
                switch selectedPeriod {
                case .week:
                    AxisMarks(values: .stride(by: .day)) { val in
                        AxisGridLine()
                        AxisValueLabel(formatWeekday(val.as(Date.self)))
                    }
                case .month:
                    AxisMarks(values: .stride(by: .day, count: 7)) { val in
                        AxisGridLine()
                        AxisValueLabel(formatDayOfMonth(val.as(Date.self)))
                    }
                case .year:
                    AxisMarks(values: .stride(by: .month)) { val in
                        AxisGridLine()
                        AxisValueLabel(formatMonthAbbrev(val.as(Date.self)))
                    }
                }
            }
            .frame(height: 260)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onEnded { value in
                                    let xLoc = value.location.x
                                    if let xDate: Date = proxy.value(atX: xLoc) {
                                        // bucket it
                                        selectedBucket = bucketDate(from: xDate)
                                    }
                                }
                        )
                }
            }

            if let sel = selectedBucket {
                let details = hk.sleepSamples
                    .filter { sample in
                        sample.stage.isAsleep
                        && bucketDate(from: sample.start) == sel
                    }
                    .toGroupedSleepWindows(calendar: calendar)

                VStack(alignment: .leading, spacing: 8) {
                    Text(detailHeader(for: sel))
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(details) { g in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(formatFullDate(g.date))
                                        .font(.subheadline).bold()
                                    Text("Start: \(formatTime(g.start)) • End: \(formatTime(g.end))")
                                        .font(.caption)
                                    Text(String(format: "Duration: %.0f min", g.duration))
                                        .font(.caption2)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .frame(height: 200)
                }
            }
        }
        .padding()
        .onAppear {
            hk.fetchSleepData(start: dateRange.lowerBound, end: dateRange.upperBound)
        }
        .onChange(of: selectedPeriod) { _ in
            selectedBucket = nil
            hk.fetchSleepData(start: dateRange.lowerBound, end: dateRange.upperBound)
        }
    }

    // MARK: – Helpers

    private var yAxisHours: [Date] {
        let base = calendar.startOfDay(for: Date())
        return stride(from: 21, through: 13 + 24, by: 4)
            .map { calendar.date(byAdding: .hour, value: $0 % 24, to: base)! }
    }

    func timeOfDay(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        return calendar.date(
            bySettingHour: comps.hour ?? 0,
            minute: comps.minute ?? 0,
            second: 0,
            of: calendar.startOfDay(for: Date())
        )!
    }

    func formatHour(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let hr = calendar.component(.hour, from: date)
        let disp = hr % 12 == 0 ? 12 : hr % 12
        return "\(disp) \(hr < 12 ? "AM" : "PM")"
    }
    func formatWeekday(_ date: Date?) -> String {
        guard let d = date else { return "" }
        let df = DateFormatter(); df.dateFormat = "E"
        return df.string(from: d)
    }
    func formatDayOfMonth(_ date: Date?) -> String {
        guard let d = date else { return "" }
        let df = DateFormatter(); df.dateFormat = "d"
        return df.string(from: d)
    }
    func formatMonthAbbrev(_ date: Date?) -> String {
        guard let d = date else { return "" }
        let df = DateFormatter(); df.dateFormat = "LLL"
        return df.string(from: d)
    }
    func formatFullMonth(_ date: Date) -> String {
        let df = DateFormatter(); df.dateFormat = "LLLL yyyy"
        return df.string(from: date)
    }
    func formatFullDate(_ date: Date) -> String {
        let df = DateFormatter(); df.dateFormat = "MMM d, yyyy"
        return df.string(from: date)
    }
    func formatTime(_ date: Date) -> String {
        let df = DateFormatter(); df.dateFormat = "h:mm a"
        return df.string(from: date)
    }

    private func bucketDate(from raw: Date) -> Date {
        switch selectedPeriod {
        case .year:
            let comps = calendar.dateComponents([.year, .month], from: raw)
            return calendar.date(from: comps)!
            
        case .month, .week:
            let shifted = calendar.date(byAdding: .hour, value: -18, to: raw)!
            return calendar.startOfDay(for: shifted)
        }
    }
    private func detailHeader(for sel: Date) -> String {
        switch selectedPeriod {
        case .year:
            return "Entries for \(formatFullMonth(sel))"
        case .month, .week:
            return "Entries for \(formatFullDate(sel))"
        }
    }
}

struct SleepWindowGroup: Identifiable {
    var id: Date { date }
    let date: Date, start: Date, end: Date
    var duration: TimeInterval { end.timeIntervalSince(start) / 60 }
}

extension Array where Element == SleepData {
    func toGroupedSleepWindows(calendar: Calendar = .current) -> [SleepWindowGroup] {
        let asleep = filter { $0.stage.isAsleep }
        let grouped = Dictionary(grouping: asleep) { s in
            let shifted = calendar.date(byAdding: .hour, value: -18, to: s.start)!
            return calendar.startOfDay(for: shifted)
        }
        return grouped.compactMap { day, samples in
            guard let first = samples.min(by: { $0.start < $1.start }),
                  let last  = samples.max(by: { $0.end   < $1.end   }) else {
                return nil
            }
            return SleepWindowGroup(date: day, start: first.start, end: last.end)
        }
        .sorted { $0.date < $1.date }
    }
}

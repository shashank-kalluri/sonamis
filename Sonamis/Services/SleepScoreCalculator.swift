//
//  SleepScoreCalculator.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/1/25.
//

import Foundation

/// Compute sleep scores from raw SleepData samples
class SleepScoreCalculator {
    private let wEfficiency = 0.5
    private let wDuration   = 0.3
    private let wConsistency = 0.2
    
    private let idealSleep: TimeInterval = 8 * 3600
    
    func compute(
        for metrics: [Date: (asleep: TimeInterval, inBed: TimeInterval)]
    ) -> [DailyMetric] {
        let days = metrics.keys.sorted()
        
        let raw = days.map { day -> (Date, TimeInterval, TimeInterval) in
            let v = metrics[day]!
            return (day, v.asleep, v.inBed)
        }
        let asleepValues = raw.map { $0.1 }
        let mean = asleepValues.reduce(0,+) / Double(asleepValues.count)
        let variance = asleepValues
            .map { pow($0 - mean, 2) }
            .reduce(0,+) / Double(asleepValues.count)
        let stdev = sqrt(variance)
        let consistency = max(0, 1 - (stdev / mean))
        
        return raw.map { (day, asleep, inBed) in
            // Efficiency metric
            let eff = inBed > 0 ? asleep / inBed : 0
            // Duration metric
            let dur = min(asleep / idealSleep, 1)
            // Holistic score 0…1
            let rawScore = wEfficiency * eff
            + wDuration   * dur
            + wConsistency * consistency
            // scale to 0…100
            let scorePercent = rawScore * 100
            
            return DailyMetric(
                date: day,
                asleep: asleep,
                inBed: inBed,
                score: scorePercent
            )
        }
    }
}

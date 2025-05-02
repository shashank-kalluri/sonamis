//
//  DailyMetric.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/1/25.
//

import Foundation
/// Holds the per-day metrics
struct DailyMetric: Identifiable {
    let id = UUID()
    let date: Date            // “display” date at 6 pm cutoff
    let asleep: TimeInterval  // total asleep seconds
    let inBed: TimeInterval   // total in-bed seconds
    let score: Double         // 0…100 holistic score
}

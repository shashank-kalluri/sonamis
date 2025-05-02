//
//  SleepData.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/1/25.
//

import Foundation
import HealthKit

enum SleepStage: CaseIterable, Codable {
  case inBed, awake, asleepUnspecified, asleepCore, asleepDeep, asleepREM

  init(hkValue: Int) {
    // Try to convert to HealthKit enum
    let hkStage = HKCategoryValueSleepAnalysis(rawValue: hkValue)
    switch hkStage {
    case .inBed:            self = .inBed
    case .awake:            self = .awake
    case .asleepUnspecified: self = .asleepUnspecified
    case .asleepCore:       self = .asleepCore
    case .asleepDeep:       self = .asleepDeep
    case .asleepREM:        self = .asleepREM
    default:                self = .asleepUnspecified
    }
  }

  var isAsleep: Bool {
    switch self {
    case .asleepUnspecified, .asleepCore, .asleepDeep, .asleepREM:
      return true
    default:
      return false
    }
  }
}

struct SleepData: Identifiable {
  let id = UUID()
  let start: Date
  let end: Date
  let stage: SleepStage

  var duration: TimeInterval { end.timeIntervalSince(start) }

  init(sample: HKCategorySample) {
    self.start = sample.startDate
    self.end   = sample.endDate
    self.stage = SleepStage(hkValue: sample.value)
  }
}

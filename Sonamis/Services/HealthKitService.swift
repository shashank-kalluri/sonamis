//
//  HealthKitService.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/1/25.
//

import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    private let store = HKHealthStore()
    
    @Published var sleepSamples: [SleepData] = []
    /// 1. Request read‐only access to sleepAnalysis
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false, HealthKitError.unavailable)
            return
        }
        store.requestAuthorization(toShare: [], read: [sleepType]) { success, err in
            DispatchQueue.main.async {
                print("🔑 HealthKit auth:", success, err?.localizedDescription ?? "")
                completion(success, err)
            }
        }
    }
    
    /// 2. Fetch all sleepAnalysis samples between `start` and `end`
    func fetchSleepData(start: Date, end: Date) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let predicate = HKQuery.predicateForSamples(
            withStart:  start,
            end:        end,
            options:    []
        )
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType:      sleepType,
            predicate:       predicate,
            limit:           HKObjectQueryNoLimit,
            sortDescriptors: [sort]
        ) { [weak self] _, results, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ HealthKit fetch error:", error)
                return
            }
            let hkSamples = results as? [HKCategorySample] ?? []
            let mapped = hkSamples.map { SleepData(sample: $0) }
            
            DispatchQueue.main.async {
                self.sleepSamples = mapped
            }
        }
        store.execute(query)
    }
    
}

enum HealthKitError: Error {
    case unavailable
}

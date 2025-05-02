//
//  SleepWindow.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/2/25.
//

import Foundation
struct SleepWindow: Identifiable {
    let id = UUID()
    let date: Date       // display date
    let start: Date      // actual sleep-start timestamp
    let end: Date        // actual wake-up timestamp
}

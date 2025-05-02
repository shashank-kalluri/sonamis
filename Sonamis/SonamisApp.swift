//  SonamisApp.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 4/25/25.
//

import SwiftUI

@main
struct SonamisApp: App {
    @StateObject private var privyManager = PrivyManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(privyManager)
                .preferredColorScheme(.dark)
                .font(.system(.body, design: .rounded))
        }
    }
}

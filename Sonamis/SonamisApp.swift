//
//  SonamisApp.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 4/25/25.
//

import SwiftUI

@main
struct SonamisApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis") }
                ChallengesView()
                    .tabItem { Label("Challenges", systemImage: "flag.fill") }
                FriendsView()
                    .tabItem { Label("Friends", systemImage: "person.2.fill") }
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            }
            .preferredColorScheme(.dark)
            .font(.system(.body, design: .rounded))
        }
    }
}

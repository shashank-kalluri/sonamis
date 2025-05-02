//
//  TabView.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/2/25.
//

import SwiftUI

struct TabView: View {
  var body: some View {
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
  }
}

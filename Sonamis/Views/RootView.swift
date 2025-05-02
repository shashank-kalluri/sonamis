//
//  RootView.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/1/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var manager: PrivyManager
    
    var body: some View {
        Group {
            if !manager.isReady {
                ProgressView("Initializing…")
            } else {
                switch manager.authState {
                case .notReady:
                    ProgressView()
                case .unauthenticated:
                    LoginView()
                case .authenticated(let user):
                    TabView()
                }
            }
        }
    }
}

//
//  ChallengesView.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/1/25.
//

import SwiftUI

struct ChallengesView: View {
    @State private var challenges: [String] = [
        "7‑Day Sleep Streak",
        "Weekend Deep‑Sleep Duel"
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CHALLENGES")
                        .font(.caption)
                        .foregroundColor(.teal)
                    Text("Your Challenges")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(challenges, id: \.self) { title in
                            HStack {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.teal)
                                Text(title)
                                    .foregroundColor(.primary)
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengesView()
    }
}

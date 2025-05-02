//
//  FriendsView.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/1/25.
//

import SwiftUI

struct FriendsView: View {
    @State private var friends: [String] = [
        "Alice", "Bob", "Charlie"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FRIENDS")
                        .font(.caption)
                        .foregroundColor(.teal)
                    Text("Your Friends")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(friends, id: \.self) { name in
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.teal)
                                Text(name)
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

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}

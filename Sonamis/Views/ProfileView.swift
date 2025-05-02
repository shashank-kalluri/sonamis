//
//  ProfileView.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/2/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var displayName: String = "Your Name"
    @State private var email: String = "you@example.com"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PROFILE")
                        .font(.caption)
                        .foregroundColor(.teal)
                    Text("Your Info")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.teal)
                    TextField("Enter your name", text: $displayName)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.teal)
                    TextField("you@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .foregroundColor(.primary)
                }
                
                Button {
                    // do sign-out flow
                } label: {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red)
                        )
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}

//
//  LoginView.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/1/25.
//

import SwiftUI

struct LoginView: View {
  @EnvironmentObject var manager: PrivyManager
  @State private var phone = ""
  @State private var code = ""
  @State private var isCodeSent = false
  @State private var errorMsg: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign in with SMS")
                .font(.title2).bold()

            TextField("Phone (+1…)", text: $phone)
                .keyboardType(.phonePad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if isCodeSent {
                TextField("Enter OTP", text: $code)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            if let err = errorMsg {
                Text(err)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                Task {
                    if !isCodeSent {
                        await sendSMS()
                    } else {
                        await verifyCode()
                    }
                }
            }) {
                Text(isCodeSent ? "Verify Code" : "Send Code")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.cornerRadius(8))
                    .foregroundColor(.white)
            }
            .disabled(isCodeSent ? code.count < 6 : phone.isEmpty)
        }
        .padding()
    }

    // Send OTP
    private func sendSMS() async {
      do {
        try await manager.sendSMSCode(to: phone)
        isCodeSent = true
        errorMsg = nil
      } catch {
        errorMsg = error.localizedDescription
      }
    }

    private func verifyCode() async {
      do {
        let user = try await manager.loginWithSMS(code: code, phone: phone)
        errorMsg = nil
        try await manager.autoCreateSolanaWalletIfNeeded(for: user)
        // authState changes to `.authenticated` -> RootView shows TabView
      } catch {
        errorMsg = error.localizedDescription
      }
    }
  }

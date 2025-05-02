//
//  PrivyManager.swift
//  Sonamis
//
//  Created by Shashank Kalluri on 5/2/25.
//

import Foundation
import Combine
import PrivySDK

/// An ObservableObject wrapper around Privy
final class PrivyManager: ObservableObject {
  // MARK: - Published state for SwiftUI
  @Published var authState: AuthState = .notReady
  @Published var isReady = false

  // MARK: - Underlying Privy instance
  let privy: Privy

  private var cancellables = Set<AnyCancellable>()

  init() {
    // Initialize Privy
    let config = PrivyConfig(
      appId:       "cma6e9di702jpl70mwzov41q3",
      appClientId: "client-WY6L7Ah4bncYt9Z5NyndAaZX5wEBfDrZ9tSaHnmHZ7r9E",
      loggingConfig: .init(logLevel: .verbose)
    )
    self.privy = PrivySdk.initialize(config: config)

    // Subscribe to Privy authStatePublisher
    privy.authStatePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newState in
        self?.authState = newState
      }
      .store(in: &cancellables)

    // Await Privy
    Task {
      await privy.awaitReady()
      await MainActor.run {
        self.isReady = true
      }
    }
  }

  func sendSMSCode(to phone: String) async throws {
    try await privy.sms.sendCode(to: phone)
  }

  func loginWithSMS(code: String, phone: String) async throws -> PrivyUser {
    try await privy.sms.loginWithCode(code, sentTo: phone)
  }

  func autoCreateSolanaWalletIfNeeded(for user: PrivyUser) async throws {
    if user.embeddedSolanaWallets.isEmpty {
      _ = try await user.createSolanaWallet()
    }
  }
}

//
//  LoginPage.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/23/24.
//

import SwiftUI
import SpotifyiOS
import LocalAuthentication

struct LoginScreen: View {
    private let keychainManager = KeychainManager()
    private let SEC = Sec.shared
    @State private var username: String = ""
    @State private var user_password: String = ""
    @State private var isLogin: Bool = true
    @State private var show_device_connect: Bool = false
    @State private var isLoading: Bool = false
    @State private var animateIn: Bool = false
    @StateObject private var loginManager = LoginManager.shared

    func createAccount() async -> Bool {
        let (public_key, private_key) = self.SEC.generateKeyPair()!
        if !keychainManager.savePrivateKey(private_key, for: "\(username)_audioshare_pkey") { return false }
        if !keychainManager.savePublicKey(public_key, for: "\(username)_audioshare_pubkey") { return false }
        if !keychainManager.saveCredentials(username: username, password: user_password) { return false }
        return await loginManager.createUser(username: username, password: user_password)
    }

    func authenticateUser() async -> Bool {
        return await loginManager.login(username: username, password: user_password)
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "080812"), Color(hex: "1A0640"), Color(hex: "591E7D")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient glow blobs
            Circle()
                .fill(Color(hex: "7B2FBE").opacity(0.22))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: -100, y: -220)

            Circle()
                .fill(Color(hex: "3D1080").opacity(0.28))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(x: 120, y: 320)

            VStack(spacing: 0) {
                // Logo / title area
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "A855F7"), Color(hex: "591E7D")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 84, height: 84)
                            .shadow(color: Color(hex: "A855F7").opacity(0.5), radius: 24, x: 0, y: 10)

                        Image(systemName: "waveform")
                            .font(.system(size: 38, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animateIn ? 1 : 0.4)
                    .opacity(animateIn ? 1 : 0)

                    Text("Audio Share")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(animateIn ? 1 : 0)

                    Text(isLogin ? "Welcome back" : "Create your account")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.55))
                        .animation(.easeInOut(duration: 0.2), value: isLogin)
                        .opacity(animateIn ? 1 : 0)
                }
                .padding(.top, 72)
                .padding(.bottom, 44)

                // Form card
                VStack(spacing: 16) {
                    AuthField(
                        icon: "person",
                        placeholder: "Username",
                        text: $username,
                        isSecure: false
                    )

                    AuthField(
                        icon: "lock",
                        placeholder: "Password",
                        text: $user_password,
                        isSecure: true
                    )

                    // Submit button
                    NavigationLink(destination: DeviceConnect()) {
                        Button(action: {
                            guard !username.isEmpty && !user_password.isEmpty else { return }
                            isLoading = true
                            Task {
                                if isLogin {
                                    let _ = await authenticateUser()
                                } else {
                                    let success = await createAccount()
                                    if success { show_device_connect = true }
                                }
                                isLoading = false
                            }
                        }) {
                            ZStack {
                                LinearGradient(
                                    colors: [Color(hex: "A855F7"), Color(hex: "591E7D")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .cornerRadius(14)

                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(isLogin ? "Log In" : "Create Account")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                        .animation(.easeInOut(duration: 0.2), value: isLogin)
                                }
                            }
                            .frame(height: 54)
                        }
                    }
                    .padding(.top, 6)

                    // Login / sign-up toggle
                    HStack(spacing: 6) {
                        Text(isLogin ? "Don't have an account?" : "Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.45))

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isLogin.toggle()
                            }
                        }) {
                            Text(isLogin ? "Sign up" : "Log in")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "C084FC"))
                        }
                    }
                    .padding(.top, 2)
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .offset(y: animateIn ? 0 : 50)
                .opacity(animateIn ? 1 : 0)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                animateIn = true
            }
        }
    }
}

struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isFocused ? Color(hex: "C084FC") : .white.opacity(0.35))
                .frame(width: 20)
                .animation(.easeInOut(duration: 0.15), value: isFocused)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .tint(Color(hex: "C084FC"))
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .tint(Color(hex: "C084FC"))
                    .focused($isFocused)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isFocused ? 0.12 : 0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? Color(hex: "C084FC").opacity(0.6) : Color.white.opacity(0.09),
                            lineWidth: 1
                        )
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

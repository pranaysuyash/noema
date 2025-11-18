import SwiftUI
import AuthenticationServices

/// Authentication view for sign in
public struct AuthenticationView: View {
    @EnvironmentObject var appState: AppState
    @State private var isSigningIn = false
    @State private var errorMessage: String?

    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // App logo and title
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                        .symbolEffect(.pulse)

                    Text("noema")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Your AI companion for emotional wellness")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Sign in options
                VStack(spacing: 16) {
                    // Sign in with Apple
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            handleSignInWithApple(result)
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .cornerRadius(12)

                    // Continue as guest
                    Button {
                        continueAsGuest()
                    } label: {
                        Text("Continue as Guest")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    // Privacy note
                    Text("By continuing, you agree to our Privacy Policy and Terms of Service")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .overlay {
            if isSigningIn {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
    }

    // MARK: - Private Methods

    private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        isSigningIn = true

        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // TODO: Send token to backend for verification
                let userId = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email

                print("Signed in with Apple ID: \(userId)")

                // For now, just mark as authenticated
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    appState.isAuthenticated = true
                    isSigningIn = false
                }
            }

        case .failure(let error):
            isSigningIn = false

            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled {
                // User canceled, don't show error
                return
            }

            errorMessage = "Failed to sign in: \(error.localizedDescription)"
        }
    }

    private func continueAsGuest() {
        isSigningIn = true

        // Create anonymous session
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appState.isAuthenticated = true
            isSigningIn = false
        }
    }
}

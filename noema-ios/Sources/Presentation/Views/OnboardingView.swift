import SwiftUI

/// Onboarding view for new users
public struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appState: AppState

    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: viewModel.progress)
                    .tint(.blue)
                    .padding(.horizontal)
                    .padding(.top)

                Spacer()

                // Step content
                VStack(spacing: 32) {
                    Image(systemName: viewModel.currentStepData.imageName)
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .symbolEffect(.bounce, value: viewModel.currentStep)

                    VStack(spacing: 16) {
                        Text(viewModel.currentStepData.title)
                            .font(.title.bold())
                            .multilineTextAlignment(.center)

                        Text(viewModel.currentStepData.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }

                Spacer()

                // Navigation buttons
                VStack(spacing: 16) {
                    Button {
                        Task {
                            await viewModel.nextStep()
                            if viewModel.currentStep == viewModel.steps.count {
                                appState.hasCompletedOnboarding = true
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.isLastStep ? "Get Started" : "Continue")
                                .font(.headline)

                            if !viewModel.isLastStep {
                                Image(systemName: "arrow.right")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isCompleting)

                    if !viewModel.isLastStep {
                        Button("Skip") {
                            Task {
                                await viewModel.skipOnboarding()
                                appState.hasCompletedOnboarding = true
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .overlay {
            if viewModel.isCompleting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
    }
}

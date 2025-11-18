import SwiftUI

/// ViewModel for onboarding flow
/// Guides new users through app features and setup
@MainActor
public final class OnboardingViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var currentStep: Int = 0
    @Published public var isCompleting: Bool = false
    @Published public var error: Error?

    // MARK: - Onboarding Steps

    public let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome to noema",
            description: "Your AI-powered companion for emotional wellness and mindful note-taking",
            imageName: "brain.head.profile",
            action: nil
        ),
        OnboardingStep(
            title: "Capture Your Thoughts",
            description: "Write or speak your thoughts. noema understands both your words and emotions",
            imageName: "note.text.badge.plus",
            action: nil
        ),
        OnboardingStep(
            title: "Track Your Emotional Journey",
            description: "See patterns in your mood over time and discover what influences your emotional wellbeing",
            imageName: "chart.line.uptrend.xyaxis",
            action: nil
        ),
        OnboardingStep(
            title: "Grow Your Virtual Garden",
            description: "Watch your garden bloom as you maintain streaks and achieve milestones",
            imageName: "leaf.fill",
            action: nil
        ),
        OnboardingStep(
            title: "Privacy First",
            description: "Your data stays on your device. AI processing happens locally by default",
            imageName: "lock.shield.fill",
            action: .requestNotifications
        )
    ]

    // MARK: - Computed Properties

    public var progress: Double {
        Double(currentStep + 1) / Double(steps.count)
    }

    public var isLastStep: Bool {
        currentStep == steps.count - 1
    }

    public var currentStepData: OnboardingStep {
        steps[currentStep]
    }

    // MARK: - Public Methods

    public func nextStep() async {
        guard currentStep < steps.count - 1 else {
            await completeOnboarding()
            return
        }

        // Handle step action if present
        if let action = currentStepData.action {
            await handleAction(action)
        }

        currentStep += 1
    }

    public func previousStep() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    public func skipOnboarding() async {
        await completeOnboarding()
    }

    // MARK: - Private Methods

    private func completeOnboarding() async {
        isCompleting = true

        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Set default settings
        UserDefaults.standard.set(true, forKey: "ai_moodDetectionEnabled")
        UserDefaults.standard.set(true, forKey: "ai_autoSummarization")
        UserDefaults.standard.set(true, forKey: "ai_entityExtraction")
        UserDefaults.standard.set(false, forKey: "ai_useCloudAI")

        // Slight delay for animation
        try? await Task.sleep(nanoseconds: 500_000_000)

        isCompleting = false
    }

    private func handleAction(_ action: OnboardingAction) async {
        switch action {
        case .requestNotifications:
            await requestNotificationPermission()
        }
    }

    private func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                print("Notification permission granted")
            }
        } catch {
            self.error = error
        }
    }
}

// MARK: - Onboarding Step

public struct OnboardingStep: Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let imageName: String
    public let action: OnboardingAction?
}

// MARK: - Onboarding Action

public enum OnboardingAction {
    case requestNotifications
}

// MARK: - UNUserNotificationCenter Extension

#if canImport(UserNotifications)
import UserNotifications
#endif

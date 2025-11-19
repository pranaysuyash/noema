//
//  View+Extensions.swift
//  Noema
//
//  Created on January 18, 2025.
//

import SwiftUI

extension View {
    // MARK: - Card Styling

    /// Apply card styling with shadow and rounded corners
    public func cardStyle(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) -> some View {
        self
            .background(Color.noemaCardBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }

    /// Apply emotion card styling with color accent
    public func emotionCardStyle(emotion: EmotionalState?) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.noemaCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                emotion != nil ?
                                Color.forEmotion(valence: emotion!.valence, arousal: emotion!.arousal)
                                : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    // MARK: - Conditional Modifiers

    /// Conditionally apply a modifier
    @ViewBuilder
    public func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Conditionally apply one of two modifiers
    @ViewBuilder
    public func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }

    // MARK: - Loading State

    /// Show loading overlay
    public func loading(_ isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    }
                }
            }
        )
    }

    // MARK: - Error Handling

    /// Show error alert
    public func errorAlert(error: Binding<Error?>) -> some View {
        self.alert(
            "Error",
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { if !$0 { error.wrappedValue = nil } }
            )
        ) {
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: {
            if let error = error.wrappedValue {
                Text(error.localizedDescription)
            }
        }
    }

    // MARK: - Keyboard Handling

    /// Dismiss keyboard on tap
    public func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - Empty State

    /// Show empty state when collection is empty
    @ViewBuilder
    public func emptyState<EmptyContent: View>(
        isEmpty: Bool,
        @ViewBuilder emptyContent: () -> EmptyContent
    ) -> some View {
        if isEmpty {
            emptyContent()
        } else {
            self
        }
    }

    // MARK: - Haptic Feedback

    /// Add haptic feedback on tap
    public func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
            }
        )
    }

    // MARK: - Animation

    /// Animate on appear
    public func animateOnAppear(delay: Double = 0, duration: Double = 0.3) -> some View {
        self.modifier(AnimateOnAppearModifier(delay: delay, duration: duration))
    }

    // MARK: - Navigation

    /// Custom navigation bar styling
    public func noemaNavigationBar(title: String, subtitle: String? = nil) -> some View {
        self.toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.noemaTextPrimary)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.noemaTextSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Measurement

    /// Read view size
    public func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

// MARK: - Supporting Types

private struct AnimateOnAppearModifier: ViewModifier {
    let delay: Double
    let duration: Double

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

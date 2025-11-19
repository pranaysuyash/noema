//
//  ThemeSettingsView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct ThemeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTheme: ThemeOption = .auto
    @State private var accentColor: AccentColor = .blue
    @State private var useMoodAdaptive = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Theme selection
                    ThemeSelectionSection(selectedTheme: $selectedTheme)

                    // Accent color
                    AccentColorSection(selectedColor: $accentColor)

                    // Mood-adaptive theme
                    MoodAdaptiveSection(isEnabled: $useMoodAdaptive)

                    // Preview
                    ThemePreviewSection(theme: selectedTheme, accentColor: accentColor)
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Theme Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    enum ThemeOption: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case auto = "Auto"
    }

    enum AccentColor: String, CaseIterable {
        case blue = "Blue"
        case purple = "Purple"
        case green = "Green"
        case orange = "Orange"
        case pink = "Pink"

        var color: Color {
            switch self {
            case .blue: return .blue
            case .purple: return .purple
            case .green: return .green
            case .orange: return .orange
            case .pink: return .pink
            }
        }
    }
}

private struct ThemeSelectionSection: View {
    @Binding var selectedTheme: ThemeSettingsView.ThemeOption

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appearance")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            ForEach(ThemeSettingsView.ThemeOption.allCases, id: \.self) { theme in
                ThemeOptionRow(
                    theme: theme,
                    isSelected: selectedTheme == theme
                ) {
                    selectedTheme = theme
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct ThemeOptionRow: View {
    let theme: ThemeSettingsView.ThemeOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.noemaTextPrimary)

                    Text(themeDescription)
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }

                Spacer()

                ThemePreviewCircles(theme: theme)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .noemaPrimary : .gray)
            }
            .padding()
            .background(isSelected ? Color.noemaPrimary.opacity(0.1) : Color.noemaCardBackground)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var themeDescription: String {
        switch theme {
        case .light:
            return "Always use light mode"
        case .dark:
            return "Always use dark mode"
        case .auto:
            return "Match system appearance"
        }
    }
}

private struct ThemePreviewCircles: View {
    let theme: ThemeSettingsView.ThemeOption

    var body: some View {
        HStack(spacing: 4) {
            switch theme {
            case .light:
                Circle().fill(Color.white).frame(width: 24, height: 24).overlay(Circle().stroke(Color.gray.opacity(0.3)))
            case .dark:
                Circle().fill(Color.black).frame(width: 24, height: 24)
            case .auto:
                HStack(spacing: 2) {
                    Circle().fill(Color.white).frame(width: 12, height: 12).overlay(Circle().stroke(Color.gray.opacity(0.3)))
                    Circle().fill(Color.black).frame(width: 12, height: 12)
                }
            }
        }
    }
}

private struct AccentColorSection: View {
    @Binding var selectedColor: ThemeSettingsView.AccentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accent Color")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            HStack(spacing: 16) {
                ForEach(ThemeSettingsView.AccentColor.allCases, id: \.self) { color in
                    AccentColorOption(
                        color: color,
                        isSelected: selectedColor == color
                    ) {
                        selectedColor = color
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct AccentColorOption: View {
    let color: ThemeSettingsView.AccentColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.color)
                        .frame(width: 44, height: 44)

                    if isSelected {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 44, height: 44)

                        Circle()
                            .stroke(color.color, lineWidth: 2)
                            .frame(width: 52, height: 52)
                    }
                }

                Text(color.rawValue)
                    .font(.caption)
                    .foregroundColor(.noemaTextPrimary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct MoodAdaptiveSection: View {
    @Binding var isEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $isEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mood-Adaptive Theme")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.noemaTextPrimary)

                    Text("Theme colors adapt to your current emotional state")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }
            }

            if isEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How it works:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.noemaTextPrimary)

                    HStack(spacing: 12) {
                        MoodExample(emoji: "😊", color: .joyColor, label: "Positive")
                        MoodExample(emoji: "😢", color: .sadnessColor, label: "Reflective")
                        MoodExample(emoji: "😌", color: .peacefulColor, label: "Calm")
                    }
                }
                .padding()
                .background(Color.noemaPrimary.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct MoodExample: View {
    let emoji: String
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(emoji)
                        .font(.title3)
                )

            Text(label)
                .font(.caption2)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ThemePreviewSection: View {
    let theme: ThemeSettingsView.ThemeOption
    let accentColor: ThemeSettingsView.AccentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            VStack(spacing: 16) {
                // Sample card
                HStack {
                    Circle()
                        .fill(accentColor.color)
                        .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sample Note")
                            .font(.headline)
                            .foregroundColor(.noemaTextPrimary)

                        Text("This is how your notes will look")
                            .font(.caption)
                            .foregroundColor(.noemaTextSecondary)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.noemaCardBackground)
                .cornerRadius(12)

                // Sample button
                HStack {
                    Spacer()

                    Button {} label: {
                        Text("Sample Button")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(accentColor.color)
                            .cornerRadius(10)
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    ThemeSettingsView()
}

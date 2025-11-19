//
//  PrivacyDashboardView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct PrivacyDashboardView: View {
    @StateObject private var viewModel = SettingsViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Privacy score
                    PrivacyScoreCard()

                    // Data processing preference
                    DataProcessingSection(viewModel: viewModel)

                    // Data collected
                    DataCollectedSection()

                    // Third-party sharing
                    ThirdPartySharingSection()

                    // Your rights
                    YourRightsSection()

                    // Transparency
                    TransparencySection()
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Privacy Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct PrivacyScoreCard: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: 0.95)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("95")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.noemaTextPrimary)

                    Text("Privacy Score")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }
            }

            Text("Excellent Privacy Protection")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            Text("Your data is encrypted and processed on-device")
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .cardStyle()
    }
}

private struct DataProcessingSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Processing")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            VStack(spacing: 12) {
                ProcessingOption(
                    title: "On-Device Only",
                    description: "All AI processing happens on your device. Maximum privacy, may be slower.",
                    isSelected: true
                )

                ProcessingOption(
                    title: "Hybrid (Cloud AI)",
                    description: "Use cloud AI for better summaries. Data is encrypted and never stored.",
                    isSelected: false
                )
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct ProcessingOption: View {
    let title: String
    let description: String
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .green : .gray)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.noemaTextPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }
        }
        .padding()
        .background(isSelected ? Color.green.opacity(0.1) : Color.noemaCardBackground)
        .cornerRadius(10)
    }
}

private struct DataCollectedSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data We Collect")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            DataItem(icon: "note.text", label: "Notes", detail: "Encrypted on device")
            DataItem(icon: "waveform", label: "Voice recordings", detail: "Stored locally")
            DataItem(icon: "face.smiling", label: "Emotion data", detail: "Never leaves device")
            DataItem(icon: "location", label: "Location (optional)", detail: "Only when you enable it")
        }
        .padding()
        .cardStyle()
    }
}

private struct DataItem: View {
    let icon: String
    let label: String
    let detail: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.noemaPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.noemaTextPrimary)

                Text(detail)
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }

            Spacer()

            Image(systemName: "lock.fill")
                .foregroundColor(.green)
                .font(.caption)
        }
    }
}

private struct ThirdPartySharingSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Third-Party Sharing")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                    .font(.title)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Zero Third-Party Sharing")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.noemaTextPrimary)

                    Text("We never sell or share your data with third parties")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct YourRightsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Rights")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            RightRow(icon: "arrow.down.doc", title: "Access Your Data", description: "Export all your data anytime")
            RightRow(icon: "trash", title: "Delete Your Data", description: "Permanently delete all data")
            RightRow(icon: "hand.raised", title: "Opt Out", description: "Disable cloud features anytime")
        }
        .padding()
        .cardStyle()
    }
}

private struct RightRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.noemaPrimary)
                .font(.title3)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaTextPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }
        }
    }
}

private struct TransparencySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transparency Report")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            VStack(spacing: 12) {
                TransparencyItem(label: "Data requests received", value: "0")
                TransparencyItem(label: "User data disclosed", value: "0")
                TransparencyItem(label: "Security incidents", value: "0")
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct TransparencyItem: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.noemaTextPrimary)
        }
    }
}

#Preview {
    PrivacyDashboardView()
}

//
//  SubscriptionView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: SubscriptionTier = .pro

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.xpGold)

                        Text("Upgrade to Noema Pro")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.noemaTextPrimary)

                        Text("Unlock advanced features and support development")
                            .font(.subheadline)
                            .foregroundColor(.noemaTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // Feature comparison
                    FeatureComparisonSection()

                    // Subscription tiers
                    VStack(spacing: 16) {
                        SubscriptionTierCard(
                            tier: .pro,
                            price: "$4.99",
                            period: "month",
                            isSelected: selectedTier == .pro
                        ) {
                            selectedTier = .pro
                        }

                        SubscriptionTierCard(
                            tier: .proYearly,
                            price: "$49.99",
                            period: "year",
                            savings: "Save 17%",
                            isSelected: selectedTier == .proYearly
                        ) {
                            selectedTier = .proYearly
                        }

                        SubscriptionTierCard(
                            tier: .lifetime,
                            price: "$99.99",
                            period: "one-time",
                            savings: "Best Value",
                            isSelected: selectedTier == .lifetime
                        ) {
                            selectedTier = .lifetime
                        }
                    }

                    // Subscribe button
                    Button {
                        // Handle subscription
                    } label: {
                        Text("Subscribe Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.noemaPrimary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Fine print
                    Text("Cancel anytime. All subscriptions include a 7-day free trial.")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
            .background(Color.noemaBackground)
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

    enum SubscriptionTier {
        case pro
        case proYearly
        case lifetime
    }
}

private struct FeatureComparisonSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's Included")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            FeatureRow(icon: "checkmark.circle.fill", feature: "Unlimited notes & voice recordings", isPro: false)
            FeatureRow(icon: "checkmark.circle.fill", feature: "Advanced AI insights & summaries", isPro: true)
            FeatureRow(icon: "checkmark.circle.fill", feature: "Knowledge graph visualization", isPro: true)
            FeatureRow(icon: "checkmark.circle.fill", feature: "iCloud sync across devices", isPro: true)
            FeatureRow(icon: "checkmark.circle.fill", feature: "Export data in multiple formats", isPro: true)
            FeatureRow(icon: "checkmark.circle.fill", feature: "Custom themes & personalization", isPro: true)
            FeatureRow(icon: "checkmark.circle.fill", feature: "Priority support", isPro: true)
        }
        .padding()
        .cardStyle()
    }
}

private struct FeatureRow: View {
    let icon: String
    let feature: String
    let isPro: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(isPro ? .xpGold : .noemaPrimary)

            Text(feature)
                .font(.subheadline)
                .foregroundColor(.noemaTextPrimary)

            Spacer()

            if isPro {
                Text("PRO")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.xpGold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.xpGold.opacity(0.2))
                    .cornerRadius(4)
            }
        }
    }
}

private struct SubscriptionTierCard: View {
    let tier: SubscriptionView.SubscriptionTier
    let price: String
    let period: String
    var savings: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tierName)
                            .font(.headline)
                            .foregroundColor(.noemaTextPrimary)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(price)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.noemaTextPrimary)

                            Text("/ \(period)")
                                .font(.caption)
                                .foregroundColor(.noemaTextSecondary)
                        }
                    }

                    Spacer()

                    if let savings = savings {
                        Text(savings)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                    }

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .noemaPrimary : .gray)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.noemaCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.noemaPrimary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var tierName: String {
        switch tier {
        case .pro: return "Pro Monthly"
        case .proYearly: return "Pro Yearly"
        case .lifetime: return "Lifetime"
        }
    }
}

#Preview {
    SubscriptionView()
}

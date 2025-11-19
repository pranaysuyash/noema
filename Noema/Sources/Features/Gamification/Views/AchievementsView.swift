//
//  AchievementsView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct AchievementsView: View {
    @StateObject private var viewModel = GamificationViewModel()
    @State private var selectedCategory: AchievementCategory?
    @State private var selectedAchievement: Achievement?

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats overview
                    AchievementStatsSection(viewModel: viewModel)

                    // Category filter
                    CategoryFilterSection(selectedCategory: $selectedCategory)

                    // Unlocked achievements
                    if !viewModel.unlockedAchievements.isEmpty {
                        AchievementSection(
                            title: "Unlocked",
                            achievements: filteredAchievements(viewModel.unlockedAchievements),
                            onSelect: { selectedAchievement = $0 }
                        )
                    }

                    // Locked achievements (in progress)
                    if !viewModel.lockedAchievements.isEmpty {
                        AchievementSection(
                            title: "In Progress",
                            achievements: filteredAchievements(viewModel.lockedAchievements),
                            onSelect: { selectedAchievement = $0 }
                        )
                    }
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Achievements")
            .sheet(item: $selectedAchievement) { achievement in
                AchievementDetailSheet(achievement: achievement)
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .task {
                await viewModel.loadAchievements()
            }
        }
    }

    private func filteredAchievements(_ achievements: [Achievement]) -> [Achievement] {
        guard let category = selectedCategory else { return achievements }
        return achievements.filter { $0.category == category }
    }
}

// MARK: - Supporting Views

private struct AchievementStatsSection: View {
    @ObservedObject var viewModel: GamificationViewModel

    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "star.fill",
                label: "Unlocked",
                value: "\(viewModel.unlockedAchievements.count)",
                color: .xpGold
            )

            StatCard(
                icon: "target",
                label: "In Progress",
                value: "\(viewModel.lockedAchievements.count)",
                color: .blue
            )

            StatCard(
                icon: "percent",
                label: "Completion",
                value: "\(completionPercentage)%",
                color: .noemaPrimary
            )
        }
    }

    private var completionPercentage: Int {
        let total = viewModel.unlockedAchievements.count + viewModel.lockedAchievements.count
        guard total > 0 else { return 0 }
        return Int(Double(viewModel.unlockedAchievements.count) / Double(total) * 100)
    }
}

private struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.noemaTextPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

private struct CategoryFilterSection: View {
    @Binding var selectedCategory: AchievementCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryPill(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach([AchievementCategory.consistency, .emotionalIntelligence, .relationships, .wellness, .insights], id: \.self) { category in
                    CategoryPill(
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
}

private struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .noemaTextPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.noemaPrimary : Color.noemaCardBackground)
                .cornerRadius(20)
        }
    }
}

private struct AchievementSection: View {
    let title: String
    let achievements: [Achievement]
    let onSelect: (Achievement) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(achievements) { achievement in
                    AchievementCard(achievement: achievement)
                        .onTapGesture {
                            onSelect(achievement)
                        }
                }
            }
        }
    }
}

private struct AchievementCard: View {
    @ObservedObject var achievement: Achievement

    var body: some View {
        VStack(spacing: 12) {
            // Badge
            ZStack {
                Circle()
                    .fill(
                        achievement.isCompleted ?
                        Color(hex: achievement.rarity.color).opacity(0.3) :
                        Color.gray.opacity(0.2)
                    )
                    .frame(width: 70, height: 70)

                if achievement.isCompleted {
                    Image(systemName: achievement.iconName)
                        .font(.title)
                        .foregroundColor(Color(hex: achievement.rarity.color))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }

            // Title
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.noemaTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)

            // Progress bar (for incomplete)
            if !achievement.isCompleted {
                VStack(spacing: 4) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                                .cornerRadius(2)

                            Rectangle()
                                .fill(Color.noemaPrimary)
                                .frame(
                                    width: geometry.size.width * achievement.progressPercentage,
                                    height: 4
                                )
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 4)

                    Text("\(achievement.progress)/\(achievement.requiredValue)")
                        .font(.caption2)
                        .foregroundColor(.noemaTextSecondary)
                }
            } else {
                // Rarity badge
                Text(achievement.rarity.rawValue.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: achievement.rarity.color))
            }
        }
        .padding()
        .cardStyle()
        .opacity(achievement.isCompleted ? 1.0 : 0.7)
    }
}

private struct AchievementDetailSheet: View {
    @ObservedObject var achievement: Achievement
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Large badge
                    ZStack {
                        Circle()
                            .fill(
                                achievement.isCompleted ?
                                Color(hex: achievement.rarity.color).opacity(0.3) :
                                Color.gray.opacity(0.2)
                            )
                            .frame(width: 120, height: 120)

                        if achievement.isCompleted {
                            Image(systemName: achievement.iconName)
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: achievement.rarity.color))
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                    }

                    // Title and description
                    VStack(spacing: 8) {
                        Text(achievement.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.noemaTextPrimary)
                            .multilineTextAlignment(.center)

                        Text(achievement.achievementDescription)
                            .font(.subheadline)
                            .foregroundColor(.noemaTextSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Rarity
                    HStack(spacing: 8) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .foregroundColor(
                                    index < rarityStars ?
                                    Color(hex: achievement.rarity.color) :
                                    Color.gray.opacity(0.3)
                                )
                        }
                    }
                    .font(.title3)

                    Divider()

                    // Details
                    VStack(spacing: 16) {
                        DetailRow(
                            label: "Category",
                            value: achievement.category.displayName
                        )

                        DetailRow(
                            label: "Rarity",
                            value: achievement.rarity.rawValue.capitalized
                        )

                        DetailRow(
                            label: "XP Reward",
                            value: "+\(achievement.xpReward) XP"
                        )

                        if achievement.isCompleted, let date = achievement.unlockedAt {
                            DetailRow(
                                label: "Unlocked",
                                value: date.formatted(date: .long, time: .omitted)
                            )
                        } else {
                            DetailRow(
                                label: "Progress",
                                value: "\(achievement.progress) / \(achievement.requiredValue)"
                            )

                            ProgressView(value: achievement.progressPercentage)
                                .tint(.noemaPrimary)
                        }
                    }
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

    private var rarityStars: Int {
        switch achievement.rarity {
        case .common: return 1
        case .uncommon: return 2
        case .rare: return 3
        case .epic: return 4
        case .legendary: return 5
        }
    }
}

private struct DetailRow: View {
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
                .fontWeight(.medium)
                .foregroundColor(.noemaTextPrimary)
        }
        .padding()
        .background(Color.noemaCardBackground)
        .cornerRadius(10)
    }
}

extension AchievementCategory {
    var displayName: String {
        rawValue.capitalized
    }
}

#Preview {
    AchievementsView()
}

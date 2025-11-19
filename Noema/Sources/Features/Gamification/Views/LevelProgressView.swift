//
//  LevelProgressView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct LevelProgressView: View {
    @StateObject private var viewModel = GamificationViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current level card
                    CurrentLevelCard(viewModel: viewModel)

                    // XP breakdown
                    XPBreakdownSection(viewModel: viewModel)

                    // Rewards
                    LevelRewardsSection(viewModel: viewModel)

                    // Stats
                    StatsSection(viewModel: viewModel)
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Level \(viewModel.level)")
            .loading(viewModel.isLoading)
            .task {
                await viewModel.loadProgress()
            }
        }
    }
}

private struct CurrentLevelCard: View {
    @ObservedObject var viewModel: GamificationViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Level circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.noemaPrimary, Color.noemaPrimary.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                VStack(spacing: 4) {
                    Text("LEVEL")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))

                    Text("\(viewModel.level)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            // XP progress
            VStack(spacing: 8) {
                HStack {
                    Text("\(viewModel.totalXP) XP")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.noemaTextPrimary)

                    Spacer()

                    Text("\(viewModel.xpForNextLevel) XP to next level")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .cornerRadius(6)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.xpGold, Color.xpGold.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.xpProgress, height: 12)
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct XPBreakdownSection: View {
    @ObservedObject var viewModel: GamificationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("XP Sources")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            XPSourceRow(icon: "note.text", label: "Notes Created", xp: 150)
            XPSourceRow(icon: "waveform", label: "Voice Notes", xp: 75)
            XPSourceRow(icon: "star.fill", label: "Achievements", xp: 200)
            XPSourceRow(icon: "target", label: "Quests Completed", xp: 125)
        }
        .padding()
        .cardStyle()
    }
}

private struct XPSourceRow: View {
    let icon: String
    let label: String
    let xp: Int

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.noemaPrimary)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.noemaTextPrimary)

            Spacer()

            Text("+\(xp) XP")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.xpGold)
        }
    }
}

private struct LevelRewardsSection: View {
    @ObservedObject var viewModel: GamificationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Level Rewards")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            RewardRow(level: viewModel.level + 1, reward: "New garden element")
            RewardRow(level: viewModel.level + 5, reward: "Streak freeze token")
            RewardRow(level: viewModel.level + 10, reward: "Special achievement badge")
        }
        .padding()
        .cardStyle()
    }
}

private struct RewardRow: View {
    let level: Int
    let reward: String

    var body: some View {
        HStack {
            Text("Level \(level)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.noemaPrimary)

            Spacer()

            Text(reward)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .padding()
        .background(Color.noemaPrimary.opacity(0.1))
        .cornerRadius(10)
    }
}

private struct StatsSection: View {
    @ObservedObject var viewModel: GamificationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(icon: "calendar", label: "Current Streak", value: "\(viewModel.currentStreak)")
                StatCard(icon: "flame.fill", label: "Longest Streak", value: "\(viewModel.longestStreak)")
                StatCard(icon: "note.text", label: "Total Notes", value: "\(viewModel.totalNotes)")
                StatCard(icon: "star.fill", label: "Total XP", value: "\(viewModel.totalXP)")
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct StatCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.noemaPrimary)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.noemaTextPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.noemaCardBackground)
        .cornerRadius(10)
    }
}

#Preview {
    LevelProgressView()
}

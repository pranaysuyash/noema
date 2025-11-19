//
//  StreakView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct StreakView: View {
    @StateObject private var viewModel = GamificationViewModel()
    @State private var showingFreezeConfirmation = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current streak card
                    CurrentStreakCard(viewModel: viewModel)

                    // Streak calendar
                    StreakCalendarSection()

                    // Freeze tokens
                    FreezeTokensSection(
                        viewModel: viewModel,
                        showingFreezeConfirmation: $showingFreezeConfirmation
                    )

                    // Milestones
                    MilestonesSection(viewModel: viewModel)

                    // Stats
                    StreakStatsSection(viewModel: viewModel)
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Streak")
            .alert("Use Streak Freeze?", isPresented: $showingFreezeConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Use Freeze") {
                    Task {
                        await viewModel.useStreakFreeze()
                    }
                }
            } message: {
                Text("This will protect your streak from breaking. You have \(viewModel.streakFreezes) freeze tokens available.")
            }
            .loading(viewModel.isLoading)
            .task {
                await viewModel.loadStreak()
            }
        }
    }
}

private struct CurrentStreakCard: View {
    @ObservedObject var viewModel: GamificationViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Flame animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 120, height: 120)
                    .opacity(0.3)

                Text("🔥")
                    .font(.system(size: 70))
            }

            VStack(spacing: 8) {
                Text("\(viewModel.currentStreak)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.noemaTextPrimary)

                Text(viewModel.currentStreak == 1 ? "Day Streak" : "Days Streak")
                    .font(.title3)
                    .foregroundColor(.noemaTextSecondary)
            }

            if viewModel.currentStreak > 0 {
                Text("Keep it going! Journal today to continue your streak")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Start your journaling streak today!")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct StreakCalendarSection: View {
    @State private var selectedMonth = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Activity")
                    .font(.headline)
                    .foregroundColor(.noemaTextPrimary)

                Spacer()

                Button(action: {}) {
                    Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.subheadline)
                        .foregroundColor(.noemaPrimary)
                }
            }

            // Simple calendar grid (placeholder - real implementation would use actual dates)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<28) { day in
                    CalendarDayCell(hasEntry: Bool.random())
                }
            }

            HStack(spacing: 16) {
                LegendItem(color: .noemaPrimary, label: "Journaled")
                LegendItem(color: .gray.opacity(0.2), label: "Missed")
            }
            .font(.caption)
        }
        .padding()
        .cardStyle()
    }
}

private struct CalendarDayCell: View {
    let hasEntry: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(hasEntry ? Color.noemaPrimary : Color.gray.opacity(0.2))
            .frame(height: 30)
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .foregroundColor(.noemaTextSecondary)
        }
    }
}

private struct FreezeTokensSection: View {
    @ObservedObject var viewModel: GamificationViewModel
    @Binding var showingFreezeConfirmation: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Streak Freeze Tokens")
                        .font(.headline)
                        .foregroundColor(.noemaTextPrimary)

                    Text("Protect your streak from breaking")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    ForEach(0..<max(viewModel.streakFreezes, 1), id: \.self) { _ in
                        Image(systemName: "snowflake")
                            .foregroundColor(.blue)
                    }
                }
                .font(.title2)
            }

            if viewModel.streakFreezes > 0 {
                Button {
                    showingFreezeConfirmation = true
                } label: {
                    Text("Use Freeze Token")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            } else {
                Text("Earn freeze tokens by leveling up (every 5 levels)")
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct MilestonesSection: View {
    @ObservedObject var viewModel: GamificationViewModel

    private let milestones = [7, 14, 30, 60, 100, 365]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            ForEach(milestones, id: \.self) { milestone in
                MilestoneRow(
                    days: milestone,
                    isAchieved: viewModel.longestStreak >= milestone,
                    isCurrent: viewModel.currentStreak >= milestone
                )
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct MilestoneRow: View {
    let days: Int
    let isAchieved: Bool
    let isCurrent: Bool

    var body: some View {
        HStack {
            Image(systemName: isAchieved ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isAchieved ? .green : .gray.opacity(0.3))

            Text("\(days) Days")
                .font(.subheadline)
                .fontWeight(isCurrent ? .semibold : .regular)
                .foregroundColor(.noemaTextPrimary)

            Spacer()

            if isCurrent && isAchieved {
                Text("Current")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.noemaPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.noemaPrimary.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
}

private struct StreakStatsSection: View {
    @ObservedObject var viewModel: GamificationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            HStack(spacing: 12) {
                StatCard(
                    icon: "flame.fill",
                    label: "Current Streak",
                    value: "\(viewModel.currentStreak)",
                    color: .orange
                )

                StatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Longest Streak",
                    value: "\(viewModel.longestStreak)",
                    color: .green
                )
            }

            HStack(spacing: 12) {
                StatCard(
                    icon: "snowflake",
                    label: "Freezes Available",
                    value: "\(viewModel.streakFreezes)",
                    color: .blue
                )

                StatCard(
                    icon: "calendar",
                    label: "Total Days",
                    value: "\(viewModel.totalNoteDays)",
                    color: .purple
                )
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
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    StreakView()
}

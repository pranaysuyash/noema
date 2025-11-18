import SwiftUI

/// Achievement list view showing all achievements
public struct AchievementListView: View {
    @StateObject private var viewModel: AchievementListViewModel

    public init() {
        _viewModel = StateObject(wrappedValue: AchievementListViewModel(
            achievementRepository: CoreDataAchievementRepository(coreDataStack: .shared)
        ))
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header stats
            HStack {
                VStack {
                    Text("\(viewModel.unlockedCount)")
                        .font(.title.bold())

                    Text("Unlocked")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()

                VStack {
                    Text("\(viewModel.totalAchievements)")
                        .font(.title.bold())

                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()

                VStack {
                    Text(String(format: "%.0f%%", viewModel.completionPercentage))
                        .font(.title.bold())

                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 80)
            .background(Color.secondary.opacity(0.1))

            // Filter picker
            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(AchievementFilter.allCases) { filter in
                    Text(filter.displayName).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Achievement list
            ScrollView {
                LazyVStack(spacing: 12) {
                    if !viewModel.unlockedAchievements.isEmpty {
                        Section {
                            ForEach(viewModel.unlockedAchievements) { achievement in
                                AchievementCardView(achievement: achievement)
                            }
                        } header: {
                            Text("Unlocked")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if !viewModel.lockedAchievements.isEmpty {
                        Section {
                            ForEach(viewModel.lockedAchievements) { achievement in
                                AchievementCardView(achievement: achievement)
                            }
                        } header: {
                            Text("Locked")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Achievements")
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadAchievements()
        }
    }
}

// MARK: - Achievement Card View

public struct AchievementCardView: View {
    let achievement: Achievement

    public var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(tierColor.opacity(achievement.isUnlocked ? 1.0 : 0.3))
                    .frame(width: 60, height: 60)

                Image(systemName: achievement.isUnlocked ? "star.fill" : "lock.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)

                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                if !achievement.isUnlocked {
                    ProgressView(value: Double(achievement.progress))
                        .tint(tierColor)
                }
            }

            Spacer()

            // Tier badge
            Text(achievement.tier.displayName)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tierColor.opacity(0.2))
                .foregroundColor(tierColor)
                .cornerRadius(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.isUnlocked ? tierColor.opacity(0.1) : Color.secondary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(tierColor.opacity(achievement.isUnlocked ? 0.5 : 0.1), lineWidth: 2)
        )
    }

    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return .brown
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .purple
        case .legendary: return .orange
        }
    }
}

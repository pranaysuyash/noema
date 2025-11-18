import SwiftUI

/// Level progress view showing user's level and XP
public struct LevelProgressView: View {
    @StateObject private var viewModel: LevelProgressViewModel

    public init() {
        _viewModel = StateObject(wrappedValue: LevelProgressViewModel(
            userProfileRepository: CoreDataUserProfileRepository(coreDataStack: .shared)
        ))
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Level circle
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 15)

                Circle()
                    .trim(from: 0, to: viewModel.progressToNextLevel)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: viewModel.progressToNextLevel)

                VStack(spacing: 4) {
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(viewModel.currentLevel)")
                        .font(.system(size: 48, weight: .bold))

                    Text("\(viewModel.currentExperience) / \(viewModel.experienceForNextLevel) XP")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 200, height: 200)

            // Next milestones
            VStack(alignment: .leading, spacing: 12) {
                Text("Upcoming Milestones")
                    .font(.headline)

                ForEach(viewModel.nextMilestones) { milestone in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Level \(milestone.level)")
                                .font(.subheadline.bold())

                            ForEach(milestone.rewards, id: \.self) { reward in
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.blue)

                                    Text(reward)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Spacer()

                        Text("\(milestone.requiredExperience) XP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .task {
            await viewModel.loadProgress()
        }
    }
}

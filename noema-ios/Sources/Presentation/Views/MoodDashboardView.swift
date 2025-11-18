import SwiftUI

/// Mood dashboard showing overview and patterns
public struct MoodDashboardView: View {
    @StateObject private var viewModel: MoodDashboardViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator

    public init() {
        let coreDataStack = CoreDataStack.shared
        _viewModel = StateObject(wrappedValue: MoodDashboardViewModel(
            moodRepository: CoreDataMoodRepository(coreDataStack: coreDataStack),
            noteRepository: CoreDataNoteRepository(coreDataStack: coreDataStack)
        ))
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Current mood
                if let currentMood = viewModel.currentMood {
                    CurrentMoodCard(mood: currentMood)
                }

                // Mood streak
                StreakCard(streak: viewModel.moodStreak)

                // Time range picker
                Picker("Time Range", selection: .constant(viewModel.selectedTimeRange)) {
                    ForEach(MoodTimeRange.allCases) { range in
                        Text(range.title).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Average mood
                if let averageMood = viewModel.averageMood {
                    AverageMoodCard(dimensions: averageMood)
                }

                // Emotion distribution
                if !viewModel.emotionDistribution.isEmpty {
                    EmotionDistributionCard(distribution: viewModel.emotionDistribution)
                }

                // Mood patterns
                if !viewModel.moodPatterns.isEmpty {
                    MoodPatternsCard(patterns: viewModel.moodPatterns)
                }

                // Quick actions
                HStack(spacing: 16) {
                    Button {
                        appCoordinator.moodCoordinator?.showMoodLog()
                    } label: {
                        Label("Log Mood", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button {
                        appCoordinator.moodCoordinator?.showTimeline()
                    } label: {
                        Label("Timeline", systemImage: "chart.line.uptrend.xyaxis")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Mood")
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadDashboard()
        }
        .sheet(isPresented: $appCoordinator.moodCoordinator!.isPresentingMoodLog) {
            MoodLogView()
        }
    }
}

// MARK: - Current Mood Card

struct CurrentMoodCard: View {
    let mood: MoodSnapshot

    var body: some View {
        VStack(spacing: 16) {
            Text("Current Mood")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(moodEmoji(for: mood.dimensions.dominantEmotion))
                .font(.system(size: 80))

            Text(mood.dimensions.dominantEmotion.capitalized)
                .font(.title.bold())

            Text(mood.timestamp, style: .relative) + Text(" ago")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func moodEmoji(for emotion: String) -> String {
        switch emotion.lowercased() {
        case "joy": return "😊"
        case "sadness": return "😢"
        case "anger": return "😠"
        case "fear": return "😰"
        case "surprise": return "😲"
        case "disgust": return "🤢"
        case "trust": return "🤗"
        case "anticipation": return "🤩"
        default: return "😐"
        }
    }
}

// MARK: - Streak Card

struct StreakCard: View {
    let streak: Int

    var body: some View {
        HStack {
            Image(systemName: "flame.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)

            VStack(alignment: .leading) {
                Text("\(streak) Day Streak")
                    .font(.title2.bold())

                Text("Keep it going!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Average Mood Card

struct AverageMoodCard: View {
    let dimensions: EmotionalDimensions

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Average Mood")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Valence")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ProgressView(value: Double((dimensions.valence + 1) / 2))
                        .tint(dimensions.valence > 0 ? .green : .red)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(dimensions.valence > 0 ? "Positive" : "Negative")
                        .font(.caption.bold())

                    Text(String(format: "%.1f", dimensions.valence))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Emotion Distribution Card

struct EmotionDistributionCard: View {
    let distribution: [String: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emotion Distribution")
                .font(.headline)

            ForEach(distribution.sorted(by: { $0.value > $1.value }), id: \.key) { emotion, count in
                HStack {
                    Text(emotion.capitalized)
                        .font(.subheadline)

                    Spacer()

                    Text("\(count)")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)

                    ProgressView(value: Double(count), total: Double(distribution.values.reduce(0, +)))
                        .frame(width: 100)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Mood Patterns Card

struct MoodPatternsCard: View {
    let patterns: [MoodPattern]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)

            ForEach(patterns, id: \.title) { pattern in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(pattern.title)
                            .font(.subheadline.bold())

                        Text(pattern.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

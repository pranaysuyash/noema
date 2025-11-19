//
//  MoodPatternsView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI
import Charts

public struct MoodPatternsView: View {
    @StateObject private var viewModel = MoodDashboardViewModel()
    @State private var selectedPattern: EmotionalPattern?

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Pattern Detection Card
                    PatternDetectionCard(patternCount: viewModel.moodPatterns.count)

                    // Patterns List
                    if viewModel.moodPatterns.isEmpty {
                        EmptyPatternsView()
                    } else {
                        ForEach(viewModel.moodPatterns, id: \.id) { pattern in
                            PatternDetailCard(pattern: pattern)
                                .onTapGesture {
                                    selectedPattern = pattern
                                }
                        }
                    }

                    // Time-of-Day Patterns
                    TimeOfDayPatternsSection()

                    // Day-of-Week Patterns
                    DayOfWeekPatternsSection()

                    // Predictions
                    PredictionsSection(viewModel: viewModel)
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Mood Patterns")
            .sheet(item: $selectedPattern) { pattern in
                PatternDetailsSheet(pattern: pattern)
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .task {
                await viewModel.fetchMoodData()
            }
        }
    }
}

// MARK: - Supporting Views

private struct PatternDetectionCard: View {
    let patternCount: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundColor(.noemaPrimary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Patterns Detected")
                        .font(.headline)
                        .foregroundColor(.noemaTextPrimary)

                    Text("AI has identified \(patternCount) emotional patterns")
                        .font(.subheadline)
                        .foregroundColor(.noemaTextSecondary)
                }

                Spacer()
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct PatternDetailCard: View {
    let pattern: EmotionalPattern

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(pattern.color)
                    .frame(width: 12, height: 12)

                Text(pattern.name)
                    .font(.headline)
                    .foregroundColor(.noemaTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }

            Text(pattern.description)
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)

            HStack {
                Label("Confidence: \(Int(pattern.confidence * 100))%", systemImage: "chart.bar.fill")
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)

                Spacer()

                Label("\(pattern.occurrences) occurrences", systemImage: "repeat")
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct EmptyPatternsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48))
                .foregroundColor(.noemaTextSecondary)

            Text("No Patterns Yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.noemaTextPrimary)

            Text("Keep logging your emotions to discover patterns")
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .cardStyle()
    }
}

private struct TimeOfDayPatternsSection: View {
    // Mock data - in real implementation, this would come from the view model
    private let timeData: [TimeOfDayData] = [
        TimeOfDayData(time: "Morning", valence: 0.6, count: 12),
        TimeOfDayData(time: "Afternoon", valence: 0.3, count: 8),
        TimeOfDayData(time: "Evening", valence: 0.4, count: 15),
        TimeOfDayData(time: "Night", valence: -0.2, count: 6),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time of Day Patterns")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            Chart(timeData) { item in
                BarMark(
                    x: .value("Time", item.time),
                    y: .value("Valence", item.valence)
                )
                .foregroundStyle(item.valence > 0 ? Color.joyColor : Color.sadnessColor)
                .annotation(position: .top) {
                    Text("\(Int(item.valence * 100))")
                        .font(.caption2)
                        .foregroundColor(.noemaTextSecondary)
                }
            }
            .frame(height: 200)
            .chartYScale(domain: -1...1)

            Text("You tend to feel better in the morning and evening")
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
                .padding(.horizontal)
        }
        .padding()
        .cardStyle()
    }
}

private struct DayOfWeekPatternsSection: View {
    // Mock data
    private let weekData: [WeekDayData] = [
        WeekDayData(day: "Mon", valence: 0.2),
        WeekDayData(day: "Tue", valence: 0.4),
        WeekDayData(day: "Wed", valence: 0.5),
        WeekDayData(day: "Thu", valence: 0.3),
        WeekDayData(day: "Fri", valence: 0.7),
        WeekDayData(day: "Sat", valence: 0.6),
        WeekDayData(day: "Sun", valence: 0.1),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Patterns")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            Chart(weekData) { item in
                LineMark(
                    x: .value("Day", item.day),
                    y: .value("Valence", item.valence)
                )
                .foregroundStyle(Color.noemaPrimary)
                .symbol(.circle)
                .symbolSize(80)

                AreaMark(
                    x: .value("Day", item.day),
                    y: .value("Valence", item.valence)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.noemaPrimary.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 150)
            .chartYScale(domain: -1...1)

            Text("Fridays are your happiest days, Sundays tend to be more reflective")
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
                .padding(.horizontal)
        }
        .padding()
        .cardStyle()
    }
}

private struct PredictionsSection: View {
    @ObservedObject var viewModel: MoodDashboardViewModel
    @State private var predictedMood: EmotionalState?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Mood Prediction", systemImage: "sparkles")
                .font(.headline)
                .foregroundColor(.noemaPrimary)

            if let predicted = predictedMood {
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.forEmotion(valence: predicted.valence, arousal: predicted.arousal))
                            .frame(width: 50, height: 50)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Predicted mood for today")
                                .font(.subheadline)
                                .foregroundColor(.noemaTextSecondary)

                            Text(predicted.primaryEmotion.displayName)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.noemaTextPrimary)
                        }

                        Spacer()
                    }

                    Text("Based on your recent patterns, you're likely to feel \(predicted.primaryEmotion.displayName.lowercased()) today.")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }
            } else {
                Button {
                    Task {
                        predictedMood = await viewModel.predictMood()
                    }
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Generate Prediction")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaPrimary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.noemaPrimary.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct PatternDetailsSheet: View {
    let pattern: EmotionalPattern
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Pattern header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(pattern.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.noemaTextPrimary)

                        Text(pattern.description)
                            .font(.body)
                            .foregroundColor(.noemaTextSecondary)
                    }

                    Divider()

                    // Metrics
                    HStack(spacing: 20) {
                        MetricView(
                            label: "Confidence",
                            value: "\(Int(pattern.confidence * 100))%",
                            icon: "chart.bar.fill"
                        )

                        MetricView(
                            label: "Occurrences",
                            value: "\(pattern.occurrences)",
                            icon: "repeat"
                        )

                        MetricView(
                            label: "Strength",
                            value: "\(Int(pattern.strength * 100))%",
                            icon: "bolt.fill"
                        )
                    }

                    Divider()

                    // Recommendations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommendations")
                            .font(.headline)
                            .foregroundColor(.noemaTextPrimary)

                        Text("Based on this pattern, consider journaling during these times to capture insights and track progress.")
                            .font(.subheadline)
                            .foregroundColor(.noemaTextSecondary)
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
}

private struct MetricView: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.noemaPrimary)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.noemaTextPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }
}

// MARK: - Supporting Types

private struct TimeOfDayData: Identifiable {
    let id = UUID()
    let time: String
    let valence: Double
    let count: Int
}

private struct WeekDayData: Identifiable {
    let id = UUID()
    let day: String
    let valence: Double
}

#Preview {
    MoodPatternsView()
}

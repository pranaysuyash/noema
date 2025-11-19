//
//  MoodDashboardView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI
import Charts

public struct MoodDashboardView: View {
    @StateObject private var viewModel = MoodDashboardViewModel()
    @State private var showingTimeline = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Range Selector
                    TimeRangeSelector(selectedRange: $viewModel.selectedTimeRange)

                    // Current Mood Card
                    if let currentMood = viewModel.currentMood {
                        CurrentMoodCard(emotion: currentMood)
                    }

                    // Mood Chart
                    MoodChartSection(moodHistory: viewModel.moodHistory)

                    // Emotional Breakdown
                    EmotionalBreakdownSection(moodHistory: viewModel.moodHistory)

                    // Patterns & Insights
                    if !viewModel.moodPatterns.isEmpty {
                        PatternsSection(patterns: viewModel.moodPatterns)
                    }

                    // AI Insights
                    if !viewModel.moodInsights.isEmpty {
                        InsightsSection(insights: viewModel.moodInsights)
                    }

                    // Quick Actions
                    QuickActionsSection()
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Mood Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingTimeline = true
                    } label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                    }
                }
            }
            .sheet(isPresented: $showingTimeline) {
                MoodTimelineView()
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

private struct TimeRangeSelector: View {
    @Binding var selectedRange: MoodDashboardViewModel.TimeRange

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MoodDashboardViewModel.TimeRange.allCases, id: \.self) { range in
                    Button {
                        selectedRange = range
                    } label: {
                        Text(range.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedRange == range ? .semibold : .regular)
                            .foregroundColor(selectedRange == range ? .white : .noemaTextPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedRange == range ? Color.noemaPrimary : Color.noemaCardBackground)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
}

private struct CurrentMoodCard: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        VStack(spacing: 16) {
            // Emotion Circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal),
                                Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal).opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                VStack(spacing: 4) {
                    Text(emotion.primaryEmotion.displayName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("\(Int(emotion.emotionIntensity * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            // Dimensions
            HStack(spacing: 20) {
                DimensionIndicator(
                    label: "Valence",
                    value: emotion.valence,
                    icon: emotion.valence > 0 ? "arrow.up" : "arrow.down",
                    color: emotion.valence > 0 ? .green : .red
                )

                DimensionIndicator(
                    label: "Energy",
                    value: emotion.energyLevel,
                    icon: "bolt.fill",
                    color: .xpGold
                )

                DimensionIndicator(
                    label: "Stress",
                    value: emotion.stressLevel,
                    icon: "flame.fill",
                    color: .angerColor
                )
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct DimensionIndicator: View {
    let label: String
    let value: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text("\(Int((value + 1) / 2 * 100))%")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.noemaTextPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MoodChartSection: View {
    let moodHistory: [EmotionalState]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emotional Journey")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            if moodHistory.isEmpty {
                Text("No mood data available")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(moodHistory) { mood in
                        LineMark(
                            x: .value("Time", mood.timestamp),
                            y: .value("Valence", mood.valence)
                        )
                        .foregroundStyle(Color.joyColor)

                        AreaMark(
                            x: .value("Time", mood.timestamp),
                            y: .value("Valence", mood.valence)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.joyColor.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: -1...1)
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct EmotionalBreakdownSection: View {
    let moodHistory: [EmotionalState]

    private var emotionCounts: [EmotionType: Int] {
        var counts: [EmotionType: Int] = [:]
        for mood in moodHistory {
            counts[mood.primaryEmotion, default: 0] += 1
        }
        return counts
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emotion Distribution")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            if emotionCounts.isEmpty {
                Text("No emotion data available")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(emotionCounts.sorted { $0.value > $1.value }.prefix(5), id: \.key) { emotion, count in
                        EmotionBar(
                            emotion: emotion,
                            count: count,
                            total: moodHistory.count
                        )
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct EmotionBar: View {
    let emotion: EmotionType
    let count: Int
    let total: Int

    private var percentage: Double {
        Double(count) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(emotion.displayName)
                    .font(.subheadline)
                    .foregroundColor(.noemaTextPrimary)

                Spacer()

                Text("\(Int(percentage * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaTextSecondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(emotion.color)
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

private struct PatternsSection: View {
    let patterns: [EmotionalPattern]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patterns Detected")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            ForEach(patterns.prefix(3), id: \.id) { pattern in
                PatternCard(pattern: pattern)
            }
        }
    }
}

private struct PatternCard: View {
    let pattern: EmotionalPattern

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "chart.bar.fill")
                .font(.title2)
                .foregroundColor(.noemaPrimary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaTextPrimary)

                Text(pattern.description)
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }

            Spacer()
        }
        .padding()
        .cardStyle()
    }
}

private struct InsightsSection: View {
    let insights: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("AI Insights", systemImage: "sparkles")
                .font(.headline)
                .foregroundColor(.noemaPrimary)

            ForEach(insights.prefix(3), id: \.self) { insight in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color.noemaPrimary)
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)

                    Text(insight)
                        .font(.subheadline)
                        .foregroundColor(.noemaTextPrimary)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct QuickActionsSection: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "Log Mood",
                    color: .noemaPrimary
                )

                QuickActionButton(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Timeline",
                    color: .blue
                )

                QuickActionButton(
                    icon: "paintpalette.fill",
                    title: "Wheel",
                    color: .purple
                )
            }
        }
    }
}

private struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button {
            // Action
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .cardStyle()
        }
    }
}

// MARK: - Supporting Extensions

extension EmotionType {
    var color: Color {
        switch self {
        case .joy: return .joyColor
        case .sadness: return .sadnessColor
        case .anger: return .angerColor
        case .fear: return .fearColor
        case .anxiety: return .anxietyColor
        case .contentment: return .contentmentColor
        case .excitement: return .excitementColor
        case .peaceful: return .peacefulColor
        default: return .gray
        }
    }
}

#Preview {
    MoodDashboardView()
}

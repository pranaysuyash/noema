//
//  MoodTimelineView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI
import Charts

public struct MoodTimelineView: View {
    @StateObject private var viewModel = MoodTimelineViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEmotion: EmotionalState?

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Range Selector
                    TimeRangeSelector(selectedRange: $viewModel.selectedTimeRange)

                    // Detailed Chart
                    DetailedMoodChart(
                        moodHistory: viewModel.moodHistory,
                        selectedEmotion: $selectedEmotion
                    )

                    // Selected Emotion Details
                    if let emotion = selectedEmotion {
                        SelectedEmotionCard(emotion: emotion)
                    }

                    // Timeline List
                    TimelineList(
                        moodHistory: viewModel.moodHistory,
                        onSelect: { emotion in
                            selectedEmotion = emotion
                        }
                    )
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Emotional Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.exportTimeline()
                        } label: {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .task {
                await viewModel.fetchMoodHistory()
            }
        }
    }
}

// MARK: - Supporting Views

private struct TimeRangeSelector: View {
    @Binding var selectedRange: MoodTimelineViewModel.TimeRange

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MoodTimelineViewModel.TimeRange.allCases, id: \.self) { range in
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

private struct DetailedMoodChart: View {
    let moodHistory: [EmotionalState]
    @Binding var selectedEmotion: EmotionalState?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emotional Trends")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            if moodHistory.isEmpty {
                Text("No mood data available for this period")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
            } else {
                Chart {
                    // Valence line
                    ForEach(moodHistory) { mood in
                        LineMark(
                            x: .value("Time", mood.timestamp),
                            y: .value("Valence", mood.valence)
                        )
                        .foregroundStyle(Color.joyColor)
                        .symbol(.circle)
                        .symbolSize(selectedEmotion?.id == mood.id ? 100 : 50)

                        // Arousal line
                        LineMark(
                            x: .value("Time", mood.timestamp),
                            y: .value("Arousal", mood.arousal)
                        )
                        .foregroundStyle(Color.excitementColor.opacity(0.6))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
                    }
                }
                .frame(height: 250)
                .chartYScale(domain: -1...1)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartLegend(position: .bottom) {
                    HStack(spacing: 20) {
                        LegendItem(color: .joyColor, label: "Valence")
                        LegendItem(color: .excitementColor, label: "Arousal", isDashed: true)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String
    var isDashed: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            if isDashed {
                Rectangle()
                    .fill(color)
                    .frame(width: 20, height: 2)
                    .overlay(
                        Rectangle()
                            .stroke(color, style: StrokeStyle(lineWidth: 2, dash: [3, 2]))
                    )
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }

            Text(label)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
    }
}

private struct SelectedEmotionCard: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Selected Moment")
                    .font(.headline)
                    .foregroundColor(.noemaTextPrimary)

                Spacer()

                Text(emotion.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }

            HStack(spacing: 20) {
                // Emotion Circle
                Circle()
                    .fill(Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(emotion.primaryEmotion.displayName.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 8) {
                    Text(emotion.primaryEmotion.displayName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.noemaTextPrimary)

                    HStack(spacing: 16) {
                        MetricPill(label: "Valence", value: emotion.valence)
                        MetricPill(label: "Arousal", value: emotion.arousal)
                        MetricPill(label: "Energy", value: emotion.energyLevel)
                    }
                }
            }
        }
        .padding()
        .emotionCardStyle(emotion: emotion)
    }
}

private struct MetricPill: View {
    let label: String
    let value: Double

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.noemaTextSecondary)

            Text("\(Int((value + 1) / 2 * 100))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.noemaTextPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

private struct TimelineList: View {
    let moodHistory: [EmotionalState]
    let onSelect: (EmotionalState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Entries")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            ForEach(moodHistory) { emotion in
                TimelineRow(emotion: emotion)
                    .onTapGesture {
                        withAnimation {
                            onSelect(emotion)
                        }
                    }
            }
        }
    }
}

private struct TimelineRow: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(alignment: .trailing, spacing: 2) {
                Text(emotion.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaTextPrimary)

                Text(emotion.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.noemaTextSecondary)
            }
            .frame(width: 60)

            // Timeline dot
            ZStack {
                Circle()
                    .fill(Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal))
                    .frame(width: 12, height: 12)

                Circle()
                    .stroke(Color.noemaBackground, lineWidth: 3)
                    .frame(width: 12, height: 12)
            }

            // Emotion info
            VStack(alignment: .leading, spacing: 4) {
                Text(emotion.primaryEmotion.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaTextPrimary)

                HStack(spacing: 12) {
                    MiniMetric(icon: "arrow.up.arrow.down", value: emotion.valence)
                    MiniMetric(icon: "bolt.fill", value: emotion.energyLevel)
                    MiniMetric(icon: "flame.fill", value: emotion.stressLevel)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .padding()
        .cardStyle()
    }
}

private struct MiniMetric: View {
    let icon: String
    let value: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.noemaTextSecondary)

            Text("\(Int((value + 1) / 2 * 100))")
                .font(.caption2)
                .foregroundColor(.noemaTextSecondary)
        }
    }
}

#Preview {
    MoodTimelineView()
}

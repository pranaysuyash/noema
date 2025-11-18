import SwiftUI

/// Mood timeline showing historical mood data
public struct MoodTimelineView: View {
    @StateObject private var viewModel: MoodTimelineViewModel

    public init() {
        _viewModel = StateObject(wrappedValue: MoodTimelineViewModel(
            moodRepository: CoreDataMoodRepository(coreDataStack: .shared)
        ))
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time range picker
                Picker("Range", selection: .constant(viewModel.selectedTimeRange)) {
                    ForEach(MoodTimeRange.allCases) { range in
                        Text(range.title).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Chart (placeholder)
                TimelineChartView(dataPoints: viewModel.chartData)
                    .frame(height: 250)
                    .padding()

                // Mood list
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.moods) { mood in
                        MoodTimelineItem(mood: mood)
                            .onTapGesture {
                                viewModel.selectMood(mood)
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Mood Timeline")
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadTimeline()
        }
        .sheet(item: $viewModel.selectedMood) { mood in
            MoodDetailSheet(mood: mood)
        }
    }
}

// MARK: - Timeline Chart View

struct TimelineChartView: View {
    let dataPoints: [ChartDataPoint]

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.1))

            if dataPoints.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
            } else {
                // Simple line chart placeholder
                GeometryReader { geometry in
                    Path { path in
                        let points = dataPoints.enumerated().map { index, point -> CGPoint in
                            let x = (CGFloat(index) / CGFloat(max(dataPoints.count - 1, 1))) * geometry.size.width
                            let y = geometry.size.height * CGFloat(1 - (point.valence + 1) / 2)
                            return CGPoint(x: x, y: y)
                        }

                        if let first = points.first {
                            path.move(to: first)
                            points.dropFirst().forEach { path.addLine(to: $0) }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
                .padding()
            }
        }
    }
}

// MARK: - Mood Timeline Item

struct MoodTimelineItem: View {
    let mood: MoodSnapshot

    var body: some View {
        HStack {
            // Emoji
            Text(moodEmoji(for: mood.dimensions.dominantEmotion))
                .font(.title2)
                .frame(width: 50)

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(mood.dimensions.dominantEmotion.capitalized)
                    .font(.headline)

                Text(mood.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let note = mood.contextNote {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Valence indicator
            VStack {
                Circle()
                    .fill(mood.dimensions.valence > 0 ? Color.green : Color.red)
                    .frame(width: 12, height: 12)

                Text(String(format: "%.1f", mood.dimensions.valence))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
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

// MARK: - Mood Detail Sheet

struct MoodDetailSheet: View {
    let mood: MoodSnapshot
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Emoji
                    Text(moodEmoji(for: mood.dimensions.dominantEmotion))
                        .font(.system(size: 80))

                    // Title
                    Text(mood.dimensions.dominantEmotion.capitalized)
                        .font(.title.bold())

                    // Timestamp
                    Text(mood.timestamp.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Dimensions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Emotional Dimensions")
                            .font(.headline)

                        dimensionBar("Joy", value: mood.dimensions.joy, color: .yellow)
                        dimensionBar("Sadness", value: mood.dimensions.sadness, color: .blue)
                        dimensionBar("Anger", value: mood.dimensions.anger, color: .red)
                        dimensionBar("Fear", value: mood.dimensions.fear, color: .purple)
                        dimensionBar("Surprise", value: mood.dimensions.surprise, color: .orange)
                        dimensionBar("Disgust", value: mood.dimensions.disgust, color: .green)
                        dimensionBar("Trust", value: mood.dimensions.trust, color: .cyan)
                        dimensionBar("Anticipation", value: mood.dimensions.anticipation, color: .pink)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)

                    // Context note
                    if let note = mood.contextNote {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note")
                                .font(.headline)

                            Text(note)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Mood Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func dimensionBar(_ name: String, value: Float, color: Color) -> some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)

            ProgressView(value: Double(value))
                .tint(color)

            Text(String(format: "%.0f%%", value * 100))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
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

//
//  NoteSummaryView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct NoteSummaryView: View {
    @ObservedObject var note: Note
    @State private var isExpanded = false
    @State private var showingFullNote = false

    public init(note: Note) {
        self.note = note
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("AI Summary", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundColor(.noemaPrimary)

                Spacer()

                Button {
                    isExpanded.toggle()
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.noemaTextSecondary)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Summary Text
                    if let summary = note.summary, !summary.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Summary")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.noemaTextPrimary)

                            Text(summary)
                                .font(.body)
                                .foregroundColor(.noemaTextPrimary)
                        }
                    } else {
                        Text("No summary available")
                            .font(.body)
                            .foregroundColor(.noemaTextSecondary)
                            .italic()
                    }

                    Divider()

                    // Key Points (placeholder - would come from AI)
                    KeyPointsSection()

                    Divider()

                    // Insights (placeholder - would come from AI)
                    InsightsSection(note: note)

                    // View Full Note Button
                    Button {
                        showingFullNote = true
                    } label: {
                        HStack {
                            Text("View Full Note")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Spacer()

                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundColor(.noemaPrimary)
                        .padding()
                        .background(Color.noemaPrimary.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
        .sheet(isPresented: $showingFullNote) {
            NoteDetailView(note: note)
        }
    }
}

// MARK: - Supporting Views

private struct KeyPointsSection: View {
    // In a real implementation, these would come from AI analysis
    private let keyPoints = [
        "Main idea: Personal reflection on growth",
        "Mentioned feeling of accomplishment",
        "Reference to overcoming challenges"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Key Points")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.noemaTextPrimary)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(keyPoints, id: \.self) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.noemaPrimary)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        Text(point)
                            .font(.subheadline)
                            .foregroundColor(.noemaTextSecondary)
                    }
                }
            }
        }
    }
}

private struct InsightsSection: View {
    @ObservedObject var note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.noemaTextPrimary)

            // Word Count Insight
            InsightCard(
                icon: "text.word.spacing",
                title: "Word Count",
                value: "\(note.wordCount) words",
                color: .blue
            )

            // Emotion Insight
            if let emotion = note.moodSnapshot {
                InsightCard(
                    icon: "face.smiling",
                    title: "Dominant Emotion",
                    value: emotion.primaryEmotion.displayName,
                    color: Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal)
                )
            }

            // Time Insight
            InsightCard(
                icon: "clock",
                title: "Time of Day",
                value: note.timeOfDay.displayName,
                color: .orange
            )

            // Quality Score
            if note.qualityScore > 0 {
                InsightCard(
                    icon: "star.fill",
                    title: "Quality Score",
                    value: "\(Int(note.qualityScore * 100))%",
                    color: .xpGold
                )
            }
        }
    }
}

private struct InsightCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaTextPrimary)
            }

            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Supporting Extensions

extension TimeOfDay {
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }
}

#Preview {
    let note = Note()
    note.content = "This is a sample note with some content"
    note.summary = "A brief summary of the note's main points and key insights."
    note.wordCount = 125
    note.qualityScore = 0.85
    return NoteSummaryView(note: note)
        .padding()
}

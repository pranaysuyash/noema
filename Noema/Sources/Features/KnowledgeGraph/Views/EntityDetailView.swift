//
//  EntityDetailView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI
import Charts

public struct EntityDetailView: View {
    @StateObject private var viewModel: EntityDetailViewModel
    @ObservedObject var entity: Entity
    @Environment(\.dismiss) private var dismiss

    public init(entity: Entity) {
        self.entity = entity
        _viewModel = StateObject(wrappedValue: EntityDetailViewModel(entity: entity))
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Entity Header
                    EntityHeaderSection(entity: entity)

                    // Metrics Overview
                    MetricsOverviewSection(entity: entity)

                    // Emotional Timeline
                    EmotionalTimelineSection(timeline: viewModel.emotionalTimeline)

                    // Related Entities
                    if !viewModel.relatedEntities.isEmpty {
                        RelatedEntitiesSection(entities: viewModel.relatedEntities)
                    }

                    // Mentions
                    MentionsSection(mentions: viewModel.mentions)

                    // Notes mentioning this entity
                    if !viewModel.relatedNotes.isEmpty {
                        RelatedNotesSection(notes: viewModel.relatedNotes)
                    }
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Entity Details")
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
                            Task {
                                await viewModel.toggleFavorite()
                            }
                        } label: {
                            Label(
                                entity.isFavorite ? "Unfavorite" : "Favorite",
                                systemImage: entity.isFavorite ? "star.slash" : "star"
                            )
                        }

                        Button {
                            // Edit entity
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .task {
                await viewModel.loadDetails()
            }
        }
    }
}

// MARK: - Supporting Views

private struct EntityHeaderSection: View {
    @ObservedObject var entity: Entity

    var body: some View {
        VStack(spacing: 16) {
            // Large entity circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.forEmotion(valence: entity.averageValence, arousal: entity.averageArousal),
                                Color.forEmotion(valence: entity.averageValence, arousal: entity.averageArousal).opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(
                        color: Color.forEmotion(valence: entity.averageValence, arousal: entity.averageArousal).opacity(0.3),
                        radius: 20
                    )

                Text(entity.type.icon)
                    .font(.system(size: 60))
            }

            VStack(spacing: 8) {
                Text(entity.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.noemaTextPrimary)
                    .multilineTextAlignment(.center)

                Text(entity.type.displayName)
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)

                // Aliases if any
                if !entity.aliases.isEmpty {
                    Text("Also known as: " + entity.aliases.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            // Favorite indicator
            if entity.isFavorite {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.xpGold)
                    Text("Favorite")
                        .font(.caption)
                        .foregroundColor(.xpGold)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct MetricsOverviewSection: View {
    @ObservedObject var entity: Entity

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MetricCard(
                    icon: "bubble.left.and.bubble.right",
                    label: "Total Mentions",
                    value: "\(entity.totalMentions)",
                    color: .blue
                )

                MetricCard(
                    icon: "star.fill",
                    label: "Importance",
                    value: "\(Int(entity.importanceScore * 100))%",
                    color: .noemaPrimary
                )

                MetricCard(
                    icon: "calendar",
                    label: "First Mentioned",
                    value: entity.firstMentioned.formatted(date: .abbreviated, time: .omitted),
                    color: .green
                )

                MetricCard(
                    icon: "clock",
                    label: "Last Mentioned",
                    value: entity.lastMentioned.formatted(date: .abbreviated, time: .omitted),
                    color: .orange
                )
            }

            // Emotional metrics
            VStack(spacing: 12) {
                EmotionMetricBar(
                    label: "Average Valence",
                    value: entity.averageValence,
                    color: entity.averageValence > 0 ? .joyColor : .sadnessColor,
                    range: (-1, 1)
                )

                EmotionMetricBar(
                    label: "Average Arousal",
                    value: entity.averageArousal,
                    color: .excitementColor,
                    range: (-1, 1)
                )

                EmotionMetricBar(
                    label: "Average Energy",
                    value: entity.averageEnergy,
                    color: .xpGold,
                    range: (0, 1)
                )
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct MetricCard: View {
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
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

private struct EmotionMetricBar: View {
    let label: String
    let value: Double
    let color: Color
    let range: (Double, Double)

    private var normalizedValue: Double {
        (value - range.0) / (range.1 - range.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.noemaTextPrimary)

                Spacer()

                Text("\(value > 0 ? "+" : "")\(Int(value * 100))")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.noemaTextSecondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * normalizedValue, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

private struct EmotionalTimelineSection: View {
    let timeline: [(Date, Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emotional Timeline")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            if timeline.isEmpty {
                Text("Not enough data to show timeline")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(timeline, id: \.0) { date, valence in
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Valence", valence)
                        )
                        .foregroundStyle(Color.noemaPrimary)

                        AreaMark(
                            x: .value("Date", date),
                            y: .value("Valence", valence)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.noemaPrimary.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .frame(height: 180)
                .chartYScale(domain: -1...1)
            }

            Text("Shows how your emotional response to this entity has changed over time")
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .padding()
        .cardStyle()
    }
}

private struct RelatedEntitiesSection: View {
    let entities: [Entity]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Entities")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(entities) { entity in
                        RelatedEntityCard(entity: entity)
                    }
                }
            }
        }
    }
}

private struct RelatedEntityCard: View {
    @ObservedObject var entity: Entity

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.forEmotion(valence: entity.averageValence, arousal: entity.averageArousal))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(entity.type.icon)
                        .font(.title2)
                )

            Text(entity.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.noemaTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
        .padding()
        .cardStyle()
    }
}

private struct MentionsSection: View {
    let mentions: [EntityMention]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Mentions")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            if mentions.isEmpty {
                Text("No mentions found")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(mentions.prefix(5), id: \.id) { mention in
                    MentionRow(mention: mention)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct MentionRow: View {
    @ObservedObject var mention: EntityMention

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let context = mention.contextSnippet, !context.isEmpty {
                Text(context)
                    .font(.subheadline)
                    .foregroundColor(.noemaTextPrimary)
                    .lineLimit(2)
            }

            HStack {
                if let emotion = mention.emotionalContext {
                    Circle()
                        .fill(Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal))
                        .frame(width: 8, height: 8)

                    Text(emotion.primaryEmotion.displayName)
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }

                Spacer()

                if let note = mention.note {
                    Text(note.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

private struct RelatedNotesSection: View {
    let notes: [Note]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes Mentioning This")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            ForEach(notes.prefix(5)) { note in
                RelatedNoteRow(note: note)
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct RelatedNoteRow: View {
    @ObservedObject var note: Note

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let title = note.title, !title.isEmpty {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.noemaTextPrimary)
                        .lineLimit(1)
                }

                Text(note.content)
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
                    .lineLimit(2)

                Text(note.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.noemaTextSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .padding()
        .background(Color.noemaCardBackground.opacity(0.5))
        .cornerRadius(10)
    }
}

#Preview {
    let entity = Entity()
    entity.name = "Sample Entity"
    entity.type = .person
    entity.totalMentions = 15
    entity.averageValence = 0.7
    entity.averageArousal = 0.4
    return EntityDetailView(entity: entity)
}

//
//  NoteDetailView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI
import AVFoundation

public struct NoteDetailView: View {
    @StateObject private var viewModel: NoteDetailViewModel
    @ObservedObject var note: Note
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditor = false

    public init(note: Note) {
        self.note = note
        _viewModel = StateObject(wrappedValue: NoteDetailViewModel(note: note))
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    HeaderSection(note: note, viewModel: viewModel)

                    // Audio Player (if available)
                    if note.hasAudio, let audioURL = note.audioURL {
                        AudioPlayerSection(audioURL: audioURL, duration: note.audioDuration)
                    }

                    // Content Section
                    ContentSection(note: note)

                    // Emotion Insights
                    if let emotion = note.moodSnapshot {
                        EmotionInsightsSection(emotion: emotion)
                    }

                    // Summary (if available)
                    if let summary = note.summary, !summary.isEmpty {
                        SummarySection(summary: summary)
                    }

                    // Entities Section
                    if !viewModel.entities.isEmpty {
                        EntitiesSection(entities: viewModel.entities)
                    }

                    // Related Notes
                    if !viewModel.relatedNotes.isEmpty {
                        RelatedNotesSection(notes: viewModel.relatedNotes)
                    }

                    // Metadata Section
                    MetadataSection(note: note)
                }
                .padding()
            }
            .background(Color.noemaBackground)
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
                            showingEditor = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button {
                            Task {
                                await viewModel.toggleFavorite()
                            }
                        } label: {
                            Label(
                                note.isFavorite ? "Unfavorite" : "Favorite",
                                systemImage: note.isFavorite ? "star.slash" : "star"
                            )
                        }

                        Divider()

                        Button {
                            Task {
                                await viewModel.generateSummary()
                            }
                        } label: {
                            Label("Generate Summary", systemImage: "doc.text.magnifyingglass")
                        }

                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteNote()
                                dismiss()
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                NoteEditorView(note: note)
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

private struct HeaderSection: View {
    @ObservedObject var note: Note
    @ObservedObject var viewModel: NoteDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            if let title = note.title, !title.isEmpty {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.noemaTextPrimary)
            }

            // Date and metadata
            HStack {
                Label(
                    note.createdAt.formatted(date: .abbreviated, time: .shortened),
                    systemImage: "calendar"
                )
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)

                Spacer()

                HStack(spacing: 16) {
                    Label("\(note.wordCount)", systemImage: "text.word.spacing")
                    Label("\(Int(note.audioDuration / 60))m", systemImage: "waveform")
                        .opacity(note.hasAudio ? 1 : 0)
                }
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
            }

            // Tags
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(note.tags), id: \.id) { tag in
                            TagChip(tag: tag)
                        }
                    }
                }
            }
        }
    }
}

private struct AudioPlayerSection: View {
    let audioURL: URL
    let duration: TimeInterval
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.noemaPrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: currentTime, total: duration)
                        .tint(.noemaPrimary)

                    HStack {
                        Text(formatTime(currentTime))
                        Spacer()
                        Text(formatTime(duration))
                    }
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
                }
            }
            .padding()
            .cardStyle()
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct ContentSection: View {
    @ObservedObject var note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Content")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            Text(note.content)
                .font(.body)
                .foregroundColor(.noemaTextPrimary)
                .textSelection(.enabled)
        }
        .padding()
        .cardStyle()
    }
}

private struct EmotionInsightsSection: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Emotional Insights")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            // Primary Emotion
            HStack {
                Circle()
                    .fill(Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal))
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(emotion.primaryEmotion.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.noemaTextPrimary)

                    Text("Intensity: \(Int(emotion.emotionIntensity * 100))%")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }

                Spacer()
            }

            // Dimensions
            VStack(spacing: 12) {
                EmotionDimensionBar(label: "Valence", value: emotion.valence, color: .joyColor)
                EmotionDimensionBar(label: "Arousal", value: emotion.arousal, color: .excitementColor)
                EmotionDimensionBar(label: "Energy", value: emotion.energyLevel, color: .xpGold)
                EmotionDimensionBar(label: "Stress", value: emotion.stressLevel, color: .angerColor)
            }
        }
        .padding()
        .emotionCardStyle(emotion: emotion)
    }
}

private struct EmotionDimensionBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
                Spacer()
                Text("\(Int((value + 1) / 2 * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaTextPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (value + 1) / 2, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

private struct SummarySection: View {
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("AI Summary", systemImage: "sparkles")
                .font(.headline)
                .foregroundColor(.noemaPrimary)

            Text(summary)
                .font(.body)
                .foregroundColor(.noemaTextPrimary)
        }
        .padding()
        .cardStyle()
    }
}

private struct EntitiesSection: View {
    let entities: [Entity]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mentioned")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(entities) { entity in
                        EntityCard(entity: entity)
                    }
                }
            }
        }
    }
}

private struct EntityCard: View {
    @ObservedObject var entity: Entity

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entity.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.noemaTextPrimary)

            Text(entity.type.displayName)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .cardStyle()
    }
}

private struct RelatedNotesSection: View {
    let notes: [Note]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Notes")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            ForEach(notes) { note in
                RelatedNoteRow(note: note)
            }
        }
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
                }

                Text(note.content)
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
                    .lineLimit(2)
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

private struct MetadataSection: View {
    @ObservedObject var note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            VStack(alignment: .leading, spacing: 6) {
                MetadataRow(label: "Created", value: note.createdAt.formatted(date: .long, time: .shortened))
                MetadataRow(label: "Modified", value: note.modifiedAt.formatted(date: .long, time: .shortened))
                MetadataRow(label: "Words", value: "\(note.wordCount)")
                MetadataRow(label: "Characters", value: "\(note.characterCount)")

                if let location = note.placeName {
                    MetadataRow(label: "Location", value: location)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.noemaTextPrimary)
        }
    }
}

private struct TagChip: View {
    @ObservedObject var tag: Tag

    var body: some View {
        Text(tag.name)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(hex: tag.color).opacity(0.2))
            .foregroundColor(Color(hex: tag.color))
            .cornerRadius(16)
    }
}

extension EntityType {
    var displayName: String {
        rawValue.capitalized
    }
}

#Preview {
    let note = Note()
    note.content = "This is a sample note"
    note.createdAt = Date()
    return NoteDetailView(note: note)
}

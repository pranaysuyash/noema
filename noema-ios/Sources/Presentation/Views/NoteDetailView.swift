import SwiftUI

/// Note detail view showing full note content
public struct NoteDetailView: View {
    @StateObject private var viewModel: NoteDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false

    public init(noteId: UUID) {
        _viewModel = StateObject(wrappedValue: NoteDetailViewModel(
            noteId: noteId,
            noteRepository: CoreDataNoteRepository(coreDataStack: .shared)
        ))
    }

    public var body: some View {
        ScrollView {
            if let note = viewModel.note {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(note.createdAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            if note.isFavorite {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }

                        if let mood = note.mood {
                            HStack {
                                Text(moodEmoji(for: mood.dimensions.dominantEmotion))
                                    .font(.title2)

                                Text(mood.dimensions.dominantEmotion.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Spacer()

                                EmotionChart(dimensions: mood.dimensions)
                                    .frame(width: 120, height: 80)
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }

                    // Content
                    Text(note.content)
                        .font(.body)
                        .lineSpacing(4)

                    // Tags
                    if !note.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(note.tags) { tag in
                                    Text(tag.name)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }

                    // Metadata
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Details")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        HStack {
                            Label("\(note.wordCount) words", systemImage: "text.word.spacing")
                            Spacer()
                            Label("\(Int(note.estimatedReadingTime / 60)) min", systemImage: "clock")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)

                        HStack {
                            Label("Modified", systemImage: "calendar")
                            Spacer()
                            Text(note.modifiedAt, style: .relative)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    // Related notes
                    if !viewModel.relatedNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Related Notes")
                                .font(.headline)

                            ForEach(viewModel.relatedNotes) { relatedNote in
                                NoteCard(note: relatedNote)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        // Edit action
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button {
                        Task {
                            await viewModel.toggleFavorite()
                        }
                    } label: {
                        Label(
                            viewModel.note?.isFavorite == true ? "Unfavorite" : "Favorite",
                            systemImage: viewModel.note?.isFavorite == true ? "star.slash" : "star"
                        )
                    }

                    Button {
                        viewModel.shareNote()
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        viewModel.confirmDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            await viewModel.loadNote()
        }
        .alert("Delete Note", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteNote()
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
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

// MARK: - Emotion Chart

struct EmotionChart: View {
    let dimensions: EmotionalDimensions

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Placeholder chart - would use Charts framework in production
                ForEach(emotions, id: \.0) { emotion, value in
                    emotionBar(emotion: emotion, value: value, geometry: geometry)
                }
            }
        }
    }

    private var emotions: [(String, Float)] {
        [
            ("Joy", dimensions.joy),
            ("Sad", dimensions.sadness),
            ("Angry", dimensions.anger),
            ("Fear", dimensions.fear)
        ]
    }

    private func emotionBar(emotion: String, value: Float, geometry: GeometryProxy) -> some View {
        let barWidth = geometry.size.width / CGFloat(emotions.count)
        let barHeight = CGFloat(value) * geometry.size.height

        return VStack {
            Spacer()
            Rectangle()
                .fill(Color.blue.opacity(Double(value)))
                .frame(width: barWidth * 0.8, height: barHeight)
            Text(emotion)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
        }
    }
}

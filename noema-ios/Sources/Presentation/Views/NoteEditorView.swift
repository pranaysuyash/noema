import SwiftUI

/// Note editor view for creating and editing notes
public struct NoteEditorView: View {
    @StateObject private var viewModel: NoteEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isContentFocused: Bool

    public init(noteId: UUID? = nil) {
        let coreDataStack = CoreDataStack.shared
        let noteRepo = CoreDataNoteRepository(coreDataStack: coreDataStack)
        let tagRepo = CoreDataTagRepository(coreDataStack: coreDataStack)
        let createNoteUseCase = DefaultCreateNoteUseCase(
            noteRepository: noteRepo,
            userProfileRepository: CoreDataUserProfileRepository(coreDataStack: coreDataStack)
        )
        let analyzeMoodUseCase = DefaultAnalyzeMoodUseCase()

        _viewModel = StateObject(wrappedValue: NoteEditorViewModel(
            noteId: noteId,
            noteRepository: noteRepo,
            tagRepository: tagRepo,
            createNoteUseCase: createNoteUseCase,
            analyzeMoodUseCase: analyzeMoodUseCase
        ))
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Editor
                ScrollView {
                    VStack(spacing: 16) {
                        // Mood indicator
                        if let mood = viewModel.detectedMood {
                            MoodIndicator(mood: mood)
                                .transition(.scale.combined(with: .opacity))
                        }

                        // Text editor
                        TextEditor(text: $viewModel.content)
                            .frame(minHeight: 300)
                            .focused($isContentFocused)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)

                        // Tags
                        if !viewModel.selectedTags.isEmpty {
                            TagsView(tags: viewModel.selectedTags) { tag in
                                viewModel.removeTag(tag)
                            }
                        }

                        // Metadata
                        HStack {
                            Label(
                                "\(viewModel.wordCount) words",
                                systemImage: "text.word.spacing"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)

                            Spacer()

                            Label(
                                "\(Int(viewModel.estimatedReadingTime / 60)) min read",
                                systemImage: "clock"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }

                // Loading overlay
                if viewModel.isSaving || viewModel.isProcessingAI {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)

                        Text(viewModel.isProcessingAI ? "Analyzing mood..." : "Saving...")
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.hasUnsavedChanges {
                            // Show confirmation
                        }
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.content.isEmpty)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            Task {
                                await viewModel.analyzeContent()
                            }
                        } label: {
                            Label("Analyze Mood", systemImage: "sparkles")
                        }

                        Button {
                            // Show tag picker
                        } label: {
                            Label("Add Tag", systemImage: "tag")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .task {
                await viewModel.loadNote()
                isContentFocused = true
            }
        }
    }
}

// MARK: - Mood Indicator

struct MoodIndicator: View {
    let mood: MoodSnapshot

    var body: some View {
        HStack {
            Image(systemName: "face.smiling.fill")
                .foregroundColor(.blue)

            Text(mood.dimensions.dominantEmotion.capitalized)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            Text("\(Int(mood.confidence * 100))% confident")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Tags View

struct TagsView: View {
    let tags: [Tag]
    let onRemove: (Tag) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags) { tag in
                    HStack(spacing: 4) {
                        Text(tag.name)
                            .font(.caption)

                        Button {
                            onRemove(tag)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption2)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
            }
        }
    }
}

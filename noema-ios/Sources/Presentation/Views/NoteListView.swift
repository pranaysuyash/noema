import SwiftUI

/// Note list view showing all user's notes
public struct NoteListView: View {
    @StateObject private var viewModel: NoteListViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator

    public init() {
        let coreDataStack = CoreDataStack.shared
        let noteRepo = CoreDataNoteRepository(coreDataStack: coreDataStack)
        let tagRepo = CoreDataTagRepository(coreDataStack: coreDataStack)

        _viewModel = StateObject(wrappedValue: NoteListViewModel(
            noteRepository: noteRepo,
            tagRepository: tagRepo
        ))
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredNotes) { note in
                    NoteCard(note: note)
                        .onTapGesture {
                            appCoordinator.notesCoordinator?.viewNote(note.id)
                        }
                        .contextMenu {
                            noteContextMenu(for: note)
                        }
                }
            }
            .padding()
        }
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    viewModeMenu
                    sortOrderMenu
                    filterMenu
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    appCoordinator.notesCoordinator?.createNewNote()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Search notes...")
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadNotes()
        }
        .sheet(isPresented: $appCoordinator.notesCoordinator!.isPresentingEditor) {
            NoteEditorView(noteId: appCoordinator.notesCoordinator?.editingNoteId)
        }
        .sheet(isPresented: $appCoordinator.notesCoordinator!.isPresentingVoiceRecorder) {
            VoiceRecordingView()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.filteredNotes.isEmpty {
                emptyState
            }
        }
    }

    // MARK: - Menu Views

    private var viewModeMenu: some View {
        Menu("View Mode") {
            ForEach(ViewMode.allCases) { mode in
                Button {
                    viewModel.updateViewMode(mode)
                } label: {
                    Label(
                        mode.rawValue.capitalized,
                        systemImage: mode.icon
                    )
                }
            }
        }
    }

    private var sortOrderMenu: some View {
        Menu("Sort By") {
            ForEach(SortOrder.allCases) { order in
                Button {
                    viewModel.updateSortOrder(order)
                } label: {
                    Label(
                        order.displayName,
                        systemImage: order.icon
                    )
                }
            }
        }
    }

    private var filterMenu: some View {
        Menu("Filter") {
            Button("All Notes") {
                viewModel.updateFilter(.all)
            }
            Button("Favorites") {
                viewModel.updateFilter(.favorites)
            }
            Button("Archived") {
                viewModel.updateFilter(.archived)
            }
        }
    }

    private func noteContextMenu(for note: Note) -> some View {
        Group {
            Button {
                appCoordinator.notesCoordinator?.editNote(note.id)
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button {
                Task {
                    await viewModel.toggleFavorite(note)
                }
            } label: {
                Label(
                    note.isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: note.isFavorite ? "star.slash" : "star"
                )
            }

            Button {
                Task {
                    await viewModel.archiveNote(note)
                }
            } label: {
                Label(
                    note.isArchived ? "Unarchive" : "Archive",
                    systemImage: "archivebox"
                )
            }

            Button(role: .destructive) {
                Task {
                    await viewModel.deleteNote(note)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No notes yet")
                .font(.title2.bold())

            Text("Tap + to create your first note")
                .font(.body)
                .foregroundColor(.secondary)

            Button {
                appCoordinator.notesCoordinator?.createNewNote()
            } label: {
                Label("Create Note", systemImage: "plus")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - Note Card

struct NoteCard: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                if let mood = note.mood {
                    Text(moodEmoji(for: mood.dimensions.dominantEmotion))
                        .font(.title2)
                }

                Text(note.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if note.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }

            // Content preview
            Text(note.content)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.primary)

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
            HStack {
                Label(
                    "\(note.wordCount) words",
                    systemImage: "text.word.spacing"
                )
                .font(.caption)
                .foregroundColor(.secondary)

                Spacer()

                if let summary = note.summary {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                        .font(.caption)
                }
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

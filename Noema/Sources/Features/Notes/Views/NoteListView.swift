//
//  NoteListView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI
import CoreData

public struct NoteListView: View {
    @StateObject private var viewModel = NoteListViewModel()
    @State private var showingNewNote = false
    @State private var showingFilters = false
    @State private var selectedNote: Note?

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.noemaBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $viewModel.searchText, placeholder: "Search notes...")
                        .padding()

                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(NoteListViewModel.FilterOption.allCases, id: \.self) { filter in
                                FilterPill(
                                    title: filter.rawValue,
                                    isSelected: viewModel.selectedFilter == filter
                                ) {
                                    viewModel.selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)

                    // Notes List
                    if viewModel.notes.isEmpty {
                        EmptyStateView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.notes) { note in
                                    NoteCard(note: note)
                                        .onTapGesture {
                                            selectedNote = note
                                        }
                                        .contextMenu {
                                            NoteContextMenu(note: note, viewModel: viewModel)
                                        }
                                        .animateOnAppear()
                                }
                            }
                            .padding()
                        }
                    }
                }
                .loading(viewModel.isLoading)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(NoteListViewModel.SortOption.allCases, id: \.self) { option in
                            Button {
                                viewModel.selectedSortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if viewModel.selectedSortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewNote = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingNewNote) {
                NoteEditorView()
            }
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note)
            }
            .errorAlert(error: $viewModel.error)
            .task {
                await viewModel.fetchNotes()
            }
        }
    }
}

// MARK: - Supporting Views

private struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.noemaTextSecondary)

            TextField(placeholder, text: $text)
                .foregroundColor(.noemaTextPrimary)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.noemaTextSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.noemaCardBackground)
        .cornerRadius(12)
    }
}

private struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .noemaTextPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.noemaPrimary : Color.noemaCardBackground
                )
                .cornerRadius(20)
        }
    }
}

private struct NoteCard: View {
    @ObservedObject var note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with date and icons
            HStack {
                Text(note.createdAt.formatted())
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)

                Spacer()

                if note.hasAudio {
                    Image(systemName: "waveform")
                        .font(.caption)
                        .foregroundColor(.noemaPrimary)
                }

                if note.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.xpGold)
                }
            }

            // Title
            if let title = note.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.noemaTextPrimary)
                    .lineLimit(1)
            }

            // Content preview
            Text(note.content)
                .font(.body)
                .foregroundColor(.noemaTextSecondary)
                .lineLimit(3)

            // Emotion indicator
            if let emotion = note.moodSnapshot {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal))
                        .frame(width: 8, height: 8)

                    Text(emotion.primaryEmotion.displayName)
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }
            }

            // Tags
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(note.tags), id: \.id) { tag in
                            TagView(tag: tag)
                        }
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct TagView: View {
    @ObservedObject var tag: Tag

    var body: some View {
        Text(tag.name)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: tag.color).opacity(0.2))
            .foregroundColor(Color(hex: tag.color))
            .cornerRadius(6)
    }
}

private struct NoteContextMenu: View {
    @ObservedObject var note: Note
    @ObservedObject var viewModel: NoteListViewModel

    var body: some View {
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

        Button(role: .destructive) {
            Task {
                await viewModel.deleteNote(note)
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "note.text")
                .font(.system(size: 64))
                .foregroundColor(.noemaTextSecondary)

            Text("No notes yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.noemaTextPrimary)

            Text("Tap + to create your first note")
                .font(.body)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Supporting Extensions

extension EmotionType {
    var displayName: String {
        rawValue.capitalized
    }
}

#Preview {
    NoteListView()
}

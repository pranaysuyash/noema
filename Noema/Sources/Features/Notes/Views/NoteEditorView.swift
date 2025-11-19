//
//  NoteEditorView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct NoteEditorView: View {
    @StateObject private var viewModel: NoteEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isContentFocused: Bool
    @State private var showingVoiceRecorder = false

    public init(note: Note? = nil) {
        _viewModel = StateObject(wrappedValue: NoteEditorViewModel(note: note))
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.noemaBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Title Field
                        TitleField(text: $viewModel.title)

                        // Content Editor
                        ContentEditor(text: $viewModel.content, isFocused: $isContentFocused)

                        // Voice Recording Section
                        if viewModel.hasAudio {
                            AudioPreviewSection(
                                audioURL: viewModel.audioURL,
                                duration: viewModel.audioDuration,
                                onDelete: {
                                    viewModel.removeAudio()
                                }
                            )
                        }

                        // Tags Section
                        TagsSection(
                            selectedTags: $viewModel.selectedTags,
                            availableTags: viewModel.availableTags
                        )

                        // Metadata
                        MetadataBar(wordCount: viewModel.wordCount)
                    }
                    .padding()
                }
                .dismissKeyboardOnTap()
            }
            .navigationTitle(viewModel.isEditing ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.saveNote()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.content.isEmpty)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button {
                        showingVoiceRecorder = true
                    } label: {
                        Image(systemName: "mic.circle.fill")
                            .font(.title3)
                            .foregroundColor(.noemaPrimary)
                    }

                    Button {
                        isContentFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingVoiceRecorder) {
                VoiceRecorderView { audioURL, duration in
                    viewModel.addAudio(url: audioURL, duration: duration)
                }
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .onAppear {
                isContentFocused = !viewModel.isEditing
            }
        }
    }
}

// MARK: - Supporting Views

private struct TitleField: View {
    @Binding var text: String

    var body: some View {
        TextField("Title (optional)", text: $text)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.noemaTextPrimary)
            .padding()
            .background(Color.noemaCardBackground)
            .cornerRadius(12)
    }
}

private struct ContentEditor: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("What's on your mind?")
                    .font(.body)
                    .foregroundColor(.noemaTextSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .font(.body)
                .foregroundColor(.noemaTextPrimary)
                .focused(isFocused)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 300)
                .padding(8)
        }
        .background(Color.noemaCardBackground)
        .cornerRadius(12)
    }
}

private struct AudioPreviewSection: View {
    let audioURL: URL?
    let duration: TimeInterval
    let onDelete: () -> Void
    @State private var isPlaying = false

    var body: some View {
        HStack {
            Image(systemName: "waveform.circle.fill")
                .font(.title2)
                .foregroundColor(.noemaPrimary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Voice Recording")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaTextPrimary)

                Text(formatDuration(duration))
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }

            Spacer()

            Button {
                isPlaying.toggle()
            } label: {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                    .font(.title3)
                    .foregroundColor(.noemaPrimary)
            }

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.circle")
                    .font(.title3)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .cardStyle()
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct TagsSection: View {
    @Binding var selectedTags: Set<Tag>
    let availableTags: [Tag]
    @State private var showingTagPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tags")
                    .font(.headline)
                    .foregroundColor(.noemaTextPrimary)

                Spacer()

                Button {
                    showingTagPicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.noemaPrimary)
                }
            }

            if !selectedTags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(Array(selectedTags), id: \.id) { tag in
                        TagChip(tag: tag) {
                            selectedTags.remove(tag)
                        }
                    }
                }
            } else {
                Text("No tags added")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
            }
        }
        .padding()
        .cardStyle()
        .sheet(isPresented: $showingTagPicker) {
            TagPickerView(selectedTags: $selectedTags, availableTags: availableTags)
        }
    }
}

private struct TagChip: View {
    @ObservedObject var tag: Tag
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(tag.name)
                .font(.caption)
                .fontWeight(.medium)

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: tag.color).opacity(0.2))
        .foregroundColor(Color(hex: tag.color))
        .cornerRadius(16)
    }
}

private struct TagPickerView: View {
    @Binding var selectedTags: Set<Tag>
    let availableTags: [Tag]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(availableTags) { tag in
                Button {
                    if selectedTags.contains(tag) {
                        selectedTags.remove(tag)
                    } else {
                        selectedTags.insert(tag)
                    }
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(hex: tag.color))
                            .frame(width: 12, height: 12)

                        Text(tag.name)
                            .foregroundColor(.noemaTextPrimary)

                        Spacer()

                        if selectedTags.contains(tag) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.noemaPrimary)
                        }
                    }
                }
            }
            .navigationTitle("Select Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct MetadataBar: View {
    let wordCount: Int

    var body: some View {
        HStack {
            Label("\(wordCount) words", systemImage: "text.word.spacing")
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)

            Spacer()
        }
        .padding(.horizontal)
    }
}

// Flow Layout for tags
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)

                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
                size.width = max(size.width, currentX)
                size.height = currentY + lineHeight
            }

            self.size = size
            self.positions = positions
        }
    }
}

#Preview {
    NoteEditorView()
}

import SwiftUI

/// Mood log view for manually entering mood
public struct MoodLogView: View {
    @StateObject private var viewModel: MoodLogViewModel
    @Environment(\.dismiss) private var dismiss

    public init() {
        _viewModel = StateObject(wrappedValue: MoodLogViewModel(
            moodRepository: CoreDataMoodRepository(coreDataStack: .shared)
        ))
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("How are you feeling?")
                            .font(.title2.bold())

                        Text("Slide to adjust intensity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Emotion sliders
                    VStack(spacing: 16) {
                        emotionSlider("Joy", emotion: "joy", color: .yellow, emoji: "😊")
                        emotionSlider("Sadness", emotion: "sadness", color: .blue, emoji: "😢")
                        emotionSlider("Anger", emotion: "anger", color: .red, emoji: "😠")
                        emotionSlider("Fear", emotion: "fear", color: .purple, emoji: "😰")
                        emotionSlider("Surprise", emotion: "surprise", color: .orange, emoji: "😲")
                        emotionSlider("Disgust", emotion: "disgust", color: .green, emoji: "🤢")
                        emotionSlider("Trust", emotion: "trust", color: .cyan, emoji: "🤗")
                        emotionSlider("Anticipation", emotion: "anticipation", color: .pink, emoji: "🤩")
                    }

                    // Context note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a note (optional)")
                            .font(.subheadline.bold())

                        TextEditor(text: $viewModel.contextNote)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Log Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        Task {
                            await viewModel.saveMood()
                            if viewModel.error == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.selectedEmotions.values.allSatisfy { $0 == 0 })
                }
            }
            .alert("Success", isPresented: $viewModel.showingSuccessMessage) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Mood logged successfully")
            }
        }
    }

    private func emotionSlider(_ name: String, emotion: String, color: Color, emoji: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(emoji)
                    .font(.title3)

                Text(name)
                    .font(.subheadline.bold())

                Spacer()

                Text(String(format: "%.0f%%", (viewModel.selectedEmotions[emotion] ?? 0) * 100))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Slider(
                value: Binding(
                    get: { viewModel.selectedEmotions[emotion] ?? 0 },
                    set: { viewModel.updateEmotion(emotion, intensity: $0) }
                ),
                in: 0...1
            )
            .tint(color)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

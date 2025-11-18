import SwiftUI

/// AI controls view for managing AI features
public struct AIControlsView: View {
    @StateObject private var viewModel = AIControlsViewModel()

    public var body: some View {
        List {
            // AI Features
            Section("AI Features") {
                Toggle("Mood Detection", isOn: $viewModel.aiSettings.moodDetectionEnabled)
                Toggle("Auto Summarization", isOn: $viewModel.aiSettings.autoSummarization)
                Toggle("Entity Extraction", isOn: $viewModel.aiSettings.entityExtraction)
            }
            .onChange(of: viewModel.aiSettings) { settings in
                viewModel.updateAISettings(settings)
            }

            // Processing location
            Section {
                Toggle("Use Cloud AI", isOn: $viewModel.aiSettings.useCloudAI)

                VStack(alignment: .leading, spacing: 8) {
                    if viewModel.aiSettings.useCloudAI {
                        Label("Cloud AI enabled", systemImage: "cloud.fill")
                            .font(.caption)
                            .foregroundColor(.blue)

                        Text("Better accuracy and speed, requires internet connection")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Label("On-device AI enabled", systemImage: "iphone")
                            .font(.caption)
                            .foregroundColor(.green)

                        Text("Private and works offline, uses device resources")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Processing Location")
            } footer: {
                Text("On-device processing keeps your data private but may be slower. Cloud processing provides better results but requires an internet connection.")
            }

            // AI Models
            Section("AI Models") {
                ForEach(viewModel.modelInfo) { model in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(model.name)
                                .font(.subheadline.bold())

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: model.processingLocation.icon)
                                    .font(.caption)

                                Text(model.processingLocation.displayName)
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }

                        HStack {
                            Text(model.model)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text(model.size)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("•")
                                .foregroundColor(.secondary)

                            Text(model.accuracy)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Language
            Section("Language") {
                Picker("Preferred Language", selection: $viewModel.aiSettings.preferredLanguage) {
                    Text("English").tag("en")
                    Text("Spanish").tag("es")
                    Text("French").tag("fr")
                    Text("German").tag("de")
                    Text("Japanese").tag("ja")
                }
            }
            .onChange(of: viewModel.aiSettings.preferredLanguage) { _ in
                viewModel.updateAISettings(viewModel.aiSettings)
            }

            // Test AI
            Section {
                Button {
                    Task {
                        _ = try? await viewModel.testMoodDetection()
                    }
                } label: {
                    Label("Test Mood Detection", systemImage: "sparkles")
                }
            }

            // Info
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About AI Features")
                        .font(.headline)

                    Text("noema uses state-of-the-art AI models to understand your emotions and provide insights. All processing happens on your device by default, ensuring your privacy.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("AI models are downloaded once and stored locally. They do not require an internet connection unless you enable Cloud AI.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("AI Controls")
        .task {
            await viewModel.loadAIControls()
        }
    }
}

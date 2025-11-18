import SwiftUI

/// Voice recording view for capturing audio notes
public struct VoiceRecordingView: View {
    @StateObject private var viewModel = VoiceRecordingViewModel()
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Waveform visualization
                    if viewModel.isRecording {
                        WaveformView(audioLevel: viewModel.audioLevel)
                            .frame(height: 100)
                            .padding(.horizontal)
                    } else if !viewModel.transcription.isEmpty {
                        // Transcription
                        ScrollView {
                            Text(viewModel.transcription)
                                .font(.body)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 2)
                        }
                        .padding()
                    } else {
                        // Initial state
                        VStack(spacing: 16) {
                            Image(systemName: "waveform")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)

                            Text("Tap to start recording")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Timer
                    if viewModel.isRecording {
                        Text(formatDuration(viewModel.recordingDuration))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    // Controls
                    if viewModel.permissionStatus == .granted {
                        recordingControls
                    } else {
                        permissionPrompt
                    }
                }
                .padding()

                // Loading overlay
                if viewModel.isTranscribing {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)

                        Text("Transcribing...")
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("Voice Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.discardRecording()
                        dismiss()
                    }
                }

                if !viewModel.transcription.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Save") {
                            Task {
                                _ = try? await viewModel.saveAsNote()
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recording Controls

    @ViewBuilder
    private var recordingControls: some View {
        HStack(spacing: 40) {
            // Delete button (when stopped)
            if !viewModel.isRecording && viewModel.recordingDuration > 0 {
                Button {
                    viewModel.discardRecording()
                } label: {
                    Image(systemName: "trash")
                        .font(.title)
                        .foregroundColor(.red)
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }

            // Main record button
            Button {
                Task {
                    if viewModel.isRecording {
                        viewModel.stopRecording()
                        await viewModel.transcribeAudio()
                    } else {
                        await viewModel.startRecording()
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(viewModel.isRecording ? Color.red : Color.blue)
                        .frame(width: 80, height: 80)

                    if viewModel.isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                    } else {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                    }
                }
                .shadow(radius: 8)
            }

            // Pause button (when recording)
            if viewModel.isRecording {
                Button {
                    if viewModel.isPaused {
                        viewModel.resumeRecording()
                    } else {
                        viewModel.pauseRecording()
                    }
                } label: {
                    Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }
        }
    }

    // MARK: - Permission Prompt

    private var permissionPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("Microphone Access Required")
                .font(.headline)

            Text("noema needs microphone access to record voice notes")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Grant Access") {
                Task {
                    await viewModel.requestPermission()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Waveform View

struct WaveformView: View {
    let audioLevel: Float
    @State private var bars: [Float] = Array(repeating: 0.2, count: 50)

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(bars.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
                    .frame(width: 4, height: CGFloat(bars[index]) * 80)
            }
        }
        .onChange(of: audioLevel) { newLevel in
            updateBars(with: newLevel)
        }
    }

    private func updateBars(with level: Float) {
        bars.removeFirst()
        bars.append(level)
    }
}

//
//  VoiceRecorderView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI
import AVFoundation

public struct VoiceRecorderView: View {
    let onRecordingComplete: (URL, TimeInterval) -> Void

    @StateObject private var recorder = VoiceRecorder()
    @Environment(\.dismiss) private var dismiss
    @State private var showingPermissionAlert = false

    public init(onRecordingComplete: @escaping (URL, TimeInterval) -> Void) {
        self.onRecordingComplete = onRecordingComplete
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.noemaBackground.ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Waveform Visualization
                    WaveformView(isRecording: recorder.isRecording, level: recorder.audioLevel)
                        .frame(height: 200)

                    // Timer
                    Text(formatDuration(recorder.duration))
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundColor(.noemaTextPrimary)

                    Spacer()

                    // Controls
                    HStack(spacing: 60) {
                        // Cancel Button
                        if recorder.isRecording || recorder.hasRecording {
                            Button {
                                recorder.cancelRecording()
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title)
                                    .foregroundColor(.red)
                                    .frame(width: 60, height: 60)
                                    .background(Color.red.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }

                        // Record/Stop Button
                        Button {
                            if recorder.isRecording {
                                recorder.stopRecording()
                            } else if recorder.hasRecording {
                                recorder.playRecording()
                            } else {
                                recorder.startRecording()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(recorder.isRecording ? Color.red : Color.noemaPrimary)
                                    .frame(width: 80, height: 80)

                                if recorder.isRecording {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                } else if recorder.hasRecording {
                                    Image(systemName: recorder.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                } else {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                        .scaleEffect(recorder.isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: recorder.isRecording)

                        // Save Button
                        if recorder.hasRecording {
                            Button {
                                if let url = recorder.recordingURL {
                                    onRecordingComplete(url, recorder.duration)
                                    dismiss()
                                }
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.title)
                                    .foregroundColor(.green)
                                    .frame(width: 60, height: 60)
                                    .background(Color.green.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Voice Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        recorder.cancelRecording()
                        dismiss()
                    }
                }
            }
            .alert("Microphone Access Required", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Please enable microphone access in Settings to record voice notes.")
            }
            .onAppear {
                recorder.requestPermission { granted in
                    if !granted {
                        showingPermissionAlert = true
                    }
                }
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Waveform Visualization

private struct WaveformView: View {
    let isRecording: Bool
    let level: Float

    @State private var barHeights: [CGFloat] = Array(repeating: 0.2, count: 50)
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(0..<barHeights.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.noemaPrimary.opacity(0.7))
                    .frame(width: 3, height: barHeights[index] * 150)
                    .animation(.easeInOut(duration: 0.1), value: barHeights[index])
            }
        }
        .onReceive(timer) { _ in
            if isRecording {
                updateWaveform()
            } else {
                resetWaveform()
            }
        }
    }

    private func updateWaveform() {
        barHeights.removeFirst()
        let newHeight = CGFloat(level) * 0.8 + CGFloat.random(in: 0.2...0.4)
        barHeights.append(newHeight)
    }

    private func resetWaveform() {
        withAnimation {
            barHeights = Array(repeating: 0.2, count: 50)
        }
    }
}

// MARK: - Voice Recorder

@MainActor
class VoiceRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var hasRecording = false
    @Published var duration: TimeInterval = 0
    @Published var audioLevel: Float = 0

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    var recordingURL: URL?

    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let url = FileManager.default.temporaryDirectory.appendingPathComponent("recording-\(UUID().uuidString).m4a")

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            recordingURL = url
            isRecording = true
            hasRecording = false
            duration = 0

            startTimer()
        } catch {
            Logger.ui.error("Failed to start recording", error: error)
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        hasRecording = true
        stopTimer()
    }

    func playRecording() {
        guard let url = recordingURL else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlaying = true
        } catch {
            Logger.ui.error("Failed to play recording", error: error)
        }
    }

    func cancelRecording() {
        audioRecorder?.stop()
        audioPlayer?.stop()
        isRecording = false
        isPlaying = false
        hasRecording = false
        duration = 0
        stopTimer()

        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.duration = self.audioRecorder?.currentTime ?? 0
            self.audioRecorder?.updateMeters()
            self.audioLevel = self.audioRecorder?.averagePower(forChannel: 0) ?? 0
            // Normalize level from dB (-160 to 0) to 0-1
            self.audioLevel = (self.audioLevel + 160) / 160
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        audioLevel = 0
    }

    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            isRecording = false
            hasRecording = flag
        }
    }
}

#Preview {
    VoiceRecorderView { url, duration in
        print("Recording completed: \(url), duration: \(duration)")
    }
}

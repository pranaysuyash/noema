import SwiftUI
import AVFoundation

/// ViewModel for voice recording screen
/// Handles audio recording, transcription, and note creation from voice
@MainActor
public final class VoiceRecordingViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var isRecording: Bool = false
    @Published public var isPaused: Bool = false
    @Published public var isTranscribing: Bool = false
    @Published public var recordingDuration: TimeInterval = 0
    @Published public var audioLevel: Float = 0.0
    @Published public var transcription: String = ""
    @Published public var error: Error?
    @Published public var permissionStatus: AVAudioSession.RecordPermission = .undetermined

    // MARK: - Private Properties

    private var recordingTimer: Timer?
    private var audioLevelTimer: Timer?
    private var recordingStartTime: Date?
    private var audioFileURL: URL?

    // MARK: - Dependencies

    // TODO: Inject AudioRecorder and TranscriptionEngine when implemented
    // private let audioRecorder: AudioRecorder
    // private let transcriptionEngine: TranscriptionEngine

    // MARK: - Initialization

    public init() {
        checkPermissions()
    }

    deinit {
        stopRecording()
    }

    // MARK: - Public Methods

    public func checkPermissions() {
        permissionStatus = AVAudioSession.sharedInstance().recordPermission
    }

    public func requestPermission() async {
        let granted = await AVAudioSession.sharedInstance().requestRecordPermission()
        permissionStatus = granted ? .granted : .denied
    }

    public func startRecording() async {
        guard permissionStatus == .granted else {
            error = VoiceRecordingError.permissionDenied
            return
        }

        do {
            // Configure audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)

            // TODO: Start actual recording with AudioRecorder
            // For now, simulate recording
            isRecording = true
            recordingStartTime = Date()
            startTimers()

        } catch {
            self.error = error
        }
    }

    public func pauseRecording() {
        guard isRecording, !isPaused else { return }

        // TODO: Pause actual recording
        isPaused = true
        stopTimers()
    }

    public func resumeRecording() {
        guard isRecording, isPaused else { return }

        // TODO: Resume actual recording
        isPaused = false
        startTimers()
    }

    public func stopRecording() {
        guard isRecording else { return }

        isRecording = false
        isPaused = false
        stopTimers()

        // TODO: Stop actual recording and get audio file
        // audioFileURL = audioRecorder.stopRecording()
    }

    public func transcribeAudio() async {
        guard let audioURL = audioFileURL else {
            error = VoiceRecordingError.noRecording
            return
        }

        isTranscribing = true
        error = nil

        do {
            // TODO: Use TranscriptionEngine when implemented
            // transcription = try await transcriptionEngine.transcribe(audioURL: audioURL)

            // Simulated transcription for now
            try await Task.sleep(nanoseconds: 2_000_000_000)  // 2 seconds
            transcription = "This is a simulated transcription of your voice recording."

        } catch {
            self.error = error
        }

        isTranscribing = false
    }

    public func saveAsNote() async throws -> Note {
        guard !transcription.isEmpty else {
            throw VoiceRecordingError.noTranscription
        }

        let note = Note(
            id: UUID(),
            content: transcription,
            createdAt: Date(),
            modifiedAt: Date(),
            mood: nil,
            entities: [],
            summary: nil,
            tags: [],
            isFavorite: false,
            isArchived: false
        )

        // TODO: Save note using repository
        // return try await noteRepository.save(note)

        return note
    }

    public func discardRecording() {
        if let audioURL = audioFileURL {
            try? FileManager.default.removeItem(at: audioURL)
        }

        resetState()
    }

    public func resetState() {
        isRecording = false
        isPaused = false
        isTranscribing = false
        recordingDuration = 0
        audioLevel = 0.0
        transcription = ""
        error = nil
        recordingStartTime = nil
        audioFileURL = nil
        stopTimers()
    }

    // MARK: - Private Methods

    private func startTimers() {
        // Timer for recording duration
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.recordingStartTime else { return }
            self.recordingDuration = Date().timeIntervalSince(startTime)
        }

        // Timer for audio level animation
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            // TODO: Get actual audio level from recorder
            // For now, simulate with random values
            self?.audioLevel = Float.random(in: 0.1...0.9)
        }
    }

    private func stopTimers() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
    }
}

// MARK: - Voice Recording Error

public enum VoiceRecordingError: Error, LocalizedError {
    case permissionDenied
    case recordingFailed
    case noRecording
    case transcriptionFailed
    case noTranscription

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone permission denied. Please enable in Settings."
        case .recordingFailed:
            return "Failed to start recording"
        case .noRecording:
            return "No recording to transcribe"
        case .transcriptionFailed:
            return "Failed to transcribe audio"
        case .noTranscription:
            return "No transcription available"
        }
    }
}

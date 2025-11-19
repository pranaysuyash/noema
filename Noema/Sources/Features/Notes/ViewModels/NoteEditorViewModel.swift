//
//  NoteEditorViewModel.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import CoreData
import Combine
import AVFoundation

@MainActor
public final class NoteEditorViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var content: String = ""
    @Published public var selectedTags: [Tag] = []
    @Published public var selectedFolder: Folder?
    @Published public var isRecording: Bool = false
    @Published public var audioURL: URL?
    @Published public var detectedEmotion: EmotionalState?
    @Published public var detectedEntities: [Entity] = []
    @Published public var isSaving: Bool = false
    @Published public var error: Error?

    // MARK: - Dependencies

    private let noteService: NoteService
    private let emotionService: EmotionAnalysisService
    private let entityService: EntityService
    private let gamificationService: GamificationService

    // Audio recording
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession?

    // MARK: - Initialization

    public init(
        noteService: NoteService = NoteService(),
        emotionService: EmotionAnalysisService = EmotionAnalysisService(),
        entityService: EntityService = EntityService(),
        gamificationService: GamificationService = GamificationService()
    ) {
        self.noteService = noteService
        self.emotionService = emotionService
        self.entityService = entityService
        self.gamificationService = gamificationService

        setupAudioSession()
        setupBindings()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
        } catch {
            Logger.ui.error("Failed to setup audio session", error: error)
        }
    }

    private func setupBindings() {
        // Auto-analyze emotion as user types
        $content
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard !text.isEmpty else { return }
                Task { await self?.analyzeEmotion() }
                Task { await self?.extractEntities() }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Methods

    public func saveNote() async {
        guard !content.isEmpty else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let note: Note
            if let audioURL = audioURL {
                note = try await noteService.createVoiceNote(
                    audioURL: audioURL,
                    transcription: content,
                    tags: selectedTags,
                    folder: selectedFolder
                )
            } else {
                note = try await noteService.createTextNote(
                    content: content,
                    tags: selectedTags,
                    folder: selectedFolder
                )
            }

            // Award XP
            let xp = gamificationService.calculateXP(for: note)
            try await gamificationService.awardXP(xp)

            // Reset form
            resetForm()

            Logger.ui.info("Note saved successfully with \(xp) XP")
        } catch {
            self.error = error
            Logger.ui.error("Failed to save note", error: error)
        }
    }

    public func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording-\(UUID().uuidString).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            audioURL = audioFilename

            Logger.ui.info("Started audio recording")
        } catch {
            self.error = error
            Logger.ui.error("Failed to start recording", error: error)
        }
    }

    public func stopRecording() {
        audioRecorder?.stop()
        isRecording = false

        if let url = audioURL {
            Logger.ui.info("Stopped audio recording: \(url)")
            // Transcribe in background
            Task {
                await transcribeAudio()
            }
        }
    }

    // MARK: - Private Methods

    private func analyzeEmotion() async {
        do {
            detectedEmotion = try await emotionService.analyzeTextEmotion(text: content)
        } catch {
            Logger.ui.error("Failed to analyze emotion", error: error)
        }
    }

    private func extractEntities() async {
        do {
            detectedEntities = try await entityService.extractEntities(from: content)
        } catch {
            Logger.ui.error("Failed to extract entities", error: error)
        }
    }

    private func transcribeAudio() async {
        guard let url = audioURL else { return }

        // Placeholder for Whisper transcription
        // TODO: Implement actual Whisper transcription
        Logger.ai.info("Transcribing audio from \(url)")
    }

    private func resetForm() {
        content = ""
        selectedTags = []
        selectedFolder = nil
        audioURL = nil
        detectedEmotion = nil
        detectedEntities = []
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

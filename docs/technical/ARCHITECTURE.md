# noema: Technical Architecture Document

## Version 1.0 | Last Updated: 2025-11-17

## Table of Contents
1. [System Overview](#system-overview)
2. [Architecture Principles](#architecture-principles)
3. [Layer Architecture](#layer-architecture)
4. [Core Components](#core-components)
5. [Data Flow](#data-flow)
6. [AI/ML Pipeline](#aiml-pipeline)
7. [Security Architecture](#security-architecture)
8. [Performance & Scalability](#performance--scalability)
9. [Technology Stack](#technology-stack)
10. [Deployment & Infrastructure](#deployment--infrastructure)

---

## 1. System Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER DEVICES (iOS 17+)                       │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    Presentation Layer                         │  │
│  │  • SwiftUI Views • Animations • Haptics • Accessibility      │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                 Application Logic Layer                       │  │
│  │  • Coordinators • ViewModels • Use Cases                     │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                   Domain Layer (Core)                         │  │
│  │  • Business Logic • Entities • Repository Protocols          │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              ▼                                       │
│  ┌──────────────────┬──────────────────┬────────────────────────┐  │
│  │  AI Processing   │   Data Layer     │  Platform Services     │  │
│  │  • On-Device ML  │   • Core Data    │  • HealthKit          │  │
│  │  • Cloud AI      │   • CloudKit     │  • Speech/AVF         │  │
│  └──────────────────┴──────────────────┴────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        CLOUD SERVICES (Optional)                     │
│  • CloudKit (Encrypted Sync) • API Gateway • ML Inference          │
│  • Analytics (Amplitude) • Crash Reporting (Crashlytics)           │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.2 Core Architectural Decisions

**Decision 1: Offline-First, Local-First**
- **Rationale**: Privacy, performance, user trust
- **Implementation**: Core Data as single source of truth, CloudKit for sync only
- **Tradeoff**: More complex sync logic vs. simpler cloud-first approach

**Decision 2: On-Device AI as Default**
- **Rationale**: Privacy, latency, battery efficiency (with Neural Engine)
- **Implementation**: Core ML quantized models, fallback to cloud for advanced features
- **Tradeoff**: Limited model sophistication vs. unlimited cloud compute

**Decision 3: MVVM-C (Model-View-ViewModel-Coordinator)**
- **Rationale**: Testability, SwiftUI compatibility, navigation decoupling
- **Implementation**: Coordinators manage flow, ViewModels manage state
- **Tradeoff**: More boilerplate vs. simpler MVC

**Decision 4: Clean Architecture with Domain Layer**
- **Rationale**: Business logic independence from frameworks (testability, portability)
- **Implementation**: Domain entities, use cases, repository protocols
- **Tradeoff**: More layers vs. simpler direct data access

**Decision 5: Swift Package Manager (SPM) over CocoaPods**
- **Rationale**: Native to Xcode, faster builds, better IDE integration
- **Implementation**: Package.swift for dependencies
- **Tradeoff**: Smaller ecosystem vs. CocoaPods' maturity

---

## 2. Architecture Principles

### 2.1 SOLID Principles

**Single Responsibility Principle (SRP)**
```swift
// ❌ Bad: God object doing everything
class NoteManager {
    func createNote()
    func transcribeAudio()
    func detectMood()
    func syncToCloud()
    func generateSummary()
}

// ✅ Good: Separate responsibilities
class NoteRepository { func createNote() }
class TranscriptionService { func transcribe() }
class MoodAnalyzer { func detectMood() }
class SyncEngine { func syncToCloud() }
class SummaryGenerator { func generateSummary() }
```

**Open/Closed Principle (OCP)**
```swift
// ✅ Good: Open for extension via protocol
protocol MoodDetector {
    func analyze(text: String) -> MoodSnapshot
}

class VoiceMoodDetector: MoodDetector { ... }
class TextMoodDetector: MoodDetector { ... }
class MultimodalMoodDetector: MoodDetector { ... } // Easy to add
```

**Liskov Substitution Principle (LSP)**
```swift
// ✅ Good: Subtypes can replace base types
protocol AIModel {
    func predict(input: Data) async throws -> Data
}

class OnDeviceModel: AIModel { ... }
class CloudModel: AIModel { ... }

// Can swap implementations without breaking code
func processWithAI(model: AIModel, input: Data) async throws -> Data {
    return try await model.predict(input: input)
}
```

**Interface Segregation Principle (ISP)**
```swift
// ❌ Bad: Fat protocol forces unnecessary implementations
protocol NoteStorage {
    func save(_ note: Note)
    func syncToCloud() // Not all storage needs cloud
    func exportToPDF() // Not all storage needs export
}

// ✅ Good: Segregated interfaces
protocol NoteStorageProtocol {
    func save(_ note: Note)
}

protocol CloudSyncable {
    func syncToCloud()
}

protocol Exportable {
    func exportToPDF() -> Data
}
```

**Dependency Inversion Principle (DIP)**
```swift
// ✅ Good: Depend on abstractions, not concrete types
class NoteCreationViewModel {
    private let repository: NoteRepositoryProtocol // Protocol, not CoreDataNoteRepository
    private let aiService: AIServiceProtocol       // Protocol, not CoreMLService

    init(repository: NoteRepositoryProtocol, aiService: AIServiceProtocol) {
        self.repository = repository
        self.aiService = aiService
    }
}
```

### 2.2 Additional Principles

**Privacy by Design**
- Default to on-device processing
- Explicit user consent for cloud features
- Data minimization: Collect only what's needed

**Performance by Design**
- Async/await for all I/O operations
- Lazy loading for heavy resources
- Pagination for large datasets

**Accessibility by Design**
- VoiceOver support from day one
- Dynamic Type support
- High contrast mode testing

---

## 3. Layer Architecture

### 3.1 Presentation Layer

**Responsibilities:**
- Render UI based on ViewModels
- Handle user interactions
- Animations and haptic feedback
- Accessibility support

**Technologies:**
- **SwiftUI**: Modern, declarative UI
- **UIKit**: Complex gestures, custom animations
- **Combine**: Reactive state management

**Structure:**
```
Presentation/
├── Views/
│   ├── Notes/
│   │   ├── NoteListView.swift
│   │   ├── NoteDetailView.swift
│   │   ├── NoteEditorView.swift
│   │   └── VoiceRecordingView.swift
│   ├── Mood/
│   │   ├── MoodTimelineView.swift
│   │   ├── MoodDashboardView.swift
│   │   └── MoodLogView.swift
│   ├── Gamification/
│   │   ├── AchievementView.swift
│   │   ├── LevelProgressView.swift
│   │   └── VirtualGardenView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       ├── PrivacyDashboardView.swift
│       └── AIControlsView.swift
├── ViewModels/
│   ├── NoteListViewModel.swift
│   ├── NoteEditorViewModel.swift
│   ├── MoodDashboardViewModel.swift
│   └── SettingsViewModel.swift
├── Coordinators/
│   ├── AppCoordinator.swift
│   ├── NotesCoordinator.swift
│   ├── MoodCoordinator.swift
│   └── SettingsCoordinator.swift
└── Components/
    ├── MoodPicker.swift
    ├── EmotionChart.swift
    └── AnimatedButton.swift
```

**Key Patterns:**
```swift
// View: Stateless, driven by ViewModel
struct NoteEditorView: View {
    @StateObject var viewModel: NoteEditorViewModel

    var body: some View {
        VStack {
            TextEditor(text: $viewModel.noteContent)
            MoodPicker(mood: $viewModel.currentMood)
            Button("Save") { viewModel.saveNote() }
        }
        .task { await viewModel.loadNote() }
    }
}

// ViewModel: Holds state, coordinates use cases
@MainActor
class NoteEditorViewModel: ObservableObject {
    @Published var noteContent: String = ""
    @Published var currentMood: MoodSnapshot?

    private let createNoteUseCase: CreateNoteUseCase
    private let analyzeMoodUseCase: AnalyzeMoodUseCase

    init(createNoteUseCase: CreateNoteUseCase, analyzeMoodUseCase: AnalyzeMoodUseCase) {
        self.createNoteUseCase = createNoteUseCase
        self.analyzeMoodUseCase = analyzeMoodUseCase
    }

    func saveNote() {
        Task {
            let note = Note(content: noteContent, mood: currentMood)
            try await createNoteUseCase.execute(note: note)
        }
    }
}
```

### 3.2 Application Logic Layer

**Responsibilities:**
- Navigation flow (Coordinators)
- State management (ViewModels)
- Orchestrate use cases
- Error handling and user feedback

**Structure:**
```
Application/
├── Coordinators/
│   └── [See Presentation section]
├── UseCases/
│   ├── Notes/
│   │   ├── CreateNoteUseCase.swift
│   │   ├── UpdateNoteUseCase.swift
│   │   ├── DeleteNoteUseCase.swift
│   │   └── SearchNotesUseCase.swift
│   ├── Mood/
│   │   ├── AnalyzeMoodUseCase.swift
│   │   ├── GetMoodTimelineUseCase.swift
│   │   └── CorrelateMoodUseCase.swift
│   ├── AI/
│   │   ├── TranscribeAudioUseCase.swift
│   │   ├── GenerateSummaryUseCase.swift
│   │   └── ExtractEntitiesUseCase.swift
│   └── Gamification/
│       ├── AwardAchievementUseCase.swift
│       ├── UpdateLevelUseCase.swift
│       └── TrackStreakUseCase.swift
└── Services/
    ├── NotificationService.swift
    ├── AnalyticsService.swift
    └── ErrorHandlingService.swift
```

**Use Case Pattern:**
```swift
// Use Case: Single responsibility, testable, reusable
protocol CreateNoteUseCase {
    func execute(note: Note) async throws -> Note
}

class DefaultCreateNoteUseCase: CreateNoteUseCase {
    private let noteRepository: NoteRepositoryProtocol
    private let moodAnalyzer: MoodAnalyzerProtocol
    private let achievementTracker: AchievementTrackerProtocol

    init(
        noteRepository: NoteRepositoryProtocol,
        moodAnalyzer: MoodAnalyzerProtocol,
        achievementTracker: AchievementTrackerProtocol
    ) {
        self.noteRepository = noteRepository
        self.moodAnalyzer = moodAnalyzer
        self.achievementTracker = achievementTracker
    }

    func execute(note: Note) async throws -> Note {
        // 1. Analyze mood if not provided
        var finalNote = note
        if note.mood == nil {
            let mood = try await moodAnalyzer.analyze(text: note.content)
            finalNote.mood = mood
        }

        // 2. Save to repository
        let savedNote = try await noteRepository.save(finalNote)

        // 3. Track achievements (fire and forget)
        Task.detached {
            try? await self.achievementTracker.trackNoteCreation()
        }

        return savedNote
    }
}
```

### 3.3 Domain Layer (Core)

**Responsibilities:**
- Business entities (models)
- Business logic (rules)
- Repository protocols (interfaces)
- Domain services (complex business operations)

**Independence:**
- ❌ No UIKit/SwiftUI imports
- ❌ No Core Data imports
- ❌ No framework dependencies
- ✅ Pure Swift, testable in isolation

**Structure:**
```
Domain/
├── Entities/
│   ├── Note.swift
│   ├── MoodSnapshot.swift
│   ├── Achievement.swift
│   ├── UserProfile.swift
│   ├── Tag.swift
│   └── NamedEntity.swift
├── ValueObjects/
│   ├── EmotionalDimensions.swift
│   ├── WellnessScore.swift
│   └── StreakInfo.swift
├── RepositoryProtocols/
│   ├── NoteRepositoryProtocol.swift
│   ├── MoodRepositoryProtocol.swift
│   ├── AchievementRepositoryProtocol.swift
│   └── UserProfileRepositoryProtocol.swift
├── DomainServices/
│   ├── MoodCorrelationService.swift
│   ├── WellnessCalculator.swift
│   └── CrisisDetector.swift
└── Enums/
    ├── MoodSource.swift
    ├── AchievementType.swift
    └── AchievementTier.swift
```

**Entity Example:**
```swift
// Domain Entity: Pure business logic, no framework dependencies
struct Note: Identifiable, Equatable {
    let id: UUID
    var content: String
    let createdAt: Date
    var modifiedAt: Date
    var mood: MoodSnapshot?
    var entities: [NamedEntity]
    var summary: String?
    var audioURL: URL?
    var transcription: Transcription?
    var tags: [Tag]
    var location: Location?
    var weather: WeatherSnapshot?

    init(
        id: UUID = UUID(),
        content: String,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        mood: MoodSnapshot? = nil,
        entities: [NamedEntity] = [],
        summary: String? = nil,
        audioURL: URL? = nil,
        transcription: Transcription? = nil,
        tags: [Tag] = [],
        location: Location? = nil,
        weather: WeatherSnapshot? = nil
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.mood = mood
        self.entities = entities
        self.summary = summary
        self.audioURL = audioURL
        self.transcription = transcription
        self.tags = tags
        self.location = location
        self.weather = weather
    }

    // Business logic: word count
    var wordCount: Int {
        content.split(separator: " ").count
    }

    // Business logic: estimated reading time
    var estimatedReadingTime: TimeInterval {
        Double(wordCount) / 200.0 * 60.0 // 200 words per minute
    }

    // Business logic: is recent?
    func isRecent(within interval: TimeInterval) -> Bool {
        Date().timeIntervalSince(createdAt) < interval
    }
}

// Value Object: Emotional dimensions (immutable)
struct EmotionalDimensions: Equatable, Codable {
    let joy: Float          // 0.0 - 1.0
    let sadness: Float
    let anger: Float
    let fear: Float
    let surprise: Float
    let disgust: Float
    let trust: Float
    let anticipation: Float

    // Validate all dimensions are in [0, 1]
    init?(
        joy: Float,
        sadness: Float,
        anger: Float,
        fear: Float,
        surprise: Float,
        disgust: Float,
        trust: Float,
        anticipation: Float
    ) {
        guard [joy, sadness, anger, fear, surprise, disgust, trust, anticipation]
                .allSatisfy({ $0 >= 0 && $0 <= 1 })
        else { return nil }

        self.joy = joy
        self.sadness = sadness
        self.anger = anger
        self.fear = fear
        self.surprise = surprise
        self.disgust = disgust
        self.trust = trust
        self.anticipation = anticipation
    }

    // Business logic: dominant emotion
    var dominantEmotion: String {
        let emotions: [(String, Float)] = [
            ("joy", joy), ("sadness", sadness), ("anger", anger), ("fear", fear),
            ("surprise", surprise), ("disgust", disgust), ("trust", trust), ("anticipation", anticipation)
        ]
        return emotions.max(by: { $0.1 < $1.1 })?.0 ?? "neutral"
    }

    // Business logic: overall valence (positive/negative)
    var valence: Float {
        let positive = joy + trust + anticipation
        let negative = sadness + anger + fear + disgust
        return (positive - negative) / 8.0 // Normalized to [-1, 1]
    }
}

// Repository Protocol: Interface for data access
protocol NoteRepositoryProtocol {
    func save(_ note: Note) async throws -> Note
    func fetch(id: UUID) async throws -> Note?
    func fetchAll() async throws -> [Note]
    func fetchRecent(limit: Int) async throws -> [Note]
    func search(query: String) async throws -> [Note]
    func delete(id: UUID) async throws
    func update(_ note: Note) async throws -> Note

    // Mood-based queries
    func fetchNotes(withMood mood: String) async throws -> [Note]
    func fetchNotes(in dateRange: ClosedRange<Date>) async throws -> [Note]
}
```

### 3.4 AI Processing Layer

**Responsibilities:**
- On-device ML model inference
- Cloud AI API calls (opt-in)
- Model management (loading, caching)
- Feature extraction and preprocessing

**Structure:**
```
AIProcessing/
├── OnDevice/
│   ├── TranscriptionModel.swift
│   ├── EmotionModel.swift
│   ├── NERModel.swift
│   ├── SummarizationModel.swift
│   └── ModelManager.swift
├── Cloud/
│   ├── CloudAIService.swift
│   ├── OpenAIClient.swift
│   └── CustomModelClient.swift
├── Preprocessing/
│   ├── AudioPreprocessor.swift
│   ├── TextPreprocessor.swift
│   └── FeatureExtractor.swift
└── PostProcessing/
    ├── EmotionPostProcessor.swift
    ├── NERPostProcessor.swift
    └── SummaryFormatter.swift
```

**On-Device Model Pattern:**
```swift
// On-Device ML Model Wrapper
protocol MLModelProtocol {
    associatedtype Input
    associatedtype Output

    func load() async throws
    func predict(input: Input) async throws -> Output
    func unload()
}

actor EmotionDetectionModel: MLModelProtocol {
    private var model: MLModel?
    private let modelURL: URL

    init(modelURL: URL) {
        self.modelURL = modelURL
    }

    func load() async throws {
        guard model == nil else { return }
        let config = MLModelConfiguration()
        config.computeUnits = .all // Use Neural Engine if available
        model = try await MLModel.load(contentsOf: modelURL, configuration: config)
    }

    func predict(input: String) async throws -> EmotionalDimensions {
        guard let model = model else {
            throw AIError.modelNotLoaded
        }

        // Preprocess text
        let tokenized = try await preprocessText(input)

        // Create MLFeatureProvider
        let inputFeatures = try MLDictionaryFeatureProvider(dictionary: [
            "input_ids": tokenized
        ])

        // Predict
        let output = try model.prediction(from: inputFeatures)

        // Post-process
        return try parseEmotionOutput(output)
    }

    func unload() {
        model = nil
    }

    private func preprocessText(_ text: String) async throws -> MLMultiArray {
        // Tokenization logic
        ...
    }

    private func parseEmotionOutput(_ output: MLFeatureProvider) throws -> EmotionalDimensions {
        // Parse model output to EmotionalDimensions
        ...
    }
}
```

### 3.5 Data Layer

**Responsibilities:**
- Persistent storage (Core Data)
- Cloud sync (CloudKit)
- Caching strategies
- Data migration

**Structure:**
```
Data/
├── Repositories/
│   ├── CoreDataNoteRepository.swift
│   ├── CoreDataMoodRepository.swift
│   ├── CoreDataAchievementRepository.swift
│   └── UserDefaultsPreferencesRepository.swift
├── CoreData/
│   ├── NoemaDataModel.xcdatamodeld
│   ├── CoreDataStack.swift
│   ├── NSManagedObject+Extensions.swift
│   └── CoreDataMigrations.swift
├── CloudKit/
│   ├── CloudKitManager.swift
│   ├── SyncEngine.swift
│   └── ConflictResolver.swift
└── Cache/
    ├── ImageCache.swift
    ├── AudioCache.swift
    └── ModelCache.swift
```

**Repository Implementation:**
```swift
// Concrete repository implementing domain protocol
actor CoreDataNoteRepository: NoteRepositoryProtocol {
    private let context: NSManagedObjectContext
    private let cloudKitManager: CloudKitManager?

    init(context: NSManagedObjectContext, cloudKitManager: CloudKitManager? = nil) {
        self.context = context
        self.cloudKitManager = cloudKitManager
    }

    func save(_ note: Note) async throws -> Note {
        // Map domain entity to Core Data entity
        let managedNote = NoteEntity(context: context)
        managedNote.id = note.id
        managedNote.content = note.content
        managedNote.createdAt = note.createdAt
        // ... map all properties

        try context.save()

        // Trigger sync if enabled
        if let cloudKitManager = cloudKitManager {
            Task.detached {
                try? await cloudKitManager.syncNote(note)
            }
        }

        return note
    }

    func fetchAll() async throws -> [Note] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let entities = try context.fetch(request)
        return entities.map { $0.toDomainModel() }
    }

    // ... other methods
}

// Mapping extension
extension NoteEntity {
    func toDomainModel() -> Note {
        Note(
            id: id ?? UUID(),
            content: content ?? "",
            createdAt: createdAt ?? Date(),
            modifiedAt: modifiedAt ?? Date(),
            mood: mood?.toDomainModel(),
            // ... map all properties
        )
    }
}
```

---

## 4. Core Components

### 4.1 Mood Analysis Engine

**Architecture:**
```
Input: Text/Voice → Preprocessor → Model → Postprocessor → EmotionalDimensions
                                   ↓
                            Context Enrichment
                        (time, location, history)
```

**Implementation:**
```swift
actor MoodAnalysisEngine {
    private let textModel: EmotionDetectionModel
    private let voiceModel: VoiceEmotionModel
    private let contextEnricher: ContextEnricher

    func analyze(text: String, audio: AVAudioFile? = nil) async throws -> MoodSnapshot {
        // Parallel analysis if both available
        async let textMood = analyzeText(text)
        async let voiceMood = audio != nil ? analyzeVoice(audio!) : nil

        // Combine results
        let textResult = try await textMood
        let voiceResult = try await voiceMood

        let combined = combineEmotions(text: textResult, voice: voiceResult)

        // Enrich with context
        let enriched = await contextEnricher.enrich(mood: combined, at: Date())

        return MoodSnapshot(
            id: UUID(),
            timestamp: Date(),
            dimensions: enriched,
            confidence: calculateConfidence(text: textResult, voice: voiceResult),
            source: voiceResult != nil ? .voice : .text,
            context: nil
        )
    }

    private func combineEmotions(text: EmotionalDimensions, voice: EmotionalDimensions?) -> EmotionalDimensions {
        guard let voice = voice else { return text }

        // Weighted average: voice is more reliable for some emotions
        return EmotionalDimensions(
            joy: text.joy * 0.3 + voice.joy * 0.7,
            sadness: text.sadness * 0.4 + voice.sadness * 0.6,
            // ... other dimensions
        )!
    }
}
```

### 4.2 Transcription Engine

**Architecture:**
```
Audio Input → Noise Cancellation → VAD (Voice Activity Detection)
           → Chunking → Whisper Model → Post-Processing → Transcription
```

**Implementation:**
```swift
actor TranscriptionEngine {
    private let whisperModel: WhisperModel
    private let audioProcessor: AudioProcessor
    private let languageDetector: LanguageDetector

    func transcribe(audioURL: URL, language: String? = nil) async throws -> Transcription {
        // 1. Preprocess audio
        let processedAudio = try await audioProcessor.process(audioURL)

        // 2. Detect language if not specified
        let finalLanguage = language ?? (try await languageDetector.detect(processedAudio))

        // 3. Chunk audio for processing
        let chunks = await audioProcessor.chunk(processedAudio, maxDuration: 30.0)

        // 4. Transcribe chunks in parallel
        let segments = try await withThrowingTaskGroup(of: TranscriptionSegment.self) { group in
            for chunk in chunks {
                group.addTask {
                    try await self.whisperModel.transcribe(
                        audio: chunk,
                        language: finalLanguage
                    )
                }
            }

            var results: [TranscriptionSegment] = []
            for try await segment in group {
                results.append(segment)
            }
            return results.sorted(by: { $0.timestamp < $1.timestamp })
        }

        // 5. Combine segments
        let fullText = segments.map { $0.text }.joined(separator: " ")

        return Transcription(
            text: fullText,
            segments: segments,
            language: finalLanguage,
            confidence: segments.map { $0.confidence }.reduce(0, +) / Double(segments.count)
        )
    }
}
```

### 4.3 Gamification Engine

**Architecture:**
```
User Action → Event Tracker → Achievement Evaluator → State Updater → UI Notification
                               ↓
                          Rule Engine
                    (streak, level, badges)
```

**Implementation:**
```swift
actor GamificationEngine {
    private let achievementRepository: AchievementRepositoryProtocol
    private let profileRepository: UserProfileRepositoryProtocol
    private let notificationService: NotificationService

    // Track note creation event
    func trackNoteCreation() async throws {
        let profile = try await profileRepository.fetchProfile()

        // Update stats
        var updatedProfile = profile
        updatedProfile.totalNotes += 1
        updatedProfile.updateStreak()

        // Check for level up
        updatedProfile.addExperience(points: 10)
        let didLevelUp = updatedProfile.checkLevelUp()

        try await profileRepository.updateProfile(updatedProfile)

        // Check for achievements
        let newAchievements = try await evaluateAchievements(profile: updatedProfile)

        // Notify user
        if didLevelUp {
            await notificationService.showLevelUpNotification(level: updatedProfile.level)
        }

        for achievement in newAchievements {
            await notificationService.showAchievementNotification(achievement: achievement)
        }
    }

    private func evaluateAchievements(profile: UserProfile) async throws -> [Achievement] {
        let allAchievements = try await achievementRepository.fetchAll()
        var newAchievements: [Achievement] = []

        for var achievement in allAchievements where achievement.unlockedAt == nil {
            if isAchievementUnlocked(achievement, profile: profile) {
                achievement.unlockedAt = Date()
                try await achievementRepository.update(achievement)
                newAchievements.append(achievement)
            }
        }

        return newAchievements
    }

    private func isAchievementUnlocked(_ achievement: Achievement, profile: UserProfile) -> Bool {
        switch achievement.type {
        case .firstNote:
            return profile.totalNotes >= 1
        case .streak7Days:
            return profile.streak >= 7
        case .streak30Days:
            return profile.streak >= 30
        case .level10:
            return profile.level >= 10
        case .noteMaster100:
            return profile.totalNotes >= 100
        // ... more achievement logic
        default:
            return false
        }
    }
}

extension UserProfile {
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastNoteDate = lastNoteDate else {
            streak = 1
            lastNoteDate = today
            return
        }

        let daysSinceLastNote = calendar.dateComponents([.day], from: lastNoteDate, to: today).day ?? 0

        if daysSinceLastNote == 0 {
            // Same day, no change
            return
        } else if daysSinceLastNote == 1 {
            // Consecutive day, increment streak
            streak += 1
        } else {
            // Streak broken
            streak = 1
        }

        self.lastNoteDate = today

        if streak > longestStreak {
            longestStreak = streak
        }
    }

    mutating func addExperience(points: Int) {
        experience += points
    }

    mutating func checkLevelUp() -> Bool {
        let requiredXP = experienceForNextLevel()
        if experience >= requiredXP {
            level += 1
            experience -= requiredXP
            return true
        }
        return false
    }

    func experienceForNextLevel() -> Int {
        // Exponential curve: 100 * level^1.5
        Int(100.0 * pow(Double(level), 1.5))
    }
}
```

---

## 5. Data Flow

### 5.1 Note Creation Flow

```
User Input (Voice/Text)
    ↓
[Presentation Layer]
    ↓ User taps "Record" or "Type"
    ↓
[ViewModel] NoteEditorViewModel
    ↓ viewModel.startRecording() or viewModel.updateText()
    ↓
[Use Case] CreateNoteUseCase
    ↓ execute(note:)
    ↓
[Domain Service] MoodAnalysisEngine
    ↓ analyze(text:audio:)
    ↓
[AI Layer] On-Device Models
    ↓ TranscriptionEngine.transcribe()
    ↓ EmotionDetectionModel.predict()
    ↓ NERModel.extract()
    ↓
[Domain Entity] Note created with mood, entities
    ↓
[Repository] CoreDataNoteRepository
    ↓ save(note:)
    ↓
[Data Layer] Core Data saves to SQLite
    ↓
[Cloud Sync] CloudKitManager (background)
    ↓ syncNote(note:) [if enabled]
    ↓
[Gamification] GamificationEngine
    ↓ trackNoteCreation()
    ↓
[Notification] Achievement unlocked!
    ↓
[ViewModel] Updates @Published properties
    ↓
[View] UI updates automatically (SwiftUI)
```

### 5.2 Mood Timeline Query Flow

```
User opens Mood Dashboard
    ↓
[View] MoodDashboardView appears
    ↓
[ViewModel] MoodDashboardViewModel
    ↓ .task { await viewModel.loadMoodTimeline() }
    ↓
[Use Case] GetMoodTimelineUseCase
    ↓ execute(dateRange:)
    ↓
[Repository] CoreDataMoodRepository
    ↓ fetchMoods(in: dateRange)
    ↓
[Data Layer] Core Data fetch with predicate
    ↓
[Domain Service] MoodCorrelationService
    ↓ correlateMoodsWithActivities()
    ↓ Fetch HealthKit data (sleep, exercise)
    ↓ Fetch Calendar events
    ↓ Correlate patterns
    ↓
[ViewModel] Processes data for visualization
    ↓ Groups by day/week/month
    ↓ Calculates trends
    ↓ Identifies patterns
    ↓
[View] Chart renders with SwiftUI Charts
```

### 5.3 Cloud Sync Flow (Encrypted)

```
Note Created Locally
    ↓
[Repository] Marks note as "needs sync"
    ↓
[Sync Engine] Background task triggered
    ↓
[Encryption] AES-256 encrypt note content
    ↓ User's key from Keychain
    ↓
[CloudKit] Upload CKRecord
    ↓ Fields: id, encryptedContent, createdAt, modifiedAt
    ↓ Note: CloudKit CANNOT read content
    ↓
[CloudKit Database] Stores encrypted blob
    ↓
[Other Devices] Receive notification
    ↓
[Download & Decrypt] Fetch CKRecord, decrypt with user's key
    ↓
[Merge] Conflict resolution (last-write-wins or operational transform)
    ↓
[Local Storage] Update Core Data
    ↓
[UI Update] If note is visible, refresh view
```

---

## 6. AI/ML Pipeline

### 6.1 Model Deployment Strategy

**On-Device Models:**
```
Development:
1. Train in Python (PyTorch/TensorFlow)
2. Export to ONNX format
3. Convert to Core ML using coremltools
4. Quantize (FP16 or INT8) for size/performance
5. Test on device with various inputs
6. Include in app bundle or download on first launch

Production:
- App bundle: Critical models (emotion detection, transcription)
- On-demand download: Optional models (advanced summarization)
- Model updates: via app updates or dynamic model loading
```

**Example: Emotion Model Conversion**
```python
# train_emotion_model.py
import coremltools as ct
import torch
from transformers import AutoModel

# 1. Load trained PyTorch model
model = AutoModel.from_pretrained("./emotion-distilbert-finetuned")

# 2. Trace model
dummy_input = torch.randint(0, 1000, (1, 128))  # Sample input
traced_model = torch.jit.trace(model, dummy_input)

# 3. Convert to Core ML
mlmodel = ct.convert(
    traced_model,
    inputs=[ct.TensorType(name="input_ids", shape=(1, 128))],
    outputs=[ct.TensorType(name="emotion_logits")],
    convert_to="mlprogram",  # Modern Core ML format
)

# 4. Quantize to FP16
mlmodel_quantized = ct.models.neural_network.quantization_utils.quantize_weights(
    mlmodel, nbits=16
)

# 5. Add metadata
mlmodel_quantized.author = "noema AI Team"
mlmodel_quantized.license = "Proprietary"
mlmodel_quantized.short_description = "8-dimension emotion detection from text"
mlmodel_quantized.version = "2.1.0"

# 6. Save
mlmodel_quantized.save("EmotionDetector_v2.1.mlpackage")
```

**Swift Integration:**
```swift
// Load and use the model
actor EmotionDetectionModel {
    private var model: EmotionDetector_v2_1?

    func load() async throws {
        let config = MLModelConfiguration()
        config.computeUnits = .all  // Use Neural Engine + GPU + CPU
        config.allowLowPrecisionAccumulationOnGPU = true

        model = try await EmotionDetector_v2_1.load(configuration: config)
    }

    func predict(text: String) async throws -> EmotionalDimensions {
        guard let model = model else {
            throw AIError.modelNotLoaded
        }

        // Tokenize (using custom tokenizer or SentencePiece)
        let tokens = try await tokenize(text)

        // Create input
        let input = EmotionDetector_v2_1Input(input_ids: tokens)

        // Predict
        let output = try model.prediction(input: input)

        // Parse logits to probabilities
        let emotions = softmax(output.emotion_logits)

        return EmotionalDimensions(
            joy: emotions[0],
            sadness: emotions[1],
            anger: emotions[2],
            fear: emotions[3],
            surprise: emotions[4],
            disgust: emotions[5],
            trust: emotions[6],
            anticipation: emotions[7]
        )!
    }
}
```

### 6.2 Cloud AI Integration (Optional)

**GPT-4 for Advanced Insights:**
```swift
actor CloudAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"

    func generateInsights(notes: [Note]) async throws -> String {
        // Prepare prompt
        let prompt = buildInsightsPrompt(notes: notes)

        // API request
        let request = ChatCompletionRequest(
            model: "gpt-4-turbo",
            messages: [
                Message(role: "system", content: "You are an empathetic AI analyzing personal journal entries."),
                Message(role: "user", content: prompt)
            ],
            max_tokens: 500,
            temperature: 0.7
        )

        // Send request
        let response = try await sendRequest(request)

        // Parse response
        return response.choices.first?.message.content ?? "No insights generated"
    }

    private func buildInsightsPrompt(notes: [Note]) -> String {
        let noteTexts = notes.map { "[\($0.createdAt.formatted())]: \($0.content)" }
            .joined(separator: "\n\n")

        return """
        Based on these recent journal entries, provide 3-5 personalized insights about emotional patterns, growth areas, or positive trends. Be empathetic and constructive.

        Journal entries:
        \(noteTexts)

        Insights:
        """
    }
}
```

**Privacy Considerations:**
```swift
// User must explicitly opt-in
class AIPreferencesManager {
    @AppStorage("cloudAIEnabled") private var cloudAIEnabled = false

    func requestCloudAIPermission() async -> Bool {
        // Show modal explaining what data is sent
        let consent = await showConsentModal(
            title: "Enable Cloud AI?",
            description: """
            This feature sends your note text to OpenAI's servers for advanced analysis.

            What's sent:
            - Note text (encrypted in transit)
            - No personal identifiers
            - No mood data

            What's NOT sent:
            - Your name or email
            - Location data
            - Health data

            OpenAI's privacy policy: [link]
            """,
            options: ["Enable", "No Thanks"]
        )

        cloudAIEnabled = (consent == "Enable")
        return cloudAIEnabled
    }
}
```

---

## 7. Security Architecture

### 7.1 Data Encryption

**At Rest (Local Storage):**
```swift
// Core Data encryption via Data Protection
class CoreDataStack {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NoemaDataModel")

        let description = container.persistentStoreDescriptions.first
        description?.setOption(
            FileProtectionType.complete as NSObject,
            forKey: NSPersistentStoreFileProtectionKey
        )

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }

        return container
    }()
}

// Keychain for sensitive data
class KeychainManager {
    func store(data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)  // Delete existing
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(status)
        }
    }

    func retrieve(forKey key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.retrieveFailed(status)
        }

        return data
    }
}
```

**In Transit (Cloud Sync):**
```swift
// End-to-end encryption for CloudKit sync
class CloudKitEncryption {
    private let keyManager: EncryptionKeyManager

    func encryptNote(_ note: Note) throws -> EncryptedNote {
        // 1. Get user's encryption key (stored in Keychain)
        let key = try keyManager.getUserEncryptionKey()

        // 2. Serialize note
        let noteData = try JSONEncoder().encode(note)

        // 3. Generate random IV (initialization vector)
        var iv = Data(count: 16)
        _ = iv.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, 16, $0.baseAddress!) }

        // 4. Encrypt with AES-256-GCM
        let sealedBox = try AES.GCM.seal(noteData, using: key, nonce: AES.GCM.Nonce(data: iv))

        return EncryptedNote(
            id: note.id,
            encryptedContent: sealedBox.ciphertext,
            iv: iv,
            tag: sealedBox.tag,
            createdAt: note.createdAt,
            modifiedAt: note.modifiedAt
        )
    }

    func decryptNote(_ encrypted: EncryptedNote) throws -> Note {
        let key = try keyManager.getUserEncryptionKey()

        let sealedBox = try AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: encrypted.iv),
            ciphertext: encrypted.encryptedContent,
            tag: encrypted.tag
        )

        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return try JSONDecoder().decode(Note.self, from: decryptedData)
    }
}

// Encryption key management
class EncryptionKeyManager {
    private let keychainManager: KeychainManager
    private let keyIdentifier = "com.noema.user.encryptionKey"

    func getUserEncryptionKey() throws -> SymmetricKey {
        // Try to retrieve existing key
        if let keyData = try? keychainManager.retrieve(forKey: keyIdentifier) {
            return SymmetricKey(data: keyData)
        }

        // Generate new key if not exists
        let key = SymmetricKey(size: .bits256)
        try keychainManager.store(data: key.dataRepresentation, forKey: keyIdentifier)
        return key
    }

    func rotateKey() throws -> SymmetricKey {
        // Generate new key
        let newKey = SymmetricKey(size: .bits256)

        // TODO: Re-encrypt all synced notes with new key
        // This is complex and should be done in background

        // Store new key
        try keychainManager.store(data: newKey.dataRepresentation, forKey: keyIdentifier)

        return newKey
    }
}
```

### 7.2 Authentication & Authorization

**Biometric Authentication:**
```swift
import LocalAuthentication

class BiometricAuthManager {
    func authenticate() async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AuthError.biometricsNotAvailable
        }

        let reason = "Unlock your personal notes"

        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }
}

// App launch flow
@main
struct NoemaApp: App {
    @StateObject private var authManager = BiometricAuthManager()
    @State private var isUnlocked = false

    var body: some Scene {
        WindowGroup {
            if isUnlocked {
                MainTabView()
            } else {
                LockScreenView {
                    Task {
                        do {
                            isUnlocked = try await authManager.authenticate()
                        } catch {
                            // Handle error
                        }
                    }
                }
            }
        }
    }
}
```

### 7.3 Network Security

**Certificate Pinning:**
```swift
class SecureNetworkManager: NSObject, URLSessionDelegate {
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Certificate pinning
        let pinnedCertificates = loadPinnedCertificates()

        if validateServerTrust(serverTrust, against: pinnedCertificates) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private func loadPinnedCertificates() -> [SecCertificate] {
        // Load certificates from bundle
        guard let certURL = Bundle.main.url(forResource: "noema-api", withExtension: "cer"),
              let certData = try? Data(contentsOf: certURL),
              let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
            return []
        }
        return [certificate]
    }

    private func validateServerTrust(_ serverTrust: SecTrust, against pinnedCerts: [SecCertificate]) -> Bool {
        let serverCertCount = SecTrustGetCertificateCount(serverTrust)

        for i in 0..<serverCertCount {
            if let serverCert = SecTrustGetCertificateAtIndex(serverTrust, i) {
                let serverCertData = SecCertificateCopyData(serverCert) as Data

                for pinnedCert in pinnedCerts {
                    let pinnedCertData = SecCertificateCopyData(pinnedCert) as Data
                    if serverCertData == pinnedCertData {
                        return true
                    }
                }
            }
        }

        return false
    }
}
```

---

## 8. Performance & Scalability

### 8.1 Performance Targets

| Operation | Target | Measurement |
|-----------|--------|-------------|
| App Launch (cold) | <1.0s | Time to first frame |
| App Launch (warm) | <0.3s | Time to first frame |
| Note List Load (100 notes) | <200ms | Fetch + render |
| Voice Transcription | <2s per minute | Processing time |
| Mood Detection (text) | <500ms | Inference time |
| Note Save | <100ms | Perceived latency |
| Search Query | <300ms | Results displayed |
| CloudKit Sync (10 notes) | <5s | Upload + confirmation |

### 8.2 Optimization Strategies

**Core Data Performance:**
```swift
// Batch fetching to reduce database round trips
let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
fetchRequest.fetchBatchSize = 20
fetchRequest.relationshipKeyPathsForPrefetching = ["mood", "tags", "entities"]

// Use fetch limits for pagination
fetchRequest.fetchLimit = 50
fetchRequest.fetchOffset = page * 50

// Faulting for lazy loading
context.shouldDeleteInaccessibleFaults = true
context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
```

**SwiftUI Performance:**
```swift
// Use @State for local view state only
struct NoteListView: View {
    @StateObject var viewModel: NoteListViewModel  // ✅ For observed objects
    @State private var searchText = ""             // ✅ For simple values

    var body: some View {
        List {
            ForEach(viewModel.filteredNotes) { note in
                NoteRow(note: note)
                    .id(note.id)  // ✅ Stable identity for diffing
            }
        }
        .searchable(text: $searchText)
        .task {
            await viewModel.loadNotes()  // ✅ Async on appear
        }
    }
}

// Lazy loading for expensive views
struct NoteRow: View {
    let note: Note
    @State private var mood: MoodSnapshot?

    var body: some View {
        VStack(alignment: .leading) {
            Text(note.content)
                .lineLimit(2)

            if let mood = mood {
                MoodBadge(mood: mood)  // Only render when loaded
            }
        }
        .task(id: note.id) {
            mood = await MoodRepository.shared.fetchMood(for: note)
        }
    }
}
```

**Background Processing:**
```swift
// Use BGTaskScheduler for heavy background work
class BackgroundTaskManager {
    func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.noema.ai.modelUpdate",
            using: nil
        ) { task in
            self.handleModelUpdate(task: task as! BGProcessingTask)
        }
    }

    private func handleModelUpdate(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        Task {
            do {
                try await downloadAndInstallModelUpdates()
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
    }

    func scheduleModelUpdate() {
        let request = BGProcessingTaskRequest(identifier: "com.noema.ai.modelUpdate")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)  // 1 hour

        try? BGTaskScheduler.shared.submit(request)
    }
}
```

### 8.3 Battery Optimization

**Neural Engine Utilization:**
```swift
// Optimize Core ML for battery efficiency
let config = MLModelConfiguration()
config.computeUnits = .all  // Let Core ML choose best compute unit

// For battery-critical scenarios, prefer Neural Engine
if ProcessInfo.processInfo.lowPowerModeEnabled {
    config.computeUnits = .cpuAndNeuralEngine  // Avoid GPU (power hungry)
}

// Batch predictions when possible
let batchInput = MLBatchProvider(...)
let batchOutput = try model.predictions(from: batchInput)  // More efficient than individual predictions
```

**Audio Processing:**
```swift
// Use AVAudioEngine efficiently
class AudioRecorder {
    private let engine = AVAudioEngine()

    func startRecording() {
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        // Install tap with smaller buffer (less memory, more responsive)
        input.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, time in
            self.processBuffer(buffer)
        }

        try? engine.start()
    }

    func stopRecording() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)  // ✅ Important: remove tap to save battery
    }
}
```

---

## 9. Technology Stack

### 9.1 iOS Development

| Category | Technology | Version | Justification |
|----------|-----------|---------|---------------|
| **Language** | Swift | 6.0 | Modern concurrency, safety, performance |
| **UI Framework** | SwiftUI | iOS 17+ | Declarative, native, future-proof |
| **UI (Legacy)** | UIKit | iOS 17+ | Complex gestures, fine-grained control |
| **Reactive** | Combine | iOS 17+ | Native, integrates with SwiftUI |
| **Persistence** | Core Data | iOS 17+ | Mature, powerful, Apple-supported |
| **Cloud Sync** | CloudKit | iOS 17+ | Native, encrypted, seamless |
| **ML Framework** | Core ML | iOS 17+ | On-device, optimized for Apple Silicon |
| **Audio** | AVFoundation | iOS 17+ | Comprehensive audio capabilities |
| **Charts** | Swift Charts | iOS 17+ | Native, beautiful visualizations |
| **Testing** | XCTest | Latest | Native, comprehensive |

### 9.2 Backend & Cloud

| Service | Purpose | Provider |
|---------|---------|----------|
| **Cloud Storage** | Encrypted note sync | CloudKit (primary) |
| **Cloud AI** | Advanced GPT-4 insights | OpenAI API |
| **Analytics** | Product analytics | Amplitude |
| **Crash Reporting** | Error tracking | Firebase Crashlytics |
| **Payments** | Subscriptions | StoreKit 2 + RevenueCat |
| **Push Notifications** | Engagement | APNs (Apple Push) |

### 9.3 Development Tools

| Tool | Purpose |
|------|---------|
| **Xcode** | IDE, build, debug |
| **Git** | Version control |
| **GitHub** | Code hosting, CI/CD |
| **Fastlane** | Automated deployment |
| **SwiftLint** | Code style enforcement |
| **SwiftFormat** | Auto-formatting |
| **Instruments** | Performance profiling |
| **Charles Proxy** | Network debugging |

### 9.4 Dependencies (Swift Package Manager)

```swift
// Package.swift
dependencies: [
    // Networking
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),

    // Image caching
    .package(url: "https://github.com/kean/Nuke.git", from: "12.0.0"),

    // Keychain wrapper
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.0"),

    // Markdown parsing (for note rendering)
    .package(url: "https://github.com/apple/swift-markdown.git", from: "0.2.0"),

    // Analytics
    .package(url: "https://github.com/amplitude/Amplitude-Swift.git", from: "1.0.0"),

    // Testing
    .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
]
```

---

## 10. Deployment & Infrastructure

### 10.1 Build Configurations

```
Configurations:
- Debug: Local development, verbose logging, no encryption
- Staging: TestFlight beta, encrypted, analytics enabled
- Release: App Store production, full encryption, minimal logging
```

**Xcode Build Settings:**
```swift
// Config-specific settings
#if DEBUG
let apiBaseURL = "https://staging-api.noema.app"
let logLevel: LogLevel = .verbose
let crashReportingEnabled = false
#elseif STAGING
let apiBaseURL = "https://staging-api.noema.app"
let logLevel: LogLevel = .info
let crashReportingEnabled = true
#else  // RELEASE
let apiBaseURL = "https://api.noema.app"
let logLevel: LogLevel = .error
let crashReportingEnabled = true
#endif
```

### 10.2 CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/ios-ci.yml
name: iOS CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.2'

      - name: Install dependencies
        run: xcodebuild -resolvePackageDependencies

      - name: Run tests
        run: xcodebuild test -scheme noema -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: macos-14
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Build for TestFlight
        run: fastlane beta

      - name: Upload to TestFlight
        run: fastlane upload_testflight
```

**Fastlane Configuration:**
```ruby
# fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    increment_build_number(xcodeproj: "noema.xcodeproj")
    build_app(scheme: "noema", configuration: "Staging")
    upload_to_testflight(skip_waiting_for_build_processing: true)
    slack(message: "New TestFlight build available!")
  end

  desc "Build and upload to App Store"
  lane :release do
    increment_version_number(bump_type: "minor")
    build_app(scheme: "noema", configuration: "Release")
    upload_to_app_store(submit_for_review: false)
  end

  desc "Run tests"
  lane :test do
    run_tests(scheme: "noema", devices: ["iPhone 15 Pro"])
  end
end
```

### 10.3 App Store Submission Checklist

**Pre-Submission:**
- [ ] All tests passing (unit, integration, UI)
- [ ] Performance profiled (Instruments)
- [ ] Memory leaks checked
- [ ] Accessibility audit (VoiceOver, Dynamic Type)
- [ ] Privacy nutrition label updated
- [ ] App Store screenshots (6.7", 6.5", 5.5")
- [ ] App preview video (30 seconds)
- [ ] Metadata localized (5 languages)
- [ ] Age rating configured (12+ for mental health content)
- [ ] Export compliance reviewed

**Submission:**
- [ ] Upload via Fastlane or Xcode Cloud
- [ ] Fill App Review Information
- [ ] Add demo account for reviewers
- [ ] Submit for review
- [ ] Monitor status (24-48 hour review)

**Post-Approval:**
- [ ] Staged rollout (10% → 50% → 100%)
- [ ] Monitor crash rates (target: <0.1%)
- [ ] Monitor reviews (respond within 24h)
- [ ] Track analytics (DAU, retention, conversion)

---

## Appendix: Useful Commands

**Xcode Build:**
```bash
# Clean build
xcodebuild clean -scheme noema

# Build for device
xcodebuild -scheme noema -destination 'generic/platform=iOS'

# Run tests
xcodebuild test -scheme noema -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Archive for App Store
xcodebuild archive -scheme noema -archivePath ./build/noema.xcarchive
```

**Swift Package Manager:**
```bash
# Resolve dependencies
swift package resolve

# Update dependencies
swift package update

# Generate Xcode project (if needed)
swift package generate-xcodeproj
```

**Fastlane:**
```bash
# Install
sudo gem install fastlane

# Setup
fastlane init

# Run lane
fastlane beta
fastlane release
fastlane test
```

**SwiftLint:**
```bash
# Install
brew install swiftlint

# Run
swiftlint

# Auto-fix
swiftlint --fix
```

---

## Document Control

**Version:** 1.0
**Last Updated:** 2025-11-17
**Status:** Living Document
**Review Schedule:** Quarterly

**Contributors:**
- Architecture Team
- iOS Engineering Team
- AI/ML Team

**Approval:**
- CTO: [Pending]
- Engineering Lead: [Pending]

---

*This architecture is designed for scalability, maintainability, and excellence. As noema evolves, this document will evolve with it.*

import Foundation
import CoreData

// MARK: - Note Model

/// Represents a user's note - the central entity in Noema
@objc(Note)
public class Note: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date

    // MARK: - Content

    @NSManaged public var content: String
    @NSManaged public var summary: String?
    @NSManaged public var title: String?

    // MARK: - Audio

    @NSManaged public var hasAudio: Bool
    @NSManaged public var audioURL: URL?
    @NSManaged public var audioDuration: TimeInterval
    @NSManaged private var transcriptionStatusRaw: String

    public var transcriptionStatus: TranscriptionStatus {
        get {
            TranscriptionStatus(rawValue: transcriptionStatusRaw) ?? .pending
        }
        set {
            transcriptionStatusRaw = newValue.rawValue
        }
    }

    // MARK: - Metadata

    @NSManaged public var wordCount: Int
    @NSManaged public var characterCount: Int
    @NSManaged public var language: String?

    // MARK: - Emotion & Mood

    @NSManaged public var moodSnapshot: EmotionalState?
    @NSManaged private var dominantEmotionRaw: String?
    @NSManaged public var emotionIntensity: Double

    public var dominantEmotion: EmotionType? {
        get {
            guard let raw = dominantEmotionRaw else { return nil }
            return EmotionType(rawValue: raw)
        }
        set {
            dominantEmotionRaw = newValue?.rawValue
        }
    }

    // MARK: - Location & Environment

    @NSManaged public var location: Location?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var placeName: String?
    @NSManaged public var weather: WeatherSnapshot?
    @NSManaged private var timeOfDayRaw: String

    public var timeOfDay: TimeOfDay {
        get {
            TimeOfDay(rawValue: timeOfDayRaw) ?? .morning
        }
        set {
            timeOfDayRaw = newValue.rawValue
        }
    }

    // MARK: - Organization

    @NSManaged public var tags: Set<Tag>
    @NSManaged public var folder: Folder?
    @NSManaged public var isPinned: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isArchived: Bool

    // MARK: - Privacy & Sync

    @NSManaged public var isEncrypted: Bool
    @NSManaged private var syncStatusRaw: String
    @NSManaged private var shareLevelRaw: String

    public var syncStatus: SyncStatus {
        get {
            SyncStatus(rawValue: syncStatusRaw) ?? .localOnly
        }
        set {
            syncStatusRaw = newValue.rawValue
        }
    }

    public var shareLevel: ShareLevel {
        get {
            ShareLevel(rawValue: shareLevelRaw) ?? .private
        }
        set {
            shareLevelRaw = newValue.rawValue
        }
    }

    // MARK: - Relationships

    @NSManaged public var entityMentions: Set<EntityMention>
    @NSManaged public var relatedNotes: Set<Note>

    // MARK: - Gamification

    @NSManaged public var qualityScore: Double
    @NSManaged private var insightLevelRaw: String?
    @NSManaged public var contributedXP: Int

    public var insightLevel: InsightLevel? {
        get {
            guard let raw = insightLevelRaw else { return nil }
            return InsightLevel(rawValue: raw)
        }
        set {
            insightLevelRaw = newValue?.rawValue
        }
    }

    // MARK: - Computed Properties

    public var hasContent: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var isSynced: Bool {
        syncStatus == .synced
    }

    public var needsTranscription: Bool {
        hasAudio && transcriptionStatus != .completed
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        createdAt = Date()
        modifiedAt = Date()
        content = ""
        hasAudio = false
        audioDuration = 0
        transcriptionStatus = .pending
        wordCount = 0
        characterCount = 0
        emotionIntensity = 0
        latitude = 0
        longitude = 0
        timeOfDay = .morning
        isPinned = false
        isFavorite = false
        isArchived = false
        isEncrypted = false
        syncStatus = .localOnly
        shareLevel = .private
        qualityScore = 0
        contributedXP = 0
        tags = Set()
        entityMentions = Set()
        relatedNotes = Set()
    }
}

// MARK: - Enums

public enum TranscriptionStatus: String, Codable {
    case pending
    case processing
    case completed
    case failed
}

public enum TimeOfDay: String, Codable {
    case earlyMorning   // 4-7am
    case morning        // 7-12pm
    case afternoon      // 12-5pm
    case evening        // 5-9pm
    case night          // 9pm-4am

    public init(from date: Date) {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 4..<7:
            self = .earlyMorning
        case 7..<12:
            self = .morning
        case 12..<17:
            self = .afternoon
        case 17..<21:
            self = .evening
        default:
            self = .night
        }
    }
}

public enum SyncStatus: String, Codable {
    case localOnly
    case synced
    case syncPending
    case syncFailed
}

public enum ShareLevel: String, Codable {
    case `private`
    case sharedSummary
    case sharedFull
}

public enum InsightLevel: String, Codable {
    case surface
    case moderate
    case deep
    case breakthrough
}

// MARK: - Extensions

extension Note {

    /// Convenient method to add tags
    public func addTag(_ tag: Tag) {
        var currentTags = tags
        currentTags.insert(tag)
        tags = currentTags
    }

    /// Convenient method to remove tags
    public func removeTag(_ tag: Tag) {
        var currentTags = tags
        currentTags.remove(tag)
        tags = currentTags
    }

    /// Update word and character counts
    public func updateCounts() {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        characterCount = trimmed.count
        wordCount = trimmed.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
        modifiedAt = Date()
    }

    /// Calculate quality score based on multiple factors
    public func calculateQualityScore() -> Double {
        var score: Double = 0

        // Length factor (optimal 100-500 words)
        let lengthScore: Double
        if wordCount >= 100 && wordCount <= 500 {
            lengthScore = 1.0
        } else if wordCount < 100 {
            lengthScore = Double(wordCount) / 100.0
        } else {
            lengthScore = max(0.5, 1.0 - (Double(wordCount - 500) / 1000.0))
        }
        score += lengthScore * 0.3

        // Emotion depth (if available)
        if emotionIntensity > 0 {
            score += emotionIntensity * 0.2
        }

        // Entity richness (mentions people, places, topics)
        let entityScore = min(1.0, Double(entityMentions.count) / 5.0)
        score += entityScore * 0.2

        // Insight level
        if let insight = insightLevel {
            switch insight {
            case .surface:
                score += 0.1
            case .moderate:
                score += 0.15
            case .deep:
                score += 0.2
            case .breakthrough:
                score += 0.3
            }
        }

        // Has audio (more engagement)
        if hasAudio {
            score += 0.1
        }

        return min(1.0, score)
    }
}

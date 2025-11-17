# Noema Database Schema
## Core Data & SQLite Schema Design

---

## Overview

Noema uses a hybrid data persistence strategy:
- **Core Data**: Primary ORM for iOS, with CloudKit sync capability
- **SQLite**: Direct access for complex graph queries and analytics
- **Secure Enclave**: Encryption keys and sensitive credentials
- **File System**: Audio recordings, exported files

---

## Core Entities

### 1. Note

The central entity representing a user's thought, reflection, or capture.

```swift
@Entity
class Note {
    // Identity
    @PrimaryKey var id: UUID
    var createdAt: Date
    var modifiedAt: Date

    // Content
    var content: String                    // Main text content
    var summary: String?                   // AI-generated summary
    var title: String?                     // Auto or user-generated

    // Audio
    var hasAudio: Bool
    var audioURL: URL?
    var audioDuration: TimeInterval?
    var transcriptionStatus: TranscriptionStatus  // .pending, .processing, .completed, .failed

    // Metadata
    var wordCount: Int
    var characterCount: Int
    var language: String?                  // Auto-detected (e.g., "en")

    // Emotion & Mood
    var moodSnapshot: EmotionalState?      // Relationship to EmotionalState
    var dominantEmotion: EmotionType?      // Primary detected emotion
    var emotionIntensity: Double?          // 0.0 - 1.0

    // Location & Environment
    var location: Location?                // Relationship to Location
    var latitude: Double?
    var longitude: Double?
    var placeName: String?

    var weather: WeatherSnapshot?          // Relationship to WeatherSnapshot
    var timeOfDay: TimeOfDay               // .earlyMorning, .morning, .afternoon, .evening, .night

    // Organization
    var tags: [Tag]                        // Many-to-many with Tag
    var folder: Folder?                    // Optional folder
    var isPinned: Bool
    var isFavorite: Bool
    var isArchived: Bool

    // Privacy & Sync
    var isEncrypted: Bool
    var syncStatus: SyncStatus             // .localOnly, .synced, .syncPending, .syncFailed
    var shareLevel: ShareLevel             // .private, .sharedSummary, .sharedFull

    // Relationships
    var entityMentions: [EntityMention]    // Entities mentioned in this note
    var relatedNotes: [Note]               // User or AI-linked related notes

    // Gamification
    var qualityScore: Double?              // AI-assessed note quality (0.0 - 1.0)
    var insightLevel: InsightLevel?        // .surface, .moderate, .deep, .breakthrough
    var contributedXP: Int                 // XP earned from this note
}

enum TranscriptionStatus: String {
    case pending
    case processing
    case completed
    case failed
}

enum TimeOfDay: String {
    case earlyMorning   // 4-7am
    case morning        // 7-12pm
    case afternoon      // 12-5pm
    case evening        // 5-9pm
    case night          // 9pm-4am
}

enum SyncStatus: String {
    case localOnly
    case synced
    case syncPending
    case syncFailed
}

enum ShareLevel: String {
    case private
    case sharedSummary
    case sharedFull
}

enum InsightLevel: String {
    case surface
    case moderate
    case deep
    case breakthrough
}
```

---

### 2. EmotionalState

Represents a snapshot of emotional state at a specific moment.

```swift
@Entity
class EmotionalState {
    // Identity
    @PrimaryKey var id: UUID
    var timestamp: Date

    // Core Dimensions (Russell's Circumplex Model)
    var valence: Double        // -1.0 (very negative) to 1.0 (very positive)
    var arousal: Double        // -1.0 (very calm) to 1.0 (very excited)
    var dominance: Double      // -1.0 (submissive) to 1.0 (dominant)

    // Additional Dimensions
    var energyLevel: Double    // 0.0 (exhausted) to 1.0 (energized)
    var stressLevel: Double    // 0.0 (relaxed) to 1.0 (stressed)
    var focusLevel: Double     // 0.0 (scattered) to 1.0 (focused)

    // Emotion Classification
    var primaryEmotion: EmotionType
    var secondaryEmotions: [EmotionType]  // For mixed emotions
    var emotionIntensity: Double          // 0.0 (mild) to 1.0 (intense)

    // Detection Source & Confidence
    var detectionSources: [DetectionSource]  // Can be multiple
    var confidence: Double                   // 0.0 - 1.0

    // Context
    var note: Note?            // Optional: If tied to a note
    var trigger: String?       // Optional: User-identified trigger

    // Voice Characteristics (if from audio)
    var voicePitch: Double?
    var voiceEnergy: Double?
    var speakingRate: Double?   // Words per minute
    var pauseFrequency: Double?

    // Biometric Data (HealthKit, if available)
    var heartRate: Double?
    var heartRateVariability: Double?
}

enum EmotionType: String, CaseIterable {
    // Basic Emotions (Ekman's 6)
    case joy
    case sadness
    case anger
    case fear
    case disgust
    case surprise

    // Extended Emotions
    case anxiety
    case excitement
    case contentment
    case frustration
    case pride
    case shame
    case guilt
    case gratitude
    case love
    case hope
    case boredom
    case confusion
    case curiosity
    case determination
    case enthusiasm

    // Complex/Mixed
    case bittersweet
    case nostalgic
    case overwhelmed
    case peaceful
    case restless
}

enum DetectionSource: String {
    case textSentiment      // NLP sentiment analysis
    case voiceTone          // Paralinguistic analysis
    case biometric          // HealthKit data
    case environmental      // Weather, location
    case userManual         // User explicitly set
}
```

---

### 3. Entity

Represents a named entity (person, place, organization, topic, etc.) extracted from notes.

```swift
@Entity
class Entity {
    // Identity
    @PrimaryKey var id: UUID
    var name: String
    var type: EntityType

    // Aliases
    var aliases: [String]          // Nicknames, variations (e.g., "Mom", "Mother", "Sarah Johnson")
    var canonicalName: String       // Preferred name for display

    // Metadata
    var firstMentioned: Date
    var lastMentioned: Date
    var totalMentions: Int

    // Emotional Association
    var averageValence: Double     // Average emotion when mentioned
    var averageArousal: Double
    var averageEnergy: Double
    var emotionalVariance: Double  // How consistent emotions are

    // Importance & Centrality
    var importanceScore: Double    // Graph centrality measure
    var recencyScore: Double       // Boost for recent mentions
    var frequencyScore: Double     // Based on mention count

    // Custom Attributes (flexible JSON)
    var attributes: [String: String]  // e.g., {"relationship": "friend", "meetingFrequency": "weekly"}

    // Relationships
    var mentions: [EntityMention]
    var relatedEntities: [Relationship]  // Connections to other entities

    // User Control
    var userNotes: String?         // User's custom notes about this entity
    var isPrivate: Bool            // Exclude from shared/exported data
    var isFavorite: Bool
    var color: String?             // User-assigned color for visualization
}

enum EntityType: String, CaseIterable {
    case person
    case place
    case organization
    case topic
    case project
    case goal
    case hobby
    case event
    case custom
}
```

---

### 4. EntityMention

Represents a specific mention of an entity within a note.

```swift
@Entity
class EntityMention {
    // Identity
    @PrimaryKey var id: UUID

    // References
    var entity: Entity             // The entity being mentioned
    var note: Note                 // The note containing the mention

    // Position in Note
    var position: Int              // Character offset in note content
    var contextSnippet: String     // Surrounding text for context

    // Emotional Context
    var emotionalState: EmotionalState?  // Mood at time of mention
    var sentimentAtMention: Double       // Local sentiment around this mention (-1 to 1)

    // Metadata
    var timestamp: Date            // When this mention occurred
    var importance: Double         // How central was this mention to the note
}
```

---

### 5. Relationship

Represents a connection between two entities (person-person, person-place, etc.).

```swift
@Entity
class Relationship {
    // Identity
    @PrimaryKey var id: UUID

    // Entities
    var entity1: Entity
    var entity2: Entity
    var relationshipType: RelationshipType

    // Strength & Frequency
    var strength: Double           // Based on co-occurrence frequency
    var coOccurrences: Int         // How many notes mention both

    // Emotional Tone
    var averageEmotionalTone: Double  // Average valence when both mentioned
    var emotionalVariance: Double

    // Temporal
    var firstCoOccurrence: Date
    var lastCoOccurrence: Date

    // User-Defined
    var label: String?             // User can label relationships
    var notes: String?
}

enum RelationshipType: String {
    case coOccurrence          // Simply mentioned together
    case personToPerson        // Both are people
    case personToPlace         // Person associated with place
    case personToOrganization  // Employment, membership, etc.
    case personToTopic         // Interest, expertise
    case topicToTopic          // Related concepts
    case custom
}
```

---

### 6. Location

Represents a physical location where a note was created.

```swift
@Entity
class Location {
    // Identity
    @PrimaryKey var id: UUID

    // Coordinates
    var latitude: Double
    var longitude: Double
    var altitude: Double?

    // Place Information
    var placeName: String?         // "Starbucks on Main St"
    var city: String?
    var state: String?
    var country: String?
    var placeType: PlaceType?      // .home, .work, .cafe, .gym, .outdoor, .transit

    // Emotional Associations
    var averageValence: Double
    var averageEnergy: Double
    var visitCount: Int

    // Metadata
    var firstVisit: Date
    var lastVisit: Date

    // User Control
    var isPrivate: Bool
    var customLabel: String?
}

enum PlaceType: String {
    case home
    case work
    case cafe
    case gym
    case outdoor
    case transit
    case restaurant
    case social
    case other
}
```

---

### 7. WeatherSnapshot

Captures weather conditions at the time of note creation.

```swift
@Entity
class WeatherSnapshot {
    // Identity
    @PrimaryKey var id: UUID
    var timestamp: Date

    // Weather Conditions
    var temperature: Double        // Celsius
    var feelsLike: Double
    var humidity: Double           // Percentage
    var pressure: Double           // hPa

    var conditions: WeatherCondition
    var cloudCover: Double         // Percentage
    var visibility: Double         // Kilometers

    var windSpeed: Double          // km/h
    var windDirection: Double      // Degrees

    // Air Quality
    var airQualityIndex: Int?      // AQI (0-500)
    var airQualityCategory: AirQualityCategory?

    // Sun
    var uvIndex: Int?
    var sunrise: Date?
    var sunset: Date?
}

enum WeatherCondition: String {
    case clear
    case partlyCloudy
    case cloudy
    case rainy
    case snowy
    case foggy
    case stormy
    case windy
}

enum AirQualityCategory: String {
    case good
    case moderate
    case unhealthySensitive
    case unhealthy
    case veryUnhealthy
    case hazardous
}
```

---

### 8. Tag

User-created or AI-suggested tags for organization.

```swift
@Entity
class Tag {
    // Identity
    @PrimaryKey var id: UUID
    var name: String

    // Metadata
    var color: String?
    var icon: String?              // SF Symbol name

    var isSystem: Bool             // System-generated vs user-created
    var createdAt: Date
    var usageCount: Int

    // Relationships
    var notes: [Note]              // Many-to-many
}
```

---

### 9. Folder

Hierarchical organization structure.

```swift
@Entity
class Folder {
    // Identity
    @PrimaryKey var id: UUID
    var name: String

    // Hierarchy
    var parent: Folder?
    var subfolders: [Folder]

    // Metadata
    var color: String?
    var icon: String?
    var createdAt: Date

    // Relationships
    var notes: [Note]
}
```

---

### 10. HealthMetric

Stores health and biometric data from HealthKit for correlation analysis.

```swift
@Entity
class HealthMetric {
    // Identity
    @PrimaryKey var id: UUID
    var timestamp: Date

    // Metric
    var metricType: HealthMetricType
    var value: Double
    var unit: String

    // Correlation
    var correlatedMood: EmotionalState?

    // Privacy
    var isShared: Bool = false     // Never shared by default
}

enum HealthMetricType: String {
    case sleepDuration
    case sleepQuality
    case steps
    case activeEnergyBurned
    case heartRate
    case heartRateVariability
    case restingHeartRate
    case mindfulMinutes
    case standHours
    case exerciseMinutes
    case vo2Max
    case bodyMass
}
```

---

## Gamification Entities

### 11. Achievement

Represents unlockable achievements and badges.

```swift
@Entity
class Achievement {
    // Identity
    @PrimaryKey var id: UUID

    // Definition
    var type: AchievementType
    var category: AchievementCategory
    var title: String
    var description: String

    // Visuals
    var iconName: String
    var badgeImageURL: String?
    var color: String

    // Unlock Criteria
    var requiredValue: Int         // e.g., 100 days for "Centurion"
    var progress: Int              // Current progress
    var isCompleted: Bool
    var unlockedAt: Date?

    // Rewards
    var xpReward: Int

    // Rarity
    var rarity: AchievementRarity
}

enum AchievementType: String {
    // Consistency
    case streak7Days = "week_warrior"
    case streak30Days = "monthly_master"
    case streak100Days = "centurion"
    case streak365Days = "year_champion"

    // Volume
    case notes100 = "hundred_thoughts"
    case notes500 = "wisdom_collector"
    case notes1000 = "knowledge_architect"

    // Emotional Intelligence
    case patternRecognized = "pattern_recognizer"
    case breakthrough = "breakthrough_moment"
    case emotionalBalance = "balance_seeker"
    case selfAwareness = "mirror_master"

    // Relationships
    case connectionCurator = "connection_curator"
    case socialScientist = "social_scientist"

    // Quality
    case deepThinker = "deep_thinker"
    case insightfulWriter = "insightful_writer"

    // Exploration
    case knowledgeExplorer = "knowledge_explorer"
    case graphNavigator = "graph_navigator"
}

enum AchievementCategory: String {
    case consistency
    case emotionalIntelligence
    case relationships
    case wellness
    case insights
}

enum AchievementRarity: String {
    case common
    case uncommon
    case rare
    case epic
    case legendary
}
```

---

### 12. UserProfile

Stores user-level data, preferences, and gamification state.

```swift
@Entity
class UserProfile {
    // Identity
    @PrimaryKey var id: UUID
    var createdAt: Date

    // Gamification
    var level: Int
    var totalXP: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastNoteDate: Date?

    // Garden
    var gardenState: GardenState   // JSON-serialized garden visualization state

    // Preferences
    var preferredLanguage: String
    var preferredTheme: ThemePreference
    var notificationSettings: NotificationSettings

    // Privacy Settings
    var dataProcessingPreference: DataProcessingPreference
    var syncEnabled: Bool
    var healthKitEnabled: Bool
    var locationServicesEnabled: Bool

    // Subscription
    var subscriptionTier: SubscriptionTier
    var subscriptionExpiresAt: Date?
    var isLifetimeMember: Bool

    // Statistics
    var totalNotes: Int
    var totalWords: Int
    var totalAudioMinutes: Int
    var totalEntitiesDetected: Int
}

enum ThemePreference: String {
    case light
    case dark
    case auto              // Based on time of day
    case moodAdaptive      // Changes based on current mood
}

enum DataProcessingPreference: String {
    case onDeviceOnly
    case hybridOptIn       // Cloud for advanced features
}

enum SubscriptionTier: String {
    case free
    case pro
    case family
    case lifetime
}

struct GardenState: Codable {
    var trees: [GardenTree]
    var flowers: [GardenFlower]
    var vines: [GardenVine]
    var crystals: [GardenCrystal]
    var season: Season
}

struct NotificationSettings: Codable {
    var dailyReminderEnabled: Bool
    var dailyReminderTime: Date?
    var insightNotificationsEnabled: Bool
    var achievementNotificationsEnabled: Bool
    var streakReminderEnabled: Bool
}
```

---

### 13. Quest

AI-generated or system-defined challenges for user engagement.

```swift
@Entity
class Quest {
    // Identity
    @PrimaryKey var id: UUID

    // Definition
    var title: String
    var description: String
    var type: QuestType

    // Timing
    var startDate: Date
    var endDate: Date
    var duration: QuestDuration

    // Progress
    var targetValue: Int
    var currentProgress: Int
    var isCompleted: Bool
    var completedAt: Date?

    // Rewards
    var xpReward: Int
    var badgeReward: Achievement?

    // Personalization
    var isPersonalized: Bool       // AI-generated based on user patterns
    var personalizationReason: String?
}

enum QuestType: String {
    case consistency = "Take notes for 7 days"
    case exploration = "Explore your knowledge graph"
    case emotionalAwareness = "Notice what triggers your creativity"
    case reflection = "Reflect on one relationship each day"
    case gratitude = "Write one thing you're grateful for daily"
    case energy = "Track your energy levels for a week"
}

enum QuestDuration: String {
    case daily
    case weekly
    case monthly
    case custom
}
```

---

## Knowledge Graph Schema

### Graph Representation

Noema's Knowledge Graph is represented as:
- **Nodes**: Entities (people, places, organizations, topics)
- **Edges**: Relationships between entities, weighted by strength and colored by emotional tone

**Graph Properties:**
- Directed or undirected (context-dependent)
- Weighted (relationship strength)
- Temporal (edges have timestamps)
- Attributed (nodes and edges have rich metadata)

### Graph Queries (Examples)

```sql
-- Find most emotionally significant entities
SELECT e.name, e.type, e.averageValence, e.importanceScore
FROM Entity e
ORDER BY e.importanceScore DESC
LIMIT 10;

-- Find entities mentioned during high-energy states
SELECT e.name, AVG(es.energyLevel) as avg_energy
FROM Entity e
JOIN EntityMention em ON e.id = em.entity_id
JOIN EmotionalState es ON em.emotionalState_id = es.id
WHERE es.energyLevel > 0.7
GROUP BY e.id
ORDER BY avg_energy DESC;

-- Find co-occurring entities (potential relationships)
SELECT e1.name, e2.name, COUNT(*) as co_occurrences
FROM EntityMention em1
JOIN EntityMention em2 ON em1.note_id = em2.note_id AND em1.entity_id < em2.entity_id
JOIN Entity e1 ON em1.entity_id = e1.id
JOIN Entity e2 ON em2.entity_id = e2.id
GROUP BY e1.id, e2.id
HAVING co_occurrences > 2
ORDER BY co_occurrences DESC;

-- Emotional trajectory for specific entity
SELECT em.timestamp, es.valence, es.arousal, n.summary
FROM EntityMention em
JOIN Entity e ON em.entity_id = e.id
JOIN EmotionalState es ON em.emotionalState_id = es.id
JOIN Note n ON em.note_id = n.id
WHERE e.name = 'Sarah'
ORDER BY em.timestamp ASC;
```

---

## Sync & Encryption

### CloudKit Sync Strategy

**Local-First Approach:**
1. All data created locally first
2. Sync happens in background, incrementally
3. Conflict resolution favors local data (user's device is source of truth)

**Delta Sync:**
- Only changes since last sync are transmitted
- Efficient use of bandwidth and battery

**Selective Sync:**
- Users choose which notes to sync (per-note toggle)
- Emotional data can be kept local-only
- Entity data local by default (opt-in to sync)

### Encryption Architecture

**End-to-End Encryption (E2EE):**
- User's master key generated on device, stored in Secure Enclave
- Each note encrypted with unique AES-256 key
- Note keys encrypted with master key
- Zero-knowledge: Server never sees plaintext or master key

**Key Management:**
- Master key derived from user's device biometrics + secure random seed
- iCloud Keychain for key backup (encrypted)
- Key rotation on demand

**Encryption Scope:**
```
Encrypted:
- Note content
- Audio files
- Summaries
- Entity mentions (context snippets)
- Emotional states (if user opts in)

Not Encrypted (Metadata for sync efficiency):
- Note ID
- Created/modified timestamps
- Sync status
```

---

## Data Retention & Privacy

### Retention Policy

**Active Data:**
- Notes: Retained indefinitely unless user deletes
- Emotional states: Retained for analysis, can be purged on user request
- Entities: Retained as long as mentioned in active notes

**Derived Data:**
- AI insights: Regenerated on-demand, not permanently stored
- Analytics aggregations: Rolling 90-day window

**Deleted Data:**
- Soft delete with 30-day grace period
- Hard delete after 30 days (unrecoverable)
- Immediate purge on user account deletion

### GDPR Compliance

**Right to Access:**
- Users can export all data (JSON, CSV, PDF)
- One-tap export in Privacy Dashboard

**Right to Erasure:**
- One-tap account deletion
- All data purged within 30 days
- Confirmation email sent

**Right to Portability:**
- Export in machine-readable formats
- Import into other apps (open standards)

**Right to Rectification:**
- Users can edit or correct any data
- AI can be retrained on corrections

---

## Performance Considerations

### Indexing Strategy

**Core Data Indexes:**
```swift
// Note
@Index([createdAt DESC])
@Index([modifiedAt DESC])
@Index([isFavorite, createdAt DESC])
@Index([isArchived, createdAt DESC])

// Entity
@Index([name])
@Index([type, importanceScore DESC])
@Index([lastMentioned DESC])

// EntityMention
@Index([note_id, entity_id])  // Composite for joins
@Index([entity_id, timestamp DESC])

// EmotionalState
@Index([timestamp DESC])
```

**SQLite Full-Text Search:**
```sql
CREATE VIRTUAL TABLE note_fts USING fts5(
    content,
    summary,
    content='Note',
    content_rowid='id'
);
```

### Pagination & Lazy Loading

- Notes list: 50 notes per page
- Entity mentions: Lazy load when entity profile opened
- Knowledge graph: Load only visible subgraph initially

### Caching Strategy

- **In-Memory Cache**: Recent notes (last 20), frequently accessed entities
- **Disk Cache**: Audio files, AI model outputs
- **Cache Invalidation**: LRU policy, max 500MB cache size

---

## Migration Strategy

### Schema Versioning

- Use Core Data lightweight migrations when possible
- Custom migrations for complex schema changes
- Version numbering: `schema_v1`, `schema_v2`, etc.

### Backward Compatibility

- Always support previous 2 schema versions
- Gradual rollout of breaking changes

---

## Summary

This comprehensive database schema provides:
- **Rich Emotional Intelligence**: Multi-dimensional mood tracking, entity-emotion linking
- **Powerful Knowledge Graph**: Entities, relationships, temporal evolution
- **Privacy-First**: Encryption, selective sync, local-first architecture
- **Gamification**: Achievements, quests, streaks, garden state
- **Scalability**: Optimized for 100K+ notes, 50K+ entities per user
- **Compliance**: GDPR-ready data retention and export

**Next Steps:**
1. Implement Core Data models in Swift
2. Create SQLite views for complex graph queries
3. Build data access layer (repositories)
4. Implement sync service with CloudKit
5. Test with realistic data volumes

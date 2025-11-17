# noema: Database Schema & Data Models

## Version 1.0 | Last Updated: 2025-11-17

## Table of Contents
1. [Schema Overview](#schema-overview)
2. [Core Data Model](#core-data-model)
3. [Entity Definitions](#entity-definitions)
4. [Relationships](#relationships)
5. [Indices & Performance](#indices--performance)
6. [CloudKit Schema](#cloudkit-schema)
7. [Migration Strategy](#migration-strategy)
8. [Sample Queries](#sample-queries)

---

## 1. Schema Overview

### 1.1 Entity Relationship Diagram

```
┌─────────────┐         ┌──────────────┐         ┌───────────────┐
│    User     │────1────│   Profile    │────1────│  Preferences  │
│  Profile    │         │              │         │               │
└─────────────┘         └──────────────┘         └───────────────┘
      │                        │
      │ 1                      │ 1
      │                        │
      │ *                      │ *
┌─────────────┐         ┌──────────────┐
│    Note     │────*────│  MoodSnapshot│
│             │         │              │
└─────────────┘         └──────────────┘
      │                        │
      │ *                      │
      │                        │
┌─────────────┐         ┌──────────────┐
│     Tag     │         │  Emotional   │
│             │         │  Dimensions  │
└─────────────┘         └──────────────┘
      │
      │ *
      │
┌─────────────┐         ┌──────────────┐         ┌───────────────┐
│ NamedEntity │         │ Transcription│         │  AudioFile    │
└─────────────┘         └──────────────┘         └───────────────┘

┌─────────────┐         ┌──────────────┐         ┌───────────────┐
│ Achievement │         │  AchievementRule│       │  LevelTier    │
└─────────────┘         └──────────────┘         └───────────────┘

┌─────────────┐         ┌──────────────┐
│  HealthData │         │ CalendarEvent│
│ Integration │         │  Integration │
└─────────────┘         └──────────────┘
```

### 1.2 Design Principles

**Normalization:**
- 3NF (Third Normal Form) for most entities
- Denormalization for performance (caching mood summaries)

**Data Integrity:**
- Foreign key constraints via Core Data relationships
- Cascading deletes for dependent entities
- Validation rules at model layer

**Privacy:**
- Sensitive data encrypted at rest (via Data Protection)
- Optional cloud sync (user-controlled)
- Local-first design (works fully offline)

---

## 2. Core Data Model

### 2.1 Model File Structure

```
NoemaDataModel.xcdatamodeld/
├── NoemaDataModel v1.xcdatamodel    # Initial schema
├── NoemaDataModel v2.xcdatamodel    # Future migrations
└── ...
```

### 2.2 Configurations

**Local Configuration:**
- All entities except CloudKit-specific ones
- Used for on-device storage
- No iCloud sync

**CloudSyncable Configuration:**
- Subset of entities that sync via CloudKit
- User must opt-in
- End-to-end encrypted before upload

---

## 3. Entity Definitions

### 3.1 User Profile

**Entity:** `UserProfileEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `createdAt` | Date | No | Now | Account creation date |
| `level` | Int32 | No | 1 | Gamification level |
| `experience` | Int64 | No | 0 | Total XP earned |
| `streak` | Int32 | No | 0 | Current daily streak |
| `longestStreak` | Int32 | No | 0 | Longest streak achieved |
| `totalNotes` | Int64 | No | 0 | Total notes created |
| `totalMoods` | Int64 | No | 0 | Total mood logs |
| `lastNoteDate` | Date | Yes | nil | Last note creation date |
| `displayName` | String | Yes | nil | User's display name |
| `avatarURL` | String | Yes | nil | Profile picture URL |

**Relationships:**
- `notes`: → [Note] (one-to-many)
- `achievements`: → [Achievement] (one-to-many)
- `preferences`: → Preferences (one-to-one)

**Validation Rules:**
```swift
extension UserProfileEntity {
    func validate() throws {
        guard level >= 1 && level <= 50 else {
            throw ValidationError.invalidLevel
        }
        guard experience >= 0 else {
            throw ValidationError.negativeExperience
        }
        guard streak >= 0 && longestStreak >= streak else {
            throw ValidationError.invalidStreak
        }
    }
}
```

---

### 3.2 Note

**Entity:** `NoteEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `content` | String | No | "" | Note text content |
| `createdAt` | Date | No | Now | Creation timestamp |
| `modifiedAt` | Date | No | Now | Last modification |
| `summary` | String | Yes | nil | AI-generated summary |
| `wordCount` | Int32 | No | 0 | Cached word count |
| `readingTime` | Double | No | 0 | Estimated reading time (seconds) |
| `isFavorite` | Bool | No | false | User-marked favorite |
| `isArchived` | Bool | No | false | Archived status |
| `cloudSyncStatus` | String | Yes | nil | "pending", "synced", "conflict" |
| `lastSyncedAt` | Date | Yes | nil | Last CloudKit sync |

**Relationships:**
- `owner`: → UserProfile (many-to-one)
- `mood`: → MoodSnapshot (one-to-one)
- `tags`: ← [Tag] (many-to-many)
- `entities`: → [NamedEntity] (one-to-many)
- `transcription`: → Transcription (one-to-one)
- `audioFile`: → AudioFile (one-to-one)
- `location`: → Location (one-to-one)
- `weather`: → WeatherSnapshot (one-to-one)

**Computed Properties:**
```swift
extension NoteEntity {
    var estimatedReadingTimeMinutes: Double {
        readingTime / 60.0
    }

    var createdDateFormatted: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    func isRecent(within interval: TimeInterval) -> Bool {
        Date().timeIntervalSince(createdAt) < interval
    }
}
```

---

### 3.3 Mood Snapshot

**Entity:** `MoodSnapshotEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `timestamp` | Date | No | Now | When mood was captured |
| `source` | String | No | "manual" | "text", "voice", "manual" |
| `confidence` | Float | No | 1.0 | AI confidence (0.0-1.0) |
| `contextNote` | String | Yes | nil | User-provided context |

**Relationships:**
- `note`: ← Note (one-to-one, optional)
- `dimensions`: → EmotionalDimensions (one-to-one)
- `owner`: → UserProfile (many-to-one)

---

### 3.4 Emotional Dimensions

**Entity:** `EmotionalDimensionsEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `joy` | Float | No | 0.0 | Joy intensity (0.0-1.0) |
| `sadness` | Float | No | 0.0 | Sadness intensity |
| `anger` | Float | No | 0.0 | Anger intensity |
| `fear` | Float | No | 0.0 | Fear intensity |
| `surprise` | Float | No | 0.0 | Surprise intensity |
| `disgust` | Float | No | 0.0 | Disgust intensity |
| `trust` | Float | No | 0.0 | Trust intensity |
| `anticipation` | Float | No | 0.0 | Anticipation intensity |

**Relationships:**
- `moodSnapshot`: ← MoodSnapshot (one-to-one)

**Validation:**
```swift
extension EmotionalDimensionsEntity {
    func validate() throws {
        let dimensions = [joy, sadness, anger, fear, surprise, disgust, trust, anticipation]
        guard dimensions.allSatisfy({ $0 >= 0.0 && $0 <= 1.0 }) else {
            throw ValidationError.dimensionOutOfRange
        }
    }

    var dominantEmotion: String {
        let emotions: [(String, Float)] = [
            ("joy", joy), ("sadness", sadness), ("anger", anger), ("fear", fear),
            ("surprise", surprise), ("disgust", disgust), ("trust", trust), ("anticipation", anticipation)
        ]
        return emotions.max(by: { $0.1 < $1.1 })?.0 ?? "neutral"
    }

    var valence: Float {
        let positive = joy + trust + anticipation
        let negative = sadness + anger + fear + disgust
        return (positive - negative) / 8.0  // Normalized to [-1, 1]
    }
}
```

---

### 3.5 Tag

**Entity:** `TagEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `name` | String | No | - | Tag name (unique) |
| `color` | String | Yes | nil | Hex color code |
| `createdAt` | Date | No | Now | Creation date |
| `usageCount` | Int32 | No | 0 | Number of notes with this tag |

**Relationships:**
- `notes`: ← [Note] (many-to-many)
- `owner`: → UserProfile (many-to-one)

**Unique Constraint:** `name` per user

---

### 3.6 Named Entity

**Entity:** `NamedEntityEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `text` | String | No | - | Entity text (e.g., "Steve Jobs") |
| `type` | String | No | - | "person", "place", "organization", "date", "custom" |
| `confidence` | Float | No | 1.0 | NER model confidence |
| `startIndex` | Int32 | No | - | Start position in note text |
| `endIndex` | Int32 | No | - | End position in note text |

**Relationships:**
- `note`: ← Note (many-to-one)

---

### 3.7 Transcription

**Entity:** `TranscriptionEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `text` | String | No | - | Full transcribed text |
| `language` | String | No | "en" | ISO language code |
| `confidence` | Float | No | 0.0 | Average confidence |
| `duration` | Double | No | 0.0 | Audio duration (seconds) |
| `createdAt` | Date | No | Now | Transcription timestamp |

**Relationships:**
- `note`: ← Note (one-to-one)
- `segments`: → [TranscriptionSegment] (one-to-many)

---

### 3.8 Transcription Segment

**Entity:** `TranscriptionSegmentEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `text` | String | No | - | Segment text |
| `startTime` | Double | No | - | Start time in audio |
| `endTime` | Double | No | - | End time in audio |
| `confidence` | Float | No | 0.0 | Segment confidence |
| `speakerID` | Int16 | Yes | nil | Speaker identifier (diarization) |

**Relationships:**
- `transcription`: ← Transcription (many-to-one)

---

### 3.9 Audio File

**Entity:** `AudioFileEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `fileURL` | String | No | - | Local file path |
| `fileName` | String | No | - | File name |
| `fileSize` | Int64 | No | 0 | Size in bytes |
| `duration` | Double | No | 0.0 | Audio duration |
| `format` | String | No | "m4a" | Audio format |
| `sampleRate` | Int32 | No | 44100 | Sample rate (Hz) |
| `createdAt` | Date | No | Now | Recording date |

**Relationships:**
- `note`: ← Note (one-to-one)

---

### 3.10 Achievement

**Entity:** `AchievementEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | String | No | - | Achievement identifier (e.g., "first_note") |
| `type` | String | No | - | Achievement category |
| `tier` | String | No | "bronze" | "bronze", "silver", "gold", "platinum" |
| `title` | String | No | - | Display title |
| `description` | String | No | - | Achievement description |
| `iconName` | String | No | - | SF Symbol name |
| `unlockedAt` | Date | Yes | nil | Unlock timestamp |
| `progress` | Float | No | 0.0 | Progress toward unlock (0.0-1.0) |
| `isHidden` | Bool | No | false | Hidden achievement |

**Relationships:**
- `owner`: → UserProfile (many-to-one)

**Example Achievements:**
```swift
static let achievements: [Achievement] = [
    Achievement(id: "first_note", type: "milestone", tier: "bronze",
                title: "First Steps", description: "Create your first note"),
    Achievement(id: "streak_7", type: "streak", tier: "silver",
                title: "Week Warrior", description: "Maintain a 7-day streak"),
    Achievement(id: "streak_30", type: "streak", tier: "gold",
                title: "Monthly Master", description: "Maintain a 30-day streak"),
    Achievement(id: "notes_100", type: "quantity", tier: "gold",
                title: "Centurion", description: "Create 100 notes"),
    Achievement(id: "mood_balance", type: "wellness", tier: "platinum",
                title: "Emotional Balance", description: "Maintain balanced moods for 30 days"),
]
```

---

### 3.11 Preferences

**Entity:** `PreferencesEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `cloudSyncEnabled` | Bool | No | false | Enable CloudKit sync |
| `cloudAIEnabled` | Bool | No | false | Enable cloud AI features |
| `biometricAuthEnabled` | Bool | No | true | Require Face/Touch ID |
| `autoMoodDetection` | Bool | No | true | Auto-detect mood from text |
| `voiceMoodDetection` | Bool | No | true | Auto-detect mood from voice |
| `notificationsEnabled` | Bool | No | true | Push notifications |
| `reminderTime` | Date | Yes | nil | Daily reminder time |
| `theme` | String | No | "system" | "light", "dark", "system" |
| `accentColor` | String | No | "blue" | App accent color |
| `privacyMode` | Bool | No | false | Hide sensitive content in app switcher |

**Relationships:**
- `owner`: ← UserProfile (one-to-one)

---

### 3.12 Location

**Entity:** `LocationEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `latitude` | Double | Yes | nil | GPS latitude |
| `longitude` | Double | Yes | nil | GPS longitude |
| `cityName` | String | Yes | nil | City name (reverse geocoded) |
| `countryCode` | String | Yes | nil | ISO country code |
| `placeName` | String | Yes | nil | Place name (e.g., "Starbucks") |

**Relationships:**
- `note`: ← Note (one-to-one)

**Privacy:** GPS coordinates stored locally only, city-level for cloud sync.

---

### 3.13 Weather Snapshot

**Entity:** `WeatherSnapshotEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `timestamp` | Date | No | Now | Weather data timestamp |
| `temperature` | Float | Yes | nil | Temperature (Celsius) |
| `condition` | String | Yes | nil | "sunny", "cloudy", "rainy", etc. |
| `humidity` | Float | Yes | nil | Humidity percentage |

**Relationships:**
- `note`: ← Note (one-to-one)

---

### 3.14 Health Data Integration

**Entity:** `HealthDataEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | UUID | No | Auto | Primary key |
| `date` | Date | No | - | Data date |
| `sleepHours` | Float | Yes | nil | Sleep duration (hours) |
| `stepCount` | Int32 | Yes | nil | Daily steps |
| `exerciseMinutes` | Int32 | Yes | nil | Exercise duration |
| `heartRateAvg` | Float | Yes | nil | Average heart rate (bpm) |
| `hrvAvg` | Float | Yes | nil | Heart rate variability (ms) |

**Relationships:**
- `owner`: → UserProfile (many-to-one)

**Privacy:** Stored locally only, used for mood correlation.

---

### 3.15 Calendar Event Integration

**Entity:** `CalendarEventEntity`

| Attribute | Type | Optional | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | String | No | - | Calendar event ID |
| `title` | String | No | - | Event title (anonymized for privacy) |
| `startDate` | Date | No | - | Event start time |
| `endDate` | Date | No | - | Event end time |
| `isAllDay` | Bool | No | false | All-day event |
| `preMoodScore` | Float | Yes | nil | Mood before event |
| `postMoodScore` | Float | Yes | nil | Mood after event |

**Relationships:**
- `owner`: → UserProfile (many-to-one)

**Privacy:** Event titles can be anonymized (e.g., "Meeting 1", "Meeting 2").

---

## 4. Relationships

### 4.1 Relationship Definitions

**One-to-One:**
- Note ↔ MoodSnapshot
- Note ↔ Transcription
- Note ↔ AudioFile
- MoodSnapshot ↔ EmotionalDimensions
- UserProfile ↔ Preferences

**One-to-Many:**
- UserProfile → Notes
- UserProfile → Achievements
- UserProfile → Tags
- Note → NamedEntities
- Transcription → TranscriptionSegments

**Many-to-Many:**
- Note ↔ Tag (junction table: NoteTag)

### 4.2 Cascade Delete Rules

```swift
// Core Data relationship delete rules

UserProfile → Notes: Cascade
// If user deleted, delete all their notes

Note → MoodSnapshot: Cascade
// If note deleted, delete associated mood

Note → Transcription: Cascade
// If note deleted, delete transcription

Note ↔ Tag: Nullify
// If tag deleted, remove from notes (don't delete notes)

UserProfile → Achievements: Cascade
// If user deleted, delete achievements
```

### 4.3 Fetched Properties

**UserProfile:**
```swift
extension UserProfileEntity {
    @NSManaged var recentNotes: NSFetchedPropertyDescription

    // Fetched property predicate:
    // createdAt >= Date().addingTimeInterval(-7 * 24 * 3600)
    // Sort: createdAt DESC
}
```

---

## 5. Indices & Performance

### 5.1 Core Data Indices

**Note Entity:**
```swift
// Frequently queried fields
@Index(\.createdAt)         // Sort by date
@Index(\.modifiedAt)        // Recent edits
@Index(\.owner)             // User's notes
@Index(\.cloudSyncStatus)   // Sync status

// Compound index for common query
@Index(\.owner, \.createdAt)  // User's notes sorted by date
```

**MoodSnapshot Entity:**
```swift
@Index(\.timestamp)         // Timeline queries
@Index(\.owner)             // User's moods
@Index(\.owner, \.timestamp)  // User's mood timeline
```

**Tag Entity:**
```swift
@Index(\.name)              // Tag name lookup (unique constraint)
@Index(\.usageCount)        // Popular tags
```

**Achievement Entity:**
```swift
@Index(\.owner)             // User's achievements
@Index(\.unlockedAt)        // Recent unlocks
```

### 5.2 Query Optimization

**Fetch Request Best Practices:**
```swift
// ✅ Good: Batch fetch, prefetch relationships
let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
fetchRequest.fetchBatchSize = 20
fetchRequest.relationshipKeyPathsForPrefetching = ["mood", "tags"]
fetchRequest.predicate = NSPredicate(format: "owner == %@", userProfile)
fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

// ❌ Bad: No batch size, no prefetch
let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
let allNotes = try context.fetch(fetchRequest)  // Loads everything into memory
```

**Faulting Strategy:**
```swift
// For list views: use faulting to defer loading
context.shouldDeleteInaccessibleFaults = true

// For detail views: fire faults explicitly
note.willAccessValue(forKey: "mood")
let mood = note.mood  // Fault fired, data loaded
note.didAccessValue(forKey: "mood")
```

---

## 6. CloudKit Schema

### 6.1 Record Types

**Syncable Entities:**
- `Note` (encrypted content)
- `MoodSnapshot` (encrypted)
- `Tag`
- `Achievement`
- `Preferences`

**Not Synced (Local Only):**
- `AudioFile` (too large, local storage only)
- `HealthData` (privacy-sensitive)
- `CalendarEvent` (privacy-sensitive)

### 6.2 CloudKit Record Structure

**Note Record:**
```swift
CKRecord {
    recordType: "Note"
    recordID: CKRecord.ID(recordName: note.id.uuidString)

    fields: [
        "id": UUID string
        "encryptedContent": Data (AES-256 encrypted note.content)
        "createdAt": Date
        "modifiedAt": Date
        "isFavorite": Bool
        "isArchived": Bool
        "ownerID": CKRecord.Reference (UserProfile)

        // Mood reference
        "moodID": CKRecord.Reference (MoodSnapshot, optional)

        // Encrypted summary
        "encryptedSummary": Data (optional)

        // Tag references
        "tags": [CKRecord.Reference] (Tag array)
    ]
}
```

**MoodSnapshot Record:**
```swift
CKRecord {
    recordType: "MoodSnapshot"
    recordID: CKRecord.ID(recordName: mood.id.uuidString)

    fields: [
        "id": UUID string
        "timestamp": Date
        "source": String
        "confidence": Float

        // Encrypted emotional dimensions
        "encryptedDimensions": Data (AES-256 encrypted)

        "ownerID": CKRecord.Reference (UserProfile)
    ]
}
```

### 6.3 Sync Strategy

**Push Strategy:**
```
Local Change → Mark as "needsSync"
               ↓
          Background Task
               ↓
         Encrypt Data
               ↓
         Upload CKRecord
               ↓
      Update syncStatus to "synced"
```

**Pull Strategy:**
```
CloudKit Notification → Fetch CKRecord
                          ↓
                     Decrypt Data
                          ↓
                 Compare with Local
                          ↓
                  Conflict Resolution
                          ↓
                   Update Local DB
```

**Conflict Resolution:**
```swift
enum SyncConflict {
    case localNewer
    case remoteNewer
    case bothModified  // Use last-write-wins or prompt user
}

func resolveConflict(local: Note, remote: Note) -> Note {
    if local.modifiedAt > remote.modifiedAt {
        return local  // Local wins
    } else if remote.modifiedAt > local.modifiedAt {
        return remote  // Remote wins
    } else {
        // Same timestamp: merge or keep both versions
        return mergeNotes(local: local, remote: remote)
    }
}
```

---

## 7. Migration Strategy

### 7.1 Lightweight Migration

**Core Data Automatic Migration:**
```swift
// Core Data Stack setup
let container = NSPersistentContainer(name: "NoemaDataModel")

let description = container.persistentStoreDescriptions.first
description?.shouldMigrateStoreAutomatically = true
description?.shouldInferMappingModelAutomatically = true  // Lightweight migration

container.loadPersistentStores { _, error in
    if let error = error {
        fatalError("Failed to load store: \(error)")
    }
}
```

**Supported Lightweight Changes:**
- Add new entity
- Add new attribute (with default value)
- Delete attribute
- Rename attribute (using renaming identifier)
- Change relationship cardinality (to-one → to-many)
- Add/remove relationship

### 7.2 Custom Migration

**Heavy Migration (when lightweight isn't enough):**
```swift
// Custom migration mapping model
class NoteEntityMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        let destInstance = NSEntityDescription.insertNewObject(
            forEntityName: mapping.destinationEntityName!,
            into: manager.destinationContext
        )

        // Custom migration logic
        // Example: Split "fullName" into "firstName" and "lastName"
        if let fullName = sInstance.value(forKey: "fullName") as? String {
            let components = fullName.split(separator: " ")
            destInstance.setValue(components.first, forKey: "firstName")
            destInstance.setValue(components.last, forKey: "lastName")
        }

        // Copy other attributes
        destInstance.setValue(sInstance.value(forKey: "id"), forKey: "id")
        // ... copy all other fields

        manager.associate(sourceInstance: sInstance, withDestinationInstance: destInstance, for: mapping)
    }
}
```

### 7.3 Migration Versions

**Version 1 → Version 2 (Example):**
```
Changes:
- Added `wordCount` attribute to Note
- Added `readingTime` attribute to Note
- Added new entity: WeatherSnapshot
- Relationship: Note → WeatherSnapshot (optional)

Migration Type: Lightweight (all changes supported)
```

**Version 2 → Version 3 (Example):**
```
Changes:
- Split EmotionalDimensions into separate entity
- Added `summary` attribute to Note
- Removed `deprecated` attribute from UserProfile

Migration Type: Lightweight
```

### 7.4 Migration Testing

```swift
func testMigrationFromV1ToV2() throws {
    // 1. Load v1 store
    let v1StoreURL = Bundle(for: type(of: self)).url(forResource: "SampleDataV1", withExtension: "sqlite")!
    let v1Model = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))])!

    // 2. Perform migration
    let migrationManager = NSMigrationManager(sourceModel: v1Model, destinationModel: v2Model)
    let mappingModel = NSMappingModel(from: [Bundle.main], forSourceModel: v1Model, destinationModel: v2Model)!

    try migrationManager.migrateStore(
        from: v1StoreURL,
        sourceType: NSSQLiteStoreType,
        options: nil,
        with: mappingModel,
        toDestinationURL: v2StoreURL,
        destinationType: NSSQLiteStoreType,
        destinationOptions: nil
    )

    // 3. Verify migrated data
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: v2Model)

    let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
    let notes = try context.fetch(fetchRequest)

    XCTAssertGreaterThan(notes.count, 0, "Notes should be migrated")
    XCTAssertNotNil(notes.first?.wordCount, "New attribute should exist")
}
```

---

## 8. Sample Queries

### 8.1 Common Queries

**Fetch Recent Notes:**
```swift
func fetchRecentNotes(limit: Int = 20) async throws -> [Note] {
    let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "owner == %@", userProfile)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    fetchRequest.fetchLimit = limit
    fetchRequest.relationshipKeyPathsForPrefetching = ["mood", "tags"]

    let entities = try context.fetch(fetchRequest)
    return entities.map { $0.toDomainModel() }
}
```

**Search Notes by Text:**
```swift
func searchNotes(query: String) async throws -> [Note] {
    let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(
        format: "owner == %@ AND (content CONTAINS[cd] %@ OR summary CONTAINS[cd] %@)",
        userProfile, query, query
    )
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "modifiedAt", ascending: false)]

    let entities = try context.fetch(fetchRequest)
    return entities.map { $0.toDomainModel() }
}
```

**Fetch Notes by Mood:**
```swift
func fetchNotes(withDominantEmotion emotion: String) async throws -> [Note] {
    // This is complex because dominant emotion is computed
    // Option 1: Fetch all and filter in memory (small datasets)
    let allNotes = try await fetchAllNotes()
    return allNotes.filter { $0.mood?.dimensions.dominantEmotion == emotion }

    // Option 2: Denormalize (store dominantEmotion in MoodSnapshot)
    // Then use predicate:
    // NSPredicate(format: "mood.dominantEmotion == %@", emotion)
}
```

**Fetch Mood Timeline:**
```swift
func fetchMoodTimeline(from startDate: Date, to endDate: Date) async throws -> [MoodSnapshot] {
    let fetchRequest: NSFetchRequest<MoodSnapshotEntity> = MoodSnapshotEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(
        format: "owner == %@ AND timestamp >= %@ AND timestamp <= %@",
        userProfile, startDate as NSDate, endDate as NSDate
    )
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
    fetchRequest.relationshipKeyPathsForPrefetching = ["dimensions"]

    let entities = try context.fetch(fetchRequest)
    return entities.map { $0.toDomainModel() }
}
```

**Fetch Unlocked Achievements:**
```swift
func fetchUnlockedAchievements() async throws -> [Achievement] {
    let fetchRequest: NSFetchRequest<AchievementEntity> = AchievementEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(
        format: "owner == %@ AND unlockedAt != nil",
        userProfile
    )
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "unlockedAt", ascending: false)]

    let entities = try context.fetch(fetchRequest)
    return entities.map { $0.toDomainModel() }
}
```

**Fetch Tags Sorted by Usage:**
```swift
func fetchPopularTags(limit: Int = 10) async throws -> [Tag] {
    let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "owner == %@", userProfile)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "usageCount", ascending: false)]
    fetchRequest.fetchLimit = limit

    let entities = try context.fetch(fetchRequest)
    return entities.map { $0.toDomainModel() }
}
```

### 8.2 Aggregation Queries

**Count Notes by Date Range:**
```swift
func countNotes(from startDate: Date, to endDate: Date) async throws -> Int {
    let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(
        format: "owner == %@ AND createdAt >= %@ AND createdAt <= %@",
        userProfile, startDate as NSDate, endDate as NSDate
    )

    return try context.count(for: fetchRequest)
}
```

**Average Mood Valence by Week:**
```swift
func averageMoodValence(for week: Date) async throws -> Float {
    let calendar = Calendar.current
    let weekStart = calendar.dateInterval(of: .weekOfYear, for: week)!.start
    let weekEnd = calendar.dateInterval(of: .weekOfYear, for: week)!.end

    let fetchRequest: NSFetchRequest<MoodSnapshotEntity> = MoodSnapshotEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(
        format: "owner == %@ AND timestamp >= %@ AND timestamp < %@",
        userProfile, weekStart as NSDate, weekEnd as NSDate
    )
    fetchRequest.relationshipKeyPathsForPrefetching = ["dimensions"]

    let moods = try context.fetch(fetchRequest)
    let valences = moods.compactMap { $0.dimensions?.valence }

    guard !valences.isEmpty else { return 0.0 }
    return valences.reduce(0, +) / Float(valences.count)
}
```

---

## 9. Performance Benchmarks

### 9.1 Target Performance

| Operation | Target Time | Notes |
|-----------|-------------|-------|
| Fetch 100 notes | <50ms | With prefetching |
| Save note | <20ms | Async save |
| Mood detection + save | <500ms | On-device AI |
| Search 10,000 notes | <200ms | Full-text search |
| Sync 10 notes to CloudKit | <3s | Network dependent |

### 9.2 Optimization Checklist

- [ ] Use batch fetching (`fetchBatchSize = 20`)
- [ ] Prefetch relationships to avoid faults
- [ ] Use `NSFetchedResultsController` for table views
- [ ] Background context for heavy writes
- [ ] Asynchronous fetch requests for large datasets
- [ ] Denormalize frequently computed properties (e.g., `dominantEmotion`)
- [ ] Regular vacuum of SQLite database (`PRAGMA vacuum`)
- [ ] Monitor with Instruments (Core Data profiling)

---

## Document Control

**Version:** 1.0
**Last Updated:** 2025-11-17
**Status:** Complete Schema Definition

**Review Schedule:** Quarterly or before major migrations

**Contributors:**
- Data Architecture Team
- iOS Engineering Team

**Approval:**
- Engineering Lead: [Pending]
- Data Privacy Officer: [Pending]

---

*This schema is designed for scalability, performance, and privacy. All changes must be reviewed by the data architecture team and tested with migration procedures.*

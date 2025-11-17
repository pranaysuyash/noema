import Foundation
import CoreData

/// Core Data stack manager with encryption and CloudKit sync support
public final class CoreDataStack: @unchecked Sendable {
    // MARK: - Singleton

    public static let shared = CoreDataStack()

    // MARK: - Properties

    private let modelName = "NoemaDataModel"

    /// Main context for UI operations (main queue)
    public lazy var mainContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    /// Background context for heavy operations
    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    // MARK: - Core Data Stack

    private lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: modelName, managedObjectModel: managedObjectModel)

        // Local store description (always available)
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
        localStoreDescription.setOption(FileProtectionType.complete as NSObject,
                                       forKey: NSPersistentStoreFileProtectionKey)
        localStoreDescription.shouldMigrateStoreAutomatically = true
        localStoreDescription.shouldInferMappingModelAutomatically = true

        // CloudKit store description (if enabled)
        if UserDefaults.standard.bool(forKey: "cloudSyncEnabled") {
            let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
            cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.noema.app"
            )
            cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            container.persistentStoreDescriptions = [localStoreDescription, cloudStoreDescription]
        } else {
            container.persistentStoreDescriptions = [localStoreDescription]
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, handle this more gracefully
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // Automatically merge changes from CloudKit
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()

    // MARK: - Managed Object Model

    private lazy var managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()

        // Define entities programmatically
        model.entities = [
            createUserProfileEntity(),
            createNoteEntity(),
            createMoodSnapshotEntity(),
            createEmotionalDimensionsEntity(),
            createTagEntity(),
            createAchievementEntity(),
            createTranscriptionEntity(),
            createTranscriptionSegmentEntity(),
            createNamedEntityEntity(),
            createPreferencesEntity(),
            createLocationEntity(),
            createWeatherSnapshotEntity()
        ]

        return model
    }()

    // MARK: - Store URLs

    private var localStoreURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("\(modelName).sqlite")
    }

    private var cloudStoreURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("\(modelName)Cloud.sqlite")
    }

    // MARK: - Initialization

    private init() {
        // Private initialization for singleton
    }

    // MARK: - Core Data Saving

    public func saveContext() throws {
        guard mainContext.hasChanges else { return }
        try mainContext.save()
    }

    public func saveContext(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }

        try context.performAndWait {
            try context.save()

            // If this is a background context, also save parent context
            if let parent = context.parent {
                try parent.performAndWait {
                    if parent.hasChanges {
                        try parent.save()
                    }
                }
            }
        }
    }

    // MARK: - Entity Definitions

    private func createUserProfileEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "UserProfileEntity"
        entity.managedObjectClassName = NSStringFromClass(UserProfileEntity.self)

        // Attributes
        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let displayName = NSAttributeDescription()
        displayName.name = "displayName"
        displayName.attributeType = .stringAttributeType
        displayName.isOptional = true

        let level = NSAttributeDescription()
        level.name = "level"
        level.attributeType = .integer32AttributeType
        level.defaultValue = 1

        let experience = NSAttributeDescription()
        experience.name = "experience"
        experience.attributeType = .integer64AttributeType
        experience.defaultValue = 0

        let streak = NSAttributeDescription()
        streak.name = "streak"
        streak.attributeType = .integer32AttributeType
        streak.defaultValue = 0

        let longestStreak = NSAttributeDescription()
        longestStreak.name = "longestStreak"
        longestStreak.attributeType = .integer32AttributeType
        longestStreak.defaultValue = 0

        let totalNotes = NSAttributeDescription()
        totalNotes.name = "totalNotes"
        totalNotes.attributeType = .integer64AttributeType
        totalNotes.defaultValue = 0

        let totalMoods = NSAttributeDescription()
        totalMoods.name = "totalMoods"
        totalMoods.attributeType = .integer64AttributeType
        totalMoods.defaultValue = 0

        let lastNoteDate = NSAttributeDescription()
        lastNoteDate.name = "lastNoteDate"
        lastNoteDate.attributeType = .dateAttributeType
        lastNoteDate.isOptional = true

        entity.properties = [id, createdAt, displayName, level, experience, streak,
                           longestStreak, totalNotes, totalMoods, lastNoteDate]

        return entity
    }

    private func createNoteEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "NoteEntity"
        entity.managedObjectClassName = NSStringFromClass(NoteEntity.self)

        // Attributes
        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let content = NSAttributeDescription()
        content.name = "content"
        content.attributeType = .stringAttributeType
        content.isOptional = false

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let modifiedAt = NSAttributeDescription()
        modifiedAt.name = "modifiedAt"
        modifiedAt.attributeType = .dateAttributeType
        modifiedAt.isOptional = false

        let summary = NSAttributeDescription()
        summary.name = "summary"
        summary.attributeType = .stringAttributeType
        summary.isOptional = true

        let isFavorite = NSAttributeDescription()
        isFavorite.name = "isFavorite"
        isFavorite.attributeType = .booleanAttributeType
        isFavorite.defaultValue = false

        let isArchived = NSAttributeDescription()
        isArchived.name = "isArchived"
        isArchived.attributeType = .booleanAttributeType
        isArchived.defaultValue = false

        entity.properties = [id, content, createdAt, modifiedAt, summary, isFavorite, isArchived]

        return entity
    }

    private func createMoodSnapshotEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "MoodSnapshotEntity"
        entity.managedObjectClassName = NSStringFromClass(MoodSnapshotEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let timestamp = NSAttributeDescription()
        timestamp.name = "timestamp"
        timestamp.attributeType = .dateAttributeType
        timestamp.isOptional = false

        let confidence = NSAttributeDescription()
        confidence.name = "confidence"
        confidence.attributeType = .floatAttributeType
        confidence.defaultValue = 0.0

        let source = NSAttributeDescription()
        source.name = "source"
        source.attributeType = .stringAttributeType
        source.isOptional = false

        let contextNote = NSAttributeDescription()
        contextNote.name = "contextNote"
        contextNote.attributeType = .stringAttributeType
        contextNote.isOptional = true

        entity.properties = [id, timestamp, confidence, source, contextNote]

        return entity
    }

    private func createEmotionalDimensionsEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "EmotionalDimensionsEntity"
        entity.managedObjectClassName = NSStringFromClass(EmotionalDimensionsEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let joy = NSAttributeDescription()
        joy.name = "joy"
        joy.attributeType = .floatAttributeType
        joy.defaultValue = 0.0

        let sadness = NSAttributeDescription()
        sadness.name = "sadness"
        sadness.attributeType = .floatAttributeType
        sadness.defaultValue = 0.0

        let anger = NSAttributeDescription()
        anger.name = "anger"
        anger.attributeType = .floatAttributeType
        anger.defaultValue = 0.0

        let fear = NSAttributeDescription()
        fear.name = "fear"
        fear.attributeType = .floatAttributeType
        fear.defaultValue = 0.0

        let surprise = NSAttributeDescription()
        surprise.name = "surprise"
        surprise.attributeType = .floatAttributeType
        surprise.defaultValue = 0.0

        let disgust = NSAttributeDescription()
        disgust.name = "disgust"
        disgust.attributeType = .floatAttributeType
        disgust.defaultValue = 0.0

        let trust = NSAttributeDescription()
        trust.name = "trust"
        trust.attributeType = .floatAttributeType
        trust.defaultValue = 0.0

        let anticipation = NSAttributeDescription()
        anticipation.name = "anticipation"
        anticipation.attributeType = .floatAttributeType
        anticipation.defaultValue = 0.0

        entity.properties = [id, joy, sadness, anger, fear, surprise, disgust, trust, anticipation]

        return entity
    }

    private func createTagEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "TagEntity"
        entity.managedObjectClassName = NSStringFromClass(TagEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let name = NSAttributeDescription()
        name.name = "name"
        name.attributeType = .stringAttributeType
        name.isOptional = false

        let colorHex = NSAttributeDescription()
        colorHex.name = "colorHex"
        colorHex.attributeType = .stringAttributeType
        colorHex.defaultValue = "#3498DB"

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let usageCount = NSAttributeDescription()
        usageCount.name = "usageCount"
        usageCount.attributeType = .integer32AttributeType
        usageCount.defaultValue = 0

        entity.properties = [id, name, colorHex, createdAt, usageCount]

        return entity
    }

    private func createAchievementEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "AchievementEntity"
        entity.managedObjectClassName = NSStringFromClass(AchievementEntity.self)

        let id = NSAttributeDescription()
        id.name = "achievementId"
        id.attributeType = .stringAttributeType
        id.isOptional = false

        let type = NSAttributeDescription()
        type.name = "type"
        type.attributeType = .stringAttributeType
        type.isOptional = false

        let tier = NSAttributeDescription()
        tier.name = "tier"
        tier.attributeType = .stringAttributeType
        tier.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false

        let achievementDescription = NSAttributeDescription()
        achievementDescription.name = "achievementDescription"
        achievementDescription.attributeType = .stringAttributeType
        achievementDescription.isOptional = false

        let iconName = NSAttributeDescription()
        iconName.name = "iconName"
        iconName.attributeType = .stringAttributeType
        iconName.isOptional = false

        let unlockedAt = NSAttributeDescription()
        unlockedAt.name = "unlockedAt"
        unlockedAt.attributeType = .dateAttributeType
        unlockedAt.isOptional = true

        let progress = NSAttributeDescription()
        progress.name = "progress"
        progress.attributeType = .floatAttributeType
        progress.defaultValue = 0.0

        let isHidden = NSAttributeDescription()
        isHidden.name = "isHidden"
        isHidden.attributeType = .booleanAttributeType
        isHidden.defaultValue = false

        entity.properties = [id, type, tier, title, achievementDescription, iconName, unlockedAt, progress, isHidden]

        return entity
    }

    private func createTranscriptionEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "TranscriptionEntity"
        entity.managedObjectClassName = NSStringFromClass(TranscriptionEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let text = NSAttributeDescription()
        text.name = "text"
        text.attributeType = .stringAttributeType
        text.isOptional = false

        let language = NSAttributeDescription()
        language.name = "language"
        language.attributeType = .stringAttributeType
        language.defaultValue = "en"

        let confidence = NSAttributeDescription()
        confidence.name = "confidence"
        confidence.attributeType = .floatAttributeType
        confidence.defaultValue = 0.0

        let duration = NSAttributeDescription()
        duration.name = "duration"
        duration.attributeType = .doubleAttributeType
        duration.defaultValue = 0.0

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        entity.properties = [id, text, language, confidence, duration, createdAt]

        return entity
    }

    private func createTranscriptionSegmentEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "TranscriptionSegmentEntity"
        entity.managedObjectClassName = NSStringFromClass(TranscriptionSegmentEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let text = NSAttributeDescription()
        text.name = "text"
        text.attributeType = .stringAttributeType
        text.isOptional = false

        let startTime = NSAttributeDescription()
        startTime.name = "startTime"
        startTime.attributeType = .doubleAttributeType
        startTime.defaultValue = 0.0

        let endTime = NSAttributeDescription()
        endTime.name = "endTime"
        endTime.attributeType = .doubleAttributeType
        endTime.defaultValue = 0.0

        let confidence = NSAttributeDescription()
        confidence.name = "confidence"
        confidence.attributeType = .floatAttributeType
        confidence.defaultValue = 0.0

        let speakerID = NSAttributeDescription()
        speakerID.name = "speakerID"
        speakerID.attributeType = .integer16AttributeType
        speakerID.isOptional = true

        entity.properties = [id, text, startTime, endTime, confidence, speakerID]

        return entity
    }

    private func createNamedEntityEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "NamedEntityEntity"
        entity.managedObjectClassName = NSStringFromClass(NamedEntityEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let text = NSAttributeDescription()
        text.name = "text"
        text.attributeType = .stringAttributeType
        text.isOptional = false

        let type = NSAttributeDescription()
        type.name = "type"
        type.attributeType = .stringAttributeType
        type.isOptional = false

        let confidence = NSAttributeDescription()
        confidence.name = "confidence"
        confidence.attributeType = .floatAttributeType
        confidence.defaultValue = 0.0

        let startIndex = NSAttributeDescription()
        startIndex.name = "startIndex"
        startIndex.attributeType = .integer32AttributeType
        startIndex.defaultValue = 0

        let endIndex = NSAttributeDescription()
        endIndex.name = "endIndex"
        endIndex.attributeType = .integer32AttributeType
        endIndex.defaultValue = 0

        entity.properties = [id, text, type, confidence, startIndex, endIndex]

        return entity
    }

    private func createPreferencesEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "PreferencesEntity"
        entity.managedObjectClassName = NSStringFromClass(PreferencesEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        // Boolean preferences
        let cloudSyncEnabled = NSAttributeDescription()
        cloudSyncEnabled.name = "cloudSyncEnabled"
        cloudSyncEnabled.attributeType = .booleanAttributeType
        cloudSyncEnabled.defaultValue = false

        let biometricAuthEnabled = NSAttributeDescription()
        biometricAuthEnabled.name = "biometricAuthEnabled"
        biometricAuthEnabled.attributeType = .booleanAttributeType
        biometricAuthEnabled.defaultValue = true

        // Add all other preferences attributes...

        entity.properties = [id, cloudSyncEnabled, biometricAuthEnabled]

        return entity
    }

    private func createLocationEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "LocationEntity"
        entity.managedObjectClassName = NSStringFromClass(LocationEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let latitude = NSAttributeDescription()
        latitude.name = "latitude"
        latitude.attributeType = .doubleAttributeType
        latitude.isOptional = true

        let longitude = NSAttributeDescription()
        longitude.name = "longitude"
        longitude.attributeType = .doubleAttributeType
        longitude.isOptional = true

        let cityName = NSAttributeDescription()
        cityName.name = "cityName"
        cityName.attributeType = .stringAttributeType
        cityName.isOptional = true

        entity.properties = [id, latitude, longitude, cityName]

        return entity
    }

    private func createWeatherSnapshotEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "WeatherSnapshotEntity"
        entity.managedObjectClassName = NSStringFromClass(WeatherSnapshotEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let timestamp = NSAttributeDescription()
        timestamp.name = "timestamp"
        timestamp.attributeType = .dateAttributeType
        timestamp.isOptional = false

        let temperature = NSAttributeDescription()
        temperature.name = "temperature"
        temperature.attributeType = .floatAttributeType
        temperature.isOptional = true

        let condition = NSAttributeDescription()
        condition.name = "condition"
        condition.attributeType = .stringAttributeType
        condition.isOptional = true

        entity.properties = [id, timestamp, temperature, condition]

        return entity
    }
}

// MARK: - NSManagedObject Subclasses (Placeholders)

@objc(UserProfileEntity)
public class UserProfileEntity: NSManagedObject {}

@objc(NoteEntity)
public class NoteEntity: NSManagedObject {}

@objc(MoodSnapshotEntity)
public class MoodSnapshotEntity: NSManagedObject {}

@objc(EmotionalDimensionsEntity)
public class EmotionalDimensionsEntity: NSManagedObject {}

@objc(TagEntity)
public class TagEntity: NSManagedObject {}

@objc(AchievementEntity)
public class AchievementEntity: NSManagedObject {}

@objc(TranscriptionEntity)
public class TranscriptionEntity: NSManagedObject {}

@objc(TranscriptionSegmentEntity)
public class TranscriptionSegmentEntity: NSManagedObject {}

@objc(NamedEntityEntity)
public class NamedEntityEntity: NSManagedObject {}

@objc(PreferencesEntity)
public class PreferencesEntity: NSManagedObject {}

@objc(LocationEntity)
public class LocationEntity: NSManagedObject {}

@objc(WeatherSnapshotEntity)
public class WeatherSnapshotEntity: NSManagedObject {}

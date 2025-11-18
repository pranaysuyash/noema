import Foundation
import CoreData
import Combine

// MARK: - PersistenceController

/// Manages Core Data stack and provides access to persistent storage
public final class PersistenceController: ObservableObject {

    // MARK: - Singleton

    public static let shared = PersistenceController()

    // MARK: - Properties

    /// Main persistent container
    public let container: NSPersistentContainer

    /// Main view context (for UI operations)
    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    /// Background context (for heavy operations)
    public lazy var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    /// Publisher for context save notifications
    public let didSavePublisher = PassthroughSubject<Notification, Never>()

    // MARK: - Initialization

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Noema")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure persistent store
            if let description = container.persistentStoreDescriptions.first {
                // Enable automatic lightweight migration
                description.shouldMigrateStoreAutomatically = true
                description.shouldInferMappingModelAutomatically = true

                // Enable remote change notifications (for CloudKit sync)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            }
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle this error appropriately
                fatalError("Failed to load Core Data stack: \(error.localizedDescription)")
            }

            print("✅ Core Data loaded: \(description)")
        }

        // Configure view context
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Observe save notifications
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .subscribe(didSavePublisher)
    }

    // MARK: - Preview/Testing

    /// Create in-memory instance for SwiftUI previews and testing
    public static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // Populate with sample data
        let context = controller.viewContext

        // Sample user profile
        let profile = UserProfile(context: context)
        profile.level = 5
        profile.totalXP = 500
        profile.currentStreak = 12
        profile.longestStreak = 30
        profile.totalNotes = 50

        // Sample notes
        for i in 0..<10 {
            let note = Note(context: context)
            note.content = "Sample note \(i + 1): This is a test note with some content."
            note.createdAt = Date().addingTimeInterval(-Double(i) * 86400)
            note.wordCount = 10
            note.characterCount = 50

            // Sample emotional state
            let emotion = EmotionalState(context: context)
            emotion.valence = Double.random(in: -1...1)
            emotion.arousal = Double.random(in: -1...1)
            emotion.energyLevel = Double.random(in: 0...1)
            emotion.primaryEmotion = EmotionType.allCases.randomElement() ?? .contentment
            note.moodSnapshot = emotion
        }

        // Sample entities
        let person = Entity(context: context)
        person.name = "Sarah"
        person.type = .person
        person.canonicalName = "Sarah Johnson"
        person.totalMentions = 15
        person.averageValence = 0.7

        let place = Entity(context: context)
        place.name = "Coffee Shop"
        place.type = .place
        place.canonicalName = "Central Perk"
        place.totalMentions = 8
        place.averageEnergy = 0.8

        do {
            try context.save()
        } catch {
            print("Failed to save preview data: \(error)")
        }

        return controller
    }()

    // MARK: - Context Management

    /// Create a new background context for heavy operations
    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    /// Perform a task on the view context
    public func performOnViewContext<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await viewContext.perform {
            try block(self.viewContext)
        }
    }

    /// Perform a task on a background context
    public func performInBackground<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        let context = newBackgroundContext()
        return try await context.perform {
            try block(context)
        }
    }

    // MARK: - Save Operations

    /// Save the view context
    public func save() throws {
        guard viewContext.hasChanges else { return }
        try viewContext.save()
    }

    /// Save a specific context
    public func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }

    /// Save all contexts
    public func saveAll() throws {
        try save(context: viewContext)
        if backgroundContext.hasChanges {
            try save(context: backgroundContext)
        }
    }

    // MARK: - Fetch Operations

    /// Generic fetch request
    public func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>, context: NSManagedObjectContext? = nil) throws -> [T] {
        let ctx = context ?? viewContext
        return try ctx.fetch(request)
    }

    /// Fetch with predicate
    public func fetch<T: NSManagedObject>(
        entityName: String,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil,
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if let limit = limit {
            request.fetchLimit = limit
        }
        return try fetch(request, context: context)
    }

    /// Fetch single object
    public func fetchOne<T: NSManagedObject>(
        entityName: String,
        predicate: NSPredicate,
        context: NSManagedObjectContext? = nil
    ) throws -> T? {
        let results: [T] = try fetch(
            entityName: entityName,
            predicate: predicate,
            limit: 1,
            context: context
        )
        return results.first
    }

    /// Count entities
    public func count<T: NSManagedObject>(_ request: NSFetchRequest<T>, context: NSManagedObjectContext? = nil) throws -> Int {
        let ctx = context ?? viewContext
        return try ctx.count(for: request)
    }

    // MARK: - Delete Operations

    /// Delete an object
    public func delete(_ object: NSManagedObject, context: NSManagedObjectContext? = nil) {
        let ctx = context ?? viewContext
        ctx.delete(object)
    }

    /// Batch delete
    public func batchDelete<T: NSManagedObject>(
        entityName: String,
        predicate: NSPredicate? = nil
    ) throws {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        deleteRequest.resultType = .resultTypeObjectIDs

        let result = try viewContext.execute(deleteRequest) as? NSBatchDeleteResult
        guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }

        // Merge changes into view context
        let changes = [NSDeletedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
    }

    // MARK: - CloudKit Sync

    /// Enable CloudKit synchronization
    public func enableCloudKitSync() {
        // CloudKit container setup would go here
        // For now, this is a placeholder
        print("CloudKit sync enabled")
    }

    /// Disable CloudKit synchronization
    public func disableCloudKitSync() {
        print("CloudKit sync disabled")
    }

    // MARK: - Data Export

    /// Export all data as JSON
    public func exportAllData() throws -> Data {
        var exportData: [String: Any] = [:]

        // Export notes
        let notes: [Note] = try fetch(entityName: "Note")
        exportData["notes"] = notes.map { note in
            [
                "id": note.id.uuidString,
                "content": note.content,
                "createdAt": note.createdAt.ISO8601Format(),
                "wordCount": note.wordCount
            ]
        }

        // Export entities
        let entities: [Entity] = try fetch(entityName: "Entity")
        exportData["entities"] = entities.map { entity in
            [
                "id": entity.id.uuidString,
                "name": entity.name,
                "type": entity.type.rawValue,
                "totalMentions": entity.totalMentions
            ]
        }

        // Export user profile
        let profiles: [UserProfile] = try fetch(entityName: "UserProfile", limit: 1)
        if let profile = profiles.first {
            exportData["profile"] = [
                "level": profile.level,
                "totalXP": profile.totalXP,
                "currentStreak": profile.currentStreak,
                "totalNotes": profile.totalNotes
            ]
        }

        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }

    // MARK: - Data Deletion

    /// Delete all data (for account deletion)
    public func deleteAllData() throws {
        let entities = container.managedObjectModel.entities.compactMap { $0.name }

        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try viewContext.execute(deleteRequest)
        }

        try save()
    }

    // MARK: - Deinitialization

    deinit {
        // Save any unsaved changes
        try? saveAll()
    }
}

// MARK: - Convenience Extensions

extension NSManagedObjectContext {

    /// Convenient save with error handling
    public func saveIfNeeded() throws {
        guard hasChanges else { return }
        try save()
    }

    /// Perform and save
    public func performAndSave(_ block: @escaping () -> Void) throws {
        perform {
            block()
        }
        try saveIfNeeded()
    }
}

import Foundation
import CoreData

/// Core Data implementation of MoodRepositoryProtocol
public actor CoreDataMoodRepository: MoodRepositoryProtocol {
    // MARK: - Properties

    private let coreDataStack: CoreDataStack

    // MARK: - Initialization

    public init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - CRUD Operations

    public func save(_ mood: MoodSnapshot) async throws -> MoodSnapshot {
        let context = coreDataStack.newBackgroundContext()

        return try await context.perform {
            let entity = MoodSnapshotEntity(context: context)
            entity.setValue(mood.id, forKey: "id")
            entity.setValue(mood.timestamp, forKey: "timestamp")
            entity.setValue(mood.confidence, forKey: "confidence")
            entity.setValue(mood.source.rawValue, forKey: "source")
            entity.setValue(mood.contextNote, forKey: "contextNote")

            // Emotional dimensions
            entity.setValue(mood.dimensions.joy, forKey: "joy")
            entity.setValue(mood.dimensions.sadness, forKey: "sadness")
            entity.setValue(mood.dimensions.anger, forKey: "anger")
            entity.setValue(mood.dimensions.fear, forKey: "fear")
            entity.setValue(mood.dimensions.surprise, forKey: "surprise")
            entity.setValue(mood.dimensions.disgust, forKey: "disgust")
            entity.setValue(mood.dimensions.trust, forKey: "trust")
            entity.setValue(mood.dimensions.anticipation, forKey: "anticipation")

            try self.coreDataStack.saveContext(context)

            return mood
        }
    }

    public func fetch(id: UUID) async throws -> MoodSnapshot? {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<MoodSnapshotEntity> = NSFetchRequest(entityName: "MoodSnapshotEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            fetchRequest.fetchLimit = 1

            guard let entity = try context.fetch(fetchRequest).first else {
                return nil
            }

            return self.mapToDomain(entity: entity)
        }
    }

    public func fetchAll() async throws -> [MoodSnapshot] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<MoodSnapshotEntity> = NSFetchRequest(entityName: "MoodSnapshotEntity")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    public func fetchRecent(limit: Int) async throws -> [MoodSnapshot] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<MoodSnapshotEntity> = NSFetchRequest(entityName: "MoodSnapshotEntity")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            fetchRequest.fetchLimit = limit

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    public func fetchMoods(in dateRange: ClosedRange<Date>) async throws -> [MoodSnapshot] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<MoodSnapshotEntity> = NSFetchRequest(entityName: "MoodSnapshotEntity")
            fetchRequest.predicate = NSPredicate(
                format: "timestamp >= %@ AND timestamp <= %@",
                dateRange.lowerBound as NSDate,
                dateRange.upperBound as NSDate
            )
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    public func delete(id: UUID) async throws {
        let context = coreDataStack.newBackgroundContext()

        try await context.perform {
            let fetchRequest: NSFetchRequest<MoodSnapshotEntity> = NSFetchRequest(entityName: "MoodSnapshotEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try context.fetch(fetchRequest).first else {
                throw RepositoryError.notFound
            }

            context.delete(entity)
            try self.coreDataStack.saveContext(context)
        }
    }

    public func countMoods() async throws -> Int {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<MoodSnapshotEntity> = NSFetchRequest(entityName: "MoodSnapshotEntity")
            return try context.count(for: fetchRequest)
        }
    }

    public func countMoods(in dateRange: ClosedRange<Date>) async throws -> Int {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<MoodSnapshotEntity> = NSFetchRequest(entityName: "MoodSnapshotEntity")
            fetchRequest.predicate = NSPredicate(
                format: "timestamp >= %@ AND timestamp <= %@",
                dateRange.lowerBound as NSDate,
                dateRange.upperBound as NSDate
            )
            return try context.count(for: fetchRequest)
        }
    }

    // MARK: - Mapping

    private func mapToDomain(entity: MoodSnapshotEntity) -> MoodSnapshot {
        let dimensions = EmotionalDimensions(
            joy: entity.value(forKey: "joy") as? Float ?? 0.0,
            sadness: entity.value(forKey: "sadness") as? Float ?? 0.0,
            anger: entity.value(forKey: "anger") as? Float ?? 0.0,
            fear: entity.value(forKey: "fear") as? Float ?? 0.0,
            surprise: entity.value(forKey: "surprise") as? Float ?? 0.0,
            disgust: entity.value(forKey: "disgust") as? Float ?? 0.0,
            trust: entity.value(forKey: "trust") as? Float ?? 0.0,
            anticipation: entity.value(forKey: "anticipation") as? Float ?? 0.0
        )

        let sourceRaw = entity.value(forKey: "source") as? String ?? "text"
        let source = MoodSource(rawValue: sourceRaw) ?? .text

        return MoodSnapshot(
            id: entity.value(forKey: "id") as? UUID ?? UUID(),
            timestamp: entity.value(forKey: "timestamp") as? Date ?? Date(),
            dimensions: dimensions,
            confidence: entity.value(forKey: "confidence") as? Float ?? 0.0,
            source: source,
            contextNote: entity.value(forKey: "contextNote") as? String
        )
    }
}

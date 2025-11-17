import Foundation
import CoreData

/// Core Data implementation of NoteRepositoryProtocol
public actor CoreDataNoteRepository: NoteRepositoryProtocol {
    // MARK: - Properties

    private let coreDataStack: CoreDataStack

    // MARK: - Initialization

    public init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - CRUD Operations

    public func save(_ note: Note) async throws -> Note {
        let context = coreDataStack.newBackgroundContext()

        return try await context.perform {
            let entity = NoteEntity(context: context)
            entity.setValue(note.id, forKey: "id")
            entity.setValue(note.content, forKey: "content")
            entity.setValue(note.createdAt, forKey: "createdAt")
            entity.setValue(note.modifiedAt, forKey: "modifiedAt")
            entity.setValue(note.summary, forKey: "summary")
            entity.setValue(note.isFavorite, forKey: "isFavorite")
            entity.setValue(note.isArchived, forKey: "isArchived")

            try self.coreDataStack.saveContext(context)

            return note
        }
    }

    public func fetch(id: UUID) async throws -> Note? {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            fetchRequest.fetchLimit = 1

            guard let entity = try context.fetch(fetchRequest).first else {
                return nil
            }

            return self.mapToDomain(entity: entity)
        }
    }

    public func fetchAll() async throws -> [Note] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    public func fetchRecent(limit: Int) async throws -> [Note] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            fetchRequest.fetchLimit = limit

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    public func delete(id: UUID) async throws {
        let context = coreDataStack.newBackgroundContext()

        try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try context.fetch(fetchRequest).first else {
                throw RepositoryError.notFound
            }

            context.delete(entity)
            try self.coreDataStack.saveContext(context)
        }
    }

    public func update(_ note: Note) async throws -> Note {
        let context = coreDataStack.newBackgroundContext()

        return try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)

            guard let entity = try context.fetch(fetchRequest).first else {
                throw RepositoryError.notFound
            }

            entity.setValue(note.content, forKey: "content")
            entity.setValue(note.modifiedAt, forKey: "modifiedAt")
            entity.setValue(note.summary, forKey: "summary")
            entity.setValue(note.isFavorite, forKey: "isFavorite")
            entity.setValue(note.isArchived, forKey: "isArchived")

            try self.coreDataStack.saveContext(context)

            return note
        }
    }

    // MARK: - Query Operations

    public func search(query: String) async throws -> [Note] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            fetchRequest.predicate = NSPredicate(
                format: "content CONTAINS[cd] %@ OR summary CONTAINS[cd] %@",
                query, query
            )
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "modifiedAt", ascending: false)]

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    public func fetchNotes(withMood mood: String) async throws -> [Note] {
        // This requires joining with mood entity - simplified for now
        return try await fetchAll()
    }

    public func fetchNotes(in dateRange: ClosedRange<Date>) async throws -> [Note] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            fetchRequest.predicate = NSPredicate(
                format: "createdAt >= %@ AND createdAt <= %@",
                dateRange.lowerBound as NSDate,
                dateRange.upperBound as NSDate
            )
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    public func fetchNotes(withTags tags: [Tag]) async throws -> [Note] {
        // Simplified - would need proper relationship queries
        return try await fetchAll()
    }

    public func fetchFavorites() async throws -> [Note] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    public func fetchArchived() async throws -> [Note] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            fetchRequest.predicate = NSPredicate(format: "isArchived == YES")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "modifiedAt", ascending: false)]

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    // MARK: - Statistics

    public func countNotes() async throws -> Int {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            return try context.count(for: fetchRequest)
        }
    }

    public func countNotes(in dateRange: ClosedRange<Date>) async throws -> Int {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
            fetchRequest.predicate = NSPredicate(
                format: "createdAt >= %@ AND createdAt <= %@",
                dateRange.lowerBound as NSDate,
                dateRange.upperBound as NSDate
            )
            return try context.count(for: fetchRequest)
        }
    }

    // MARK: - Mapping

    private func mapToDomain(entity: NoteEntity) -> Note {
        Note(
            id: entity.value(forKey: "id") as? UUID ?? UUID(),
            content: entity.value(forKey: "content") as? String ?? "",
            createdAt: entity.value(forKey: "createdAt") as? Date ?? Date(),
            modifiedAt: entity.value(forKey: "modifiedAt") as? Date ?? Date(),
            summary: entity.value(forKey: "summary") as? String,
            isFavorite: entity.value(forKey: "isFavorite") as? Bool ?? false,
            isArchived: entity.value(forKey: "isArchived") as? Bool ?? false
        )
    }
}

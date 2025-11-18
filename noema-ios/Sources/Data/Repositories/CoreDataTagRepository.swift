import Foundation
import CoreData

/// Core Data implementation of TagRepositoryProtocol
public actor CoreDataTagRepository: TagRepositoryProtocol {
    // MARK: - Properties

    private let coreDataStack: CoreDataStack

    // MARK: - Initialization

    public init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - CRUD Operations

    public func save(_ tag: Tag) async throws -> Tag {
        let context = coreDataStack.newBackgroundContext()

        return try await context.perform {
            let entity = TagEntity(context: context)
            entity.setValue(tag.id, forKey: "id")
            entity.setValue(tag.name, forKey: "name")
            entity.setValue(tag.color, forKey: "color")
            entity.setValue(tag.createdAt, forKey: "createdAt")

            try self.coreDataStack.saveContext(context)

            return tag
        }
    }

    public func fetch(id: UUID) async throws -> Tag? {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<TagEntity> = NSFetchRequest(entityName: "TagEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            fetchRequest.fetchLimit = 1

            guard let entity = try context.fetch(fetchRequest).first else {
                return nil
            }

            return self.mapToDomain(entity: entity)
        }
    }

    public func fetchAll() async throws -> [Tag] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<TagEntity> = NSFetchRequest(entityName: "TagEntity")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    public func fetchByName(_ name: String) async throws -> Tag? {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<TagEntity> = NSFetchRequest(entityName: "TagEntity")
            fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
            fetchRequest.fetchLimit = 1

            guard let entity = try context.fetch(fetchRequest).first else {
                return nil
            }

            return self.mapToDomain(entity: entity)
        }
    }

    public func search(query: String) async throws -> [Tag] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<TagEntity> = NSFetchRequest(entityName: "TagEntity")
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try context.fetch(fetchRequest)
            return entities.map { self.mapToDomain(entity: $0) }
        }
    }

    public func delete(id: UUID) async throws {
        let context = coreDataStack.newBackgroundContext()

        try await context.perform {
            let fetchRequest: NSFetchRequest<TagEntity> = NSFetchRequest(entityName: "TagEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try context.fetch(fetchRequest).first else {
                throw RepositoryError.notFound
            }

            context.delete(entity)
            try self.coreDataStack.saveContext(context)
        }
    }

    public func update(_ tag: Tag) async throws -> Tag {
        let context = coreDataStack.newBackgroundContext()

        return try await context.perform {
            let fetchRequest: NSFetchRequest<TagEntity> = NSFetchRequest(entityName: "TagEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", tag.id as CVarArg)

            guard let entity = try context.fetch(fetchRequest).first else {
                throw RepositoryError.notFound
            }

            entity.setValue(tag.name, forKey: "name")
            entity.setValue(tag.color, forKey: "color")

            try self.coreDataStack.saveContext(context)

            return tag
        }
    }

    // MARK: - Mapping

    private func mapToDomain(entity: TagEntity) -> Tag {
        Tag(
            id: entity.value(forKey: "id") as? UUID ?? UUID(),
            name: entity.value(forKey: "name") as? String ?? "",
            color: entity.value(forKey: "color") as? String ?? "#0000FF",
            createdAt: entity.value(forKey: "createdAt") as? Date ?? Date()
        )
    }
}

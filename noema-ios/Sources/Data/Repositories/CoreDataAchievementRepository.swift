import Foundation
import CoreData

/// Core Data implementation of AchievementRepositoryProtocol
public actor CoreDataAchievementRepository: AchievementRepositoryProtocol {
    // MARK: - Properties

    private let coreDataStack: CoreDataStack

    // MARK: - Initialization

    public init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - CRUD Operations

    public func save(_ achievement: Achievement) async throws -> Achievement {
        let context = coreDataStack.newBackgroundContext()

        return try await context.perform {
            let fetchRequest: NSFetchRequest<AchievementEntity> = NSFetchRequest(entityName: "AchievementEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", achievement.id)
            fetchRequest.fetchLimit = 1

            let entity: AchievementEntity
            if let existing = try context.fetch(fetchRequest).first {
                entity = existing
            } else {
                entity = AchievementEntity(context: context)
                entity.setValue(achievement.id, forKey: "id")
                entity.setValue(achievement.title, forKey: "title")
                entity.setValue(achievement.achievementDescription, forKey: "achievementDescription")
                entity.setValue(achievement.type.rawValue, forKey: "type")
                entity.setValue(achievement.tier.rawValue, forKey: "tier")
            }

            entity.setValue(achievement.progress, forKey: "progress")
            entity.setValue(achievement.unlockedAt, forKey: "unlockedAt")

            try self.coreDataStack.saveContext(context)

            return achievement
        }
    }

    public func fetch(id: String) async throws -> Achievement? {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<AchievementEntity> = NSFetchRequest(entityName: "AchievementEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            fetchRequest.fetchLimit = 1

            guard let entity = try context.fetch(fetchRequest).first else {
                return nil
            }

            return self.mapToDomain(entity: entity)
        }
    }

    public func fetchAll() async throws -> [Achievement] {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<AchievementEntity> = NSFetchRequest(entityName: "AchievementEntity")
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "unlockedAt", ascending: false),
                NSSortDescriptor(key: "progress", ascending: false)
            ]

            let entities = try context.fetch(fetchRequest)

            // Merge with predefined achievements
            let allAchievements = Achievement.allAchievements
            var result: [Achievement] = []

            for predefined in allAchievements {
                if let saved = entities.first(where: { ($0.value(forKey: "id") as? String) == predefined.id }) {
                    result.append(self.mapToDomain(entity: saved))
                } else {
                    result.append(predefined)
                }
            }

            return result
        }
    }

    public func fetchUnlocked() async throws -> [Achievement] {
        let all = try await fetchAll()
        return all.filter { $0.isUnlocked }
    }

    public func fetchByType(_ type: AchievementType) async throws -> [Achievement] {
        let all = try await fetchAll()
        return all.filter { $0.type == type }
    }

    public func fetchByTier(_ tier: AchievementTier) async throws -> [Achievement] {
        let all = try await fetchAll()
        return all.filter { $0.tier == tier }
    }

    public func updateProgress(id: String, progress: Float) async throws {
        let context = coreDataStack.newBackgroundContext()

        try await context.perform {
            let fetchRequest: NSFetchRequest<AchievementEntity> = NSFetchRequest(entityName: "AchievementEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            fetchRequest.fetchLimit = 1

            let entity: AchievementEntity
            if let existing = try context.fetch(fetchRequest).first {
                entity = existing
            } else {
                // Find predefined achievement
                guard let predefined = Achievement.allAchievements.first(where: { $0.id == id }) else {
                    throw RepositoryError.notFound
                }

                entity = AchievementEntity(context: context)
                entity.setValue(predefined.id, forKey: "id")
                entity.setValue(predefined.title, forKey: "title")
                entity.setValue(predefined.achievementDescription, forKey: "achievementDescription")
                entity.setValue(predefined.type.rawValue, forKey: "type")
                entity.setValue(predefined.tier.rawValue, forKey: "tier")
            }

            entity.setValue(progress, forKey: "progress")

            // Unlock if progress reaches 100%
            if progress >= 1.0 && entity.value(forKey: "unlockedAt") == nil {
                entity.setValue(Date(), forKey: "unlockedAt")
            }

            try self.coreDataStack.saveContext(context)
        }
    }

    public func unlock(id: String) async throws {
        try await updateProgress(id: id, progress: 1.0)
    }

    // MARK: - Mapping

    private func mapToDomain(entity: AchievementEntity) -> Achievement {
        let id = entity.value(forKey: "id") as? String ?? ""
        let typeRaw = entity.value(forKey: "type") as? String ?? "milestone"
        let tierRaw = entity.value(forKey: "tier") as? String ?? "bronze"

        let type = AchievementType(rawValue: typeRaw) ?? .milestone
        let tier = AchievementTier(rawValue: tierRaw) ?? .bronze

        return Achievement(
            id: id,
            title: entity.value(forKey: "title") as? String ?? "",
            achievementDescription: entity.value(forKey: "achievementDescription") as? String ?? "",
            type: type,
            tier: tier,
            progress: entity.value(forKey: "progress") as? Float ?? 0.0,
            unlockedAt: entity.value(forKey: "unlockedAt") as? Date
        )
    }
}

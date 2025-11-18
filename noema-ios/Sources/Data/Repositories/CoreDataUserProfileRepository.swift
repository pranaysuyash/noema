import Foundation
import CoreData

/// Core Data implementation of UserProfileRepositoryProtocol
public actor CoreDataUserProfileRepository: UserProfileRepositoryProtocol {
    // MARK: - Properties

    private let coreDataStack: CoreDataStack

    // MARK: - Initialization

    public init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - CRUD Operations

    public func fetch() async throws -> UserProfile? {
        let context = coreDataStack.mainContext

        return try await context.perform {
            let fetchRequest: NSFetchRequest<UserProfileEntity> = NSFetchRequest(entityName: "UserProfileEntity")
            fetchRequest.fetchLimit = 1

            guard let entity = try context.fetch(fetchRequest).first else {
                // Create default profile if none exists
                return try self.createDefaultProfile()
            }

            return self.mapToDomain(entity: entity)
        }
    }

    public func save(_ profile: UserProfile) async throws -> UserProfile {
        let context = coreDataStack.newBackgroundContext()

        return try await context.perform {
            let fetchRequest: NSFetchRequest<UserProfileEntity> = NSFetchRequest(entityName: "UserProfileEntity")
            fetchRequest.fetchLimit = 1

            let entity: UserProfileEntity
            if let existing = try context.fetch(fetchRequest).first {
                entity = existing
            } else {
                entity = UserProfileEntity(context: context)
                entity.setValue(profile.id, forKey: "id")
                entity.setValue(profile.createdAt, forKey: "createdAt")
            }

            entity.setValue(profile.name, forKey: "name")
            entity.setValue(profile.email, forKey: "email")
            entity.setValue(profile.avatarURL, forKey: "avatarURL")
            entity.setValue(profile.bio, forKey: "bio")
            entity.setValue(profile.level, forKey: "level")
            entity.setValue(profile.experience, forKey: "experience")
            entity.setValue(profile.streak, forKey: "streak")
            entity.setValue(profile.longestStreak, forKey: "longestStreak")
            entity.setValue(profile.totalNotes, forKey: "totalNotes")
            entity.setValue(profile.totalMoodLogs, forKey: "totalMoodLogs")
            entity.setValue(profile.joinedAt, forKey: "joinedAt")
            entity.setValue(profile.lastActiveAt, forKey: "lastActiveAt")

            try self.coreDataStack.saveContext(context)

            return profile
        }
    }

    public func update(_ profile: UserProfile) async throws -> UserProfile {
        return try await save(profile)
    }

    public func delete() async throws {
        let context = coreDataStack.newBackgroundContext()

        try await context.perform {
            let fetchRequest: NSFetchRequest<UserProfileEntity> = NSFetchRequest(entityName: "UserProfileEntity")

            let entities = try context.fetch(fetchRequest)
            entities.forEach { context.delete($0) }

            try self.coreDataStack.saveContext(context)
        }
    }

    // MARK: - Progression

    public func addExperience(_ amount: Int) async throws {
        guard var profile = try await fetch() else {
            throw RepositoryError.notFound
        }

        profile.addExperience(amount)
        _ = try await save(profile)
    }

    public func updateStreak() async throws {
        guard var profile = try await fetch() else {
            throw RepositoryError.notFound
        }

        profile.updateStreak()
        _ = try await save(profile)
    }

    public func incrementNoteCount() async throws {
        guard var profile = try await fetch() else {
            throw RepositoryError.notFound
        }

        profile.totalNotes += 1
        profile.lastActiveAt = Date()
        _ = try await save(profile)
    }

    public func incrementMoodLogCount() async throws {
        guard var profile = try await fetch() else {
            throw RepositoryError.notFound
        }

        profile.totalMoodLogs += 1
        profile.lastActiveAt = Date()
        _ = try await save(profile)
    }

    // MARK: - Private Methods

    private func createDefaultProfile() throws -> UserProfile {
        UserProfile(
            id: UUID(),
            name: nil,
            email: nil,
            avatarURL: nil,
            bio: nil,
            level: 1,
            experience: 0,
            streak: 0,
            longestStreak: 0,
            totalNotes: 0,
            totalMoodLogs: 0,
            joinedAt: Date(),
            lastActiveAt: Date(),
            createdAt: Date()
        )
    }

    // MARK: - Mapping

    private func mapToDomain(entity: UserProfileEntity) -> UserProfile {
        UserProfile(
            id: entity.value(forKey: "id") as? UUID ?? UUID(),
            name: entity.value(forKey: "name") as? String,
            email: entity.value(forKey: "email") as? String,
            avatarURL: entity.value(forKey: "avatarURL") as? String,
            bio: entity.value(forKey: "bio") as? String,
            level: entity.value(forKey: "level") as? Int ?? 1,
            experience: entity.value(forKey: "experience") as? Int ?? 0,
            streak: entity.value(forKey: "streak") as? Int ?? 0,
            longestStreak: entity.value(forKey: "longestStreak") as? Int ?? 0,
            totalNotes: entity.value(forKey: "totalNotes") as? Int ?? 0,
            totalMoodLogs: entity.value(forKey: "totalMoodLogs") as? Int ?? 0,
            joinedAt: entity.value(forKey: "joinedAt") as? Date ?? Date(),
            lastActiveAt: entity.value(forKey: "lastActiveAt") as? Date ?? Date(),
            createdAt: entity.value(forKey: "createdAt") as? Date ?? Date()
        )
    }
}

import Foundation
import CoreData
import CloudKit

// MARK: - SyncService

/// Service for CloudKit synchronization
public final class SyncService {

    // MARK: - Properties

    private let persistenceController: PersistenceController
    private let container: CKContainer
    private var isSyncing = false

    // MARK: - Initialization

    public init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.container = CKContainer(identifier: "iCloud.com.noema.app")
    }

    // MARK: - Singleton

    public static let shared = SyncService()

    // MARK: - Sync Operations

    /// Start sync process
    public func sync() async throws {
        guard !isSyncing else {
            throw SyncServiceError.syncInProgress
        }

        isSyncing = true
        defer { isSyncing = false }

        // Upload local changes
        try await uploadChanges()

        // Download remote changes
        try await downloadChanges()

        // Resolve conflicts
        try await resolveConflicts()
    }

    /// Upload changes to cloud
    public func uploadChanges() async throws {
        try await persistenceController.performInBackground { context in
            // Fetch notes that need syncing
            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "syncStatus == %@", SyncStatus.syncPending.rawValue)

            let notes = try context.fetch(fetchRequest)

            for note in notes {
                guard note.syncStatus == .syncPending else { continue }

                // Create CloudKit record
                let record = try self.createCKRecord(for: note)

                // Save to CloudKit
                try await self.saveRecord(record)

                // Update sync status
                note.syncStatus = .synced
            }

            try context.save()
        }
    }

    /// Download remote changes
    public func downloadChanges() async throws {
        // Fetch changes from CloudKit
        let database = container.privateCloudDatabase

        let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)

        var fetchedRecords: [CKRecord] = []

        operation.recordMatchedBlock = { (_, result) in
            if case .success(let record) = result {
                fetchedRecords.append(record)
            }
        }

        operation.queryResultBlock = { _ in
            // Completion handled in continuation
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            operation.queryResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            database.add(operation)
        }

        // Process fetched records
        try await persistenceController.performInBackground { context in
            for record in fetchedRecords {
                try self.processCloudKitRecord(record, context: context)
            }
            try context.save()
        }
    }

    /// Resolve sync conflicts
    public func resolveConflicts() async throws {
        // Simple conflict resolution: server wins
        try await persistenceController.performInBackground { context in
            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "syncStatus == %@", SyncStatus.syncFailed.rawValue)

            let conflictedNotes = try context.fetch(fetchRequest)

            for note in conflictedNotes {
                // Retry upload
                note.syncStatus = .syncPending
            }

            try context.save()
        }
    }

    // MARK: - CloudKit Operations

    private func createCKRecord(for note: Note) throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: note.id.uuidString)
        let record = CKRecord(recordType: "Note", recordID: recordID)

        // Encrypt content before uploading
        if let encryptedContent = encryptContent(note.content) {
            record["content"] = encryptedContent
        }

        record["createdAt"] = note.createdAt
        record["modifiedAt"] = note.modifiedAt
        record["wordCount"] = note.wordCount as CKRecordValue

        if let summary = note.summary {
            if let encryptedSummary = encryptContent(summary) {
                record["summary"] = encryptedSummary
            }
        }

        return record
    }

    private func saveRecord(_ record: CKRecord) async throws {
        let database = container.privateCloudDatabase

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            database.save(record) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func processCloudKitRecord(_ record: CKRecord, context: NSManagedObjectContext) throws {
        // Check if note exists locally
        guard let noteID = UUID(uuidString: record.recordID.recordName) else {
            return
        }

        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", noteID as CVarArg)
        fetchRequest.fetchLimit = 1

        let existingNote = try context.fetch(fetchRequest).first

        if let note = existingNote {
            // Update existing note
            if let encryptedContent = record["content"] as? String,
               let decryptedContent = decryptContent(encryptedContent) {
                note.content = decryptedContent
            }

            if let modifiedAt = record["modifiedAt"] as? Date {
                note.modifiedAt = modifiedAt
            }

            note.syncStatus = .synced
        } else {
            // Create new note from CloudKit record
            let newNote = Note(context: context)
            newNote.id = noteID

            if let encryptedContent = record["content"] as? String,
               let decryptedContent = decryptContent(encryptedContent) {
                newNote.content = decryptedContent
            }

            if let createdAt = record["createdAt"] as? Date {
                newNote.createdAt = createdAt
            }

            if let modifiedAt = record["modifiedAt"] as? Date {
                newNote.modifiedAt = modifiedAt
            }

            newNote.syncStatus = .synced
        }
    }

    // MARK: - Encryption

    private func encryptContent(_ content: String) -> String? {
        // Placeholder - would use AES-256 encryption
        return content.data(using: .utf8)?.base64EncodedString()
    }

    private func decryptContent(_ encrypted: String) -> String? {
        // Placeholder - would decrypt AES-256
        guard let data = Data(base64Encoded: encrypted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Sync Status

    /// Get sync status
    public func getSyncStatus() async throws -> SyncStatusInfo {
        try await persistenceController.performInBackground { context in
            let pendingCount = try self.persistenceController.count(
                Note.fetchRequest(),
                context: context
            )

            let lastSyncDate = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date

            return SyncStatusInfo(
                status: self.isSyncing ? .syncing : .synced,
                lastSync: lastSyncDate,
                pendingUploadCount: pendingCount,
                pendingDownloadCount: 0
            )
        }
    }

    /// Enable/disable sync for specific note
    public func setSyncEnabled(for note: Note, enabled: Bool) async throws {
        try await persistenceController.performOnViewContext { context in
            note.syncStatus = enabled ? .syncPending : .localOnly
            try context.save()
        }
    }

    // MARK: - Account Status

    /// Check CloudKit availability
    public func checkCloudKitStatus() async throws -> CKAccountStatus {
        try await withCheckedThrowingContinuation { continuation in
            container.accountStatus { status, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: status)
                }
            }
        }
    }
}

// MARK: - Supporting Types

public struct SyncStatusInfo {
    public var status: SyncStatusValue
    public var lastSync: Date?
    public var pendingUploadCount: Int
    public var pendingDownloadCount: Int

    public init(status: SyncStatusValue, lastSync: Date?, pendingUploadCount: Int, pendingDownloadCount: Int) {
        self.status = status
        self.lastSync = lastSync
        self.pendingUploadCount = pendingUploadCount
        self.pendingDownloadCount = pendingDownloadCount
    }
}

public enum SyncStatusValue {
    case synced
    case syncPending
    case syncing
    case syncFailed(Error)
    case offline
}

// MARK: - Errors

public enum SyncServiceError: LocalizedError {
    case syncInProgress
    case cloudKitUnavailable
    case encryptionFailed
    case decryptionFailed

    public var errorDescription: String? {
        switch self {
        case .syncInProgress:
            return "Sync already in progress"
        case .cloudKitUnavailable:
            return "CloudKit is not available"
        case .encryptionFailed:
            return "Failed to encrypt content"
        case .decryptionFailed:
            return "Failed to decrypt content"
        }
    }
}

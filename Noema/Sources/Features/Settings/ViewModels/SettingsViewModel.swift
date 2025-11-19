//
//  SettingsViewModel.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import Combine

@MainActor
public final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var userProfile: UserProfile?
    @Published public var notificationsEnabled: Bool = false
    @Published public var dailyReminderTime: Date = Date()
    @Published public var cloudSyncEnabled: Bool = false
    @Published public var healthKitEnabled: Bool = false
    @Published public var locationEnabled: Bool = false
    @Published public var encryptionEnabled: Bool = true
    @Published public var subscriptionTier: SubscriptionTier = .free
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var showingDeleteConfirmation: Bool = false

    // MARK: - Subscription Tier

    public enum SubscriptionTier: String, CaseIterable {
        case free = "Free"
        case pro = "Pro"
        case premium = "Premium"
    }

    // MARK: - Dependencies

    private let persistenceController: PersistenceController
    private let syncService: SyncService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        persistenceController: PersistenceController = .shared,
        syncService: SyncService = SyncService()
    ) {
        self.persistenceController = persistenceController
        self.syncService = syncService

        loadSettings()
        setupBindings()
    }

    // MARK: - Setup

    private func loadSettings() {
        Task {
            await loadUserProfile()
        }
    }

    private func setupBindings() {
        // Save settings when they change
        Publishers.CombineLatest4($notificationsEnabled, $dailyReminderTime, $cloudSyncEnabled, $healthKitEnabled)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _, _ in
                Task { await self?.saveSettings() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    public func loadUserProfile() async {
        do {
            userProfile = try await persistenceController.performInBackground { context in
                let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
                request.fetchLimit = 1
                return try context.fetch(request).first
            }

            // Load settings from profile
            if let profile = userProfile {
                notificationsEnabled = profile.notificationsEnabled
                dailyReminderTime = profile.dailyReminderTime ?? Date()
                cloudSyncEnabled = profile.cloudSyncEnabled
                healthKitEnabled = profile.healthKitEnabled
                locationEnabled = profile.locationEnabled
                subscriptionTier = SubscriptionTier(rawValue: profile.subscriptionTier ?? "Free") ?? .free
            }
        } catch {
            Logger.ui.error("Failed to load user profile", error: error)
        }
    }

    public func saveSettings() async {
        guard let profile = userProfile else { return }

        do {
            try await persistenceController.performInBackground { context in
                profile.notificationsEnabled = self.notificationsEnabled
                profile.dailyReminderTime = self.dailyReminderTime
                profile.cloudSyncEnabled = self.cloudSyncEnabled
                profile.healthKitEnabled = self.healthKitEnabled
                profile.locationEnabled = self.locationEnabled
                profile.subscriptionTier = self.subscriptionTier.rawValue
            }
            try persistenceController.save()

            Logger.app.info("Settings saved successfully")
        } catch {
            self.error = error
            Logger.ui.error("Failed to save settings", error: error)
        }
    }

    public func exportAllData() async {
        do {
            let data = try persistenceController.exportAllData()
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("noema-export-\(Date().timeIntervalSince1970).json")
            try data.write(to: url)

            Logger.app.info("Data exported to \(url)")
            // TODO: Present share sheet with URL
        } catch {
            self.error = error
            Logger.ui.error("Failed to export data", error: error)
        }
    }

    public func deleteAllData() async {
        showingDeleteConfirmation = false
        isLoading = true
        defer { isLoading = false }

        do {
            try await persistenceController.performInBackground { context in
                // Delete all entities
                let entityNames = ["Note", "EmotionalState", "Entity", "EntityMention", "Relationship",
                                 "Location", "WeatherSnapshot", "Tag", "Folder", "Achievement", "Quest",
                                 "UserProfile", "HealthMetric"]

                for entityName in entityNames {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try context.execute(deleteRequest)
                }
            }

            try persistenceController.save()

            // Clear keychain
            try KeychainManager.shared.clearAll()

            Logger.app.info("All data deleted successfully")
        } catch {
            self.error = error
            Logger.ui.error("Failed to delete all data", error: error)
        }
    }

    public func syncNow() async {
        guard cloudSyncEnabled else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await syncService.sync()
            Logger.app.info("Sync completed successfully")
        } catch {
            self.error = error
            Logger.ui.error("Failed to sync", error: error)
        }
    }
}

import SwiftUI

/// ViewModel for privacy dashboard screen
/// Shows privacy settings, data usage, and control options
@MainActor
public final class PrivacyDashboardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var privacySettings: PrivacySettings
    @Published public var dataUsageStats: DataUsageStats?
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var showingDataDeletionConfirmation: Bool = false
    @Published public var showingExportSheet: Bool = false

    // MARK: - Dependencies

    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Initialization

    public init(userProfileRepository: UserProfileRepositoryProtocol) {
        self.userProfileRepository = userProfileRepository
        self.privacySettings = Self.loadPrivacySettings()
    }

    // MARK: - Public Methods

    public func loadPrivacyDashboard() async {
        isLoading = true
        error = nil

        await loadDataUsageStats()

        isLoading = false
    }

    public func updatePrivacySettings(_ settings: PrivacySettings) {
        privacySettings = settings
        Self.savePrivacySettings(settings)

        // Apply settings immediately
        if settings.cloudSyncEnabled {
            // TODO: Enable cloud sync
        } else {
            // TODO: Disable cloud sync
        }
    }

    public func exportAllData() async throws -> URL {
        // TODO: Implement data export
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("noema-export.json")
        return tempURL
    }

    public func deleteAllData() async throws {
        // TODO: Implement data deletion
        throw PrivacyError.notImplemented
    }

    public func showDataDeletionConfirmation() {
        showingDataDeletionConfirmation = true
    }

    public func showExportSheet() {
        showingExportSheet = true
    }

    // MARK: - Private Methods

    private func loadDataUsageStats() async {
        // TODO: Load actual data usage stats
        dataUsageStats = DataUsageStats(
            totalNotes: 0,
            totalMoods: 0,
            storageUsed: 0,
            cloudSyncEnabled: privacySettings.cloudSyncEnabled,
            lastBackup: nil
        )
    }

    // MARK: - Static Helpers

    private static func loadPrivacySettings() -> PrivacySettings {
        PrivacySettings(
            cloudSyncEnabled: UserDefaults.standard.bool(forKey: "cloudSyncEnabled"),
            analyticsEnabled: UserDefaults.standard.bool(forKey: "analyticsEnabled"),
            crashReportingEnabled: UserDefaults.standard.bool(forKey: "crashReportingEnabled"),
            biometricsEnabled: UserDefaults.standard.bool(forKey: "biometricsEnabled")
        )
    }

    private static func savePrivacySettings(_ settings: PrivacySettings) {
        UserDefaults.standard.set(settings.cloudSyncEnabled, forKey: "cloudSyncEnabled")
        UserDefaults.standard.set(settings.analyticsEnabled, forKey: "analyticsEnabled")
        UserDefaults.standard.set(settings.crashReportingEnabled, forKey: "crashReportingEnabled")
        UserDefaults.standard.set(settings.biometricsEnabled, forKey: "biometricsEnabled")
    }
}

// MARK: - Data Usage Stats

public struct DataUsageStats {
    public let totalNotes: Int
    public let totalMoods: Int
    public let storageUsed: Int64  // bytes
    public let cloudSyncEnabled: Bool
    public let lastBackup: Date?

    public var storageUsedMB: Double {
        Double(storageUsed) / 1_048_576.0
    }
}

// MARK: - Privacy Error

public enum PrivacyError: Error, LocalizedError {
    case notImplemented
    case exportFailed
    case deleteFailed

    public var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "Feature not yet implemented"
        case .exportFailed:
            return "Failed to export data"
        case .deleteFailed:
            return "Failed to delete data"
        }
    }
}

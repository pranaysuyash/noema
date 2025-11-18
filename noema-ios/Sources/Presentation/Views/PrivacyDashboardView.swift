import SwiftUI

/// Privacy dashboard view for data management
public struct PrivacyDashboardView: View {
    @StateObject private var viewModel: PrivacyDashboardViewModel

    public init() {
        _viewModel = StateObject(wrappedValue: PrivacyDashboardViewModel(
            userProfileRepository: CoreDataUserProfileRepository(coreDataStack: .shared)
        ))
    }

    public var body: some View {
        List {
            // Privacy settings
            Section("Privacy Settings") {
                Toggle("Cloud Sync", isOn: $viewModel.privacySettings.cloudSyncEnabled)
                Toggle("Analytics", isOn: $viewModel.privacySettings.analyticsEnabled)
                Toggle("Crash Reporting", isOn: $viewModel.privacySettings.crashReportingEnabled)
                Toggle("Biometric Authentication", isOn: $viewModel.privacySettings.biometricsEnabled)
            }
            .onChange(of: viewModel.privacySettings) { settings in
                viewModel.updatePrivacySettings(settings)
            }

            // Data usage
            Section("Data Usage") {
                if let stats = viewModel.dataUsageStats {
                    HStack {
                        Text("Total Notes")
                        Spacer()
                        Text("\(stats.totalNotes)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Moods")
                        Spacer()
                        Text("\(stats.totalMoods)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Storage Used")
                        Spacer()
                        Text(String(format: "%.1f MB", stats.storageUsedMB))
                            .foregroundColor(.secondary)
                    }

                    if let lastBackup = stats.lastBackup {
                        HStack {
                            Text("Last Backup")
                            Spacer()
                            Text(lastBackup, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // Data management
            Section("Data Management") {
                Button {
                    viewModel.showExportSheet()
                } label: {
                    Label("Export All Data", systemImage: "square.and.arrow.up")
                }

                Button(role: .destructive) {
                    viewModel.showDataDeletionConfirmation()
                } label: {
                    Label("Delete All Data", systemImage: "trash")
                }
            }

            // Privacy info
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Privacy Matters")
                        .font(.headline)

                    Text("noema is built with privacy as a core principle. By default, all AI processing happens on your device. Your notes and emotional data never leave your device unless you explicitly enable cloud sync.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Privacy & Security")
        .task {
            await viewModel.loadPrivacyDashboard()
        }
        .alert("Delete All Data", isPresented: $viewModel.showingDataDeletionConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteAllData()
                }
            }
        } message: {
            Text("This will permanently delete all your notes, moods, and settings. This action cannot be undone.")
        }
        .sheet(isPresented: $viewModel.showingExportSheet) {
            DataExportSheet()
        }
    }
}

// MARK: - Data Export Sheet

struct DataExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: ExportFormat = .json
    @State private var isExporting = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Export Format") {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What will be exported:")
                            .font(.subheadline.bold())

                        ForEach([
                            "All notes and voice recordings",
                            "Mood history and patterns",
                            "Achievements and progress",
                            "Tags and categories",
                            "Settings and preferences"
                        ], id: \.self) { item in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)

                                Text(item)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Export") {
                        isExporting = true
                        // TODO: Implement export
                        dismiss()
                    }
                    .disabled(isExporting)
                }
            }
        }
    }
}

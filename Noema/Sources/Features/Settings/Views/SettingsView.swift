//
//  SettingsView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingPrivacyDashboard = false
    @State private var showingSubscription = false
    @State private var showingExport = false
    @State private var showingThemeSettings = false

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                // Profile section
                Section {
                    ProfileRow(viewModel: viewModel)
                }

                // Preferences
                Section("Preferences") {
                    Toggle("Daily Reminders", isOn: $viewModel.notificationsEnabled)

                    if viewModel.notificationsEnabled {
                        DatePicker("Reminder Time", selection: $viewModel.dailyReminderTime, displayedComponents: .hourAndMinute)
                    }

                    Button {
                        showingThemeSettings = true
                    } label: {
                        HStack {
                            Label("Theme", systemImage: "paintbrush")
                            Spacer()
                            Text("Auto")
                                .foregroundColor(.noemaTextSecondary)
                        }
                    }
                }

                // Data & Sync
                Section("Data & Sync") {
                    Toggle("iCloud Sync", isOn: $viewModel.cloudSyncEnabled)
                    Toggle("HealthKit Integration", isOn: $viewModel.healthKitEnabled)
                    Toggle("Location Services", isOn: $viewModel.locationEnabled)

                    Button {
                        Task {
                            await viewModel.syncNow()
                        }
                    } label: {
                        HStack {
                            Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(!viewModel.cloudSyncEnabled)
                }

                // Privacy & Security
                Section("Privacy & Security") {
                    NavigationLink {
                        PrivacyDashboardView()
                    } label: {
                        Label("Privacy Dashboard", systemImage: "hand.raised")
                    }

                    Toggle("Encryption", isOn: $viewModel.encryptionEnabled)
                        .disabled(true) // Always on
                }

                // Subscription
                Section("Subscription") {
                    Button {
                        showingSubscription = true
                    } label: {
                        HStack {
                            Label("Manage Subscription", systemImage: "star.circle")
                            Spacer()
                            Text(viewModel.subscriptionTier.rawValue)
                                .foregroundColor(.noemaTextSecondary)
                        }
                    }
                }

                // Data Management
                Section("Data Management") {
                    Button {
                        showingExport = true
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        viewModel.showingDeleteConfirmation = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash")
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.noemaTextSecondary)
                    }

                    Link(destination: URL(string: "https://noema.app/privacy")!) {
                        Label("Privacy Policy", systemImage: "doc.text")
                    }

                    Link(destination: URL(string: "https://noema.app/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
            .sheet(isPresented: $showingExport) {
                ExportDataView()
            }
            .sheet(isPresented: $showingThemeSettings) {
                ThemeSettingsView()
            }
            .alert("Delete All Data?", isPresented: $viewModel.showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteAllData()
                    }
                }
            } message: {
                Text("This action cannot be undone. All your notes, emotions, and progress will be permanently deleted.")
            }
            .errorAlert(error: $viewModel.error)
        }
    }
}

private struct ProfileRow: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.noemaPrimary.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Text("👤")
                        .font(.largeTitle)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("User")
                    .font(.headline)
                    .foregroundColor(.noemaTextPrimary)

                Text(viewModel.subscriptionTier.rawValue + " Plan")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SettingsView()
}

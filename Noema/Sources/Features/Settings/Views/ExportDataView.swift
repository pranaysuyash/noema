//
//  ExportDataView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct ExportDataView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: ExportFormat = .json
    @State private var includeAudio = true
    @State private var includeEmotions = true
    @State private var includeEntities = true
    @State private var isExporting = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Info card
                    InfoCard()

                    // Export format
                    FormatSelectionSection(selectedFormat: $selectedFormat)

                    // Data options
                    DataOptionsSection(
                        includeAudio: $includeAudio,
                        includeEmotions: $includeEmotions,
                        includeEntities: $includeEntities
                    )

                    // Export button
                    Button {
                        isExporting = true
                        Task {
                            await viewModel.exportAllData()
                            isExporting = false
                        }
                    } label: {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "square.and.arrow.up")
                            }

                            Text(isExporting ? "Exporting..." : "Export Data")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.noemaPrimary)
                        .cornerRadius(12)
                    }
                    .disabled(isExporting)

                    // GDPR info
                    GDPRInfoSection()
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .errorAlert(error: $viewModel.error)
        }
    }

    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
        case pdf = "PDF Report"
        case markdown = "Markdown"
    }
}

private struct InfoCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Data Portability")
                    .font(.headline)
                    .foregroundColor(.noemaTextPrimary)

                Text("Export your data in a portable format. This is your right under GDPR and CCPA.")
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct FormatSelectionSection: View {
    @Binding var selectedFormat: ExportDataView.ExportFormat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Format")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            ForEach(ExportDataView.ExportFormat.allCases, id: \.self) { format in
                FormatOption(
                    format: format,
                    isSelected: selectedFormat == format
                ) {
                    selectedFormat = format
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct FormatOption: View {
    let format: ExportDataView.ExportFormat
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.noemaTextPrimary)

                    Text(formatDescription)
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .noemaPrimary : .gray)
            }
            .padding()
            .background(isSelected ? Color.noemaPrimary.opacity(0.1) : Color.noemaCardBackground)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var formatDescription: String {
        switch format {
        case .json:
            return "Machine-readable format, best for importing elsewhere"
        case .csv:
            return "Spreadsheet format, open in Excel or Numbers"
        case .pdf:
            return "Human-readable report with charts and insights"
        case .markdown:
            return "Plain text format, great for archiving"
        }
    }
}

private struct DataOptionsSection: View {
    @Binding var includeAudio: Bool
    @Binding var includeEmotions: Bool
    @Binding var includeEntities: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Include in Export")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            Toggle("Audio Recordings", isOn: $includeAudio)
            Toggle("Emotion Data", isOn: $includeEmotions)
            Toggle("Entities & Relationships", isOn: $includeEntities)
        }
        .padding()
        .cardStyle()
    }
}

private struct GDPRInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Rights")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(icon: "checkmark.circle", text: "Your data is yours. Export it anytime, for free.")
                InfoRow(icon: "checkmark.circle", text: "No limits on export frequency.")
                InfoRow(icon: "checkmark.circle", text: "Data is exported in standard formats.")
                InfoRow(icon: "checkmark.circle", text: "Compliant with GDPR, CCPA, and other privacy laws.")
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.caption)

            Text(text)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
    }
}

#Preview {
    ExportDataView()
}

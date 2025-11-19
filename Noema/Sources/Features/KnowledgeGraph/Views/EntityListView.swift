//
//  EntityListView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct EntityListView: View {
    @StateObject private var viewModel = KnowledgeGraphViewModel()
    @State private var selectedEntity: Entity?
    @State private var searchText = ""
    @State private var selectedType: EntityType?
    @State private var sortOption: SortOption = .importance

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding()

                // Filter and sort
                HStack {
                    // Type filter
                    Menu {
                        Button("All Types") {
                            selectedType = nil
                        }

                        ForEach(EntityType.allCases, id: \.self) { type in
                            Button(type.displayName) {
                                selectedType = type
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(selectedType?.displayName ?? "All Types")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.noemaCardBackground)
                        .cornerRadius(20)
                    }

                    Spacer()

                    // Sort menu
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.title3)
                            .foregroundColor(.noemaPrimary)
                    }
                }
                .padding(.horizontal)

                // Entity list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredEntities) { entity in
                            EntityRow(entity: entity)
                                .onTapGesture {
                                    selectedEntity = entity
                                }
                                .animateOnAppear()
                        }
                    }
                    .padding()
                }
            }
            .background(Color.noemaBackground)
            .navigationTitle("Entities")
            .sheet(item: $selectedEntity) { entity in
                EntityDetailView(entity: entity)
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .task {
                await viewModel.loadGraph()
            }
        }
    }

    private var filteredEntities: [Entity] {
        var entities = viewModel.entities

        // Filter by search
        if !searchText.isEmpty {
            entities = entities.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        // Filter by type
        if let type = selectedType {
            entities = entities.filter { $0.type == type }
        }

        // Sort
        switch sortOption {
        case .importance:
            entities.sort { $0.importanceScore > $1.importanceScore }
        case .mentions:
            entities.sort { $0.totalMentions > $1.totalMentions }
        case .recent:
            entities.sort { $0.lastMentioned > $1.lastMentioned }
        case .alphabetical:
            entities.sort { $0.name < $1.name }
        }

        return entities
    }

    enum SortOption: String, CaseIterable {
        case importance = "Importance"
        case mentions = "Mentions"
        case recent = "Recently Mentioned"
        case alphabetical = "A-Z"
    }
}

// MARK: - Supporting Views

private struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.noemaTextSecondary)

            TextField("Search entities...", text: $text)
                .foregroundColor(.noemaTextPrimary)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.noemaTextSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.noemaCardBackground)
        .cornerRadius(12)
    }
}

private struct EntityRow: View {
    @ObservedObject var entity: Entity

    var body: some View {
        HStack(spacing: 12) {
            // Entity icon
            Circle()
                .fill(Color.forEmotion(valence: entity.averageValence, arousal: entity.averageArousal))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(entity.type.icon)
                        .font(.title3)
                )

            // Entity info
            VStack(alignment: .leading, spacing: 4) {
                Text(entity.name)
                    .font(.headline)
                    .foregroundColor(.noemaTextPrimary)

                HStack(spacing: 8) {
                    Text(entity.type.displayName)
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)

                    Circle()
                        .fill(Color.noemaTextSecondary)
                        .frame(width: 3, height: 3)

                    Text("\(entity.totalMentions) mentions")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }

                // Emotional indicator
                HStack(spacing: 12) {
                    EmotionIndicator(
                        label: "Valence",
                        value: entity.averageValence,
                        color: entity.averageValence > 0 ? .joyColor : .sadnessColor
                    )

                    EmotionIndicator(
                        label: "Energy",
                        value: entity.averageEnergy,
                        color: .xpGold
                    )
                }
            }

            Spacer()

            // Importance badge
            VStack(spacing: 4) {
                Text("\(Int(entity.importanceScore * 100))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.noemaPrimary)

                Text("Score")
                    .font(.caption2)
                    .foregroundColor(.noemaTextSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .padding()
        .cardStyle()
    }
}

private struct EmotionIndicator: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text(label)
                .font(.caption2)
                .foregroundColor(.noemaTextSecondary)

            Text("\(value > 0 ? "+" : "")\(Int(value * 100))")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.noemaTextPrimary)
        }
    }
}

#Preview {
    EntityListView()
}

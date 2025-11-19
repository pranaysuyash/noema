//
//  RelationshipMapView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct RelationshipMapView: View {
    @StateObject private var viewModel = KnowledgeGraphViewModel()
    @State private var selectedRelationship: Relationship?
    @State private var centerEntity: Entity?

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.noemaBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Center entity selector
                    if !viewModel.entities.isEmpty {
                        EntitySelector(
                            entities: viewModel.entities,
                            selectedEntity: $centerEntity
                        )
                    }

                    // Relationship visualization
                    if let entity = centerEntity {
                        RelationshipRadialView(
                            centerEntity: entity,
                            relationships: viewModel.relationships.filter {
                                $0.sourceEntity?.id == entity.id || $0.targetEntity?.id == entity.id
                            },
                            onRelationshipTap: { relationship in
                                selectedRelationship = relationship
                            }
                        )
                    } else {
                        EmptyRelationshipView()
                    }

                    // Relationship list
                    if let entity = centerEntity {
                        RelationshipsList(
                            entity: entity,
                            relationships: viewModel.relationships.filter {
                                $0.sourceEntity?.id == entity.id || $0.targetEntity?.id == entity.id
                            }
                        )
                    }
                }
            }
            .navigationTitle("Relationships")
            .sheet(item: $selectedRelationship) { relationship in
                RelationshipDetailSheet(relationship: relationship)
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .task {
                await viewModel.loadGraph()
                if let first = viewModel.entities.first {
                    centerEntity = first
                }
            }
        }
    }
}

// MARK: - Supporting Views

private struct EntitySelector: View {
    let entities: [Entity]
    @Binding var selectedEntity: Entity?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Focus Entity")
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(entities.sorted { $0.importanceScore > $1.importanceScore }.prefix(20)) { entity in
                        EntityChip(
                            entity: entity,
                            isSelected: selectedEntity?.id == entity.id
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedEntity = entity
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color.noemaCardBackground.opacity(0.5))
    }
}

private struct EntityChip: View {
    @ObservedObject var entity: Entity
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text(entity.type.icon)
                .font(.caption)

            Text(entity.name)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.noemaPrimary : Color.noemaCardBackground)
        .foregroundColor(isSelected ? .white : .noemaTextPrimary)
        .cornerRadius(16)
    }
}

private struct RelationshipRadialView: View {
    @ObservedObject var centerEntity: Entity
    let relationships: [Relationship]
    let onRelationshipTap: (Relationship) -> Void

    private var connectedEntities: [(Entity, Relationship)] {
        relationships.compactMap { rel in
            if rel.sourceEntity?.id == centerEntity.id, let target = rel.targetEntity {
                return (target, rel)
            } else if rel.targetEntity?.id == centerEntity.id, let source = rel.sourceEntity {
                return (source, rel)
            }
            return nil
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size * 0.35

            ZStack {
                // Center entity
                VStack(spacing: 4) {
                    Circle()
                        .fill(Color.forEmotion(valence: centerEntity.averageValence, arousal: centerEntity.averageArousal))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(centerEntity.type.icon)
                                .font(.largeTitle)
                        )

                    Text(centerEntity.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.noemaTextPrimary)
                        .lineLimit(1)
                        .frame(width: 100)
                }
                .position(center)

                // Connected entities and relationships
                ForEach(Array(connectedEntities.enumerated()), id: \.element.0.id) { index, element in
                    let (entity, relationship) = element
                    let angle = 2 * .pi * Double(index) / Double(max(connectedEntities.count, 1))
                    let position = CGPoint(
                        x: center.x + CGFloat(cos(angle)) * radius,
                        y: center.y + CGFloat(sin(angle)) * radius
                    )

                    // Relationship line
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: position)
                    }
                    .stroke(
                        Color.noemaPrimary.opacity(relationship.strength),
                        style: StrokeStyle(
                            lineWidth: CGFloat(relationship.strength) * 4,
                            dash: relationship.type == .cooccurrence ? [5, 3] : []
                        )
                    )

                    // Connected entity node
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color.forEmotion(valence: entity.averageValence, arousal: entity.averageArousal))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(entity.type.icon)
                                    .font(.title3)
                            )

                        Text(entity.name)
                            .font(.caption2)
                            .foregroundColor(.noemaTextPrimary)
                            .lineLimit(1)
                            .frame(width: 70)
                    }
                    .position(position)
                    .onTapGesture {
                        onRelationshipTap(relationship)
                    }
                }
            }
        }
        .frame(height: 400)
        .padding()
    }
}

private struct EmptyRelationshipView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "link.circle")
                .font(.system(size: 60))
                .foregroundColor(.noemaTextSecondary)

            Text("No Entity Selected")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.noemaTextPrimary)

            Text("Select an entity to view its relationships")
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct RelationshipsList: View {
    @ObservedObject var entity: Entity
    let relationships: [Relationship]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Relationships")
                    .font(.headline)
                    .foregroundColor(.noemaTextPrimary)

                Spacer()

                Text("\(relationships.count)")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
            }
            .padding(.horizontal)

            if relationships.isEmpty {
                Text("No relationships found")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(relationships.sorted { $0.strength > $1.strength }) { relationship in
                            RelationshipRow(centerEntity: entity, relationship: relationship)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxHeight: 200)
    }
}

private struct RelationshipRow: View {
    @ObservedObject var centerEntity: Entity
    @ObservedObject var relationship: Relationship

    private var otherEntity: Entity? {
        if relationship.sourceEntity?.id == centerEntity.id {
            return relationship.targetEntity
        } else {
            return relationship.sourceEntity
        }
    }

    var body: some View {
        if let other = otherEntity {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.forEmotion(valence: other.averageValence, arousal: other.averageArousal))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text(other.type.icon)
                            .font(.caption)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(other.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.noemaTextPrimary)

                    HStack(spacing: 8) {
                        Text(relationship.type.displayName)
                            .font(.caption2)
                            .foregroundColor(.noemaTextSecondary)

                        Circle()
                            .fill(Color.noemaTextSecondary)
                            .frame(width: 3, height: 3)

                        Text("\(relationship.cooccurrenceCount) co-occurrences")
                            .font(.caption2)
                            .foregroundColor(.noemaTextSecondary)
                    }
                }

                Spacer()

                // Strength indicator
                VStack(spacing: 2) {
                    Text("\(Int(relationship.strength * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.noemaPrimary)

                    Text("Strength")
                        .font(.caption2)
                        .foregroundColor(.noemaTextSecondary)
                }
            }
            .padding()
            .background(Color.noemaCardBackground)
            .cornerRadius(10)
        }
    }
}

private struct RelationshipDetailSheet: View {
    @ObservedObject var relationship: Relationship
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Entities involved
                    HStack(spacing: 12) {
                        if let source = relationship.sourceEntity {
                            EntityPill(entity: source)
                        }

                        Image(systemName: "arrow.right")
                            .foregroundColor(.noemaTextSecondary)

                        if let target = relationship.targetEntity {
                            EntityPill(entity: target)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    // Metrics
                    VStack(spacing: 16) {
                        MetricRow(
                            label: "Relationship Type",
                            value: relationship.type.displayName
                        )

                        MetricRow(
                            label: "Strength",
                            value: "\(Int(relationship.strength * 100))%"
                        )

                        MetricRow(
                            label: "Co-occurrences",
                            value: "\(relationship.cooccurrenceCount)"
                        )

                        if relationship.emotionalTone != 0 {
                            MetricRow(
                                label: "Emotional Tone",
                                value: relationship.emotionalTone > 0 ? "Positive (+\(Int(relationship.emotionalTone * 100)))" : "Negative (\(Int(relationship.emotionalTone * 100)))"
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Relationship Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct EntityPill: View {
    @ObservedObject var entity: Entity

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.forEmotion(valence: entity.averageValence, arousal: entity.averageArousal))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(entity.type.icon)
                        .font(.title3)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(entity.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.noemaTextPrimary)

                Text(entity.type.displayName)
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.noemaTextPrimary)
        }
        .padding()
        .background(Color.noemaCardBackground)
        .cornerRadius(10)
    }
}

extension RelationshipType {
    var displayName: String {
        switch self {
        case .cooccurrence: return "Co-occurrence"
        case .semantic: return "Semantic"
        case .temporal: return "Temporal"
        case .causal: return "Causal"
        case .emotional: return "Emotional"
        }
    }
}

#Preview {
    RelationshipMapView()
}

//
//  KnowledgeGraphView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct KnowledgeGraphView: View {
    @StateObject private var viewModel = KnowledgeGraphViewModel()
    @State private var selectedEntity: Entity?
    @State private var zoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.noemaBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Controls Bar
                    ControlsBar(
                        viewModel: viewModel,
                        zoomScale: $zoomScale,
                        offset: $offset
                    )

                    // Graph Canvas
                    GraphCanvas(
                        entities: viewModel.entities,
                        relationships: viewModel.relationships,
                        selectedEntity: $selectedEntity,
                        zoomScale: $zoomScale,
                        offset: $offset
                    )
                }

                // Selected Entity Panel
                if let entity = selectedEntity {
                    VStack {
                        Spacer()
                        EntityQuickView(entity: entity, onDismiss: {
                            selectedEntity = nil
                        })
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("Knowledge Graph")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.layoutStyle = .force
                        } label: {
                            Label("Force-Directed", systemImage: viewModel.layoutStyle == .force ? "checkmark" : "")
                        }

                        Button {
                            viewModel.layoutStyle = .circular
                        } label: {
                            Label("Circular", systemImage: viewModel.layoutStyle == .circular ? "checkmark" : "")
                        }

                        Button {
                            viewModel.layoutStyle = .hierarchical
                        } label: {
                            Label("Hierarchical", systemImage: viewModel.layoutStyle == .hierarchical ? "checkmark" : "")
                        }

                        Divider()

                        Button {
                            Task {
                                await viewModel.exportGraph()
                            }
                        } label: {
                            Label("Export Graph", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .sheet(item: $selectedEntity) { entity in
                EntityDetailView(entity: entity)
            }
            .task {
                await viewModel.loadGraph()
            }
        }
    }
}

// MARK: - Supporting Views

private struct ControlsBar: View {
    @ObservedObject var viewModel: KnowledgeGraphViewModel
    @Binding var zoomScale: CGFloat
    @Binding var offset: CGSize

    var body: some View {
        HStack(spacing: 16) {
            // Filter by entity type
            Menu {
                Button("All") {
                    viewModel.filterEntityType = nil
                }

                ForEach(EntityType.allCases, id: \.self) { type in
                    Button(type.displayName) {
                        viewModel.filterEntityType = type
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(viewModel.filterEntityType?.displayName ?? "All")
                        .font(.subheadline)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.noemaCardBackground)
                .cornerRadius(20)
            }

            Spacer()

            // Zoom controls
            HStack(spacing: 8) {
                Button {
                    withAnimation {
                        zoomScale = max(0.5, zoomScale - 0.2)
                    }
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.title3)
                }

                Button {
                    withAnimation {
                        zoomScale = 1.0
                        offset = .zero
                    }
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.title3)
                }

                Button {
                    withAnimation {
                        zoomScale = min(3.0, zoomScale + 0.2)
                    }
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.title3)
                }
            }
            .foregroundColor(.noemaPrimary)
        }
        .padding()
        .background(Color.noemaBackground)
    }
}

private struct GraphCanvas: View {
    let entities: [Entity]
    let relationships: [Relationship]
    @Binding var selectedEntity: Entity?
    @Binding var zoomScale: CGFloat
    @Binding var offset: CGSize
    @GestureState private var magnification: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Relationships (edges)
                ForEach(relationships, id: \.id) { relationship in
                    if let source = entities.first(where: { $0.id == relationship.sourceEntity?.id }),
                       let target = entities.first(where: { $0.id == relationship.targetEntity?.id }) {
                        RelationshipEdge(
                            from: nodePosition(for: source, in: geometry.size),
                            to: nodePosition(for: target, in: geometry.size),
                            strength: relationship.strength
                        )
                    }
                }

                // Entities (nodes)
                ForEach(entities) { entity in
                    EntityNode(
                        entity: entity,
                        isSelected: selectedEntity?.id == entity.id
                    )
                    .position(nodePosition(for: entity, in: geometry.size))
                    .onTapGesture {
                        withAnimation {
                            selectedEntity = entity
                        }
                    }
                }
            }
            .scaleEffect(zoomScale * magnification)
            .offset(
                x: offset.width + dragOffset.width,
                y: offset.height + dragOffset.height
            )
            .gesture(
                MagnificationGesture()
                    .updating($magnification) { value, state, _ in
                        state = value
                    }
                    .onEnded { value in
                        zoomScale *= value
                    }
            )
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        offset.width += value.translation.width
                        offset.height += value.translation.height
                    }
            )
        }
        .background(Color.noemaCardBackground.opacity(0.3))
    }

    private func nodePosition(for entity: Entity, in size: CGSize) -> CGPoint {
        // Simple circular layout - in production, use force-directed or other algorithms
        let index = entities.firstIndex(where: { $0.id == entity.id }) ?? 0
        let angle = 2 * .pi * Double(index) / Double(max(entities.count, 1))
        let radius = min(size.width, size.height) * 0.3

        return CGPoint(
            x: size.width / 2 + CGFloat(cos(angle)) * radius,
            y: size.height / 2 + CGFloat(sin(angle)) * radius
        )
    }
}

private struct EntityNode: View {
    @ObservedObject var entity: Entity
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(
                        Color.forEmotion(
                            valence: entity.averageValence,
                            arousal: entity.averageArousal
                        )
                    )
                    .frame(width: nodeSize, height: nodeSize)
                    .shadow(
                        color: isSelected ? Color.noemaPrimary : Color.clear,
                        radius: isSelected ? 10 : 0
                    )

                Text(entity.type.icon)
                    .font(.title3)
            }

            Text(entity.name)
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(.noemaTextPrimary)
                .lineLimit(1)
                .frame(width: 80)
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(), value: isSelected)
    }

    private var nodeSize: CGFloat {
        let baseSize: CGFloat = 50
        let importance = entity.importanceScore
        return baseSize + CGFloat(importance) * 20
    }
}

private struct RelationshipEdge: View {
    let from: CGPoint
    let to: CGPoint
    let strength: Double

    var body: some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(
            Color.noemaPrimary.opacity(strength),
            lineWidth: CGFloat(strength) * 3
        )
    }
}

private struct EntityQuickView: View {
    @ObservedObject var entity: Entity
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.forEmotion(valence: entity.averageValence, arousal: entity.averageArousal))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(entity.type.icon)
                            .font(.title3)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(entity.name)
                        .font(.headline)
                        .foregroundColor(.noemaTextPrimary)

                    Text(entity.type.displayName)
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.noemaTextSecondary)
                }
            }

            HStack(spacing: 16) {
                QuickStat(label: "Mentions", value: "\(entity.totalMentions)")
                QuickStat(label: "Importance", value: "\(Int(entity.importanceScore * 100))%")
                QuickStat(label: "Valence", value: entity.averageValence > 0 ? "+\(Int(entity.averageValence * 100))" : "\(Int(entity.averageValence * 100))")
            }
        }
        .padding()
        .background(Color.noemaCardBackground)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
}

private struct QuickStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.noemaTextPrimary)

            Text(label)
                .font(.caption2)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Supporting Extensions

extension EntityType {
    var icon: String {
        switch self {
        case .person: return "👤"
        case .place: return "📍"
        case .organization: return "🏢"
        case .event: return "📅"
        case .topic: return "💡"
        case .project: return "📊"
        case .goal: return "🎯"
        case .custom: return "⭐"
        }
    }

    static var allCases: [EntityType] {
        [.person, .place, .organization, .event, .topic, .project, .goal, .custom]
    }
}

#Preview {
    KnowledgeGraphView()
}

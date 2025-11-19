//
//  KnowledgeGraphViewModel.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import Combine

@MainActor
public final class KnowledgeGraphViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var graph: KnowledgeGraph?
    @Published public var selectedEntity: Entity?
    @Published public var highlightedEntities: Set<UUID> = []
    @Published public var filterByType: EntityType?
    @Published public var isLoading: Bool = false
    @Published public var error: Error?

    // MARK: - Dependencies

    private let graphService: KnowledgeGraphService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(graphService: KnowledgeGraphService = KnowledgeGraphService()) {
        self.graphService = graphService

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        $filterByType
            .sink { [weak self] _ in
                Task { await self?.refreshGraph() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    public func loadGraph() async {
        isLoading = true
        defer { isLoading = false }

        do {
            graph = try await graphService.buildGraph()
        } catch {
            self.error = error
            Logger.ui.error("Failed to load knowledge graph", error: error)
        }
    }

    public func selectEntity(_ entity: Entity) async {
        selectedEntity = entity

        do {
            // Highlight related entities
            let related = try await graphService.getRelatedEntities(for: entity, maxDistance: 2)
            highlightedEntities = Set(related.map { $0.id })
        } catch {
            Logger.ui.error("Failed to get related entities", error: error)
        }
    }

    public func findPath(from: Entity, to: Entity) async -> [Entity]? {
        do {
            return try await graphService.findPath(from: from, to: to)
        } catch {
            Logger.ui.error("Failed to find path", error: error)
            return nil
        }
    }

    public func exportGraph(format: GraphExportFormat) async {
        do {
            let data = try await graphService.exportGraph(format: format)
            // Save to files
            let filename = "knowledge-graph.\(format.fileExtension)"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try data.write(to: url)

            Logger.ui.info("Graph exported to \(url)")
        } catch {
            self.error = error
            Logger.ui.error("Failed to export graph", error: error)
        }
    }

    // MARK: - Private Methods

    private func refreshGraph() async {
        guard let filterType = filterByType else {
            await loadGraph()
            return
        }

        // Load filtered subgraph
        isLoading = true
        defer { isLoading = false }

        // Placeholder for filtered graph loading
        // TODO: Implement filtered graph loading
    }
}

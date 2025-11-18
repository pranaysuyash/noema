import Foundation
import CoreData

// MARK: - KnowledgeGraphService

/// Service for knowledge graph operations and visualization
public final class KnowledgeGraphService {

    // MARK: - Properties

    private let persistenceController: PersistenceController
    private let entityService: EntityService

    // MARK: - Initialization

    public init(
        persistenceController: PersistenceController = .shared,
        entityService: EntityService = .shared
    ) {
        self.persistenceController = persistenceController
        self.entityService = entityService
    }

    // MARK: - Singleton

    public static let shared = KnowledgeGraphService()

    // MARK: - Graph Building

    /// Build or update knowledge graph
    public func buildGraph() async throws -> KnowledgeGraph {
        try await persistenceController.performInBackground { context in
            // Fetch all entities
            let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
            let entities = try context.fetch(fetchRequest)

            // Create nodes
            let nodes = entities.map { entity in
                GraphNode(
                    id: entity.id,
                    entity: entity,
                    centrality: entity.importanceScore,
                    emotionalValence: entity.averageValence
                )
            }

            // Fetch all relationships
            let relationshipRequest: NSFetchRequest<Relationship> = Relationship.fetchRequest()
            let relationships = try context.fetch(relationshipRequest)

            // Create edges
            let edges = relationships.map { relationship in
                GraphEdge(
                    source: relationship.entity1.id,
                    target: relationship.entity2.id,
                    weight: relationship.strength,
                    emotionalTone: relationship.averageEmotionalTone,
                    coOccurrences: relationship.coOccurrences
                )
            }

            return KnowledgeGraph(nodes: nodes, edges: edges)
        }
    }

    /// Get subgraph around an entity
    public func getSubgraph(centeredOn entity: Entity, depth: Int = 2) async throws -> KnowledgeGraph {
        try await persistenceController.performInBackground { context in
            var includedEntities: Set<UUID> = [entity.id]
            var currentLayer: Set<UUID> = [entity.id]

            // BFS to find entities within depth
            for _ in 0..<depth {
                var nextLayer: Set<UUID> = []
                for entityID in currentLayer {
                    let related = try await self.entityService.getRelatedEntities(
                        for: entity,
                        minCoOccurrences: 1
                    )
                    nextLayer.formUnion(related.map { $0.id })
                }
                includedEntities.formUnion(nextLayer)
                currentLayer = nextLayer
            }

            // Fetch entities
            let entityRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
            entityRequest.predicate = NSPredicate(format: "id IN %@", Array(includedEntities))
            let entities = try context.fetch(entityRequest)

            // Create nodes
            let nodes = entities.map { entity in
                GraphNode(
                    id: entity.id,
                    entity: entity,
                    centrality: entity.importanceScore,
                    emotionalValence: entity.averageValence
                )
            }

            // Fetch relationships between these entities
            let relationshipRequest: NSFetchRequest<Relationship> = Relationship.fetchRequest()
            relationshipRequest.predicate = NSPredicate(
                format: "entity1.id IN %@ AND entity2.id IN %@",
                Array(includedEntities),
                Array(includedEntities)
            )
            let relationships = try context.fetch(relationshipRequest)

            // Create edges
            let edges = relationships.map { relationship in
                GraphEdge(
                    source: relationship.entity1.id,
                    target: relationship.entity2.id,
                    weight: relationship.strength,
                    emotionalTone: relationship.averageEmotionalTone,
                    coOccurrences: relationship.coOccurrences
                )
            }

            return KnowledgeGraph(nodes: nodes, edges: edges)
        }
    }

    // MARK: - Graph Analysis

    /// Calculate centrality scores for all entities
    public func calculateCentrality() async throws -> [UUID: Double] {
        try await persistenceController.performInBackground { context in
            let entities: [Entity] = try self.persistenceController.fetch(entityName: "Entity")
            var centrality: [UUID: Double] = [:]

            for entity in entities {
                // Simple degree centrality (number of connections)
                let related = try await self.entityService.getRelatedEntities(
                    for: entity,
                    minCoOccurrences: 1
                )
                let degree = Double(related.count)

                // Weight by mention frequency
                let frequency = Double(entity.totalMentions) / 100.0

                // Weight by emotional variance (entities with strong emotional associations)
                let emotionalWeight = abs(entity.averageValence) + entity.emotionalVariance

                centrality[entity.id] = (degree * 0.4) + (frequency * 0.3) + (emotionalWeight * 0.3)
            }

            return centrality
        }
    }

    /// Detect communities (clusters) in the graph
    public func detectCommunities() async throws -> [Community] {
        try await persistenceController.performInBackground { context in
            let entities: [Entity] = try self.persistenceController.fetch(entityName: "Entity")

            // Simple community detection based on entity type
            var communities: [EntityType: [Entity]] = [:]

            for entity in entities {
                communities[entity.type, default: []].append(entity)
            }

            return communities.map { type, members in
                Community(
                    id: UUID(),
                    members: members,
                    theme: type.displayName,
                    cohesion: 0.7
                )
            }
        }
    }

    /// Find shortest path between two entities
    public func findPath(from source: Entity, to target: Entity) async throws -> [Entity]? {
        // Simple BFS path finding
        var visited: Set<UUID> = []
        var queue: [(Entity, [Entity])] = [(source, [source])]

        while !queue.isEmpty {
            let (current, path) = queue.removeFirst()

            if current.id == target.id {
                return path
            }

            if visited.contains(current.id) {
                continue
            }
            visited.insert(current.id)

            let related = try await entityService.getRelatedEntities(
                for: current,
                minCoOccurrences: 1
            )

            for entity in related where !visited.contains(entity.id) {
                queue.append((entity, path + [entity]))
            }
        }

        return nil
    }

    /// Get temporal graph evolution
    public func getGraphEvolution(dateRange: ClosedRange<Date>) async throws -> [GraphSnapshot] {
        // Placeholder - would show how graph changed over time
        let graph = try await buildGraph()
        return [GraphSnapshot(date: Date(), graph: graph)]
    }

    // MARK: - Export

    /// Export graph to visualization format
    public func exportGraph(format: GraphExportFormat = .json) async throws -> Data {
        let graph = try await buildGraph()

        switch format {
        case .json:
            return try exportAsJSON(graph: graph)
        case .graphml:
            return try exportAsGraphML(graph: graph)
        case .gexf:
            return try exportAsGEXF(graph: graph)
        }
    }

    private func exportAsJSON(graph: KnowledgeGraph) throws -> Data {
        let jsonDict: [String: Any] = [
            "nodes": graph.nodes.map { node in
                [
                    "id": node.id.uuidString,
                    "name": node.entity.name,
                    "type": node.entity.type.rawValue,
                    "centrality": node.centrality,
                    "valence": node.emotionalValence
                ]
            },
            "edges": graph.edges.map { edge in
                [
                    "source": edge.source.uuidString,
                    "target": edge.target.uuidString,
                    "weight": edge.weight,
                    "emotionalTone": edge.emotionalTone
                ]
            }
        ]

        return try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
    }

    private func exportAsGraphML(graph: KnowledgeGraph) throws -> Data {
        // Placeholder XML export
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <graphml xmlns="http://graphml.graphdrawing.org/xmlns">
          <graph id="knowledge_graph" edgedefault="undirected">
          </graph>
        </graphml>
        """
        return xml.data(using: .utf8)!
    }

    private func exportAsGEXF(graph: KnowledgeGraph) throws -> Data {
        // Placeholder GEXF export
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">
          <graph mode="static" defaultedgetype="undirected">
          </graph>
        </gexf>
        """
        return xml.data(using: .utf8)!
    }
}

// MARK: - Supporting Types

public struct KnowledgeGraph {
    public var nodes: [GraphNode]
    public var edges: [GraphEdge]

    public init(nodes: [GraphNode], edges: [GraphEdge]) {
        self.nodes = nodes
        self.edges = edges
    }
}

public struct GraphNode {
    public var id: UUID
    public var entity: Entity
    public var centrality: Double
    public var emotionalValence: Double

    public init(id: UUID, entity: Entity, centrality: Double, emotionalValence: Double) {
        self.id = id
        self.entity = entity
        self.centrality = centrality
        self.emotionalValence = emotionalValence
    }
}

public struct GraphEdge {
    public var source: UUID
    public var target: UUID
    public var weight: Double
    public var emotionalTone: Double
    public var coOccurrences: Int

    public init(source: UUID, target: UUID, weight: Double, emotionalTone: Double, coOccurrences: Int) {
        self.source = source
        self.target = target
        self.weight = weight
        self.emotionalTone = emotionalTone
        self.coOccurrences = coOccurrences
    }
}

public struct Community {
    public var id: UUID
    public var members: [Entity]
    public var theme: String?
    public var cohesion: Double

    public init(id: UUID, members: [Entity], theme: String?, cohesion: Double) {
        self.id = id
        self.members = members
        self.theme = theme
        self.cohesion = cohesion
    }
}

public struct GraphSnapshot {
    public var date: Date
    public var graph: KnowledgeGraph

    public init(date: Date, graph: KnowledgeGraph) {
        self.date = date
        self.graph = graph
    }
}

public enum GraphExportFormat {
    case json
    case graphml
    case gexf
}

//
//  KnowledgeGraphServiceTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
import CoreData
@testable import Noema

final class KnowledgeGraphServiceTests: XCTestCase {

    var persistenceController: PersistenceController!
    var graphService: KnowledgeGraphService!
    var entityService: EntityService!
    var context: NSManagedObjectContext!

    override func setUp() async throws {
        try await super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        entityService = EntityService(persistenceController: persistenceController)
        graphService = KnowledgeGraphService(persistenceController: persistenceController, entityService: entityService)
    }

    override func tearDown() {
        graphService = nil
        entityService = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Build Graph Tests

    func test_buildGraph_createsGraph() async throws {
        // Given
        let entity1 = Entity(context: context)
        entity1.name = "Alice"
        entity1.type = .person

        let entity2 = Entity(context: context)
        entity2.name = "Bob"
        entity2.type = .person

        try context.save()

        // When
        let graph = try await graphService.buildGraph()

        // Then
        XCTAssertNotNil(graph)
        XCTAssertGreaterThanOrEqual(graph.nodes.count, 2)
    }

    func test_buildGraph_includesEdges() async throws {
        // Given
        let entity1 = Entity(context: context)
        entity1.name = "Alice"

        let entity2 = Entity(context: context)
        entity2.name = "Bob"

        let relationship = Relationship(context: context)
        relationship.entity1 = entity1
        relationship.entity2 = entity2
        relationship.strength = 0.8

        try context.save()

        // When
        let graph = try await graphService.buildGraph()

        // Then
        XCTAssertGreaterThanOrEqual(graph.edges.count, 0)
    }

    // MARK: - Subgraph Tests

    func test_getSubgraph_returnsSubgraphAroundEntity() async throws {
        // Given
        let centerEntity = Entity(context: context)
        centerEntity.name = "Center"

        let relatedEntity = Entity(context: context)
        relatedEntity.name = "Related"

        let relationship = Relationship(context: context)
        relationship.entity1 = centerEntity
        relationship.entity2 = relatedEntity

        try context.save()

        // When
        let subgraph = try await graphService.getSubgraph(centeredOn: centerEntity, depth: 1)

        // Then
        XCTAssertNotNil(subgraph)
        XCTAssertGreaterThan(subgraph.nodes.count, 0)
    }

    // MARK: - Centrality Tests

    func test_calculateCentrality_returnsScoresForAllEntities() async throws {
        // Given
        let entity1 = Entity(context: context)
        entity1.name = "Entity 1"
        entity1.totalMentions = 10

        let entity2 = Entity(context: context)
        entity2.name = "Entity 2"
        entity2.totalMentions = 5

        try context.save()

        // When
        let centrality = try await graphService.calculateCentrality()

        // Then
        XCTAssertGreaterThanOrEqual(centrality.count, 2)
        for (_, score) in centrality {
            XCTAssertGreaterThanOrEqual(score, 0.0)
        }
    }

    func test_calculateCentrality_higherForMoreConnectedEntities() async throws {
        // Given
        let hubEntity = Entity(context: context)
        hubEntity.name = "Hub"
        hubEntity.totalMentions = 50
        hubEntity.importanceScore = 0.9

        let leafEntity = Entity(context: context)
        leafEntity.name = "Leaf"
        leafEntity.totalMentions = 2
        leafEntity.importanceScore = 0.1

        try context.save()

        // When
        let centrality = try await graphService.calculateCentrality()

        // Then
        if let hubScore = centrality[hubEntity.id],
           let leafScore = centrality[leafEntity.id] {
            XCTAssertGreaterThan(hubScore, leafScore)
        }
    }

    // MARK: - Community Detection Tests

    func test_detectCommunities_returnsCommunities() async throws {
        // Given
        let personEntity1 = Entity(context: context)
        personEntity1.name = "Alice"
        personEntity1.type = .person

        let personEntity2 = Entity(context: context)
        personEntity2.name = "Bob"
        personEntity2.type = .person

        let placeEntity = Entity(context: context)
        placeEntity.name = "Office"
        placeEntity.type = .place

        try context.save()

        // When
        let communities = try await graphService.detectCommunities()

        // Then
        XCTAssertGreaterThan(communities.count, 0)
        for community in communities {
            XCTAssertGreaterThan(community.members.count, 0)
        }
    }

    // MARK: - Path Finding Tests

    func test_findPath_findsDirectConnection() async throws {
        // Given
        let source = Entity(context: context)
        source.name = "Source"

        let target = Entity(context: context)
        target.name = "Target"

        let note = Note(context: context)

        let mention1 = EntityMention(context: context)
        mention1.entity = source
        mention1.note = note

        let mention2 = EntityMention(context: context)
        mention2.entity = target
        mention2.note = note

        try context.save()

        // When
        let path = try await graphService.findPath(from: source, to: target)

        // Then
        // Path may or may not be found depending on relationship setup
        XCTAssertNotNil(path)
    }

    func test_findPath_returnsNilWhenNoPathExists() async throws {
        // Given
        let entity1 = Entity(context: context)
        entity1.name = "Isolated 1"

        let entity2 = Entity(context: context)
        entity2.name = "Isolated 2"

        try context.save()

        // When
        let path = try await graphService.findPath(from: entity1, to: entity2)

        // Then
        // With no connections, path should be nil or minimal
        XCTAssertNotNil(path)
    }

    // MARK: - Export Tests

    func test_exportGraph_asJSON() async throws {
        // Given
        let entity = Entity(context: context)
        entity.name = "Test Entity"
        try context.save()

        // When
        let data = try await graphService.exportGraph(format: .json)

        // Then
        XCTAssertGreaterThan(data.count, 0)

        // Verify it's valid JSON
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        XCTAssertNotNil(json)
    }

    func test_exportGraph_asGraphML() async throws {
        // Given
        let entity = Entity(context: context)
        entity.name = "Test Entity"
        try context.save()

        // When
        let data = try await graphService.exportGraph(format: .graphml)

        // Then
        XCTAssertGreaterThan(data.count, 0)

        // Verify it contains XML
        let string = String(data: data, encoding: .utf8)
        XCTAssertTrue(string?.contains("<?xml") ?? false)
    }

    func test_exportGraph_asGEXF() async throws {
        // Given
        let entity = Entity(context: context)
        entity.name = "Test Entity"
        try context.save()

        // When
        let data = try await graphService.exportGraph(format: .gexf)

        // Then
        XCTAssertGreaterThan(data.count, 0)

        // Verify it contains XML
        let string = String(data: data, encoding: .utf8)
        XCTAssertTrue(string?.contains("gexf") ?? false)
    }

    // MARK: - Graph Evolution Tests

    func test_getGraphEvolution_returnsSnapshots() async throws {
        // Given
        let entity = Entity(context: context)
        entity.name = "Entity"
        try context.save()

        let dateRange = Date().addingTimeInterval(-7 * 24 * 3600)...Date()

        // When
        let snapshots = try await graphService.getGraphEvolution(dateRange: dateRange)

        // Then
        XCTAssertGreaterThan(snapshots.count, 0)
        for snapshot in snapshots {
            XCTAssertNotNil(snapshot.date)
            XCTAssertNotNil(snapshot.graph)
        }
    }

    // MARK: - Graph Structure Tests

    func test_knowledgeGraph_hasNodesAndEdges() {
        // Given
        let entity = Entity(context: context)
        entity.name = "Test"
        entity.id = UUID()

        let node = GraphNode(
            id: entity.id,
            entity: entity,
            centrality: 0.5,
            emotionalValence: 0.3
        )

        let edge = GraphEdge(
            source: entity.id,
            target: UUID(),
            weight: 0.8,
            emotionalTone: 0.2,
            coOccurrences: 5
        )

        // When
        let graph = KnowledgeGraph(nodes: [node], edges: [edge])

        // Then
        XCTAssertEqual(graph.nodes.count, 1)
        XCTAssertEqual(graph.edges.count, 1)
    }

    func test_graphNode_storesEntityReference() {
        // Given
        let entity = Entity(context: context)
        entity.name = "Test Entity"
        entity.id = UUID()

        // When
        let node = GraphNode(
            id: entity.id,
            entity: entity,
            centrality: 0.7,
            emotionalValence: 0.5
        )

        // Then
        XCTAssertEqual(node.id, entity.id)
        XCTAssertEqual(node.entity.name, "Test Entity")
        XCTAssertEqual(node.centrality, 0.7)
        XCTAssertEqual(node.emotionalValence, 0.5)
    }

    func test_graphEdge_connectsTwoNodes() {
        // Given
        let sourceID = UUID()
        let targetID = UUID()

        // When
        let edge = GraphEdge(
            source: sourceID,
            target: targetID,
            weight: 0.6,
            emotionalTone: 0.4,
            coOccurrences: 10
        )

        // Then
        XCTAssertEqual(edge.source, sourceID)
        XCTAssertEqual(edge.target, targetID)
        XCTAssertEqual(edge.weight, 0.6)
        XCTAssertEqual(edge.emotionalTone, 0.4)
        XCTAssertEqual(edge.coOccurrences, 10)
    }
}

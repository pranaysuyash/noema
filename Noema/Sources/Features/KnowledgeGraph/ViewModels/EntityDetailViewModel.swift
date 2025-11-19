//
//  EntityDetailViewModel.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import Combine

@MainActor
public final class EntityDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var entity: Entity
    @Published public var emotionalTimeline: [EmotionalDataPoint] = []
    @Published public var relatedEntities: [Entity] = []
    @Published public var mentions: [EntityMention] = []
    @Published public var isLoading: Bool = false
    @Published public var error: Error?

    // MARK: - Dependencies

    private let entityService: EntityService
    private let graphService: KnowledgeGraphService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        entity: Entity,
        entityService: EntityService = EntityService(),
        graphService: KnowledgeGraphService = KnowledgeGraphService()
    ) {
        self.entity = entity
        self.entityService = entityService
        self.graphService = graphService
    }

    // MARK: - Public Methods

    public func loadEntityData() async {
        isLoading = true
        defer { isLoading = false }

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.loadEmotionalTimeline()
            }

            group.addTask {
                await self.loadRelatedEntities()
            }

            group.addTask {
                await self.loadMentions()
            }
        }
    }

    public func updateEntityColor(_ color: String) {
        entity.customColor = color
        // Save changes
        Task {
            do {
                try PersistenceController.shared.save()
            } catch {
                self.error = error
                Logger.ui.error("Failed to update entity color", error: error)
            }
        }
    }

    public func toggleFavorite() {
        entity.isFavorite.toggle()
        Task {
            do {
                try PersistenceController.shared.save()
            } catch {
                self.error = error
                Logger.ui.error("Failed to toggle favorite", error: error)
            }
        }
    }

    // MARK: - Private Methods

    private func loadEmotionalTimeline() async {
        do {
            emotionalTimeline = try await entityService.getEmotionalTimeline(for: entity, dateRange: nil)
        } catch {
            Logger.ui.error("Failed to load emotional timeline", error: error)
        }
    }

    private func loadRelatedEntities() async {
        do {
            relatedEntities = try await entityService.getRelatedEntities(for: entity, limit: 10)
        } catch {
            Logger.ui.error("Failed to load related entities", error: error)
        }
    }

    private func loadMentions() async {
        do {
            mentions = try await entityService.getMentions(for: entity, limit: 20)
        } catch {
            Logger.ui.error("Failed to load mentions", error: error)
        }
    }
}

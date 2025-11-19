//
//  KnowledgeGraphCoordinator.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import SwiftUI

/// Coordinator for Knowledge Graph feature flow
public final class KnowledgeGraphCoordinator: Coordinator {
    public var childCoordinators: [Coordinator] = []

    private weak var appCoordinator: AppCoordinator?

    public init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
    }

    public func start() {
        Logger.ui.info("KnowledgeGraphCoordinator started")
    }

    // MARK: - Navigation

    public func showEntityDetail(_ entity: Entity) {
        appCoordinator?.navigateToEntity(entity)
    }

    public func showGraphExport() {
        // Show graph export options
    }
}

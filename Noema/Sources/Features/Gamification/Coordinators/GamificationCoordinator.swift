//
//  GamificationCoordinator.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import SwiftUI

/// Coordinator for Gamification feature flow
public final class GamificationCoordinator: Coordinator {
    public var childCoordinators: [Coordinator] = []

    private weak var appCoordinator: AppCoordinator?

    public init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
    }

    public func start() {
        Logger.ui.info("GamificationCoordinator started")
    }

    // MARK: - Navigation

    public func showAchievementDetail(_ achievement: Achievement) {
        // Show achievement detail
    }

    public func showGarden() {
        // Show garden view
    }

    public func showQuest(_ quest: Quest) {
        // Show quest detail
    }
}

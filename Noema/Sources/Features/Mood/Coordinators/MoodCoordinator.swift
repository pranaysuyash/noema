//
//  MoodCoordinator.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import SwiftUI

/// Coordinator for Mood feature flow
public final class MoodCoordinator: Coordinator {
    public var childCoordinators: [Coordinator] = []

    private weak var appCoordinator: AppCoordinator?

    public init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
    }

    public func start() {
        Logger.ui.info("MoodCoordinator started")
    }

    // MARK: - Navigation

    public func showMoodDetail(date: Date) {
        appCoordinator?.navigateToMoodDetail(date: date)
    }

    public func showEmotionPicker() {
        // Show emotion picker sheet
    }
}

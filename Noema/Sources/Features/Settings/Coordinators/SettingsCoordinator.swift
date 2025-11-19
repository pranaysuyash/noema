//
//  SettingsCoordinator.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import SwiftUI

/// Coordinator for Settings feature flow
public final class SettingsCoordinator: Coordinator {
    public var childCoordinators: [Coordinator] = []

    private weak var appCoordinator: AppCoordinator?

    public init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
    }

    public func start() {
        Logger.ui.info("SettingsCoordinator started")
    }

    // MARK: - Navigation

    public func showPrivacyDashboard() {
        // Show privacy dashboard
    }

    public func showSubscription() {
        // Show subscription options
    }

    public func showDataExport() {
        // Show data export options
    }
}

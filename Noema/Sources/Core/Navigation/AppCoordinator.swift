//
//  AppCoordinator.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import SwiftUI
import Combine

/// Main app coordinator managing navigation flow
public final class AppCoordinator: ObservableObject, Coordinator {
    // MARK: - Published Properties

    @Published public var selectedTab: Tab = .notes
    @Published public var notesPath = NavigationPath()
    @Published public var moodPath = NavigationPath()
    @Published public var graphPath = NavigationPath()
    @Published public var gamificationPath = NavigationPath()
    @Published public var settingsPath = NavigationPath()

    // MARK: - Tab Selection

    public enum Tab: Int {
        case notes = 0
        case mood = 1
        case graph = 2
        case gamification = 3
        case settings = 4
    }

    // MARK: - Coordinator Properties

    public var childCoordinators: [Coordinator] = []

    // MARK: - Initialization

    public init() {
        Logger.app.info("AppCoordinator initialized")
    }

    // MARK: - Coordinator Methods

    public func start() {
        // Initialize app
        Logger.app.info("AppCoordinator started")
    }

    // MARK: - Navigation Methods

    public func navigateToNote(_ note: Note) {
        selectedTab = .notes
        notesPath.append(note)
    }

    public func navigateToEntity(_ entity: Entity) {
        selectedTab = .graph
        graphPath.append(entity)
    }

    public func navigateToMoodDetail(date: Date) {
        selectedTab = .mood
        moodPath.append(date)
    }

    public func navigateToSettings() {
        selectedTab = .settings
    }

    public func popToRoot(for tab: Tab) {
        switch tab {
        case .notes:
            notesPath = NavigationPath()
        case .mood:
            moodPath = NavigationPath()
        case .graph:
            graphPath = NavigationPath()
        case .gamification:
            gamificationPath = NavigationPath()
        case .settings:
            settingsPath = NavigationPath()
        }
    }
}

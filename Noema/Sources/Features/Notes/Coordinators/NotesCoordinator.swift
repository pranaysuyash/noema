//
//  NotesCoordinator.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import SwiftUI

/// Coordinator for Notes feature flow
public final class NotesCoordinator: Coordinator {
    public var childCoordinators: [Coordinator] = []

    private weak var appCoordinator: AppCoordinator?

    public init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
    }

    public func start() {
        Logger.ui.info("NotesCoordinator started")
    }

    // MARK: - Navigation

    public func showNoteDetail(_ note: Note) {
        appCoordinator?.navigateToNote(note)
    }

    public func showNoteEditor() {
        // Show note editor sheet
    }

    public func showVoiceRecorder() {
        // Show voice recorder sheet
    }
}

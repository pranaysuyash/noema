//
//  Coordinator.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import SwiftUI

/// Base coordinator protocol
public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
    func coordinate(to coordinator: Coordinator)
}

extension Coordinator {
    public func coordinate(to coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}


//
//  Bird.swift
//  AngrySpparrowbird
//
//  Model representing the sparrow bird projectile.
//  Tracks position, velocity, and flight state.
//

import SwiftUI

/// Represents a single sparrow bird projectile in the game.
struct Bird: Identifiable {
    let id: UUID
    var position: CGPoint    // Current center position in the game canvas
    var velocity: CGVector   // Current velocity in pts/second (dy positive = downward)
    var isLaunched: Bool     // True once released from the slingshot
    var isActive: Bool       // False once bird lands or exits the canvas
    var rotation: Double     // Rotation angle in radians, follows velocity direction

    /// The visual radius of the bird (used for collision detection).
    static let radius: CGFloat = 18

    // MARK: - Factory

    /// Creates a resting bird at the given slingshot position.
    static func idle(at position: CGPoint) -> Bird {
        Bird(
            id: UUID(),
            position: position,
            velocity: .zero,
            isLaunched: false,
            isActive: true,
            rotation: 0
        )
    }
}

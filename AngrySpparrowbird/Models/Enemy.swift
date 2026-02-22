
//
//  Enemy.swift
//  AngrySpparrowbird
//
//  Model representing an enemy character (green pig) in Stage 2.
//  Enemies are the primary targets — the player must defeat all enemies to win.
//

import SwiftUI

/// An enemy target placed in the game arena (Stage 2 only).
struct Enemy: Identifiable {
    let id: UUID
    var position: CGPoint   // Center position in the game canvas
    var health: Int         // Hit points (reduced on bird collision)
    var isDefeated: Bool    // True once health reaches 0

    /// The visual collision radius of an enemy.
    static let radius: CGFloat = 26

    // MARK: - Factory

    /// Creates a healthy enemy at the specified position.
    static func make(at position: CGPoint) -> Enemy {
        Enemy(id: UUID(), position: position, health: 2, isDefeated: false)
    }

    // MARK: - Mutation

    /// Applies damage and marks the enemy as defeated when health ≤ 0.
    mutating func takeDamage(_ amount: Int = 1) {
        health = max(0, health - amount)
        if health == 0 { isDefeated = true }
    }
}

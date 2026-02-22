
//
//  Block.swift
//  AngrySpparrowbird
//
//  Model representing a destructible block in the game.
//  Blocks can be wooden (fragile) or stone (durable).
//

import SwiftUI

/// The type of block in the game world.
enum BlockType {
    case wood   // Health = 1, destroyed in one hit
    case stone  // Health = 3, requires multiple hits
}

/// A destructible block placed in the game arena.
struct Block: Identifiable {
    let id: UUID
    var type: BlockType
    var position: CGPoint   // Center of the block
    var size: CGSize
    var health: Int         // Remaining hit points
    var isDestroyed: Bool   // True once health reaches 0
    var crackLevel: Int     // 0 = pristine, 1 = cracked, 2 = heavily cracked (used for visuals)

    // MARK: - Factory Helpers

    /// Creates a wooden block centered at the given position.
    static func woodBlock(at pos: CGPoint) -> Block {
        Block(
            id: UUID(),
            type: .wood,
            position: pos,
            size: CGSize(width: 48, height: 48),
            health: 1,
            isDestroyed: false,
            crackLevel: 0
        )
    }

    /// Creates a stone block centered at the given position.
    static func stoneBlock(at pos: CGPoint) -> Block {
        Block(
            id: UUID(),
            type: .stone,
            position: pos,
            size: CGSize(width: 52, height: 52),
            health: 3,
            isDestroyed: false,
            crackLevel: 0
        )
    }

    // MARK: - Computed Frame

    /// The axis-aligned bounding rectangle for collision detection.
    var rect: CGRect {
        CGRect(
            x: position.x - size.width / 2,
            y: position.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    // MARK: - Mutation

    /// Applies damage, updates crack level, and marks as destroyed when health ≤ 0.
    mutating func takeDamage(_ amount: Int = 1) {
        health = max(0, health - amount)
        // Compute visual crack level as 0-2 progression based on damage taken.
        let maxHealth = (type == .wood) ? 1 : 3
        let damageTaken = maxHealth - health
        crackLevel = min(2, damageTaken)
        if health == 0 { isDestroyed = true }
    }
}

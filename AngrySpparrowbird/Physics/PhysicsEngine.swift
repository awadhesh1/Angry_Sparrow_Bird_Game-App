
//
//  PhysicsEngine.swift
//  AngrySpparrowbird
//
//  Pure-Swift, stateless physics utilities.
//  Uses Euler integration: each tick updates velocity then position.
//
//  Coordinate system: origin top-left, +x right, +y DOWN (SwiftUI canvas).
//  Therefore gravity adds to velocity.dy each tick.
//

import CoreGraphics

enum PhysicsEngine {

    // MARK: - Gravity Constants

    /// Stage 1: lighter gravity for a gentle, beginner-friendly arc.
    static let stage1Gravity: CGFloat = 280.0   // pts / s²

    /// Stage 2: stronger gravity for a more challenging arc.
    static let stage2Gravity: CGFloat = 480.0   // pts / s²

    // MARK: - Power Multiplier

    /// Converts the slingshot drag distance into pixels-per-second.
    /// Higher value → more punch per pixel of drag.
    static let launchPower: CGFloat = 8.5

    // MARK: - Integration Steps

    /// Applies gravitational acceleration to the bird's vertical velocity.
    /// - Parameters:
    ///   - velocity: Bird's current velocity vector (mutated in-place).
    ///   - gravity: Downward acceleration in pts/s².
    ///   - dt: Time step in seconds.
    static func applyGravity(to velocity: inout CGVector,
                             gravity: CGFloat,
                             dt: CGFloat) {
        velocity.dy += gravity * dt
    }

    /// Advances the bird's position by one time step.
    /// - Parameters:
    ///   - position: Bird's current position (mutated in-place).
    ///   - velocity: Current velocity vector.
    ///   - dt: Time step in seconds.
    static func move(_ position: inout CGPoint,
                     velocity: CGVector,
                     dt: CGFloat) {
        position.x += velocity.dx * dt
        position.y += velocity.dy * dt
    }

    // MARK: - Collision Detection

    /// Circle–AABB (axis-aligned bounding box) collision.
    /// Returns true if the circular bird overlaps the block rectangle.
    static func birdHitsBlock(birdCenter: CGPoint,
                              birdRadius: CGFloat = Bird.radius,
                              block: Block) -> Bool {
        guard !block.isDestroyed else { return false }
        let rect = block.rect
        // Clamp bird center to the nearest point on the rect
        let nearestX = max(rect.minX, min(birdCenter.x, rect.maxX))
        let nearestY = max(rect.minY, min(birdCenter.y, rect.maxY))
        let dx = birdCenter.x - nearestX
        let dy = birdCenter.y - nearestY
        return (dx * dx + dy * dy) < (birdRadius * birdRadius)
    }

    /// Circle–Circle collision for bird vs. enemy.
    static func birdHitsEnemy(birdCenter: CGPoint,
                              birdRadius: CGFloat = Bird.radius,
                              enemy: Enemy) -> Bool {
        guard !enemy.isDefeated else { return false }
        let dx = birdCenter.x - enemy.position.x
        let dy = birdCenter.y - enemy.position.y
        let combinedRadius = birdRadius + Enemy.radius
        return (dx * dx + dy * dy) < (combinedRadius * combinedRadius)
    }

    // MARK: - Trajectory Preview

    /// Simulates a ballistic arc and returns N sample positions.
    /// Used to render the dotted trajectory preview while the player aims.
    /// - Parameters:
    ///   - start: Bird's starting position (slingshot tip).
    ///   - velocity: Computed launch velocity from slingshot drag.
    ///   - gravity: Gravity constant for the current stage.
    ///   - count: Number of preview dots to generate.
    ///   - stepDt: Time interval between simulated steps (fine = smoother arc).
    static func trajectoryPreview(from start: CGPoint,
                                  velocity: CGVector,
                                  gravity: CGFloat,
                                  count: Int = 18,
                                  stepDt: CGFloat = 0.045) -> [CGPoint] {
        var points: [CGPoint] = []
        var pos = start
        var vel = velocity
        for _ in 0 ..< count {
            points.append(pos)
            vel.dy += gravity * stepDt
            pos.x  += vel.dx  * stepDt
            pos.y  += vel.dy  * stepDt
        }
        return points
    }

    // MARK: - Launch Velocity

    /// Converts the player's rubber-band drag vector into a launch velocity.
    /// The drag is negated because pulling left/up should launch right/up.
    static func launchVelocity(from drag: CGVector) -> CGVector {
        CGVector(dx: -drag.dx * launchPower,
                 dy: -drag.dy * launchPower)
    }

    // MARK: - Bird Rotation

    /// Computes the rotation angle (radians) of the bird to align with its velocity.
    static func rotationAngle(for velocity: CGVector) -> Double {
        atan2(Double(velocity.dy), Double(velocity.dx))
    }
}

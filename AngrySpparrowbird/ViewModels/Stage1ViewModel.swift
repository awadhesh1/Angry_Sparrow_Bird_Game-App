
//
//  Stage1ViewModel.swift
//  AngrySpparrowbird
//
//  Game logic for Stage 1 – Beginner.
//  Uses @Observable (Swift 5.9+) to avoid Swift 6 @MainActor + ObservableObject conflict.
//

import SwiftUI

// MARK: - Game Phase

/// Lifecycle state of a single game round.
enum GamePhase {
    case aiming    // Waiting for the player to drag the slingshot
    case flying    // Bird is in the air; physics loop running
    case success   // All targets destroyed
    case failure   // Bird missed; targets remain
}

// MARK: - ViewModel

@Observable
class Stage1ViewModel {

    // MARK: State (all automatically observed via @Observable)
    var bird: Bird
    var blocks: [Block]
    var score: Int = 0
    var phase: GamePhase = .aiming
    var dragOffset: CGVector = .zero
    var destroyedIDs: Set<UUID> = []

    // MARK: Layout constants (set once via setup)
    private(set) var canvasSize: CGSize = CGSize(width: 390, height: 700)

    /// Top of the slingshot fork (bird rests here when aiming).
    var slingshotTip: CGPoint {
        CGPoint(x: canvasSize.width * 0.22, y: canvasSize.height * 0.72)
    }

    /// Y coordinate of the ground line.
    var groundY: CGFloat { canvasSize.height * 0.835 }

    // MARK: Internal
    private var timer: Timer?
    private let gravity = PhysicsEngine.stage1Gravity
    private let maxDrag: CGFloat = 80

    /// Injected reference so we can call stageEnded when the round finishes.
    weak var gameVM: GameViewModel?

    // MARK: - Init

    init() {
        bird   = Bird.idle(at: .zero)   // Real pos set in setup()
        blocks = []
    }

    // MARK: - Setup

    /// Called from the view once GeometryReader provides the canvas size.
    func setup(canvasSize: CGSize) {
        self.canvasSize = canvasSize
        reset()
    }

    // MARK: - Block Layout

    private func makeBlocks() -> [Block] {
        let bx: CGFloat = canvasSize.width * 0.68
        let by: CGFloat = groundY
        return [
            .woodBlock(at: CGPoint(x: bx - 52, y: by - 24)),
            .woodBlock(at: CGPoint(x: bx,       y: by - 24)),
            .woodBlock(at: CGPoint(x: bx + 52,  y: by - 24)),
            .woodBlock(at: CGPoint(x: bx - 26,  y: by - 72)),
            .woodBlock(at: CGPoint(x: bx + 26,  y: by - 72)),
        ]
    }

    // MARK: - Drag Handling

    func updateDrag(_ offset: CGVector) {
        guard phase == .aiming else { return }
        let mag = hypot(offset.dx, offset.dy)
        if mag > maxDrag {
            let scale = maxDrag / mag
            dragOffset = CGVector(dx: offset.dx * scale, dy: offset.dy * scale)
        } else {
            dragOffset = offset
        }
        bird.position = CGPoint(
            x: slingshotTip.x + dragOffset.dx,
            y: slingshotTip.y + dragOffset.dy
        )
    }

    // MARK: - Launch

    func launchBird() {
        guard phase == .aiming,
              hypot(dragOffset.dx, dragOffset.dy) > 5 else { return }
        bird.velocity   = PhysicsEngine.launchVelocity(from: dragOffset)
        bird.isLaunched = true
        phase           = .flying
        dragOffset      = .zero
        startPhysicsLoop()
    }

    // MARK: - Physics Loop

    private func startPhysicsLoop() {
        // Timer on RunLoop.main fires on the main thread.
        // With SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor, self.tick() is
        // implicitly @MainActor so calling it from RunLoop.main is safe.
        timer = Timer(timeInterval: 1 / 60.0, repeats: true) { [weak self] _ in
            self?.tick(dt: 1 / 60.0)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick(dt: CGFloat) {
        guard phase == .flying else { timer?.invalidate(); return }

        // --- Integration ---
        PhysicsEngine.applyGravity(to: &bird.velocity, gravity: gravity, dt: dt)
        PhysicsEngine.move(&bird.position, velocity: bird.velocity, dt: dt)
        bird.rotation = PhysicsEngine.rotationAngle(for: bird.velocity)

        // --- Block Collisions ---
        for idx in blocks.indices {
            guard !blocks[idx].isDestroyed else { continue }
            if PhysicsEngine.birdHitsBlock(birdCenter: bird.position, block: blocks[idx]) {
                blocks[idx].takeDamage()
                if blocks[idx].isDestroyed {
                    destroyedIDs.insert(blocks[idx].id)
                    score += 100
                }
                bird.velocity.dy *= -0.25
                bird.velocity.dx *=  0.60
            }
        }

        // --- Exit Conditions ---
        let offScreen = bird.position.y > groundY + 20
                     || bird.position.x > canvasSize.width + 50
                     || bird.position.x < -50
        let allGone = blocks.allSatisfy(\.isDestroyed)

        if allGone {
            finishRound(success: true)
        } else if offScreen {
            finishRound(success: false)
        }
    }

    // MARK: - Round Finish

    private func finishRound(success: Bool) {
        timer?.invalidate()
        phase = success ? .success : .failure
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            gameVM?.stageEnded(stage: .stage1, success: success, score: score)
        }
    }

    // MARK: - Reset

    func reset() {
        timer?.invalidate()
        phase        = .aiming
        score        = 0
        dragOffset   = .zero
        destroyedIDs = []
        bird   = Bird.idle(at: slingshotTip)
        blocks = makeBlocks()
    }

    // MARK: - Trajectory Preview

    var trajectoryDots: [CGPoint] {
        guard phase == .aiming else { return [] }
        let vel = PhysicsEngine.launchVelocity(from: dragOffset)
        return PhysicsEngine.trajectoryPreview(
            from: bird.position,
            velocity: vel,
            gravity: gravity
        )
    }
}

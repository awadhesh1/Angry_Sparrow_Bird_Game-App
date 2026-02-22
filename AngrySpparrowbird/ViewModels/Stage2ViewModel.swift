
//
//  Stage2ViewModel.swift
//  AngrySpparrowbird
//
//  Game logic for Stage 2 – Advanced.
//  Uses @Observable (Swift 5.9+) to avoid Swift 6 @MainActor + ObservableObject conflict.
//

import SwiftUI

// MARK: - ViewModel

@Observable
class Stage2ViewModel {

    // MARK: State (all automatically observed via @Observable)
    var birds: [Bird]
    var blocks: [Block]
    var enemies: [Enemy]
    var score: Int = 0
    var phase: GamePhase = .aiming
    var dragOffset: CGVector = .zero
    var destroyedBlockIDs: Set<UUID> = []
    var defeatedEnemyIDs:  Set<UUID> = []
    var activeBirdIndex: Int = 0

    // MARK: Layout constants
    private(set) var canvasSize: CGSize = CGSize(width: 390, height: 700)

    var slingshotTip: CGPoint {
        CGPoint(x: canvasSize.width * 0.22, y: canvasSize.height * 0.72)
    }
    var groundY: CGFloat { canvasSize.height * 0.835 }

    // MARK: Internal
    private var timer: Timer?
    private let gravity    = PhysicsEngine.stage2Gravity
    private let maxDrag: CGFloat = 80
    private let birdCount  = 3

    weak var gameVM: GameViewModel?

    // MARK: Computed helpers
    var activeBird: Bird? {
        guard activeBirdIndex < birds.count else { return nil }
        return birds[activeBirdIndex]
    }
    var birdsRemaining: Int { birds.count - activeBirdIndex }

    // MARK: - Init

    init() {
        birds   = []
        blocks  = []
        enemies = []
    }

    // MARK: - Setup

    func setup(canvasSize: CGSize) {
        self.canvasSize = canvasSize
        reset()
    }

    // MARK: - Layout Builders

    private func makeBirds() -> [Bird] {
        (0 ..< birdCount).map { _ in Bird.idle(at: slingshotTip) }
    }

    private func makeBlocks() -> [Block] {
        let bx: CGFloat = canvasSize.width * 0.62
        let by: CGFloat = groundY
        return [
            .woodBlock( at: CGPoint(x: bx,       y: by - 24)),
            .woodBlock( at: CGPoint(x: bx + 62,  y: by - 24)),
            .stoneBlock(at: CGPoint(x: bx + 124, y: by - 26)),
            .stoneBlock(at: CGPoint(x: bx + 31,  y: by - 76)),
            .woodBlock( at: CGPoint(x: bx + 93,  y: by - 72)),
            .stoneBlock(at: CGPoint(x: bx + 62,  y: by - 128)),
            .woodBlock( at: CGPoint(x: bx + 155, y: by - 24)),
            .woodBlock( at: CGPoint(x: bx + 155, y: by - 72)),
        ]
    }

    private func makeEnemies() -> [Enemy] {
        let ex: CGFloat = canvasSize.width * 0.72
        let by: CGFloat = groundY
        return [
            .make(at: CGPoint(x: ex - 10,  y: by - 26)),
            .make(at: CGPoint(x: ex + 85,  y: by - 26)),
            .make(at: CGPoint(x: ex + 35,  y: by - 158)),
        ]
    }

    // MARK: - Drag Handling

    func updateDrag(_ offset: CGVector) {
        guard phase == .aiming, activeBirdIndex < birds.count else { return }
        let mag = hypot(offset.dx, offset.dy)
        if mag > maxDrag {
            let scale = maxDrag / mag
            dragOffset = CGVector(dx: offset.dx * scale, dy: offset.dy * scale)
        } else {
            dragOffset = offset
        }
        birds[activeBirdIndex].position = CGPoint(
            x: slingshotTip.x + dragOffset.dx,
            y: slingshotTip.y + dragOffset.dy
        )
    }

    // MARK: - Launch

    func launchBird() {
        guard phase == .aiming,
              activeBirdIndex < birds.count,
              hypot(dragOffset.dx, dragOffset.dy) > 5 else { return }
        birds[activeBirdIndex].velocity   = PhysicsEngine.launchVelocity(from: dragOffset)
        birds[activeBirdIndex].isLaunched = true
        phase      = .flying
        dragOffset = .zero
        startPhysicsLoop()
    }

    // MARK: - Physics Loop

    private func startPhysicsLoop() {
        timer = Timer(timeInterval: 1 / 60.0, repeats: true) { [weak self] _ in
            self?.tick(dt: 1 / 60.0)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick(dt: CGFloat) {
        guard phase == .flying, activeBirdIndex < birds.count else {
            timer?.invalidate()
            return
        }

        // --- Integration ---
        PhysicsEngine.applyGravity(to: &birds[activeBirdIndex].velocity, gravity: gravity, dt: dt)
        PhysicsEngine.move(&birds[activeBirdIndex].position, velocity: birds[activeBirdIndex].velocity, dt: dt)
        birds[activeBirdIndex].rotation = PhysicsEngine.rotationAngle(for: birds[activeBirdIndex].velocity)

        let birdPos = birds[activeBirdIndex].position

        // --- Block Collisions ---
        for idx in blocks.indices {
            guard !blocks[idx].isDestroyed else { continue }
            if PhysicsEngine.birdHitsBlock(birdCenter: birdPos, block: blocks[idx]) {
                blocks[idx].takeDamage()
                if blocks[idx].isDestroyed {
                    destroyedBlockIDs.insert(blocks[idx].id)
                    score += (blocks[idx].type == .stone) ? 200 : 100
                }
                birds[activeBirdIndex].velocity.dy *= -0.20
                birds[activeBirdIndex].velocity.dx *=  0.55
            }
        }

        // --- Enemy Collisions ---
        for idx in enemies.indices {
            guard !enemies[idx].isDefeated else { continue }
            if PhysicsEngine.birdHitsEnemy(birdCenter: birdPos, enemy: enemies[idx]) {
                enemies[idx].takeDamage()
                if enemies[idx].isDefeated {
                    defeatedEnemyIDs.insert(enemies[idx].id)
                    score += 500
                }
                birds[activeBirdIndex].velocity.dy *= -0.15
                birds[activeBirdIndex].velocity.dx *=  0.50
            }
        }

        // --- Win Condition ---
        if enemies.allSatisfy(\.isDefeated) {
            finishRound(success: true)
            return
        }

        // --- Bird exits canvas ---
        let offScreen = birdPos.y > groundY + 20
                     || birdPos.x > canvasSize.width + 50
                     || birdPos.x < -50
        if offScreen {
            timer?.invalidate()
            birds[activeBirdIndex].isActive = false
            advanceToNextBird()
        }
    }

    // MARK: - Bird Queue

    private func advanceToNextBird() {
        let nextIdx = activeBirdIndex + 1
        if nextIdx < birds.count {
            activeBirdIndex = nextIdx
            birds[activeBirdIndex].position = slingshotTip
            phase = .aiming
        } else {
            finishRound(success: false)
        }
    }

    // MARK: - Round Finish

    private func finishRound(success: Bool) {
        timer?.invalidate()
        phase = success ? .success : .failure
        let bonus = success ? (birds.count - 1 - activeBirdIndex) * 200 : 0
        if success { score += bonus }
        Task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            gameVM?.stageEnded(stage: .stage2, success: success, score: score, bonus: bonus)
        }
    }

    // MARK: - Reset

    func reset() {
        timer?.invalidate()
        phase             = .aiming
        score             = 0
        activeBirdIndex   = 0
        dragOffset        = .zero
        destroyedBlockIDs = []
        defeatedEnemyIDs  = []
        birds   = makeBirds()
        blocks  = makeBlocks()
        enemies = makeEnemies()
    }

    // MARK: - Trajectory Preview

    var trajectoryDots: [CGPoint] {
        guard phase == .aiming, activeBirdIndex < birds.count else { return [] }
        let vel = PhysicsEngine.launchVelocity(from: dragOffset)
        return PhysicsEngine.trajectoryPreview(
            from: birds[activeBirdIndex].position,
            velocity: vel,
            gravity: gravity
        )
    }
}

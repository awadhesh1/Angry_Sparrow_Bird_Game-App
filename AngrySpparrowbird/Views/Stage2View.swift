
//
//  Stage2View.swift
//  AngrySpparrowbird
//
//  The gameplay canvas for Stage 2 (Advanced).
//  Features: 3-bird queue, stone blocks, enemy pigs, heavier gravity.
//

import SwiftUI

struct Stage2View: View {
    @State private var vm = Stage2ViewModel()
    @Environment(GameViewModel.self) var gameVM

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                // ── Background (darker, more dramatic) ──
                stage2Background(size: geo.size)

                // ── Trajectory preview ──
                TrajectoryView(dots: vm.trajectoryDots)

                // ── Slingshot ──
                if let activeBird = vm.activeBird {
                    SlingshotView(
                        birdPosition: activeBird.position,
                        origin: CGPoint(x: vm.slingshotTip.x,
                                       y: vm.slingshotTip.y + 60)
                    )
                }

                // ── Blocks ──
                ForEach(vm.blocks) { block in
                    BlockView(block: block)
                        .position(block.position)
                }

                // ── Enemies ──
                ForEach(vm.enemies) { enemy in
                    EnemyView(enemy: enemy, size: 52)
                        .position(enemy.position)
                }

                // ── Bird queue: waiting birds stacked at base ──
                birdQueueView

                // ── Active bird ──
                if vm.activeBirdIndex < vm.birds.count {
                    SparrowBirdView(bird: vm.birds[vm.activeBirdIndex], size: 36)
                        .position(vm.birds[vm.activeBirdIndex].position)
                }

                // ── Phase overlay ──
                phaseOverlay

                // ── HUD ──
                VStack {
                    ScoreHUDView(
                        stageLabel: "Stage 2",
                        score: vm.score,
                        birdsRemaining: vm.birdsRemaining
                    )
                    Spacer()
                }

                // ── Drag region ──
                dragRegion(geo: geo)
            }
            .onAppear {
                vm.gameVM = gameVM
                vm.setup(canvasSize: geo.size)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }

    // MARK: - Background (evening atmosphere)

    private func stage2Background(size: CGSize) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(red: 0.18, green: 0.35, blue: 0.70),
                         Color(red: 0.45, green: 0.68, blue: 0.95)],
                startPoint: .top, endPoint: .bottom
            )
            // Ground
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color(red: 0.22, green: 0.45, blue: 0.10),
                                 Color(red: 0.14, green: 0.30, blue: 0.06)],
                        startPoint: .top, endPoint: .bottom))
                    .frame(height: size.height * 0.165)
            }
            // Darker hills
            Canvas { ctx, sz in
                var hill = Path()
                hill.move(to: CGPoint(x: 0, y: sz.height * 0.84))
                hill.addQuadCurve(to: CGPoint(x: sz.width * 0.38, y: sz.height * 0.60),
                                  control: CGPoint(x: sz.width * 0.18, y: sz.height * 0.50))
                hill.addQuadCurve(to: CGPoint(x: sz.width, y: sz.height * 0.835),
                                  control: CGPoint(x: sz.width * 0.72, y: sz.height * 0.56))
                hill.addLine(to: CGPoint(x: sz.width, y: sz.height))
                hill.addLine(to: CGPoint(x: 0, y: sz.height))
                ctx.fill(hill, with: .color(Color(red: 0.24, green: 0.50, blue: 0.14).opacity(0.60)))
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Bird Queue

    private var birdQueueView: some View {
        GeometryReader { geo in
            let startX = vm.slingshotTip.x - 60
            let queueY = vm.groundY - 12
            ForEach(Array(vm.birds.enumerated()), id: \.element.id) { idx, bird in
                if idx > vm.activeBirdIndex && bird.isActive {
                    let qx = startX - CGFloat(idx - vm.activeBirdIndex - 1) * 36
                    SparrowBirdView(bird: bird, size: 26)
                        .position(x: qx, y: queueY)
                        .opacity(0.75)
                }
            }
        }
    }

    // MARK: - Phase Overlay

    @ViewBuilder
    private var phaseOverlay: some View {
        switch vm.phase {
        case .success:
            statusBanner("🏆 Stage 2 Complete!", color: .purple)
        case .failure:
            statusBanner("💔 No Birds Left!", color: .red)
        default:
            EmptyView()
        }
    }

    private func statusBanner(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 30, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 22).fill(color.opacity(0.90)))
            .shadow(radius: 14)
            .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Drag Gesture

    private func dragRegion(geo: GeometryProxy) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        let offset = CGVector(
                            dx: value.location.x - vm.slingshotTip.x,
                            dy: value.location.y - vm.slingshotTip.y
                        )
                        vm.updateDrag(offset)
                    }
                    .onEnded { _ in
                        vm.launchBird()
                    }
            )
    }
}

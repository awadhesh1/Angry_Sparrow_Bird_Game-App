
//
//  Stage1View.swift
//  AngrySpparrowbird
//
//  The gameplay canvas for Stage 1 (Beginner).
//  Handles: slingshot drag, physics rendering, background, HUD.
//

import SwiftUI

struct Stage1View: View {
    @State private var vm = Stage1ViewModel()
    @Environment(GameViewModel.self) var gameVM

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                // ── Background ──
                gameBackground(size: geo.size)

                // ── Trajectory preview ──
                TrajectoryView(dots: vm.trajectoryDots)

                // ── Slingshot ──
                SlingshotView(
                    birdPosition: vm.bird.position,
                    origin: CGPoint(x: vm.slingshotTip.x,
                                   y: vm.slingshotTip.y + 60)
                )

                // ── Blocks ──
                ForEach(vm.blocks) { block in
                    BlockView(block: block)
                        .position(block.position)
                }

                // ── Bird ──
                SparrowBirdView(bird: vm.bird, size: 36)
                    .position(vm.bird.position)

                // ── Phase overlay animations ──
                phaseOverlay

                // ── HUD ──
                VStack {
                    ScoreHUDView(
                        stageLabel: "Stage 1",
                        score: vm.score,
                        birdsRemaining: vm.phase == .aiming ? 1 : 0
                    )
                    Spacer()
                }

                // ── Drag hit area ──
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

    // MARK: - Background

    private func gameBackground(size: CGSize) -> some View {
        ZStack(alignment: .bottom) {
            // Sky
            LinearGradient(
                colors: [Color(red: 0.44, green: 0.82, blue: 1.0),
                         Color(red: 0.72, green: 0.93, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            )
            // Ground
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color(red: 0.35, green: 0.62, blue: 0.15),
                                 Color(red: 0.25, green: 0.46, blue: 0.10)],
                        startPoint: .top, endPoint: .bottom))
                    .frame(height: size.height * 0.165)
            }
            // Distant hills
            Canvas { ctx, sz in
                var hill = Path()
                hill.move(to: CGPoint(x: 0, y: sz.height * 0.84))
                hill.addQuadCurve(to: CGPoint(x: sz.width * 0.45, y: sz.height * 0.64),
                                  control: CGPoint(x: sz.width * 0.22, y: sz.height * 0.55))
                hill.addQuadCurve(to: CGPoint(x: sz.width * 0.9, y: sz.height * 0.835),
                                  control: CGPoint(x: sz.width * 0.68, y: sz.height * 0.60))
                hill.addLine(to: CGPoint(x: sz.width, y: sz.height))
                hill.addLine(to: CGPoint(x: 0, y: sz.height))
                ctx.fill(hill, with: .color(Color(red: 0.42, green: 0.72, blue: 0.22).opacity(0.55)))
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Phase Overlay

    @ViewBuilder
    private var phaseOverlay: some View {
        switch vm.phase {
        case .success:
            statusBanner("🎉 Stage Clear!", color: .green)
        case .failure:
            statusBanner("💔 Try Again!", color: .red)
        default:
            EmptyView()
        }
    }

    private func statusBanner(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 36, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 22).fill(color.opacity(0.88)))
            .shadow(radius: 12)
            .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Drag Gesture Region

    private func dragRegion(geo: GeometryProxy) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        // Convert global drag to offset from slingshot tip
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


//
//  HomeView.swift
//  AngrySpparrowbird
//
//  Landing screen with animated sparrow logo, game title, and Play button.
//

import SwiftUI

struct HomeView: View {
    @Environment(GameViewModel.self) var gameVM

    @State private var birdBounce: Bool = false
    @State private var titleScale: CGFloat = 0.6
    @State private var cloudOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // ── Background sky gradient ──
            LinearGradient(
                colors: [
                    Color(red: 0.36, green: 0.74, blue: 0.97),
                    Color(red: 0.55, green: 0.88, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // ── Animated clouds ──
            clouds

            // ── Ground strip ──
            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.38, green: 0.65, blue: 0.18),
                                     Color(red: 0.28, green: 0.50, blue: 0.10)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 90)
            }
            .ignoresSafeArea(edges: .bottom)

            // ── Content ──
            VStack(spacing: 28) {
                Spacer()

                // Title
                VStack(spacing: 6) {
                    Text("🐦")
                        .font(.system(size: 72))
                        .offset(y: birdBounce ? -18 : 0)
                        .scaleEffect(birdBounce ? 1.12 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.55).repeatForever(autoreverses: true),
                            value: birdBounce
                        )

                    Text("Angry")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.orange)

                    Text("Sparrow Bird")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .orange.opacity(0.8), radius: 4, x: 0, y: 2)
                }
                .scaleEffect(titleScale)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        titleScale = 1.0
                    }
                }

                Spacer()

                // Play button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        gameVM.goToStageSelect()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                        Text("PLAY")
                    }
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 62)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.45, blue: 0.05),
                                                 Color(red: 0.90, green: 0.28, blue: 0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.35), lineWidth: 2)
                        }
                    )
                    .shadow(color: .orange.opacity(0.6), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)

                // Best score / credits row
                if gameVM.totalScore > 0 {
                    Text("Best: \(gameVM.totalScore) pts")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                }

                Spacer().frame(height: 60)
            }
        }
        .onAppear { birdBounce = true; startCloudAnimation() }
    }

    // MARK: - Clouds

    private var clouds: some View {
        GeometryReader { geo in
            ForEach(0 ..< 3, id: \.self) { i in
                cloudShape
                    .offset(
                        x: cloudOffset + CGFloat(i) * geo.size.width * 0.42 - geo.size.width * 0.15,
                        y: CGFloat(i % 2 == 0 ? 60 : 120)
                    )
                    .opacity(0.82)
            }
        }
    }

    private var cloudShape: some View {
        ZStack {
            Capsule()
                .fill(Color.white)
                .frame(width: 110, height: 36)
            Circle()
                .fill(Color.white)
                .frame(width: 44, height: 44)
                .offset(x: -22, y: -10)
            Circle()
                .fill(Color.white)
                .frame(width: 56, height: 56)
                .offset(x: 8, y: -14)
            Circle()
                .fill(Color.white)
                .frame(width: 36, height: 36)
                .offset(x: 32, y: -5)
        }
    }

    private func startCloudAnimation() {
        withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
            cloudOffset = 420
        }
    }
}

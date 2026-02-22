
//
//  ResultView.swift
//  AngrySpparrowbird
//
//  Shown after a stage ends. Displays:
//   - Success 🎉 or failure 💔 banner
//   - Stage score + bonus breakdown (Stage 2)
//   - "Stage 2 Unlocked!" badge (Stage 1 success only)
//   - Play Again / Home buttons
//

import SwiftUI

struct ResultView: View {
    let stage: StageID
    let success: Bool
    let score: Int
    let bonus: Int

    @Environment(GameViewModel.self) var gameVM

    @State private var bannerScale: CGFloat  = 0.4
    @State private var contentSlide: CGFloat = 80

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: success
                    ? [Color(red: 0.10, green: 0.40, blue: 0.10), Color(red: 0.22, green: 0.68, blue: 0.22)]
                    : [Color(red: 0.40, green: 0.08, blue: 0.08), Color(red: 0.72, green: 0.18, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Confetti emojis (success only)
            if success {
                confettiLayer
            }

            VStack(spacing: 28) {
                Spacer()

                // ── Main emoji banner ──
                Text(success ? "🎉" : "💔")
                    .font(.system(size: 90))
                    .scaleEffect(bannerScale)

                Text(success ? "Stage Cleared!" : "Game Over")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                // ── Score card ──
                scoreCard
                    .offset(y: contentSlide)

                // ── Stage 2 unlocked badge ──
                if success && stage == .stage1 {
                    unlockedBadge
                        .offset(y: contentSlide)
                }

                Spacer()

                // ── Action buttons ──
                VStack(spacing: 14) {
                    actionButton(
                        title: "Play Again",
                        icon: "arrow.clockwise",
                        color: Color(red: 0.98, green: 0.62, blue: 0.10)
                    ) {
                        stage == .stage1 ? gameVM.startStage1() : gameVM.startStage2()
                    }

                    actionButton(
                        title: "Home",
                        icon: "house.fill",
                        color: Color.white.opacity(0.25)
                    ) {
                        gameVM.goHome()
                    }
                }
                .padding(.horizontal, 40)
                .offset(y: contentSlide)

                Spacer().frame(height: 30)
            }
        }
        .onAppear { animateEntrance() }
    }

    // MARK: - Score Card

    private var scoreCard: some View {
        VStack(spacing: 12) {
            if bonus > 0 {
                scoreRow(label: "Stage Score", value: score - bonus, color: .white)
                scoreRow(label: "🐦 Bird Bonus", value: bonus, color: .yellow)
                Divider().background(Color.white.opacity(0.4))
            }
            scoreRow(label: success ? "Total Score" : "Score", value: score, color: .yellow)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.black.opacity(0.30))
        )
        .padding(.horizontal, 36)
    }

    private func scoreRow(label: String, value: Int, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Text("\(value) pts")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(color)
        }
    }

    // MARK: - Unlocked Badge

    private var unlockedBadge: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.open.fill")
                .foregroundColor(.yellow)
            Text("Stage 2 Unlocked! 🎊")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(red: 0.60, green: 0.15, blue: 0.78).opacity(0.85))
                .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1.5))
        )
        .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
    }

    // MARK: - Action Buttons

    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 28).fill(color))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Confetti Visual

    private var confettiLayer: some View {
        GeometryReader { geo in
            let confetti = ["⭐️", "🌟", "✨", "🎊", "🎈"]
            ForEach(0 ..< 14, id: \.self) { i in
                Text(confetti[i % confetti.count])
                    .font(.system(size: CGFloat.random(in: 18...32)))
                    .position(
                        x: CGFloat.random(in: 10...(geo.size.width - 10)),
                        y: CGFloat.random(in: 40...(geo.size.height * 0.55))
                    )
                    .opacity(0.7)
            }
        }
    }

    // MARK: - Entrance Animation

    private func animateEntrance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.60)) {
            bannerScale  = 1.0
            contentSlide = 0
        }
    }
}

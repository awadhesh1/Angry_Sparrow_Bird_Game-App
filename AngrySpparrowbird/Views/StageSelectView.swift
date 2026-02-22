
//
//  StageSelectView.swift
//  AngrySpparrowbird
//
//  Stage selection screen. Shows two stage cards.
//  Stage 2 is overlaid with a lock icon until Stage 1 is completed.
//

import SwiftUI

struct StageSelectView: View {
    @Environment(GameViewModel.self) var gameVM
    @State private var cardScale: [CGFloat] = [0.8, 0.8]

    var body: some View {
        ZStack {
            // Sky background
            LinearGradient(
                colors: [Color(red: 0.20, green: 0.50, blue: 0.88),
                         Color(red: 0.50, green: 0.80, blue: 1.00)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Back + title row
                HStack {
                    Button { gameVM.goHome() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.25)))
                    }
                    Spacer()
                    Text("Choose Stage")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 44)
                }
                .padding(.horizontal)

                // Stage cards
                VStack(spacing: 22) {
                    stageCard(
                        index: 0,
                        number: 1,
                        title: "Beginner",
                        subtitle: "Wooden blocks · 1 bird",
                        emoji: "🪵",
                        color1: Color(red: 0.98, green: 0.62, blue: 0.15),
                        color2: Color(red: 0.88, green: 0.38, blue: 0.05),
                        isLocked: false
                    ) {
                        gameVM.startStage1()
                    }

                    stageCard(
                        index: 1,
                        number: 2,
                        title: "Advanced",
                        subtitle: "Mixed blocks · 3 birds · Enemies",
                        emoji: "🪨",
                        color1: Color(red: 0.62, green: 0.18, blue: 0.78),
                        color2: Color(red: 0.38, green: 0.08, blue: 0.55),
                        isLocked: !gameVM.stage2Unlocked
                    ) {
                        if gameVM.stage2Unlocked { gameVM.startStage2() }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 16)
        }
        .onAppear {
            for i in 0 ..< 2 {
                let delay = Double(i) * 0.15
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                        cardScale[i] = 1.0
                    }
                }
            }
        }
    }

    // MARK: - Stage Card Builder

    @ViewBuilder
    private func stageCard(
        index: Int,
        number: Int,
        title: String,
        subtitle: String,
        emoji: String,
        color1: Color,
        color2: Color,
        isLocked: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(colors: [color1, color2],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )
                    .shadow(color: color2.opacity(0.45), radius: 14, x: 0, y: 8)

                // Content row
                HStack(spacing: 20) {
                    // Emoji icon
                    Text(emoji)
                        .font(.system(size: 54))
                        .shadow(radius: 4)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("STAGE \(number)")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundColor(.white.opacity(0.75))
                                .tracking(2)
                            Spacer()
                        }
                        Text(title)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Spacer()

                    // Arrow or lock
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title.bold())
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 22)

                // Lock overlay
                if isLocked {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black.opacity(0.35))
                    VStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        Text("Complete Stage 1 to unlock")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .frame(height: 130)
        }
        .buttonStyle(.plain)
        .scaleEffect(cardScale[index])
        .disabled(isLocked)
    }
}

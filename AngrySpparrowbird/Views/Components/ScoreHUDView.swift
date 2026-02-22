
//
//  ScoreHUDView.swift
//  AngrySpparrowbird
//
//  Translucent top HUD showing stage name, score, and remaining birds/lives.
//

import SwiftUI

struct ScoreHUDView: View {
    let stageLabel: String
    let score: Int
    let birdsRemaining: Int   // Pass 1 for Stage 1 (single bird)

    var body: some View {
        HStack {
            // Stage badge
            Text(stageLabel)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(Color.orange.opacity(0.85))
                )

            Spacer()

            // Bird icons remaining
            HStack(spacing: 4) {
                ForEach(0 ..< max(birdsRemaining, 0), id: \.self) { _ in
                    Text("🐦")
                        .font(.system(size: 16))
                }
            }

            Spacer()

            // Score counter
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
                Text("\(score)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.35))
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.5), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

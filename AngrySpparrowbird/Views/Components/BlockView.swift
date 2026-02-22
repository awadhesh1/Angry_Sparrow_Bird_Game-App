
//
//  BlockView.swift
//  AngrySpparrowbird
//
//  Renders a single wooden or stone block with crack detail.
//  Plays a scale-down + fade "explosion" animation when destroyed.
//

import SwiftUI

struct BlockView: View {
    let block: Block

    // Each destroyed block gets an animated scale-down
    @State private var exploding: Bool = false
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            if block.type == .wood {
                woodBlock
            } else {
                stoneBlock
            }
            // Crack overlays based on crackLevel (1 or 2)
            if block.crackLevel > 0 {
                crackOverlay
            }
        }
        .frame(width: block.size.width, height: block.size.height)
        .scaleEffect(exploding ? 0.01 : 1.0)
        .opacity(opacity)
        .onChange(of: block.isDestroyed) { _, destroyed in
            if destroyed { triggerExplosion() }
        }
    }

    // MARK: - Wooden Block

    private var woodBlock: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.72, green: 0.48, blue: 0.22),
                                 Color(red: 0.55, green: 0.35, blue: 0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            // Wood grain lines
            Canvas { ctx, sz in
                for i in stride(from: 4.0, through: sz.height - 2, by: 8) {
                    var line = Path()
                    line.move(to: CGPoint(x: 3, y: i))
                    line.addLine(to: CGPoint(x: sz.width - 3, y: i + 2))
                    ctx.stroke(line, with: .color(Color.brown.opacity(0.35)),
                               style: StrokeStyle(lineWidth: 1, lineCap: .round))
                }
            }
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(red: 0.42, green: 0.26, blue: 0.08), lineWidth: 1.5)
        }
    }

    // MARK: - Stone Block

    private var stoneBlock: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.65, green: 0.65, blue: 0.68),
                                 Color(red: 0.42, green: 0.42, blue: 0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            // Stone texture dots
            Canvas { ctx, sz in
                let positions: [(CGFloat, CGFloat)] = [
                    (0.25, 0.3), (0.55, 0.18), (0.72, 0.5),
                    (0.35, 0.68), (0.62, 0.78), (0.15, 0.6)
                ]
                for (fx, fy) in positions {
                    let dotRect = CGRect(x: fx * sz.width - 2, y: fy * sz.height - 2,
                                        width: 4, height: 4)
                    ctx.fill(Path(ellipseIn: dotRect),
                             with: .color(Color.gray.opacity(0.45)))
                }
            }
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(red: 0.28, green: 0.28, blue: 0.30), lineWidth: 2)
        }
    }

    // MARK: - Crack Overlay

    private var crackOverlay: some View {
        Canvas { ctx, sz in
            let cx = sz.width / 2
            let cy = sz.height / 2
            // Level-1 crack
            var c1 = Path()
            c1.move(to: CGPoint(x: cx - 5, y: 4))
            c1.addLine(to: CGPoint(x: cx, y: cy - 3))
            c1.addLine(to: CGPoint(x: cx + 8, y: sz.height - 4))
            ctx.stroke(c1, with: .color(Color.black.opacity(0.55)),
                       style: StrokeStyle(lineWidth: block.crackLevel > 1 ? 2 : 1.5, lineCap: .round))

            if block.crackLevel > 1 {
                // Level-2 additional crack
                var c2 = Path()
                c2.move(to: CGPoint(x: 4, y: cy + 5))
                c2.addLine(to: CGPoint(x: cx + 3, y: cy))
                c2.addLine(to: CGPoint(x: sz.width - 4, y: cy - 8))
                ctx.stroke(c2, with: .color(Color.black.opacity(0.50)),
                           style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            }
        }
    }

    // MARK: - Destruction Animation

    private func triggerExplosion() {
        withAnimation(.easeIn(duration: 0.25)) {
            exploding = true
            opacity   = 0
        }
    }
}

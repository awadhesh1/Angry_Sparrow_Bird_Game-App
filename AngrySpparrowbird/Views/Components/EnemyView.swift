
//
//  EnemyView.swift
//  AngrySpparrowbird
//
//  Renders a cartoonish green pig enemy.
//  Wobbles when hit; shows ✕ eyes when defeated.
//

import SwiftUI

struct EnemyView: View {
    let enemy: Enemy
    var size: CGFloat = 52

    @State private var wobble: Bool = false
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0

    private var isDefeated: Bool { enemy.isDefeated }

    var body: some View {
        ZStack {
            Canvas { ctx, sz in
                let cx = sz.width  / 2
                let cy = sz.height / 2
                let r  = min(sz.width, sz.height) / 2 - 2

                // ── Head ──
                let headRect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
                ctx.fill(Path(ellipseIn: headRect),
                         with: .color(Color(red: 0.28, green: 0.72, blue: 0.27)))
                ctx.stroke(Path(ellipseIn: headRect),
                           with: .color(Color(red: 0.15, green: 0.5, blue: 0.15)),
                           lineWidth: 2)

                // ── Snout ──
                let snoutRect = CGRect(x: cx - r * 0.38, y: cy + r * 0.15,
                                       width: r * 0.76, height: r * 0.55)
                ctx.fill(Path(ellipseIn: snoutRect),
                         with: .color(Color(red: 0.22, green: 0.60, blue: 0.22)))
                ctx.stroke(Path(ellipseIn: snoutRect),
                           with: .color(Color(red: 0.15, green: 0.45, blue: 0.15)),
                           lineWidth: 1)
                // Nostrils
                for nx in [cx - r * 0.18, cx + r * 0.18] {
                    ctx.fill(Path(ellipseIn: CGRect(x: nx - r * 0.06, y: cy + r * 0.35,
                                                    width: r * 0.12, height: r * 0.11)),
                             with: .color(Color(red: 0.12, green: 0.40, blue: 0.12)))
                }

                // ── Ears ──
                for ex in [cx - r * 0.8, cx + r * 0.8] {
                    let earRect = CGRect(x: ex - r * 0.22, y: cy - r * 0.9,
                                        width: r * 0.44, height: r * 0.44)
                    ctx.fill(Path(ellipseIn: earRect),
                             with: .color(Color(red: 0.22, green: 0.60, blue: 0.22)))
                    ctx.stroke(Path(ellipseIn: earRect),
                               with: .color(Color(red: 0.13, green: 0.44, blue: 0.13)),
                               lineWidth: 1)
                }

                // ── Eyes ──
                let eyeOffsets: [CGFloat] = [-0.30, 0.30]
                for eyeX in eyeOffsets {
                    let ex2 = cx + r * eyeX
                    let ey  = cy - r * 0.25
                    if isDefeated {
                        // ✕ eyes when defeated
                        let s: CGFloat = r * 0.2
                        var x1 = Path()
                        x1.move(to: CGPoint(x: ex2 - s, y: ey - s))
                        x1.addLine(to: CGPoint(x: ex2 + s, y: ey + s))
                        ctx.stroke(x1, with: .color(.white),
                                   style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        var x2 = Path()
                        x2.move(to: CGPoint(x: ex2 + s, y: ey - s))
                        x2.addLine(to: CGPoint(x: ex2 - s, y: ey + s))
                        ctx.stroke(x2, with: .color(.white),
                                   style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    } else {
                        // Normal eyes
                        ctx.fill(Path(ellipseIn: CGRect(x: ex2 - r * 0.18, y: ey - r * 0.18,
                                                        width: r * 0.36, height: r * 0.36)),
                                 with: .color(.white))
                        ctx.fill(Path(ellipseIn: CGRect(x: ex2 - r * 0.09, y: ey - r * 0.09,
                                                        width: r * 0.18, height: r * 0.18)),
                                 with: .color(.black))
                    }
                }
            }
            .frame(width: size, height: size)

            // Helmet (small brown dome at top)
            if !isDefeated {
                Capsule()
                    .fill(Color(red: 0.45, green: 0.28, blue: 0.08))
                    .frame(width: size * 0.55, height: size * 0.22)
                    .offset(y: -size * 0.36)
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .rotationEffect(.degrees(wobble ? 12 : 0))
        .onChange(of: enemy.health) { _, _ in
            triggerWobble()
        }
        .onChange(of: enemy.isDefeated) { _, defeated in
            if defeated { triggerDefeat() }
        }
    }

    // MARK: - Animations

    private func triggerWobble() {
        withAnimation(.easeInOut(duration: 0.08).repeatCount(4, autoreverses: true)) {
            wobble = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            wobble = false
        }
    }

    private func triggerDefeat() {
        withAnimation(.easeIn(duration: 0.35)) {
            scale   = 0.01
            opacity = 0
        }
    }
}

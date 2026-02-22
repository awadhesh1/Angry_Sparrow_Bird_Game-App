
//
//  SparrowBirdView.swift
//  AngrySpparrowbird
//
//  A fully drawn (no asset required) cartoon sparrow bird.
//  The bird rotates to align with its velocity direction while in flight.
//

import SwiftUI

struct SparrowBirdView: View {
    let bird: Bird
    var size: CGFloat = 36

    var body: some View {
        ZStack {
            // Bird body drawn with Canvas
            Canvas { ctx, sz in
                let cx = sz.width  / 2
                let cy = sz.height / 2
                let r  = min(sz.width, sz.height) / 2 - 1

                // ── Body ──
                var bodyPath = Path(ellipseIn: CGRect(x: cx - r, y: cy - r * 0.9,
                                                      width: r * 2, height: r * 1.8))
                ctx.fill(bodyPath, with: .color(.yellow))
                ctx.stroke(bodyPath, with: .color(.orange), lineWidth: 1.5)

                // ── Wing (left) ──
                var wing = Path()
                wing.move(to: CGPoint(x: cx - r * 0.3, y: cy))
                wing.addQuadCurve(to: CGPoint(x: cx - r * 1.1, y: cy + r * 0.5),
                                  control: CGPoint(x: cx - r * 0.8, y: cy - r * 0.3))
                wing.addQuadCurve(to: CGPoint(x: cx - r * 0.3, y: cy + r * 0.5),
                                  control: CGPoint(x: cx - r * 0.9, y: cy + r * 0.7))
                ctx.fill(wing, with: .color(Color(red: 1.0, green: 0.78, blue: 0.1)))
                ctx.stroke(wing, with: .color(.orange), lineWidth: 1)

                // ── Beak ──
                var beak = Path()
                beak.move(to: CGPoint(x: cx + r * 0.6, y: cy - r * 0.15))
                beak.addLine(to: CGPoint(x: cx + r * 1.1, y: cy))
                beak.addLine(to: CGPoint(x: cx + r * 0.6, y: cy + r * 0.15))
                beak.closeSubpath()
                ctx.fill(beak, with: .color(.orange))

                // ── Eye white ──
                let eyeX = cx + r * 0.2
                let eyeY = cy - r * 0.35
                ctx.fill(Path(ellipseIn: CGRect(x: eyeX - r * 0.18, y: eyeY - r * 0.18,
                                                width: r * 0.36, height: r * 0.36)),
                         with: .color(.white))
                // ── Pupil ──
                ctx.fill(Path(ellipseIn: CGRect(x: eyeX - r * 0.08, y: eyeY - r * 0.08,
                                                width: r * 0.16, height: r * 0.16)),
                         with: .color(.black))

                // ── Angry eyebrow ──
                var brow = Path()
                brow.move(to: CGPoint(x: eyeX - r * 0.18, y: eyeY - r * 0.22))
                brow.addLine(to: CGPoint(x: eyeX + r * 0.18, y: eyeY - r * 0.30))
                ctx.stroke(brow, with: .color(.black),
                           style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

                // ── Crest ──
                var crest = Path()
                crest.move(to: CGPoint(x: cx + r * 0.05, y: cy - r * 0.85))
                crest.addQuadCurve(to: CGPoint(x: cx + r * 0.30, y: cy - r),
                                   control: CGPoint(x: cx + r * 0.4, y: cy - r * 1.1))
                crest.addQuadCurve(to: CGPoint(x: cx - r * 0.15, y: cy - r * 0.8),
                                   control: CGPoint(x: cx - r * 0.05, y: cy - r * 1.05))
                ctx.fill(crest, with: .color(.orange))

                // ── Tail feathers ──
                var tail = Path()
                tail.move(to: CGPoint(x: cx - r * 0.5, y: cy + r * 0.6))
                tail.addLine(to: CGPoint(x: cx - r * 1.0, y: cy + r * 0.3))
                tail.addLine(to: CGPoint(x: cx - r * 0.9, y: cy + r * 0.9))
                tail.addLine(to: CGPoint(x: cx - r * 0.5, y: cy + r * 0.75))
                ctx.fill(tail, with: .color(.brown))
            }
            .frame(width: size, height: size)
        }
        // Rotate to match velocity direction when in flight
        .rotationEffect(.radians(bird.isLaunched ? bird.rotation : 0))
    }
}

// MARK: - Preview
#Preview {
    SparrowBirdView(bird: Bird.idle(at: .zero), size: 60)
        .padding()
}

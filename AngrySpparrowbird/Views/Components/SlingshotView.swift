
//
//  SlingshotView.swift
//  AngrySpparrowbird
//
//  Draws the slingshot Y-fork and rubber-band stretching to the bird.
//  The fork is drawn with a Path; the band connects both tips to the bird position.
//

import SwiftUI

struct SlingshotView: View {
    /// World-space position of the bird (or slingshot tip when resting).
    let birdPosition: CGPoint
    /// World-space origin (pivot / base) of the slingshot.
    let origin: CGPoint
    /// Height of the slingshot fork above the pivot.
    var forkHeight: CGFloat = 60
    /// Width between left and right fork tips.
    var forkWidth:  CGFloat = 28

    // Derived fork tip coordinates (in world space)
    private var leftTip:  CGPoint { CGPoint(x: origin.x - forkWidth / 2, y: origin.y - forkHeight) }
    private var rightTip: CGPoint { CGPoint(x: origin.x + forkWidth / 2, y: origin.y - forkHeight) }

    var body: some View {
        Canvas { ctx, _ in
            drawFork(ctx: ctx)
            drawBand(ctx: ctx)
        }
    }

    // MARK: - Fork

    private func drawFork(ctx: GraphicsContext) {
        // Pole (trunk)
        var pole = Path()
        pole.move(to: CGPoint(x: origin.x, y: origin.y + 30))
        pole.addLine(to: CGPoint(x: origin.x, y: origin.y))
        ctx.stroke(pole, with: .color(Color(red: 0.40, green: 0.24, blue: 0.06)),
                   style: StrokeStyle(lineWidth: 10, lineCap: .round))

        // Left prong
        var leftProng = Path()
        leftProng.move(to: CGPoint(x: origin.x, y: origin.y - forkHeight * 0.3))
        leftProng.addCurve(to: leftTip,
                           control1: CGPoint(x: origin.x - 5, y: origin.y - forkHeight * 0.6),
                           control2: CGPoint(x: leftTip.x + 4, y: leftTip.y + 10))
        ctx.stroke(leftProng, with: .color(Color(red: 0.40, green: 0.24, blue: 0.06)),
                   style: StrokeStyle(lineWidth: 8, lineCap: .round))

        // Right prong
        var rightProng = Path()
        rightProng.move(to: CGPoint(x: origin.x, y: origin.y - forkHeight * 0.3))
        rightProng.addCurve(to: rightTip,
                            control1: CGPoint(x: origin.x + 5, y: origin.y - forkHeight * 0.6),
                            control2: CGPoint(x: rightTip.x - 4, y: rightTip.y + 10))
        ctx.stroke(rightProng, with: .color(Color(red: 0.40, green: 0.24, blue: 0.06)),
                   style: StrokeStyle(lineWidth: 8, lineCap: .round))

        // Knots at fork tips
        for tip in [leftTip, rightTip] {
            ctx.fill(Path(ellipseIn: CGRect(x: tip.x - 5, y: tip.y - 5, width: 10, height: 10)),
                     with: .color(Color(red: 0.28, green: 0.16, blue: 0.04)))
        }
    }

    // MARK: - Rubber Band

    private func drawBand(ctx: GraphicsContext) {
        // Left band: left tip → bird
        var lb = Path()
        lb.move(to: leftTip)
        lb.addLine(to: birdPosition)
        ctx.stroke(lb, with: .color(Color(red: 0.55, green: 0.28, blue: 0.04)),
                   style: StrokeStyle(lineWidth: 3, lineCap: .round))

        // Right band: right tip → bird
        var rb = Path()
        rb.move(to: rightTip)
        rb.addLine(to: birdPosition)
        ctx.stroke(rb, with: .color(Color(red: 0.55, green: 0.28, blue: 0.04)),
                   style: StrokeStyle(lineWidth: 3, lineCap: .round))
    }
}

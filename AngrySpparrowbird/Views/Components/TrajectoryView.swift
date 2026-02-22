
//
//  TrajectoryView.swift
//  AngrySpparrowbird
//
//  Renders a dotted arc preview of the bird's ballistic trajectory
//  while the player is aiming. Dots fade out with distance.
//

import SwiftUI

struct TrajectoryView: View {
    let dots: [CGPoint]

    var body: some View {
        Canvas { ctx, _ in
            for (i, point) in dots.enumerated() {
                // Dots progressively fade away (near = opaque, far = transparent)
                let progress  = Double(i) / Double(max(dots.count - 1, 1))
                let opacity   = 1.0 - progress * 0.85
                let dotRadius = CGFloat(5.5 - progress * 3.0)

                let dotRect = CGRect(
                    x: point.x - dotRadius,
                    y: point.y - dotRadius,
                    width:  dotRadius * 2,
                    height: dotRadius * 2
                )
                ctx.fill(
                    Path(ellipseIn: dotRect),
                    with: .color(Color.white.opacity(opacity))
                )
                // Thin outline for visibility against bright backgrounds
                ctx.stroke(
                    Path(ellipseIn: dotRect),
                    with: .color(Color.orange.opacity(opacity * 0.6)),
                    lineWidth: 0.5
                )
            }
        }
    }
}

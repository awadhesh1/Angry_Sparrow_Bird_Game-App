
//
//  GameplayView.swift
//  AngrySpparrowbird
//
//  Wrapper view that selects the correct stage view based on the
//  current screen value in GameViewModel. Also handles back navigation.
//

import SwiftUI

struct GameplayView: View {
    let stage: StageID
    @Environment(GameViewModel.self) var gameVM

    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                if stage == .stage1 {
                    Stage1View()
                } else {
                    Stage2View()
                }
            }

            // ── Back / Home button ──
            Button {
                withAnimation { gameVM.goToStageSelect() }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.75))
                    .padding(16)
                    .padding(.top, 44)   // safe-area offset
            }
        }
    }
}

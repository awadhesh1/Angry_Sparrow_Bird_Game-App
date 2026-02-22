
//
//  ContentView.swift
//  AngrySpparrowbird
//
//  Root view. Uses @Environment (not @EnvironmentObject) for @Observable GameViewModel.
//

import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) var gameVM

    var body: some View {
        ZStack {
            switch gameVM.currentScreen {

            case .home:
                HomeView()
                    .transition(.opacity)

            case .stageSelect:
                StageSelectView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))

            case .stage1:
                GameplayView(stage: .stage1)
                    .transition(.move(edge: .bottom).combined(with: .opacity))

            case .stage2:
                GameplayView(stage: .stage2)
                    .transition(.move(edge: .bottom).combined(with: .opacity))

            case let .result(stage, success, score, bonus):
                ResultView(stage: stage, success: success, score: score, bonus: bonus)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: gameVM.currentScreen)
    }
}

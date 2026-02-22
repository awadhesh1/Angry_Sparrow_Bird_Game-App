
//
//  GameViewModel.swift
//  AngrySpparrowbird
//
//  Top-level app state: screen navigation + stage-unlock persistence.
//  Uses @Observable (Swift 5.9+) instead of ObservableObject to avoid
//  the Swift 6 actor-isolation conflict with @MainActor + ObservableObject.
//

import SwiftUI

// MARK: - ViewModel

@Observable
class GameViewModel {

    // MARK: - State

    /// The currently displayed screen; drives root view switching.
    var currentScreen: AppScreen = .home

    /// Whether Stage 2 is accessible. Persisted to UserDefaults.
    var stage2Unlocked: Bool

    /// Cumulative score across stages.
    var totalScore: Int = 0

    // MARK: - Persistence Key

    private let unlockedKey = "stage2Unlocked"

    // MARK: - Init

    init() {
        stage2Unlocked = UserDefaults.standard.bool(forKey: "stage2Unlocked")
    }

    // MARK: - Navigation

    func goHome()          { currentScreen = .home }
    func goToStageSelect() { currentScreen = .stageSelect }
    func startStage1()     { currentScreen = .stage1 }
    func startStage2()     { currentScreen = .stage2 }

    /// Called by stage VMs when a stage ends.
    func stageEnded(stage: StageID, success: Bool, score: Int, bonus: Int = 0) {
        if success {
            totalScore += score + bonus
            if stage == .stage1 { unlockStage2() }
        }
        currentScreen = .result(stage: stage, success: success, score: score, bonus: bonus)
    }

    // MARK: - Stage Unlock

    private func unlockStage2() {
        stage2Unlocked = true
        UserDefaults.standard.set(true, forKey: unlockedKey)
    }

    /// Debug / reset helper.
    func resetProgress() {
        stage2Unlocked = false
        totalScore = 0
        UserDefaults.standard.set(false, forKey: unlockedKey)
    }
}

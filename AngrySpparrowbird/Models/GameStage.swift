
//
//  GameStage.swift
//  AngrySpparrowbird
//
//  Defines the app's navigation screens and stage identifiers.
//

import Foundation

// MARK: - Stage Identifier

/// Identifies which game stage is being played.
enum StageID: Int {
    case stage1 = 1
    case stage2 = 2
}

// MARK: - App Navigation

/// Represents every distinct screen in the app.
/// The root view switches on this enum to present the correct UI.
enum AppScreen: Equatable {
    case home
    case stageSelect
    case stage1
    case stage2
    /// Show after a stage ends: carries results for the result screen.
    case result(stage: StageID, success: Bool, score: Int, bonus: Int)

    // Equatable conformance for associated-value case
    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home): return true
        case (.stageSelect, .stageSelect): return true
        case (.stage1, .stage1): return true
        case (.stage2, .stage2): return true
        case let (.result(s1, ok1, sc1, b1), .result(s2, ok2, sc2, b2)):
            return s1 == s2 && ok1 == ok2 && sc1 == sc2 && b1 == b2
        default: return false
        }
    }
}

// MARK: - Stage Equatable
extension StageID: Equatable {}

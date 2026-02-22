
//
//  AngrySpparrowbirdApp.swift
//  AngrySpparrowbird
//
//  App entry point. Uses @State (not @StateObject) since GameViewModel is now
//  @Observable. Injects via .environment() (not .environmentObject()).
//

import SwiftUI

@main
struct AngrySpparrowbirdApp: App {
    /// @Observable classes are owned by @State, not @StateObject.
    @State private var gameViewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(gameViewModel)  // .environment() for @Observable
        }
    }
}

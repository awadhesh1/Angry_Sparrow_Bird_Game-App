//
//  AngrySpparrowbirdApp.swift
//  AngrySpparrowbird
//
//  Created by Awadhesh on 2026-02-22.
//

import SwiftUI
import CoreData

@main
struct AngrySpparrowbirdApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

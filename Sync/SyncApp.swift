//
//  SyncApp.swift
//  Sync
//
//  Created by Nicho on 23/07/2024.
//

import SwiftUI

@main
struct SyncApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

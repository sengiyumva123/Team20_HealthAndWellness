//
//  REMindApp.swift
//  REMind
//
//  Created by Sengi Mathias on 4/12/25.
//

import SwiftUI

@main
struct REMindApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

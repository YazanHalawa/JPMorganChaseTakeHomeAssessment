//
//  JPMorganChaseTakeHomeAssessmentApp.swift
//  JPMorganChaseTakeHomeAssessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import SwiftUI

@main
struct JPMorganChaseTakeHomeAssessmentApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

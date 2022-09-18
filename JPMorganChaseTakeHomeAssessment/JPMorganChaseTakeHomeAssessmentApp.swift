//
//  JPMorganChaseTakeHomeAssessmentApp.swift
//  JPMorganChaseTakeHomeAssessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import SwiftUI

@main
struct JPMorganChaseTakeHomeAssessmentApp: App {
    
    init() {
        NetworkMonitor.shared.startMonitoring()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//
//  KorongaApp.swift
//  Koronga
//
//  Created by Sam Hawthorne on 2024-07-16.
//

import SwiftUI
import FamilyControls
import os

@main
struct KorongaApp: App {
    @StateObject private var appUsageController = AppUsageController()
    
    init() {
        let logger = Logger(subsystem: "com.yourdomain.Koronga", category: "App")
        logger.info("App initializing")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appUsageController)
                .onAppear {
                    let logger = Logger(subsystem: "com.yourdomain.Koronga", category: "App")
                    logger.info("ContentView appeared")
                }
        }
    }
}

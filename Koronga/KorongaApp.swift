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
        
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                logger.info("Authorization requested successfully")
            } catch {
                logger.error("Failed to request authorization: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ShieldView()
                .environmentObject(appUsageController)
                .onAppear {
                    let logger = Logger(subsystem: "com.yourdomain.Koronga", category: "App")
                    logger.info("ShieldView appeared")
                }
        }
    }
}

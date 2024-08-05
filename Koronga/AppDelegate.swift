//
//  AppDelegate.swift
//  Koronga
//
//  Created by Sam Hawthorne on 2024-08-04.
//

import UIKit
import FamilyControls

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            } catch {
                print("Failed to request authorization: \(error)")
            }
        }
        return true
    }
}

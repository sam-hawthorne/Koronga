//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Sam Hawthorne on 2024-07-16.
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import UserNotifications

class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Show a motivational message
            sendNotification(title: "Stay focused!", body: "You can do it!")
            completionHandler(.close)
        case .secondaryButtonPressed:
            // Allow a brief break
            allowBriefBreak(for: application)
            completionHandler(.close)
        @unknown default:
            completionHandler(.none)
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle shield actions for web domains if needed
        completionHandler(.none)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle shield actions for activity categories if needed
        completionHandler(.none)
    }
    
    private func allowBriefBreak(for application: ApplicationToken) {
        let store = ManagedSettingsStore()
        store.shield.applications?.remove(application)
        
        // Set a timer to re-restrict the app after the break
        DispatchQueue.main.asyncAfter(deadline: .now() + 300) {
            if let selectedApps = UserDefaults.standard.data(forKey: "SelectedApps"),
               let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectedApps) {
                store.shield.applications = selection.applicationTokens
            }
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}


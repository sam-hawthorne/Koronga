//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created by Sam Hawthorne on 2024-07-16.
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import UserNotifications

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Start monitoring and restricting apps
        let store = ManagedSettingsStore()
        if let selectedApps = UserDefaults.standard.data(forKey: "SelectedApps"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectedApps) {
            store.shield.applications = selection.applicationTokens
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // End restrictions
        let store = ManagedSettingsStore()
        store.shield.applications = nil
        
        // Provide a summary or reward
        sendNotification(title: "Great job!", body: "You've completed your focus session.")
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        // Handle threshold reached events if needed
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        // Handle interval start warnings if needed
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        // Handle interval end warnings if needed
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

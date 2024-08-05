//
//  AppUsageController.swift
//  Koronga
//
//  Created by Sam Hawthorne on 2024-08-04.
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftUI

class AppUsageController: ObservableObject {
    @Published var selectedApps: [AppUsageModel] = []
    @Published var selection = FamilyActivitySelection()
    
    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    private let coreDataManager = CoreDataManager.shared
    
    private let dailyActivityName = DeviceActivityName("daily")

    init() {
        setupMonitoring()
        loadSelectedApps()
    }

    private func setupMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try center.startMonitoring(dailyActivityName, during: schedule)
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }

    func loadSelectedApps() {
        let savedTokenIdentifiers = Set(coreDataManager.fetchApplicationProfiles())
        
        if let selectionData = UserDefaults.standard.data(forKey: "FamilyActivitySelection"),
           let savedSelection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectionData) {
            self.selection = savedSelection
        }
        
        self.selectedApps = selection.applicationTokens
            .filter { savedTokenIdentifiers.contains("\($0.hashValue)") }
            .map { token in
                let displayName = getApplicationDisplayName(for: token)
                return AppUsageModel(application: token, displayName: displayName, usageTime: 0, isRestricted: false)
            }
    }

    private func getApplicationDisplayName(for token: ApplicationToken) -> String {
        if let application = try? Application(token: token) {
            return application.localizedDisplayName ?? "Unknown App"
        }
        return "Unknown App"
    }

    func toggleRestriction(for app: AppUsageModel) {
        if let index = selectedApps.firstIndex(where: { $0.id == app.id }) {
            selectedApps[index].isRestricted.toggle()
            updateRestrictions()
        }
    }

    private func updateRestrictions() {
        let restrictedApps = Set(selectedApps.filter { $0.isRestricted }.map { $0.application })
        store.shield.applications = restrictedApps.isEmpty ? nil : restrictedApps
    }

    func saveSelectedApps() {
        if let encodedData = try? JSONEncoder().encode(selection) {
            UserDefaults.standard.set(encodedData, forKey: "FamilyActivitySelection")
        }
        
        for app in selectedApps {
            let profile = ApplicationProfile(applicationToken: app.application)
            coreDataManager.saveApplicationProfile(profile)
        }
        
        updateRestrictions()
    }

    func setDailyGoal(for app: AppUsageModel, goal: TimeInterval) {
        if let index = selectedApps.firstIndex(where: { $0.id == app.id }) {
            selectedApps[index].dailyGoal = goal
        }
    }

    func setWeeklyGoal(for app: AppUsageModel, goal: TimeInterval) {
        if let index = selectedApps.firstIndex(where: { $0.id == app.id }) {
            selectedApps[index].weeklyGoal = goal
        }
    }
    
    // MARK: - Family Activity Selection Handling
    
    func updateSelectionAndSave() {
        // Update the selection based on the current selectedApps
        let updatedTokens = Set(selectedApps.map { $0.application })
        selection.applicationTokens = updatedTokens
        
        // Save the updated selection
        saveSelectedApps()
    }
    
    // MARK: - Device Activity Reporting
    
    func fetchDeviceActivityReport(for dateInterval: DateInterval) {
        // Implement fetching of device activity report
        // This will depend on how you've set up your DeviceActivityMonitorExtension
    }
    
    // MARK: - Utility Methods
    
    func getAppUsageModel(for token: ApplicationToken) -> AppUsageModel? {
        return selectedApps.first { $0.application == token }
    }
}

//
//  ShieldManager.swift
//  Koronga
//
//  Created by Sam Hawthorne on 2024-08-04.
//

import SwiftUI
import FamilyControls
import ManagedSettings

class ShieldManager: ObservableObject {
    @Published var discouragedSelections = FamilyActivitySelection()
    
    private let store = ManagedSettingsStore()
    
    func updateRestrictions(restrictedApps: Set<ApplicationToken>, restrictedCategories: Set<ActivityCategoryToken>) {
        store.shield.applications = restrictedApps.isEmpty ? nil : restrictedApps
        store.shield.applicationCategories = restrictedCategories.isEmpty ? nil : .specific(restrictedCategories)
        store.shield.webDomainCategories = restrictedCategories.isEmpty ? nil : .specific(restrictedCategories)
    }
    
    func shieldActivities() {
        store.clearAllSettings()
                     
        let applications = discouragedSelections.applicationTokens
        let categories = discouragedSelections.categoryTokens
        
        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        store.shield.webDomainCategories = categories.isEmpty ? nil : .specific(categories)
        
        // Save application profiles to CoreData
        for token in applications {
            let profile = ApplicationProfile(applicationToken: token)
            CoreDataManager.shared.saveApplicationProfile(profile)
        }
    }
    
    func loadShieldedApps() {
        let savedTokenIdentifiers = Set(CoreDataManager.shared.fetchApplicationProfiles())
        
        // Filter the current selection based on saved identifiers
        discouragedSelections.applicationTokens = discouragedSelections.applicationTokens.filter { token in
            savedTokenIdentifiers.contains("\(token.hashValue)")
        }
    }
}

//
//  AppUsageModel.swift
//  Koronga
//
//  Created by Sam Hawthorne on 2024-08-04.
//

import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

struct AppUsageModel: Identifiable, Equatable {
    let id = UUID()
    let application: ApplicationToken
    var displayName: String
    var usageTime: TimeInterval
    var isRestricted: Bool
    var dailyGoal: TimeInterval?
    var weeklyGoal: TimeInterval?
    
    static func == (lhs: AppUsageModel, rhs: AppUsageModel) -> Bool {
        lhs.id == rhs.id
    }
}


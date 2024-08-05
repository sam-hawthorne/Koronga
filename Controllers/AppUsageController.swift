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
    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    @Published var selection = FamilyActivitySelection()
    
    private let dailyActivityName = DeviceActivityName("daily")

    init() {
        print("AppUsageController initialized")
        setupMonitoring()
    }

    private func setupMonitoring() {
        print("Setting up monitoring")
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            print("Monitoring started successfully")
            try center.startMonitoring(dailyActivityName, during: schedule)
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }

    func fetchSelectedApps() {
        selectedApps = selection.applicationTokens.map { token in
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

    func presentActivitySelection() {
            Task {
                await MainActor.run {
                    let picker = FamilyActivityPicker(selection: Binding(
                        get: { self.selection },
                        set: { newValue in
                            self.selection = newValue
                            self.fetchSelectedApps()
                        }
                    ))
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        let hostingController = UIHostingController(rootView: picker)
                        window.rootViewController?.present(hostingController, animated: true)
                    }
                }
            }
        }
}

struct DeviceActivityReportView: View {
    @ObservedObject var controller: AppUsageController
    
    var body: some View {
        DeviceActivityReport(DeviceActivityReport.Context("daily"), filter: DeviceActivityFilter(
            segment: .daily(during: Calendar.current.dateInterval(of: .day, for: Date())!),
            users: .all,
            devices: .init([.iPhone, .iPad])
        ))
        .onAppear {
            // You might want to update your controller's data here
            // or use a custom DeviceActivityReportExtension to handle the data
        }
    }
}







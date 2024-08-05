//
//  ContentView.swift
//  Koronga
//
//  Created by Sam Hawthorne on 2024-08-04.
//
//
import SwiftUI
import FamilyControls

struct ContentView: View {
    @StateObject private var controller = AppUsageController()
    @State private var isShowingPicker = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Selected Apps")) {
                    ForEach(controller.selectedApps) { app in
                        AppUsageRow(app: app, controller: controller)
                    }
                }
                
                Section {
                    Button("Select Apps") {
                        isShowingPicker = true
                    }
                }
            }
            .navigationTitle("App Usage")
            .sheet(isPresented: $isShowingPicker) {
                ActivityPickerView(selection: $controller.selection, isPresented: $isShowingPicker)
            }
        }
    }
}

struct ActivityPickerView: View {
    @Binding var selection: FamilyActivitySelection
    @Binding var isPresented: Bool
    @EnvironmentObject var controller: AppUsageController
    
    var body: some View {
        NavigationView {
            FamilyActivityPicker(selection: $selection)
                .navigationTitle("Choose Activities")
                .navigationBarItems(trailing: Button("Save") {
                    controller.saveSelectedApps()
                    isPresented = false
                })
        }
    }
}

struct AppUsageRow: View {
    let app: AppUsageModel
    @ObservedObject var controller: AppUsageController
    
    var body: some View {
        HStack {
            Text(app.displayName)
            Spacer()
            Text(formatTime(app.usageTime))
            Toggle("", isOn: Binding(
                get: { app.isRestricted },
                set: { _ in controller.toggleRestriction(for: app) }
            ))
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time) ?? "0m"
    }
}

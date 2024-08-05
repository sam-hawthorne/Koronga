//
//  ContentView.swift
//  Koronga
//
//  Created by Sam Hawthorne on 2024-08-04.
//
//
import SwiftUI

struct ContentView: View {
    @StateObject private var controller = AppUsageController()
    
    var body: some View {
        NavigationView {
            VStack {
                DeviceActivityReportView(controller: controller)
                
                Button("Select Apps") {
                    controller.presentActivitySelection()
                }
            }
            .navigationTitle("App Usage")
        }
    }
}

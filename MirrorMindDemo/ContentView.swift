//
//  ContentView.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//  Updated for Phase 3 - Bluetooth Integration
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - Phase 3 Dashboard
            BiometricDashboardView()
                .tabItem {
                    Image(systemName: "heart.circle.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            // Biometric Monitoring Tab
            BiometricMonitoringView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("Monitor")
                }
                .tag(1)
            
            // Emotion Recognition Tab (Phase 2 Integration)
            EmotionIntegrationView()
                .tabItem {
                    Image(systemName: "face.smiling")
                    Text("Emotion")
                }
                .tag(2)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

// MARK: - Placeholder Views for Integration

struct EmotionIntegrationView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "face.smiling.inverse")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Emotion Recognition")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Integrated with Phase 2")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("This feature combines camera-based emotion detection with biometric monitoring for comprehensive mood and health tracking.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Start Integrated Session") {
                    // Integration with Phase 2 emotion recognition
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Emotion Integration")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Phase 3 - Biometric") {
                    NavigationLink("Biometric Settings") {
                        BiometricSettingsView()
                    }
                    NavigationLink("SmartBand Configuration") {
                        SmartBandConfigView()
                    }
                }
                
                Section("Phase 2 - Emotion") {
                    NavigationLink("Emotion Settings") {
                        EmotionSettingsPlaceholder()
                    }
                    NavigationLink("Camera Configuration") {
                        CameraConfigPlaceholder()
                    }
                }
                
                Section("Data Storage") {
                    NavigationLink("Local Storage Settings") {
                        LocalStorageSettingsPlaceholder()
                    }
                    NavigationLink("Data Export") {
                        DataExportPlaceholder()
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("Phase 3.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("Bluetooth Integration")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SmartBandConfigView: View {
    var body: some View {
        List {
            Section("Device Information") {
                HStack {
                    Text("Device Name")
                    Spacer()
                    Text("MirrorMind-SmartBand")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Service UUID")
                    Spacer()
                    Text("12345678-1234...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Connection Settings") {
                Toggle("Auto-reconnect", isOn: .constant(true))
                Toggle("Background monitoring", isOn: .constant(false))
            }
            
            Section("Data Settings") {
                Picker("Update Frequency", selection: .constant(0)) {
                    Text("Real-time").tag(0)
                    Text("Every 5 seconds").tag(1)
                    Text("Every 10 seconds").tag(2)
                }
            }
        }
        .navigationTitle("SmartBand Config")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Placeholder views for settings
struct EmotionSettingsPlaceholder: View {
    var body: some View {
        Text("Phase 2 Emotion Settings")
            .navigationTitle("Emotion Settings")
    }
}

struct CameraConfigPlaceholder: View {
    var body: some View {
        Text("Camera Configuration")
            .navigationTitle("Camera Config")
    }
}

struct DataCorrelationPlaceholder: View {
    var body: some View {
        Text("Data Correlation Settings")
            .navigationTitle("Data Correlation")
    }
}

struct LocalStorageSettingsPlaceholder: View {
    var body: some View {
        Text("Local Storage Configuration")
            .navigationTitle("Storage Settings")
    }
}

struct DataExportPlaceholder: View {
    var body: some View {
        Text("Data Export Options")
            .navigationTitle("Export Data")
    }
}

#Preview {
    ContentView()
}

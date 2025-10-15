//
//  BiometricMonitoringView.swift
//  MirrorMindDemo
//
//  Created on Phase 3 - Bluetooth Integration
//

import SwiftUI
import Combine

/// Main view for biometric monitoring with SmartBand integration
struct BiometricMonitoringView: View {
    @StateObject private var biometricManager = BiometricManager()
    @State private var showingIntegratedMode = false
    @State private var showingSessionStats = false
    @State private var showingConnectionHelp = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    headerSection
                    
                    // Connection Status Card
                    connectionStatusCard
                    
                    // Current Data Display
                    if biometricManager.isActive {
                        currentDataSection
                    }
                    
                    // Session Controls
                    sessionControlsSection
                    
                    // Session Statistics
                    if biometricManager.isActive {
                        sessionStatsSection
                    }
                    
                    // Recent Readings
                    recentReadingsSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Biometric Monitor")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Connection Help", systemImage: "questionmark.circle") {
                            showingConnectionHelp = true
                        }
                        
                        Button("Session Statistics", systemImage: "chart.bar") {
                            showingSessionStats = true
                        }
                        
                        Toggle("Integrated Mode", isOn: $showingIntegratedMode)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingConnectionHelp) {
            ConnectionHelpView()
        }
        .sheet(isPresented: $showingSessionStats) {
            SessionStatsView(manager: biometricManager)
        }
        .alert("Error", isPresented: .constant(biometricManager.errorMessage != nil)) {
            Button("OK") {
                // Clear error message logic would go here
            }
        } message: {
            Text(biometricManager.errorMessage ?? "")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("MirrorMind SmartBand")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if showingIntegratedMode {
                    Text("Integrated Mode")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
            
            Text("Real-time biometric monitoring with emotion correlation")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Connection Status Card
    private var connectionStatusCard: some View {
        HStack {
            // Status Indicator
            Circle()
                .fill(colorForConnectionStatus(biometricManager.connectionStatus))
                .frame(width: 20, height: 20)
                .overlay {
                    if biometricManager.connectionStatus == .scanning {
                        ProgressView()
                            .scaleEffect(0.6)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: systemImageForConnectionStatus(biometricManager.connectionStatus))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Connection Status")
                    .font(.headline)
                
                Text(biometricManager.connectionStatus.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Help") {
                showingConnectionHelp = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Current Data Section
    private var currentDataSection: some View {
        VStack(spacing: 16) {
            Text("Live Biometric Data")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let currentData = biometricManager.currentBiometricData {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    // Heart Rate Card
                    BiometricDataCard(
                        title: "Heart Rate",
                        value: currentData.heartRateStatus,
                        subtitle: currentData.heartRateCategory.rawValue,
                        icon: "heart.fill",
                        color: colorForHeartRateCategory(currentData.heartRateCategory)
                    )
                    
                    // Temperature Card
                    BiometricDataCard(
                        title: "Temperature",
                        value: currentData.formattedTemperature,
                        subtitle: currentData.temperatureStatus.rawValue,
                        icon: "thermometer",
                        color: colorForTemperatureStatus(currentData.temperatureStatus)
                    )
                    
                    // Sensor Quality Card
                    BiometricDataCard(
                        title: "Sensor Quality",
                        value: currentData.sensorQuality.rawValue,
                        subtitle: "IR: \(currentData.irValue)",
                        icon: "sensor.fill",
                        color: colorForSensorQuality(currentData.sensorQuality)
                    )
                    
                    // Finger Detection Card
                    BiometricDataCard(
                        title: "Contact",
                        value: currentData.fingerDetected ? "Detected" : "No Contact",
                        subtitle: currentData.fingerDetected ? "Good" : "Place Finger",
                        icon: currentData.fingerDetected ? "hand.raised.fill" : "hand.raised.slash.fill",
                        color: currentData.fingerDetected ? .green : .orange
                    )
                }
            } else {
                Text("No data received yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Session Controls
    private var sessionControlsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Main session control button
                Button(action: {
                    if showingIntegratedMode {
                        // Would integrate with camera and emotion services
                        biometricManager.toggleSession()
                    } else {
                        biometricManager.toggleSession()
                    }
                }) {
                    HStack {
                        Image(systemName: biometricManager.isActive ? "stop.circle.fill" : "play.circle.fill")
                        Text(biometricManager.isActive ? "Stop Session" : "Start Session")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(biometricManager.isActive ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                // Secondary controls
                Menu {
                    Toggle("Auto-reconnect", isOn: .constant(true))
                    Button("Clear Data") { }
                    Button("Export Session") { }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                }
            }
            
            // Session duration display
            if biometricManager.isActive, let stats = biometricManager.getCurrentSessionStats() {
                HStack {
                    Text("Session Duration: \(formatDuration(stats.duration))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Readings: \(stats.totalReadings)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Session Stats Section
    private var sessionStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Statistics")
                .font(.headline)
            
            if let stats = biometricManager.getCurrentSessionStats() {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    StatCard(
                        title: "Duration",
                        value: formatDuration(stats.duration),
                        icon: "clock.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Valid HR",
                        value: "\(Int(stats.validHeartRatePercentage))%",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Avg HR",
                        value: stats.averageHeartRate.map { "\(Int($0))" } ?? "--",
                        icon: "heart.fill",
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Recent Readings Section
    private var recentReadingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Readings")
                .font(.headline)
            
            if !biometricManager.integratedReadings.isEmpty {
                LazyVStack(spacing: 8) {
                    ForEach(biometricManager.integratedReadings.suffix(5).reversed(), id: \.id) { reading in
                        ReadingRowView(reading: reading)
                    }
                }
            } else {
                Text("No readings available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Supporting Views

struct BiometricDataCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ReadingRowView: View {
    let reading: BiometricManager.IntegratedReading
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if reading.biometricData.validHeartRate {
                        Text("\(Int(reading.biometricData.heartRate)) BPM")
                            .fontWeight(.medium)
                    } else {
                        Text("-- BPM")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(reading.biometricData.formattedTemperature)
                        .foregroundColor(.secondary)
                }
                
                Text(reading.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if reading.hasEmotionData {
                Image(systemName: "face.smiling")
                    .foregroundColor(.blue)
            }
            
            Circle()
                .fill(colorForSensorQuality(reading.biometricData.sensorQuality))
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
    
    func colorForSensorQuality(_ quality: SensorQuality) -> Color {
        switch quality {
        case .noContact, .poorContact: return .red
        case .fair: return .orange
        case .good: return .yellow
        case .excellent: return .green
        }
    }
}

// MARK: - Helper Views

struct ConnectionHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    helpSection(
                        title: "SmartBand Not Found",
                        icon: "magnifyingglass.circle",
                        solutions: [
                            "Ensure SmartBand is powered on",
                            "Check battery level",
                            "Move closer (within 10 meters)",
                            "Enable Bluetooth on device"
                        ]
                    )
                    
                    helpSection(
                        title: "Connection Drops",
                        icon: "wifi.slash",
                        solutions: [
                            "Stay within range",
                            "Check battery levels",
                            "Restart Bluetooth",
                            "Keep app in foreground"
                        ]
                    )
                    
                    helpSection(
                        title: "No Heart Rate",
                        icon: "heart.slash",
                        solutions: [
                            "Place finger firmly on sensor",
                            "Keep finger still",
                            "Clean sensor surface",
                            "Wait 5-10 seconds"
                        ]
                    )
                }
                .padding()
            }
            .navigationTitle("Connection Help")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func helpSection(title: String, icon: String, solutions: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(solutions, id: \.self) { solution in
                    HStack(alignment: .top) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text(solution)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

struct SessionStatsView: View {
    @ObservedObject var manager: BiometricManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let summary = manager.sessionSummary {
                        SessionSummaryCard(summary: summary)
                    } else if manager.isActive, let stats = manager.getCurrentSessionStats() {
                        CurrentSessionCard(stats: stats)
                    } else {
                        Text("No session data available")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 200)
                    }
                }
                .padding()
            }
            .navigationTitle("Session Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SessionSummaryCard: View {
    let summary: BiometricManager.SessionSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Summary")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Duration",
                    value: summary.formattedDuration,
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Readings",
                    value: "\(summary.totalReadings)",
                    icon: "list.bullet",
                    color: .green
                )
                
                if let avgHR = summary.averageHeartRate {
                    StatCard(
                        title: "Avg HR",
                        value: "\(Int(avgHR))",
                        icon: "heart.fill",
                        color: .red
                    )
                }
                
                if let hrv = summary.heartRateVariability {
                    StatCard(
                        title: "HR Range",
                        value: "\(Int(hrv))",
                        icon: "waveform.path",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CurrentSessionCard: View {
    let stats: BiometricManager.SessionStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Session")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Duration",
                    value: formatDuration(stats.duration),
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Readings/Min",
                    value: String(format: "%.1f", stats.readingsPerMinute),
                    icon: "speedometer",
                    color: .green
                )
                
                StatCard(
                    title: "Valid %",
                    value: "\(Int(stats.validHeartRatePercentage))%",
                    icon: "checkmark.circle.fill",
                    color: .orange
                )
                
                if let avgHR = stats.averageHeartRate {
                    StatCard(
                        title: "Avg HR",
                        value: "\(Int(avgHR))",
                        icon: "heart.fill",
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Helper Functions

private extension BiometricMonitoringView {
    func colorForConnectionStatus(_ status: BiometricManager.ConnectionStatus) -> Color {
        switch status {
        case .disconnected: return .red
        case .scanning: return .orange
        case .connecting: return .yellow
        case .connected: return .green
        }
    }
    
    func systemImageForConnectionStatus(_ status: BiometricManager.ConnectionStatus) -> String {
        switch status {
        case .disconnected: return "xmark"
        case .scanning: return "magnifyingglass"
        case .connecting: return "arrow.triangle.2.circlepath"
        case .connected: return "checkmark"
        }
    }
    
    func colorForHeartRateCategory(_ category: HeartRateCategory) -> Color {
        switch category {
        case .unknown: return .gray
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .orange
        case .high: return .red
        }
    }
    
    func colorForTemperatureStatus(_ status: TemperatureStatus) -> Color {
        switch status {
        case .unknown: return .gray
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .red
        }
    }
    
    func colorForSensorQuality(_ quality: SensorQuality) -> Color {
        switch quality {
        case .noContact, .poorContact: return .red
        case .fair: return .orange
        case .good: return .yellow
        case .excellent: return .green
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    

}



// MARK: - Preview

#Preview {
    BiometricMonitoringView()
}
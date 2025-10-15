//
//  BiometricDashboardView.swift
//  MirrorMindDemo
//
//  Created on Phase 3 - Bluetooth Integration
//

import SwiftUI
import Charts
import Combine

/// Comprehensive dashboard view combining biometric monitoring with emotion correlation
struct BiometricDashboardView: View {
    @StateObject private var biometricManager = BiometricManager()
    @State private var selectedTab = 0
    @State private var showingSettings = false
    @State private var timeRange: TimeRange = .last30Minutes
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with quick stats
                headerSection
                
                // Tab selection
                Picker("View", selection: $selectedTab) {
                    Text("Live").tag(0)
                    Text("Charts").tag(1)
                    Text("History").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    liveMonitoringView
                        .tag(0)
                    
                    chartsView
                        .tag(1)
                    
                    historyView
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Biometric Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        timeRange = timeRange.next()
                    } label: {
                        Text(timeRange.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                    
                    Button("Settings") {
                        showingSettings = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            BiometricSettingsView()
        }
        .onAppear {
            if !biometricManager.isActive {
                biometricManager.startSession(withEmotionIntegration: false)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Connection status banner
            connectionBanner
            
            // Quick stats row
            if biometricManager.isActive {
                quickStatsRow
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var connectionBanner: some View {
        HStack {
            // Status indicator
            Circle()
                .fill(connectionStatusColor)
                .frame(width: 12, height: 12)
            
            Text(biometricManager.connectionStatus.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            if biometricManager.isActive, let stats = biometricManager.getCurrentSessionStats() {
                Text(formatDuration(stats.duration))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(connectionStatusColor.opacity(0.1))
        .cornerRadius(20)
    }
    
    private var quickStatsRow: some View {
        HStack(spacing: 20) {
            if let currentData = biometricManager.currentBiometricData {
                QuickStatView(
                    icon: "heart.fill",
                    value: currentData.validHeartRate ? "\(Int(currentData.heartRate))" : "--",
                    label: "BPM",
                    color: .red
                )
                
                QuickStatView(
                    icon: "thermometer",
                    value: String(format: "%.1f", currentData.temperature),
                    label: "°C",
                    color: .orange
                )
                
                QuickStatView(
                    icon: "sensor.fill",
                    value: currentData.sensorQuality.rawValue,
                    label: "Quality",
                    color: colorForSensorQuality(currentData.sensorQuality)
                )
            }
        }
    }
    
    // MARK: - Live Monitoring View
    private var liveMonitoringView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Real-time biometric cards
                if let currentData = biometricManager.currentBiometricData {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        LiveDataCard(
                            title: "Heart Rate",
                            currentValue: currentData.validHeartRate ? "\(Int(currentData.heartRate)) BPM" : "Calculating...",
                            status: currentData.heartRateCategory.rawValue,
                            icon: "heart.fill",
                            color: colorForHeartRateCategory(currentData.heartRateCategory),
                            trend: calculateHeartRateTrend()
                        )
                        
                        LiveDataCard(
                            title: "Temperature",
                            currentValue: currentData.formattedTemperature,
                            status: currentData.temperatureStatus.rawValue,
                            icon: "thermometer",
                            color: colorForTemperatureStatus(currentData.temperatureStatus),
                            trend: calculateTemperatureTrend()
                        )
                    }
                    
                    // Integrated emotion-biometric correlation
                    if let lastReading = biometricManager.integratedReadings.last,
                       lastReading.hasEmotionData {
                        CorrelationCard(reading: lastReading)
                    }
                }
                
                // Recent readings list
                RecentReadingsList(readings: Array(biometricManager.integratedReadings.suffix(10)))
            }
            .padding()
        }
    }
    
    // MARK: - Charts View
    private var chartsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Heart rate chart
                ChartCard(title: "Heart Rate Trend") {
                    heartRateChart
                }
                
                // Temperature chart
                ChartCard(title: "Temperature Trend") {
                    temperatureChart
                }
                
                // Correlation chart
                if biometricManager.integratedReadings.contains(where: { $0.hasEmotionData }) {
                    ChartCard(title: "Emotion-Biometric Correlation") {
                        correlationChart
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - History View
    private var historyView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Session summary cards
                if let summary = biometricManager.sessionSummary {
                    SessionSummaryDetailCard(summary: summary)
                }
                
                // Historical data list
                HistoricalSessionsList()
            }
            .padding()
        }
    }
    
    // MARK: - Chart Components
    private var heartRateChart: some View {
        Chart {
            ForEach(getFilteredReadings(), id: \.id) { reading in
                if reading.biometricData.validHeartRate {
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value("Heart Rate", reading.biometricData.heartRate)
                    )
                    .foregroundStyle(.red)
                    .interpolationMethod(.catmullRom)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .minute, count: 5)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour().minute())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(height: 200)
    }
    
    private var temperatureChart: some View {
        Chart {
            ForEach(getFilteredReadings(), id: \.id) { reading in
                LineMark(
                    x: .value("Time", reading.timestamp),
                    y: .value("Temperature", reading.biometricData.temperature)
                )
                .foregroundStyle(.orange)
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .minute, count: 5)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour().minute())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(height: 200)
    }
    
    private var correlationChart: some View {
        Chart {
            ForEach(getFilteredReadings().filter { $0.hasEmotionData }, id: \.id) { reading in
                if let _ = reading.correlationScore,
                   reading.biometricData.validHeartRate {
                    PointMark(
                        x: .value("Heart Rate", reading.biometricData.heartRate),
                        y: .value("Emotion Confidence", reading.emotionData?.confidence ?? 0)
                    )
                    .foregroundStyle(.blue)
                    .symbolSize(30)
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(height: 200)
    }
}

// MARK: - Supporting Views

struct QuickStatView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct LiveDataCard: View {
    let title: String
    let currentValue: String
    let status: String
    let icon: String
    let color: Color
    let trend: TrendDirection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
                
                Image(systemName: trend.systemImage)
                    .foregroundColor(trend.color)
                    .font(.caption)
            }
            
            Text(currentValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(status)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CorrelationCard: View {
    let reading: BiometricManager.IntegratedReading
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                    .font(.title3)
                
                Text("Emotion-Biometric Correlation")
                    .font(.headline)
                
                Spacer()
            }
            
            if let emotion = reading.emotionData {
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Emotion")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(emotion.emotion.capitalized)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(Int(emotion.confidence * 100))% confidence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Heart Rate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(reading.biometricData.heartRate)) BPM")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(reading.biometricData.heartRateCategory.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let correlation = reading.correlationScore {
                        VStack {
                            Text("Match")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int((1 - correlation) * 100))%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(correlation < 0.3 ? .green : correlation < 0.6 ? .orange : .red)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            content
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RecentReadingsList: View {
    let readings: [BiometricManager.IntegratedReading]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Readings")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(readings.reversed(), id: \.id) { reading in
                    RecentReadingRow(reading: reading)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RecentReadingRow: View {
    let reading: BiometricManager.IntegratedReading
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if reading.biometricData.validHeartRate {
                        Text("\(Int(reading.biometricData.heartRate)) BPM")
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    } else {
                        Text("-- BPM")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(reading.biometricData.formattedTemperature)
                        .foregroundColor(.orange)
                }
                
                Text(reading.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if reading.hasEmotionData {
                    if let emotion = reading.emotionData {
                        Text(emotion.emotion.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
                
                Circle()
                    .fill(colorForSensorQuality(reading.biometricData.sensorQuality))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
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

struct SessionSummaryDetailCard: View {
    let summary: BiometricManager.SessionSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Summary")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                SummaryStatView(
                    title: "Duration",
                    value: summary.formattedDuration,
                    icon: "clock.fill",
                    color: .blue
                )
                
                SummaryStatView(
                    title: "Readings",
                    value: "\(summary.totalReadings)",
                    icon: "list.bullet",
                    color: .green
                )
                
                SummaryStatView(
                    title: "Valid HR",
                    value: "\(summary.validHeartRateReadings)",
                    icon: "checkmark.circle.fill",
                    color: .orange
                )
                
                if let avgHR = summary.averageHeartRate {
                    SummaryStatView(
                        title: "Avg HR",
                        value: "\(Int(avgHR))",
                        icon: "heart.fill",
                        color: .red
                    )
                }
                
                if let minHR = summary.minHeartRate {
                    SummaryStatView(
                        title: "Min HR",
                        value: "\(Int(minHR))",
                        icon: "arrow.down.circle.fill",
                        color: .blue
                    )
                }
                
                if let maxHR = summary.maxHeartRate {
                    SummaryStatView(
                        title: "Max HR",
                        value: "\(Int(maxHR))",
                        icon: "arrow.up.circle.fill",
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SummaryStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct HistoricalSessionsList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session History")
                .font(.headline)
            
            // Placeholder for historical sessions
            ForEach(0..<3, id: \.self) { index in
                HistoricalSessionRow(
                    date: Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date(),
                    duration: TimeInterval(1800 + index * 600),
                    avgHeartRate: 72 + Float(index * 3),
                    readingsCount: 150 + index * 20
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct HistoricalSessionRow: View {
    let date: Date
    let duration: TimeInterval
    let avgHeartRate: Float
    let readingsCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatDuration(duration))
                    .font(.subheadline)
                
                Text("\(Int(avgHeartRate)) avg BPM")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(readingsCount)")
                    .font(.subheadline)
                
                Text("readings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


struct BiometricSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var autoReconnect = true
    @State private var emotionIntegration = true
    @State private var dataRetentionDays = 7
    
    var body: some View {
        NavigationView {
            List {
                Section("Connection") {
                    Toggle("Auto-reconnect", isOn: $autoReconnect)
                    Toggle("Emotion Integration", isOn: $emotionIntegration)
                }
                
                Section("Data") {
                    Picker("Data Retention", selection: $dataRetentionDays) {
                        Text("1 Day").tag(1)
                        Text("7 Days").tag(7)
                        Text("30 Days").tag(30)
                        Text("Forever").tag(0)
                    }
                }
                
                Section("Privacy") {
                    Button("Export Data") { }
                    Button("Delete All Data") { }
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Helper Types and Extensions

enum TimeRange: CaseIterable {
    case last15Minutes, last30Minutes, last1Hour, last3Hours, last6Hours
    
    var displayName: String {
        switch self {
        case .last15Minutes: return "15m"
        case .last30Minutes: return "30m"
        case .last1Hour: return "1h"
        case .last3Hours: return "3h"
        case .last6Hours: return "6h"
        }
    }
    
    var timeInterval: TimeInterval {
        switch self {
        case .last15Minutes: return 15 * 60
        case .last30Minutes: return 30 * 60
        case .last1Hour: return 60 * 60
        case .last3Hours: return 3 * 60 * 60
        case .last6Hours: return 6 * 60 * 60
        }
    }
    
    func next() -> TimeRange {
        let allCases = TimeRange.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else { return self }
        let nextIndex = (currentIndex + 1) % allCases.count
        return allCases[nextIndex]
    }
}

enum TrendDirection {
    case up, down, stable
    
    var systemImage: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .stable: return .gray
        }
    }
}

// MARK: - Helper Functions

private extension BiometricDashboardView {
    var connectionStatusColor: Color {
        switch biometricManager.connectionStatus {
        case .disconnected: return .red
        case .scanning: return .orange
        case .connecting: return .yellow
        case .connected: return .green
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
    
    func getFilteredReadings() -> [BiometricManager.IntegratedReading] {
        let cutoffTime = Date().addingTimeInterval(-timeRange.timeInterval)
        return biometricManager.integratedReadings.filter { $0.timestamp >= cutoffTime }
    }
    
    func calculateHeartRateTrend() -> TrendDirection {
        let recentReadings = Array(biometricManager.integratedReadings.suffix(5))
            .filter { $0.biometricData.validHeartRate }
        
        guard recentReadings.count >= 2 else { return .stable }
        
        let recent = recentReadings.suffix(2).map { $0.biometricData.heartRate }
        let diff = recent.last! - recent.first!
        
        if diff > 2 { return .up }
        else if diff < -2 { return .down }
        else { return .stable }
    }
    
    func calculateTemperatureTrend() -> TrendDirection {
        let recentReadings = Array(biometricManager.integratedReadings.suffix(5))
        
        guard recentReadings.count >= 2 else { return .stable }
        
        let recent = recentReadings.suffix(2).map { $0.biometricData.temperature }
        let diff = recent.last! - recent.first!
        
        if diff > 0.2 { return .up }
        else if diff < -0.2 { return .down }
        else { return .stable }
    }
}

#Preview {
    BiometricDashboardView()
}

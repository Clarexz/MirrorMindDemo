//
//  BiometricTestUtils.swift
//  MirrorMindDemo
//
//  Created on Phase 3 - Bluetooth Integration
//

import Foundation
import CoreBluetooth
import Combine

/// Utility class for testing biometric functionality in Phase 3
class BiometricTestUtils {
    
    // MARK: - Singleton
    static let shared = BiometricTestUtils()
    private init() {}
    
    // MARK: - Mock Data Generation
    
    /// Generate mock biometric data for testing
    static func generateMockBiometricData(
        heartRate: Float? = nil,
        temperature: Float? = nil,
        fingerDetected: Bool = true,
        validHeartRate: Bool = true
    ) -> BiometricData {
        return BiometricData(
            heartRate: heartRate ?? Float.random(in: 60...100),
            temperature: temperature ?? Float.random(in: 36.0...37.0),
            rawTemperature: Float.random(in: 33.0...36.0),
            irValue: Int64.random(in: 50000...200000),
            fingerDetected: fingerDetected,
            validHeartRate: validHeartRate && fingerDetected,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }
    
    /// Generate a sequence of realistic biometric data
    static func generateBiometricSequence(
        count: Int = 10,
        baseHeartRate: Float = 72,
        baseTemperature: Float = 36.5,
        variation: Float = 10
    ) -> [BiometricData] {
        var sequence: [BiometricData] = []
        let startTime = Date().timeIntervalSince1970 * 1000
        
        for i in 0..<count {
            let heartRateVariation = Float.random(in: -variation...variation)
            let temperatureVariation = Float.random(in: -0.5...0.5)
            
            let data = BiometricData(
                heartRate: max(40, baseHeartRate + heartRateVariation),
                temperature: max(36.0, min(37.5, baseTemperature + temperatureVariation)),
                rawTemperature: Float.random(in: 33.0...36.0),
                irValue: Int64.random(in: 80000...150000),
                fingerDetected: true,
                validHeartRate: true,
                timestamp: Int64(startTime + Double(i * 2000)) // 2-second intervals
            )
            sequence.append(data)
        }
        
        return sequence
    }
    
    /// Generate data with no finger detected
    static func generateNoFingerData() -> BiometricData {
        return BiometricData(
            heartRate: 0.0,
            temperature: Float.random(in: 35.0...36.0),
            rawTemperature: Float.random(in: 32.0...34.0),
            irValue: Int64.random(in: 20000...45000),
            fingerDetected: false,
            validHeartRate: false,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }
    
    /// Generate data with finger detected but invalid heart rate
    static func generateCalculatingHeartRateData() -> BiometricData {
        return BiometricData(
            heartRate: 0.0,
            temperature: Float.random(in: 36.0...37.0),
            rawTemperature: Float.random(in: 33.5...35.5),
            irValue: Int64.random(in: 75000...120000),
            fingerDetected: true,
            validHeartRate: false,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }
}

// MARK: - Mock Biometric Service
class MockBiometricService: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var isScanning: Bool = false
    @Published var currentData: BiometricData?
    @Published var connectionState: BiometricService.ConnectionState = .disconnected
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var lastError: BiometricService.BluetoothError?
    
    private var dataTimer: Timer?
    private var dataSubject = PassthroughSubject<BiometricData, Never>()
    private var simulatedSequence: [BiometricData] = []
    private var currentIndex: Int = 0
    
    var dataPublisher: AnyPublisher<BiometricData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    func startScanning() {
        guard !isScanning else { return }
        
        isScanning = true
        connectionState = .scanning
        
        // Simulate finding device after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.simulateDeviceFound()
        }
    }
    
    func stopScanning() {
        isScanning = false
        if connectionState == .scanning {
            connectionState = .disconnected
        }
    }
    
    func connectToSmartBand() {
        if !isScanning {
            startScanning()
        }
    }
    
    func disconnect() {
        dataTimer?.invalidate()
        dataTimer = nil
        isConnected = false
        connectionState = .disconnected
        currentData = nil
    }
    
    func toggleConnection() {
        if isConnected {
            disconnect()
        } else {
            connectToSmartBand()
        }
    }
    
    func enableAutoReconnect() {
        // Mock implementation
    }
    
    func disableAutoReconnect() {
        // Mock implementation
    }
    
    // MARK: - Simulation Methods
    
    private func simulateDeviceFound() {
        guard isScanning else { return }
        
        stopScanning()
        connectionState = .connecting
        
        // Simulate connection after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.simulateConnected()
        }
    }
    
    private func simulateConnected() {
        isConnected = true
        connectionState = .dataReady
        
        // Generate realistic data sequence
        simulatedSequence = BiometricTestUtils.generateBiometricSequence(
            count: 100,
            baseHeartRate: Float.random(in: 65...85),
            baseTemperature: Float.random(in: 36.2...36.8)
        )
        
        startDataSimulation()
    }
    
    private func startDataSimulation() {
        dataTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.sendNextDataPoint()
        }
    }
    
    private func sendNextDataPoint() {
        guard isConnected && !simulatedSequence.isEmpty else { return }
        
        let data = simulatedSequence[currentIndex % simulatedSequence.count]
        currentIndex += 1
        
        // Occasionally simulate different states
        let randomState = Int.random(in: 1...100)
        let finalData: BiometricData
        
        switch randomState {
        case 1...5: // 5% no finger
            finalData = BiometricTestUtils.generateNoFingerData()
        case 6...10: // 5% calculating
            finalData = BiometricTestUtils.generateCalculatingHeartRateData()
        default: // 90% normal data
            finalData = data
        }
        
        currentData = finalData
        dataSubject.send(finalData)
    }
}

// MARK: - Test Validation
extension BiometricTestUtils {
    
    /// Validate biometric data structure and values
    static func validateBiometricData(_ data: BiometricData) -> BiometricValidationResult {
        var issues: [String] = []
        
        // Heart rate validation
        if data.validHeartRate {
            if data.heartRate <= 0 {
                issues.append("Valid heart rate flag is true but heart rate is <= 0")
            }
            if data.heartRate < 30 || data.heartRate > 220 {
                issues.append("Heart rate \(data.heartRate) is outside reasonable range (30-220 BPM)")
            }
            if !data.fingerDetected {
                issues.append("Valid heart rate is true but finger not detected")
            }
        }
        
        // Temperature validation
        if data.temperature < 30.0 || data.temperature > 45.0 {
            issues.append("Temperature \(data.temperature)°C is outside reasonable range")
        }
        
        // IR value validation
        if data.fingerDetected && data.irValue < 50000 {
            issues.append("Finger detected but IR value (\(data.irValue)) is below threshold")
        }
        
        // Timestamp validation
        let currentTime = Date().timeIntervalSince1970 * 1000
        if abs(Double(data.timestamp) - currentTime) > 60000 { // More than 1 minute difference
            issues.append("Timestamp appears to be significantly different from current time")
        }
        
        return BiometricValidationResult(
            isValid: issues.isEmpty,
            issues: issues,
            data: data
        )
    }
    
    /// Validate a sequence of biometric data for consistency
    static func validateBiometricSequence(_ sequence: [BiometricData]) -> SequenceValidationResult {
        guard !sequence.isEmpty else {
            return SequenceValidationResult(isValid: false, issues: ["Empty sequence"], totalPoints: 0, validHeartRatePoints: nil, fingerDetectedPoints: nil)
        }
        
        var issues: [String] = []
        let sortedSequence = sequence.sorted { $0.timestamp < $1.timestamp }
        
        // Check for reasonable time gaps
        for i in 1..<sortedSequence.count {
            let timeDiff = sortedSequence[i].timestamp - sortedSequence[i-1].timestamp
            if timeDiff < 0 {
                issues.append("Negative time difference at index \(i)")
            } else if timeDiff > 10000 { // More than 10 seconds
                issues.append("Large time gap (\(timeDiff)ms) between readings at indices \(i-1) and \(i)")
            }
        }
        
        // Check for reasonable value changes
        let validHeartRates = sortedSequence.compactMap { $0.validHeartRate ? $0.heartRate : nil }
        if validHeartRates.count > 1 {
            for i in 1..<validHeartRates.count {
                let heartRateDiff = abs(validHeartRates[i] - validHeartRates[i-1])
                if heartRateDiff > 30 { // More than 30 BPM change between readings
                    issues.append("Large heart rate change (\(heartRateDiff) BPM) between consecutive valid readings")
                }
            }
        }
        
        return SequenceValidationResult(
            isValid: issues.isEmpty,
            issues: issues,
            totalPoints: sequence.count,
            validHeartRatePoints: sortedSequence.filter { $0.validHeartRate }.count,
            fingerDetectedPoints: sortedSequence.filter { $0.fingerDetected }.count
        )
    }
}

// MARK: - Test Results
struct BiometricValidationResult {
    let isValid: Bool
    let issues: [String]
    let data: BiometricData
    
    func printReport() {
        print("📊 Biometric Data Validation Report")
        print("Valid: \(isValid ? "✅" : "❌")")
        print("Heart Rate: \(data.heartRateStatus)")
        print("Temperature: \(data.formattedTemperature)")
        print("Sensor Quality: \(data.sensorQuality.rawValue)")
        
        if !issues.isEmpty {
            print("Issues found:")
            for issue in issues {
                print("  ⚠️ \(issue)")
            }
        }
        print("---")
    }
}

struct SequenceValidationResult {
    let isValid: Bool
    let issues: [String]
    let totalPoints: Int
    let validHeartRatePoints: Int?
    let fingerDetectedPoints: Int?
    
    func printReport() {
        print("📈 Sequence Validation Report")
        print("Valid: \(isValid ? "✅" : "❌")")
        print("Total Points: \(totalPoints)")
        
        if let validHR = validHeartRatePoints {
            print("Valid Heart Rate Points: \(validHR)")
        }
        
        if let fingerDetected = fingerDetectedPoints {
            print("Finger Detected Points: \(fingerDetected)")
        }
        
        if !issues.isEmpty {
            print("Issues found:")
            for issue in issues {
                print("  ⚠️ \(issue)")
            }
        }
        print("---")
    }
}

// MARK: - Performance Testing
extension BiometricTestUtils {
    
    /// Test Storage upload performance
    static func testStorageUploadPerformance(
        service: BiometricStorageService,
        dataCount: Int = 100,
        completion: @escaping (PerformanceTestResult) -> Void
    ) {
        let testData = generateBiometricSequence(count: dataCount)
        let startTime = Date()
        
        let initialUploadCount = service.uploadCount
        
        for data in testData {
            service.storeBiometricData(data)
        }
        
        // Since we're using local storage, simulate async upload with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let uploadCount = service.uploadCount - initialUploadCount
            
            let result = PerformanceTestResult(
                testType: "Local Storage Upload",
                expectedOperations: dataCount,
                completedOperations: uploadCount,
                duration: Date().timeIntervalSince(startTime),
                success: uploadCount == dataCount
            )
            
            completion(result)
        }
    }
    
    /// Test Bluetooth data parsing performance
    static func testBluetoothParsingPerformance(dataCount: Int = 1000) -> PerformanceTestResult {
        let testData = generateBiometricSequence(count: dataCount)
        let startTime = Date()
        
        var successCount = 0
        
        for data in testData {
            do {
                let jsonData = try JSONEncoder().encode(data)
                let parsedData = try JSONDecoder().decode(BiometricData.self, from: jsonData)
                if parsedData.heartRate == data.heartRate {
                    successCount += 1
                }
            } catch {
                // Parsing failed
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        return PerformanceTestResult(
            testType: "Bluetooth Data Parsing",
            expectedOperations: dataCount,
            completedOperations: successCount,
            duration: duration,
            success: successCount == dataCount
        )
    }
}

struct PerformanceTestResult {
    let testType: String
    let expectedOperations: Int
    let completedOperations: Int
    let duration: TimeInterval
    let success: Bool
    
    var operationsPerSecond: Double {
        return Double(completedOperations) / duration
    }
    
    func printReport() {
        print("⚡ Performance Test Report: \(testType)")
        print("Success: \(success ? "✅" : "❌")")
        print("Completed: \(completedOperations)/\(expectedOperations)")
        print("Duration: \(String(format: "%.2f", duration))s")
        print("Operations/sec: \(String(format: "%.1f", operationsPerSecond))")
        print("---")
    }
}
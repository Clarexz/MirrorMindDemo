//
//  BiometricData.swift
//  MirrorMindDemo
//
//  Created on Phase 3 - Bluetooth Integration
//

import Foundation

/// Model representing biometric data from the MirrorMind SmartBand
struct BiometricData: Codable, Identifiable, Equatable {
    let id = UUID()
    let heartRate: Float
    let temperature: Float
    let rawTemperature: Float
    let irValue: Int64
    let fingerDetected: Bool
    let validHeartRate: Bool
    let timestamp: Int64
    let receivedAt: Date
    
    /// Initializer for received data from SmartBand
    init(heartRate: Float, temperature: Float, rawTemperature: Float, irValue: Int64, fingerDetected: Bool, validHeartRate: Bool, timestamp: Int64) {
        self.heartRate = heartRate
        self.temperature = temperature
        self.rawTemperature = rawTemperature
        self.irValue = irValue
        self.fingerDetected = fingerDetected
        self.validHeartRate = validHeartRate
        self.timestamp = timestamp
        self.receivedAt = Date()
    }
    
    /// Coding keys for JSON serialization (excluding computed properties)
    private enum CodingKeys: String, CodingKey {
        case heartRate, temperature, rawTemperature, irValue, fingerDetected, validHeartRate, timestamp
    }
    
    /// Custom decoder to handle JSON from SmartBand
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        heartRate = try container.decode(Float.self, forKey: .heartRate)
        temperature = try container.decode(Float.self, forKey: .temperature)
        rawTemperature = try container.decode(Float.self, forKey: .rawTemperature)
        irValue = try container.decode(Int64.self, forKey: .irValue)
        fingerDetected = try container.decode(Bool.self, forKey: .fingerDetected)
        validHeartRate = try container.decode(Bool.self, forKey: .validHeartRate)
        timestamp = try container.decode(Int64.self, forKey: .timestamp)
        receivedAt = Date()
    }
    
    /// Encode to JSON (excluding local computed properties)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(heartRate, forKey: .heartRate)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(rawTemperature, forKey: .rawTemperature)
        try container.encode(irValue, forKey: .irValue)
        try container.encode(fingerDetected, forKey: .fingerDetected)
        try container.encode(validHeartRate, forKey: .validHeartRate)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

// MARK: - Computed Properties
extension BiometricData {
    /// Human-readable heart rate status
    var heartRateStatus: String {
        guard fingerDetected else { return "No finger detected" }
        guard validHeartRate else { return "Calculating..." }
        return "\(Int(heartRate)) BPM"
    }
    
    /// Temperature in Celsius with formatting
    var formattedTemperature: String {
        return String(format: "%.1f°C", temperature)
    }
    
    /// Heart rate category based on general guidelines
    var heartRateCategory: HeartRateCategory {
        guard validHeartRate && heartRate > 0 else { return .unknown }
        
        switch heartRate {
        case 0..<60:
            return .low
        case 60..<100:
            return .normal
        case 100..<120:
            return .elevated
        case 120...:
            return .high
        default:
            return .unknown
        }
    }
    
    /// Temperature status based on normal body temperature ranges
    var temperatureStatus: TemperatureStatus {
        switch temperature {
        case 0..<36.0:
            return .low
        case 36.0...37.5:
            return .normal
        case 37.5...:
            return .elevated
        default:
            return .unknown
        }
    }
    
    /// Overall sensor quality assessment
    var sensorQuality: SensorQuality {
        guard fingerDetected else { return .noContact }
        
        // IR value threshold for good contact
        if irValue < 50000 {
            return .poorContact
        } else if irValue > 200000 {
            return .excellent
        } else if irValue > 100000 {
            return .good
        } else {
            return .fair
        }
    }
}

// MARK: - Supporting Enums
enum HeartRateCategory: String, CaseIterable {
    case unknown = "Unknown"
    case low = "Low"
    case normal = "Normal"
    case elevated = "Elevated"
    case high = "High"
    
    var color: String {
        switch self {
        case .unknown: return "gray"
        case .low: return "blue"
        case .normal: return "green"
        case .elevated: return "orange"
        case .high: return "red"
        }
    }
}

enum TemperatureStatus: String, CaseIterable {
    case unknown = "Unknown"
    case low = "Below Normal"
    case normal = "Normal"
    case elevated = "Elevated"
    
    var color: String {
        switch self {
        case .unknown: return "gray"
        case .low: return "blue"
        case .normal: return "green"
        case .elevated: return "red"
        }
    }
}

enum SensorQuality: String, CaseIterable {
    case noContact = "No Contact"
    case poorContact = "Poor Contact"
    case fair = "Fair"
    case good = "Good"
    case excellent = "Excellent"
    
    var color: String {
        switch self {
        case .noContact, .poorContact: return "red"
        case .fair: return "orange"
        case .good: return "yellow"
        case .excellent: return "green"
        }
    }
}

// MARK: - Sample Data for Testing
extension BiometricData {
    /// Sample data for UI previews and testing
    static let sampleData: [BiometricData] = [
        BiometricData(
            heartRate: 72.0,
            temperature: 36.5,
            rawTemperature: 34.2,
            irValue: 85432,
            fingerDetected: true,
            validHeartRate: true,
            timestamp: 123456789
        ),
        BiometricData(
            heartRate: 0.0,
            temperature: 36.8,
            rawTemperature: 34.5,
            irValue: 75221,
            fingerDetected: true,
            validHeartRate: false,
            timestamp: 123456790
        ),
        BiometricData(
            heartRate: 0.0,
            temperature: 36.2,
            rawTemperature: 33.9,
            irValue: 25000,
            fingerDetected: false,
            validHeartRate: false,
            timestamp: 123456791
        )
    ]
    
    /// Sample valid reading
    static let sampleValid = BiometricData(
        heartRate: 75.0,
        temperature: 36.6,
        rawTemperature: 34.3,
        irValue: 95000,
        fingerDetected: true,
        validHeartRate: true,
        timestamp: Int64(Date().timeIntervalSince1970 * 1000)
    )
    
    /// Sample no finger detected
    static let sampleNoFinger = BiometricData(
        heartRate: 0.0,
        temperature: 36.1,
        rawTemperature: 33.8,
        irValue: 30000,
        fingerDetected: false,
        validHeartRate: false,
        timestamp: Int64(Date().timeIntervalSince1970 * 1000)
    )
}

// MARK: - Equatable Implementation
extension BiometricData {
    static func == (lhs: BiometricData, rhs: BiometricData) -> Bool {
        return lhs.timestamp == rhs.timestamp &&
               lhs.heartRate == rhs.heartRate &&
               lhs.temperature == rhs.temperature &&
               lhs.fingerDetected == rhs.fingerDetected &&
               lhs.validHeartRate == rhs.validHeartRate
    }
}
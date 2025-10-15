//
//  BiometricStorageService.swift
//  MirrorMindDemo
//
//  Created on Phase 3 - Bluetooth Integration
//  Local storage service for biometric data (no Firebase dependencies)
//

import Foundation
import UIKit
import Combine

/// Service responsible for storing and retrieving biometric data locally
class BiometricStorageService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isConnected: Bool = true // Always connected for local storage
    @Published var lastUploadTime: Date?
    @Published var uploadCount: Int = 0
    @Published var lastError: StorageError?
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let biometricDataKey = "biometric_data"
    private let sessionsKey = "biometric_sessions"
    private var cancellables = Set<AnyCancellable>()
    private let uploadQueue = DispatchQueue(label: "biometric.upload.queue", qos: .utility)
    
    // MARK: - Constants
    private let maxRetries = 3
    private let batchSize = 10
    
    // MARK: - Initialization
    init() {
        print("🔵 BiometricStorageService initialized (Local Storage)")
    }
    
    deinit {
        cancellables.removeAll()
        print("🔴 BiometricStorageService deinitialized")
    }
    
    // MARK: - Public Methods
    
    /// Store a single biometric data point
    func storeBiometricData(_ data: BiometricData) {
        uploadQueue.async { [weak self] in
            self?.uploadBiometricData(data)
        }
    }
    
    /// Store multiple biometric data points in a batch
    func storeBiometricDataBatch(_ dataArray: [BiometricData]) {
        uploadQueue.async { [weak self] in
            self?.uploadBiometricDataBatch(dataArray)
        }
    }
    
    /// Start a new biometric session
    func startBiometricSession(userId: String = "default_user") -> String {
        let sessionId = generateSessionId()
        let sessionData: [String: Any] = [
            "sessionId": sessionId,
            "userId": userId,
            "startTime": Date().timeIntervalSince1970,
            "status": "active",
            "deviceInfo": getDeviceInfo()
        ]
        
        // Store session data locally
        var existingSessions = userDefaults.dictionary(forKey: sessionsKey) ?? [:]
        existingSessions[sessionId] = sessionData
        userDefaults.set(existingSessions, forKey: sessionsKey)
        
        DispatchQueue.main.async {
            print("✅ Biometric session started: \(sessionId)")
        }
        
        return sessionId
    }
    
    /// End a biometric session
    func endBiometricSession(sessionId: String, summary: BiometricSessionSummary? = nil) {
        var existingSessions = userDefaults.dictionary(forKey: sessionsKey) ?? [:]
        if var sessionData = existingSessions[sessionId] as? [String: Any] {
            sessionData["endTime"] = Date().timeIntervalSince1970
            sessionData["status"] = "completed"
            
            if let summary = summary {
                sessionData["summary"] = summary.toDictionary()
            }
            
            existingSessions[sessionId] = sessionData
            userDefaults.set(existingSessions, forKey: sessionsKey)
            
            DispatchQueue.main.async {
                print("✅ Biometric session ended: \(sessionId)")
            }
        }
    }
    
    /// Retrieve biometric data for a specific time range
    func retrieveBiometricData(
        from startTime: Date,
        to endTime: Date,
        completion: @escaping (Result<[BiometricData], Error>) -> Void
    ) {
        let startTimestamp = startTime.timeIntervalSince1970 * 1000
        let endTimestamp = endTime.timeIntervalSince1970 * 1000
        
        // Retrieve from local storage
        if let storedData = userDefaults.array(forKey: biometricDataKey) as? [[String: Any]] {
            let filteredData = storedData.compactMap { dict -> BiometricData? in
                guard let timestamp = dict["timestamp"] as? Int64,
                      timestamp >= Int64(startTimestamp),
                      timestamp <= Int64(endTimestamp) else { return nil }
                
                return try? parseBiometricDataFromDictionary(dict)
            }
            completion(.success(filteredData))
        } else {
            completion(.success([]))
        }
    }
    
    /// Get the latest biometric reading
    func getLatestBiometricData(completion: @escaping (Result<BiometricData?, Error>) -> Void) {
        if let storedData = userDefaults.array(forKey: biometricDataKey) as? [[String: Any]],
           let lastItem = storedData.last,
           let latestData = try? parseBiometricDataFromDictionary(lastItem) {
            completion(.success(latestData))
        } else {
            completion(.success(nil))
        }
    }
    
    /// Monitor real-time biometric data changes
    func observeBiometricData() -> AnyPublisher<BiometricData, Never> {
        let subject = PassthroughSubject<BiometricData, Never>()
        
        // For local storage, we don't have real-time observation
        // This would be implemented with file system watching or notifications
        
        return subject.eraseToAnyPublisher()
    }
    
    /// Clean up old biometric data (older than specified days)
    func cleanupOldData(olderThanDays days: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let cutoffTimestamp = cutoffDate.timeIntervalSince1970 * 1000
        
        if var storedData = userDefaults.array(forKey: biometricDataKey) as? [[String: Any]] {
            let originalCount = storedData.count
            
            storedData = storedData.filter { dict in
                guard let timestamp = dict["timestamp"] as? Int64 else { return true }
                return timestamp > Int64(cutoffTimestamp)
            }
            
            userDefaults.set(storedData, forKey: biometricDataKey)
            let deletedCount = originalCount - storedData.count
            completion(.success(deletedCount))
        } else {
            completion(.success(0))
        }
    }
    
    /// Get all stored sessions
    func getAllSessions() -> [BiometricSessionInfo] {
        guard let sessionsDict = userDefaults.dictionary(forKey: sessionsKey) else { return [] }
        
        return sessionsDict.compactMap { (key, value) in
            guard let sessionData = value as? [String: Any],
                  let sessionId = sessionData["sessionId"] as? String,
                  let startTime = sessionData["startTime"] as? Double,
                  let status = sessionData["status"] as? String else { return nil }
            
            let endTime = sessionData["endTime"] as? Double
            let userId = sessionData["userId"] as? String ?? "unknown"
            
            return BiometricSessionInfo(
                sessionId: sessionId,
                userId: userId,
                startTime: Date(timeIntervalSince1970: startTime),
                endTime: endTime != nil ? Date(timeIntervalSince1970: endTime!) : nil,
                status: status
            )
        }
        .sorted { $0.startTime > $1.startTime }
    }
    
    /// Get total count of stored data points
    func getStoredDataCount() -> Int {
        let storedData = userDefaults.array(forKey: biometricDataKey) as? [[String: Any]] ?? []
        return storedData.count
    }
    
    /// Clear all stored data
    func clearAllData() {
        userDefaults.removeObject(forKey: biometricDataKey)
        userDefaults.removeObject(forKey: sessionsKey)
        uploadCount = 0
        lastUploadTime = nil
        print("🗑️ All biometric data cleared")
    }
}

// MARK: - Private Methods
private extension BiometricStorageService {
    
    func uploadBiometricData(_ data: BiometricData, retryCount: Int = 0) {
        let dataDict = convertBiometricDataToDictionary(data)
        
        // Store locally in UserDefaults
        var existingData = userDefaults.array(forKey: biometricDataKey) as? [[String: Any]] ?? []
        existingData.append(dataDict)
        
        // Keep only last 1000 readings to prevent storage bloat
        if existingData.count > 1000 {
            existingData = Array(existingData.suffix(1000))
        }
        
        userDefaults.set(existingData, forKey: biometricDataKey)
        
        DispatchQueue.main.async {
            self.uploadCount += 1
            self.lastUploadTime = Date()
            self.lastError = nil
            print("✅ Biometric data stored locally (Total: \(self.uploadCount))")
        }
    }
    
    func uploadBiometricDataBatch(_ dataArray: [BiometricData]) {
        var updates: [[String: Any]] = []
        
        for data in dataArray {
            let dataDict = convertBiometricDataToDictionary(data)
            updates.append(dataDict)
        }
        
        // Store batch locally
        var existingData = userDefaults.array(forKey: biometricDataKey) as? [[String: Any]] ?? []
        existingData.append(contentsOf: updates)
        
        // Keep only last 1000 readings
        if existingData.count > 1000 {
            existingData = Array(existingData.suffix(1000))
        }
        
        userDefaults.set(existingData, forKey: biometricDataKey)
        
        DispatchQueue.main.async {
            self.uploadCount += dataArray.count
            self.lastUploadTime = Date()
            self.lastError = nil
            print("✅ Batch stored locally: \(dataArray.count) readings (Total: \(self.uploadCount))")
        }
    }
    
    func convertBiometricDataToDictionary(_ data: BiometricData) -> [String: Any] {
        return [
            "heartRate": data.heartRate,
            "temperature": data.temperature,
            "rawTemperature": data.rawTemperature,
            "irValue": data.irValue,
            "fingerDetected": data.fingerDetected,
            "validHeartRate": data.validHeartRate,
            "timestamp": data.timestamp,
            "receivedAt": data.receivedAt.timeIntervalSince1970 * 1000,
            "heartRateCategory": data.heartRateCategory.rawValue,
            "temperatureStatus": data.temperatureStatus.rawValue,
            "sensorQuality": data.sensorQuality.rawValue
        ]
    }
    
    func parseBiometricDataFromDictionary(_ dict: [String: Any]) throws -> BiometricData {
        guard let heartRate = dict["heartRate"] as? Float,
              let temperature = dict["temperature"] as? Float,
              let rawTemperature = dict["rawTemperature"] as? Float,
              let irValue = dict["irValue"] as? Int64,
              let fingerDetected = dict["fingerDetected"] as? Bool,
              let validHeartRate = dict["validHeartRate"] as? Bool,
              let timestamp = dict["timestamp"] as? Int64 else {
            throw StorageError.dataParsingFailed("Missing required fields")
        }
        
        return BiometricData(
            heartRate: heartRate,
            temperature: temperature,
            rawTemperature: rawTemperature,
            irValue: irValue,
            fingerDetected: fingerDetected,
            validHeartRate: validHeartRate,
            timestamp: timestamp
        )
    }
    
    func generateSessionId() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return "session_\(formatter.string(from: Date()))_\(UUID().uuidString.prefix(8))"
    }
    
    func getDeviceInfo() -> [String: Any] {
        return [
            "deviceModel": UIDevice.current.model,
            "systemName": UIDevice.current.systemName,
            "systemVersion": UIDevice.current.systemVersion,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "Unknown",
            "storageType": "local"
        ]
    }
}

// MARK: - Supporting Types
extension BiometricStorageService {
    
    enum StorageError: Error, LocalizedError {
        case uploadFailed(String)
        case batchUploadFailed(String)
        case sessionCreationFailed(String)
        case sessionUpdateFailed(String)
        case dataParsingFailed(String)
        case storageError(String)
        
        var errorDescription: String? {
            switch self {
            case .uploadFailed(let message):
                return "Upload failed: \(message)"
            case .batchUploadFailed(let message):
                return "Batch upload failed: \(message)"
            case .sessionCreationFailed(let message):
                return "Session creation failed: \(message)"
            case .sessionUpdateFailed(let message):
                return "Session update failed: \(message)"
            case .dataParsingFailed(let message):
                return "Data parsing failed: \(message)"
            case .storageError(let message):
                return "Storage error: \(message)"
            }
        }
    }
}

// MARK: - Session Info Model
struct BiometricSessionInfo: Identifiable {
    let id = UUID()
    let sessionId: String
    let userId: String
    let startTime: Date
    let endTime: Date?
    let status: String
    
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        guard let duration = duration else { return "Ongoing" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Biometric Session Summary (maintained for compatibility)
struct BiometricSessionSummary {
    let totalReadings: Int
    let validHeartRateReadings: Int
    let averageHeartRate: Float?
    let minHeartRate: Float?
    let maxHeartRate: Float?
    let averageTemperature: Float?
    let sessionDuration: TimeInterval
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "totalReadings": totalReadings,
            "validHeartRateReadings": validHeartRateReadings,
            "sessionDuration": sessionDuration
        ]
        
        if let avgHR = averageHeartRate { dict["averageHeartRate"] = avgHR }
        if let minHR = minHeartRate { dict["minHeartRate"] = minHR }
        if let maxHR = maxHeartRate { dict["maxHeartRate"] = maxHR }
        if let avgTemp = averageTemperature { dict["averageTemperature"] = avgTemp }
        
        return dict
    }
}
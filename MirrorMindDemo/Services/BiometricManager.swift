//
//  BiometricManager.swift
//  MirrorMindDemo
//
//  Created on Phase 3 - Bluetooth Integration
//

import Foundation
import Combine
import CoreBluetooth

/// Main coordinator for biometric data collection and integration with emotion recognition
@MainActor
class BiometricManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isActive: Bool = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var currentBiometricData: BiometricData?
    @Published var lastEmotionData: EmotionResponse?
    @Published var integratedReadings: [IntegratedReading] = []
    @Published var sessionSummary: SessionSummary?
    @Published var errorMessage: String?
    
    // MARK: - Services
    private let biometricService: BiometricService
    private let biometricStorageService: BiometricStorageService
    private var emotionAPIService: EmotionAPIService?
    private var cameraService: CameraService?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var currentSessionId: String?
    private var sessionStartTime: Date?
    private var dataBuffer: [BiometricData] = []
    private let bufferLimit = 50
    private var integrationTimer: Timer?
    
    // MARK: - Configuration
    private let uploadInterval: TimeInterval = 10.0 // Upload every 10 seconds
    private let maxRetainedReadings = 100
    
    // MARK: - Initialization
    init(
        biometricService: BiometricService = BiometricService(),
        biometricStorageService: BiometricStorageService = BiometricStorageService(),
        emotionAPIService: EmotionAPIService? = nil,
        cameraService: CameraService? = nil
    ) {
        self.biometricService = biometricService
        self.biometricStorageService = biometricStorageService
        self.emotionAPIService = emotionAPIService
        self.cameraService = cameraService
        
        setupBindings()
        print("🔵 BiometricManager initialized")
    }
    
    deinit {
        Task { @MainActor in
            if isActive {
                biometricService.disableAutoReconnect()
                biometricService.disconnect()
                integrationTimer?.invalidate()
                integrationTimer = nil
                isActive = false
                currentSessionId = nil
                sessionStartTime = nil
            }
        }
        cancellables.removeAll()
        print("🔴 BiometricManager deinitialized")
    }
    
    // MARK: - Public Methods
    
    /// Start a new biometric monitoring session
    func startSession(withEmotionIntegration: Bool = false) {
        guard !isActive else {
            print("⚠️ Session already active")
            return
        }
        
        print("🚀 Starting biometric session")
        
        // Reset state
        integratedReadings.removeAll()
        dataBuffer.removeAll()
        errorMessage = nil
        sessionSummary = nil
        
        // Start session
        currentSessionId = biometricStorageService.startBiometricSession()
        sessionStartTime = Date()
        isActive = true
        
        // Connect to SmartBand
        biometricService.connectToSmartBand()
        biometricService.enableAutoReconnect()
        
        // Start emotion integration if requested
        if withEmotionIntegration {
            startEmotionIntegration()
        }
        
        // Start periodic upload timer
        startUploadTimer()
        
        print("✅ Biometric session started with ID: \(currentSessionId ?? "unknown")")
    }
    
    /// Stop the current biometric monitoring session
    func stopSession() {
        guard isActive else { return }
        
        print("🛑 Stopping biometric session")
        
        // Stop services
        biometricService.disableAutoReconnect()
        biometricService.disconnect()
        integrationTimer?.invalidate()
        integrationTimer = nil
        
        // Upload remaining data
        uploadBufferedData()
        
        // Calculate session summary
        if let startTime = sessionStartTime, let sessionId = currentSessionId {
            calculateSessionSummary()
            biometricStorageService.endBiometricSession(sessionId: sessionId, summary: createStorageSummary())
        }
        
        // Reset state
        isActive = false
        connectionStatus = .disconnected
        currentSessionId = nil
        sessionStartTime = nil
        
        print("✅ Biometric session stopped")
    }
    
    /// Toggle session state
    func toggleSession() {
        if isActive {
            stopSession()
        } else {
            startSession()
        }
    }
    
    /// Start session with full emotion recognition integration
    func startIntegratedSession(cameraService: CameraService, emotionAPIService: EmotionAPIService) {
        self.cameraService = cameraService
        self.emotionAPIService = emotionAPIService
        startSession(withEmotionIntegration: true)
    }
    
    /// Start session connecting directly to known SmartBand (for demo)
    func startSessionWithKnownDevice(withEmotionIntegration: Bool = false) {
        guard !isActive else {
            print("⚠️ Session already active")
            return
        }
        
        print("🚀 Starting biometric session (known device)")
        
        // Reset state
        integratedReadings.removeAll()
        dataBuffer.removeAll()
        errorMessage = nil
        sessionSummary = nil
        
        // Start session
        currentSessionId = biometricStorageService.startBiometricSession()
        sessionStartTime = Date()
        isActive = true
        
        // Connect directly to known SmartBand
        biometricService.connectToKnownSmartBand()
        biometricService.enableAutoReconnect()
        
        // Start emotion integration if requested
        if withEmotionIntegration {
            startEmotionIntegration()
        }
        
        // Start periodic upload timer
        startUploadTimer()
        
        print("✅ Biometric session started with known device: \(currentSessionId ?? "unknown")")
    }
    
    /// Get current session statistics
    func getCurrentSessionStats() -> SessionStats? {
        guard isActive, let startTime = sessionStartTime else { return nil }
        
        let duration = Date().timeIntervalSince(startTime)
        let totalReadings = integratedReadings.count
        let validHeartRateReadings = integratedReadings.filter { $0.biometricData.validHeartRate }.count
        
        return SessionStats(
            duration: duration,
            totalReadings: totalReadings,
            validHeartRateReadings: validHeartRateReadings,
            averageHeartRate: calculateAverageHeartRate(),
            currentConnectionStatus: connectionStatus
        )
    }
}

// MARK: - Private Methods
private extension BiometricManager {
    
    func setupBindings() {
        // Bind biometric service connection state
        biometricService.$connectionState
            .map { state in
                switch state {
                case .disconnected: return .disconnected
                case .scanning: return .scanning
                case .connecting: return .connecting
                case .connected, .dataReady: return .connected
                }
            }
            .assign(to: &$connectionStatus)
        
        // Bind biometric data updates
        biometricService.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] biometricData in
                self?.handleNewBiometricData(biometricData)
            }
            .store(in: &cancellables)
        
        // Bind biometric service errors
        biometricService.$lastError
            .compactMap { $0?.errorDescription }
            .assign(to: &$errorMessage)
        
        // Bind Storage connection errors
        biometricStorageService.$lastError
            .compactMap { $0?.errorDescription }
            .sink { [weak self] error in
                self?.errorMessage = "Storage: \(error)"
            }
            .store(in: &cancellables)
    }
    
    func handleNewBiometricData(_ data: BiometricData) {
        currentBiometricData = data
        
        // Add to buffer
        dataBuffer.append(data)
        if dataBuffer.count > bufferLimit {
            dataBuffer.removeFirst()
        }
        
        // Create integrated reading
        let integratedReading = IntegratedReading(
            biometricData: data,
            emotionData: lastEmotionData,
            timestamp: Date()
        )
        
        integratedReadings.append(integratedReading)
        
        // Limit retained readings
        if integratedReadings.count > maxRetainedReadings {
            integratedReadings.removeFirst()
        }
        
        print("📊 New biometric reading: HR=\(data.heartRateStatus), Temp=\(data.formattedTemperature)")
    }
    
    func startEmotionIntegration() {
        guard let cameraService = cameraService,
              let emotionAPIService = emotionAPIService else {
            print("⚠️ Camera or emotion API service not available for integration")
            return
        }
        
        // Subscribe to emotion data (simplified for demo)
        // In a real implementation, this would integrate with the Phase 2 emotion service
        print("🎭 Emotion integration started (Phase 2 integration placeholder)")
        
        print("🎭 Emotion integration started")
    }
    
    func startUploadTimer() {
        integrationTimer = Timer.scheduledTimer(withTimeInterval: uploadInterval, repeats: true) { [weak self] _ in
            self?.uploadBufferedData()
        }
    }
    
    func uploadBufferedData() {
        guard !dataBuffer.isEmpty else { return }
        
        print("📤 Storing \(dataBuffer.count) biometric readings locally")
        biometricStorageService.storeBiometricDataBatch(dataBuffer)
        dataBuffer.removeAll()
    }
    
    func calculateSessionSummary() {
        guard let startTime = sessionStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        let validHeartRateReadings = integratedReadings.filter { $0.biometricData.validHeartRate }
        
        let heartRates = validHeartRateReadings.map { $0.biometricData.heartRate }
        let temperatures = integratedReadings.map { $0.biometricData.temperature }
        
        sessionSummary = SessionSummary(
            duration: duration,
            totalReadings: integratedReadings.count,
            validHeartRateReadings: validHeartRateReadings.count,
            averageHeartRate: heartRates.isEmpty ? nil : heartRates.reduce(0, +) / Float(heartRates.count),
            minHeartRate: heartRates.min(),
            maxHeartRate: heartRates.max(),
            averageTemperature: temperatures.reduce(0, +) / Float(temperatures.count),
            emotionIntegrationCount: integratedReadings.filter { $0.emotionData != nil }.count
        )
        
        print("📈 Session summary calculated: \(sessionSummary!)")
    }
    
    func createStorageSummary() -> BiometricSessionSummary? {
        guard let summary = sessionSummary else { return nil }
        
        return BiometricSessionSummary(
            totalReadings: summary.totalReadings,
            validHeartRateReadings: summary.validHeartRateReadings,
            averageHeartRate: summary.averageHeartRate,
            minHeartRate: summary.minHeartRate,
            maxHeartRate: summary.maxHeartRate,
            averageTemperature: summary.averageTemperature,
            sessionDuration: summary.duration
        )
    }
    
    func calculateAverageHeartRate() -> Float? {
        let validReadings = integratedReadings.filter { $0.biometricData.validHeartRate }
        guard !validReadings.isEmpty else { return nil }
        
        let sum = validReadings.reduce(0) { $0 + $1.biometricData.heartRate }
        return sum / Float(validReadings.count)
    }
}

// MARK: - Supporting Types
extension BiometricManager {
    
    enum ConnectionStatus: String, CaseIterable {
        case disconnected = "Disconnected"
        case scanning = "Scanning"
        case connecting = "Connecting"
        case connected = "Connected"
        
        var color: String {
            switch self {
            case .disconnected: return "red"
            case .scanning: return "orange"
            case .connecting: return "yellow"
            case .connected: return "green"
            }
        }
        
        var systemImage: String {
            switch self {
            case .disconnected: return "multiply.circle"
            case .scanning: return "magnifyingglass"
            case .connecting: return "arrow.triangle.2.circlepath"
            case .connected: return "checkmark.circle"
            }
        }
    }
    
    struct IntegratedReading: Identifiable, Codable {
        let id = UUID()
        let biometricData: BiometricData
        let emotionData: EmotionResponse?
        let timestamp: Date
        
        var hasEmotionData: Bool {
            return emotionData != nil
        }
        
        var correlationScore: Float? {
            guard let emotion = emotionData,
                  biometricData.validHeartRate else { return nil }
            
            // Simple correlation based on emotion confidence and heart rate
            let emotionIntensity = emotion.confidence
            let heartRateNormalized = (biometricData.heartRate - 60) / 40 // Normalize to 0-1 range roughly
            
            return abs(emotionIntensity - heartRateNormalized)
        }
    }
    
    struct SessionSummary {
        let duration: TimeInterval
        let totalReadings: Int
        let validHeartRateReadings: Int
        let averageHeartRate: Float?
        let minHeartRate: Float?
        let maxHeartRate: Float?
        let averageTemperature: Float?
        let emotionIntegrationCount: Int
        
        var formattedDuration: String {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
        var heartRateVariability: Float? {
            guard let min = minHeartRate, let max = maxHeartRate else { return nil }
            return max - min
        }
    }
    
    struct SessionStats {
        let duration: TimeInterval
        let totalReadings: Int
        let validHeartRateReadings: Int
        let averageHeartRate: Float?
        let currentConnectionStatus: ConnectionStatus
        
        var readingsPerMinute: Float {
            let minutes = Float(duration / 60)
            return minutes > 0 ? Float(totalReadings) / minutes : 0
        }
        
        var validHeartRatePercentage: Float {
            return totalReadings > 0 ? (Float(validHeartRateReadings) / Float(totalReadings)) * 100 : 0
        }
    }
}

// MARK: - Static Factory Methods
extension BiometricManager {
    
    /// Create a BiometricManager configured for testing
    static func createForTesting() -> BiometricManager {
        return BiometricManager()
    }
    
    /// Create a BiometricManager with full integration capabilities
    static func createWithFullIntegration(
        cameraService: CameraService,
        emotionAPIService: EmotionAPIService
    ) -> BiometricManager {
        let manager = BiometricManager()
        manager.cameraService = cameraService
        manager.emotionAPIService = emotionAPIService
        return manager
    }
}
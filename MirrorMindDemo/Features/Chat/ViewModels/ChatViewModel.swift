//
//  ChatViewModel.swift
//  MirrorMindDemo
//
//  Created by Demo Firebase Chat Lead on 21/08/25.
//

import Foundation
import Combine

/// ViewModel para la vista de Chat con datos mock y Firebase
class ChatViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isCameraOn: Bool = false
    @Published var isSmartbandConnected: Bool = false
    @Published var currentSuggestions: [VideoSuggestion] = []
    @Published var mockHeartRate: Int = 75
    @Published var mockStressLevel: Double = 0.3
    @Published var isLoadingSuggestions: Bool = false
    
    // MARK: - Services
    @Published var emotionService = EmotionFirebaseService()
    private var suggestionEngine: SuggestionEngine!
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var mockDataTimer: Timer?
    
    init() {
        suggestionEngine = SuggestionEngine(emotionService: emotionService)
        setupMockData()
        observeEmotionChanges()
    }
    
    // MARK: - Public Methods
    
    /// Alterna el estado de la cámara
    func toggleCamera() {
        isCameraOn.toggle()
    }
    
    /// Simula conexión/desconexión del smartband
    func toggleSmartband() {
        isSmartbandConnected.toggle()
        
        if isSmartbandConnected {
            startMockSensorData()
        } else {
            stopMockSensorData()
        }
    }
    
    /// Obtiene sugerencias inteligentes solo si hay datos válidos
    func getSuggestions() {
        isLoadingSuggestions = true
        
        // Verificar si se pueden generar sugerencias
        if !canGenerateSuggestions() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.currentSuggestions = []
                self?.isLoadingSuggestions = false
            }
            return
        }
        
        // Generar sugerencias solo si hay datos válidos
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Usar SuggestionEngine con datos biométricos mock
            self.suggestionEngine.generateSuggestions(
                heartRate: self.mockHeartRate,
                stressLevel: self.mockStressLevel
            )
            
            self.currentSuggestions = self.suggestionEngine.currentSuggestions
            self.isLoadingSuggestions = false
        }
    }
    
    /// Formatea los datos biométricos según estado de conexión
    func getFormattedBiometrics() -> (heartRate: String, stress: String) {
        if !isSmartbandConnected {
            return ("Sin datos", "Sin datos")
        }
        
        let heartRateText = "\(mockHeartRate) LPM"
        let stressText = String(format: "%.1f", mockStressLevel * 100) + "%"
        return (heartRateText, stressText)
    }
    
    /// Verifica si se pueden generar sugerencias
    func canGenerateSuggestions() -> Bool {
        return emotionService.hasValidData() && isSmartbandConnected
    }
    
    /// Obtiene el estado del sistema para mostrar en UI
    func getSystemStatus() -> String {
        if !emotionService.isSystemOn {
            return "Apagado"
        } else if emotionService.currentEmotion.isEmpty {
            return "Sin emoción detectada"
        } else {
            return emotionService.currentEmotion
        }
    }
    
    // MARK: - Private Methods
    
    /// Configura datos mock iniciales
    private func setupMockData() {
        // Simular smartband conectado de inicio
        isSmartbandConnected = true
        startMockSensorData()
        
        // Cargar sugerencias iniciales
        getSuggestions()
    }
    
    /// Observa cambios en la emoción desde Firebase
    private func observeEmotionChanges() {
        emotionService.$currentEmotion
            .sink { [weak self] emotion in
                self?.getSuggestions()
            }
            .store(in: &cancellables)
    }
    
    /// Inicia la generación de datos mock de sensores
    private func startMockSensorData() {
        mockDataTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMockSensorData()
        }
    }
    
    /// Detiene la generación de datos mock
    private func stopMockSensorData() {
        mockDataTimer?.invalidate()
        mockDataTimer = nil
    }
    
    /// Actualiza los datos mock de sensores
    private func updateMockSensorData() {
        // Heart rate: rango normal 60-100 LPM
        mockHeartRate = Int.random(in: 65...95)
        
        // Stress level: 0.0 (relajado) - 1.0 (estresado)
        mockStressLevel = Double.random(in: 0.1...0.8)
        
    }
    
    deinit {
        stopMockSensorData()
        cancellables.removeAll()
    }
}

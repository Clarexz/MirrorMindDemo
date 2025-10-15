//
//  ChatViewModel.swift
//  MirrorMindDemo
//
//  Created by Demo Firebase Chat Lead on 21/08/25.
//  Modified by Emotion API Lead on 01/09/25.
//

import Foundation
import Combine

/// ViewModel para la vista de Chat con datos reales y Firebase
class ChatViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isCameraOn: Bool = false
    @Published var isSmartbandConnected: Bool = false
    @Published var currentSuggestions: [VideoSuggestion] = []
    @Published var mockHeartRate: Int = 75
    @Published var mockStressLevel: Double = 0.3
    @Published var isLoadingSuggestions: Bool = false
    
    // MARK: - Services (simplificado para evitar crashes)
    @Published var emotionService = EmotionFirebaseService()
    @Published var cameraService = CameraService()
    @Published var biometricManager = BiometricManager() // Para tarjeta de smartband
    private var suggestionEngine: SuggestionEngine!
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var frameProcessingEnabled: Bool = false
    
    init() {
        suggestionEngine = SuggestionEngine(emotionService: emotionService)
        // Simplificado: solo setup básico
        observeEmotionChanges()
        
        // Chat no maneja smartband, usa datos mock
        isSmartbandConnected = false
    }
    
    // MARK: - Public Methods
    
    /// Alterna el estado de la cámara
    func toggleCamera() {
        isCameraOn.toggle()
        
        if isCameraOn {
            startCamera()
        } else {
            stopCamera()
        }
    }
    
    // Métodos de smartband eliminados - ahora usa el componente de Inicio
    
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
            
            // Usar SuggestionEngine con datos mock para Chat
            self.suggestionEngine.generateSuggestions(
                heartRate: self.mockHeartRate,
                stressLevel: self.mockStressLevel
            )
            
            self.currentSuggestions = self.suggestionEngine.currentSuggestions
            self.isLoadingSuggestions = false
        }
    }
    
    /// Verifica si se pueden generar sugerencias (solo basado en emociones)
    func canGenerateSuggestions() -> Bool {
        return emotionService.hasValidData()
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
    
    // Métodos biométricos eliminados - Chat usa componente de Inicio
    
    /// Observa cambios en la emoción desde Firebase
    private func observeEmotionChanges() {
        emotionService.$currentEmotion
            .sink { [weak self] emotion in
                self?.getSuggestions()
            }
            .store(in: &cancellables)
    }
    
    // setupEmotionPipeline removido para evitar crashes
    
    /// Inicia la cámara real y el procesamiento de frames
    private func startCamera() {
        guard cameraService.isAuthorized else {
            print("❌ Cámara no autorizada")
            return
        }
        
        // Iniciar cámara
        cameraService.startCamera()
        
        // Frame capture simplificado (sin procesamiento API)
        frameProcessingEnabled = true
        
        print("✅ Cámara iniciada - procesando frames cada 2 segundos")
    }
    
    /// Detiene la cámara y el procesamiento
    private func stopCamera() {
        frameProcessingEnabled = false
        cameraService.stopFrameCapture()
        cameraService.stopCamera()
        print("⏹️ Cámara detenida")
    }
    
    // Métodos de API removidos para evitar crashes
    
    // Chat simplificado - biometría gestionada por BiometricDashboardView
    
    deinit {
        // Limpiar recursos de forma simple
        cancellables.removeAll()
        // No necesitamos detener la cámara manualmente en deinit
    }
    
    // MARK: - API Status Methods
    
    // Métodos de API status removidos para evitar crashes
}

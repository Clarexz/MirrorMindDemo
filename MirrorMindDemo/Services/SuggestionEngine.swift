//
//  SuggestionEngine.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//


import Foundation
import Combine

/// Motor de sugerencias inteligente que combina emoción Firebase + sensores mock
class SuggestionEngine: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentSuggestions: [VideoSuggestion] = []
    @Published var recommendationReason: String = ""
    
    // MARK: - Services
    private let emotionService: EmotionFirebaseService
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    init(emotionService: EmotionFirebaseService) {
        self.emotionService = emotionService
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    /// Genera sugerencias inteligentes basadas en emoción y datos biométricos
    func generateSuggestions(heartRate: Int, stressLevel: Double) {
        let emotion = emotionService.getCurrentEmotion()
        let suggestions = computeIntelligentSuggestions(
            emotion: emotion,
            heartRate: heartRate,
            stressLevel: stressLevel
        )
        
        currentSuggestions = suggestions
        recommendationReason = generateRecommendationReason(
            emotion: emotion,
            heartRate: heartRate,
            stressLevel: stressLevel
        )
    }
    
    /// Obtiene la mejor sugerencia para el estado actual
    func getTopSuggestion() -> VideoSuggestion? {
        return currentSuggestions.first
    }
    
    // MARK: - Private Methods
    
    /// Configura observadores para cambios automáticos
    private func setupObservers() {
        emotionService.$currentEmotion
            .sink { [weak self] _ in
                self?.triggerAutoUpdate()
            }
            .store(in: &cancellables)
    }
    
    /// Dispara actualización automática con datos mock
    private func triggerAutoUpdate() {
        // Usar datos mock aleatorios para demo
        let mockHeartRate = Int.random(in: 65...95)
        let mockStressLevel = Double.random(in: 0.1...0.8)
        
        generateSuggestions(heartRate: mockHeartRate, stressLevel: mockStressLevel)
    }
    
    /// Computa sugerencias inteligentes combinando múltiples factores
    private func computeIntelligentSuggestions(emotion: String, heartRate: Int, stressLevel: Double) -> [VideoSuggestion] {
        var suggestions = VideoSuggestion.getSuggestions(for: emotion)
        
        // Aplicar filtros inteligentes basados en biometría
        suggestions = applyBiometricFiltering(suggestions, heartRate: heartRate, stressLevel: stressLevel)
        
        // Ordenar por relevancia
        suggestions = prioritizeSuggestions(suggestions, emotion: emotion, heartRate: heartRate, stressLevel: stressLevel)
        
        // Limitar a top 3 para mejor UX
        return Array(suggestions.prefix(3))
    }
    
    /// Aplica filtrado basado en datos biométricos
    private func applyBiometricFiltering(_ suggestions: [VideoSuggestion], heartRate: Int, stressLevel: Double) -> [VideoSuggestion] {
        return suggestions.filter { suggestion in
            // Filtros inteligentes basados en estado biométrico
            if stressLevel > 0.6 {
                // Alto estrés: priorizar respiración y relajación
                return suggestion.category.contains("Respiración") || suggestion.category.contains("Bienestar")
            } else if heartRate > 85 {
                // Frecuencia alta: evitar ejercicios activadores
                return !suggestion.category.contains("Motivación")
            } else {
                // Estado normal: todas las sugerencias son válidas
                return true
            }
        }
    }
    
    /// Prioriza sugerencias por relevancia
    private func prioritizeSuggestions(_ suggestions: [VideoSuggestion], emotion: String, heartRate: Int, stressLevel: Double) -> [VideoSuggestion] {
        return suggestions.sorted { first, second in
            let firstScore = calculateRelevanceScore(first, emotion: emotion, heartRate: heartRate, stressLevel: stressLevel)
            let secondScore = calculateRelevanceScore(second, emotion: emotion, heartRate: heartRate, stressLevel: stressLevel)
            
            return firstScore > secondScore
        }
    }
    
    /// Calcula score de relevancia para una sugerencia
    private func calculateRelevanceScore(_ suggestion: VideoSuggestion, emotion: String, heartRate: Int, stressLevel: Double) -> Double {
        var score: Double = 0.0
        
        // Puntuación base por coincidencia de emoción
        if suggestion.emotion == emotion {
            score += 10.0
        }
        
        // Ajustes por datos biométricos
        if stressLevel > 0.6 && suggestion.category.contains("Respiración") {
            score += 5.0
        }
        
        if heartRate < 70 && suggestion.category.contains("Motivación") {
            score += 3.0
        }
        
        if emotion == "Feliz" && suggestion.category.contains("Social") {
            score += 4.0
        }
        
        return score
    }
    
    /// Genera explicación de por qué se hicieron estas recomendaciones
    private func generateRecommendationReason(emotion: String, heartRate: Int, stressLevel: Double) -> String {
        var reasons: [String] = []
        
        reasons.append("Tu estado emocional actual es \(emotion)")
        
        if stressLevel > 0.6 {
            reasons.append("detectamos un nivel de estrés elevado (\(String(format: "%.0f", stressLevel * 100))%)")
        }
        
        if heartRate > 85 {
            reasons.append("tu frecuencia cardíaca está algo elevada (\(heartRate) LPM)")
        }
        
        if emotion == "Feliz" {
            reasons.append("queremos ayudarte a mantener ese estado positivo")
        } else if emotion == "Neutral" {
            reasons.append("te sugerimos actividades para encontrar motivación")
        }
        
        return reasons.joined(separator: ", ")
    }
    
    deinit {
        cancellables.removeAll()
    }
}

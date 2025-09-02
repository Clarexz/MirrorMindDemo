//
//  VideoSuggestion.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import Foundation

/// Modelo para las tarjetas de sugerencias de video
struct VideoSuggestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let emotion: String
    let category: String
    let duration: String
    let thumbnailName: String
    let videoURL: String?
    
    init(title: String, description: String, emotion: String, category: String, duration: String, thumbnailName: String = "video_thumbnail", videoURL: String? = nil) {
        self.title = title
        self.description = description
        self.emotion = emotion
        self.category = category
        self.duration = duration
        self.thumbnailName = thumbnailName
        self.videoURL = videoURL
    }
}

/// Base de datos mock de sugerencias de video
extension VideoSuggestion {
    static let mockSuggestions = [
        // Sugerencias para estado "Feliz"
        VideoSuggestion(
            title: "Mantén tu energía positiva",
            description: "Ejercicios de gratitud para prolongar tu felicidad",
            emotion: "Feliz",
            category: "Bienestar",
            duration: "5 min"
        ),
        VideoSuggestion(
            title: "Comparte tu alegría",
            description: "Técnicas para contagiar positividad a otros",
            emotion: "Feliz",
            category: "Social",
            duration: "3 min"
        ),
        VideoSuggestion(
            title: "Celebra tus logros",
            description: "Reflexión sobre tus éxitos recientes",
            emotion: "Feliz",
            category: "Reflexión",
            duration: "4 min"
        ),
        
        // Sugerencias para estado "Neutral"
        VideoSuggestion(
            title: "Encuentra tu motivación",
            description: "Ejercicios para activar tu energía interna",
            emotion: "Neutral",
            category: "Motivación",
            duration: "6 min"
        ),
        VideoSuggestion(
            title: "Respiración energizante",
            description: "Técnicas de respiración para aumentar vitalidad",
            emotion: "Neutral",
            category: "Respiración",
            duration: "4 min"
        ),
        VideoSuggestion(
            title: "Descubre nuevas metas",
            description: "Reflexión para establecer objetivos claros",
            emotion: "Neutral",
            category: "Planificación",
            duration: "7 min"
        )
    ]
    
    /// Filtra sugerencias por emoción
    static func getSuggestions(for emotion: String) -> [VideoSuggestion] {
        return mockSuggestions.filter { $0.emotion == emotion }
    }
    
    /// Obtiene una sugerencia aleatoria para una emoción
    static func getRandomSuggestion(for emotion: String) -> VideoSuggestion? {
        return getSuggestions(for: emotion).randomElement()
    }
}

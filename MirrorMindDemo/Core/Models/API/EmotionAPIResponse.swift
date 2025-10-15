//
//  EmotionAPIResponse.swift
//  MirrorMindDemo
//
//  Created by Emotion API Lead on 01/09/25.
//

import Foundation

/// Modelo para parsear la respuesta de la API de reconocimiento emocional
struct EmotionAPIResponse: Codable {
    let status: String
    let recognition: RecognitionData?
    let emotion: String
    let confidence: Double
    let description: String
    
    /// Datos de reconocimiento (no nos interesan pero están en la respuesta)
    struct RecognitionData: Codable {
        // Podemos agregar campos si los necesitamos en el futuro
    }
    
    /// Verifica si la respuesta es exitosa
    var isSuccessful: Bool {
        return status.lowercased() == "success"
    }
    
    /// Verifica si la confianza es suficientemente alta
    func hasHighConfidence(threshold: Double = 0.5) -> Bool {
        return confidence >= threshold
    }
    
    /// Obtiene la emoción en español (usa description si está disponible)
    var localizedEmotion: String {
        return description.isEmpty ? emotion : description
    }
}

/// Modelo para errores de la API
struct EmotionAPIError: Codable, Error {
    let status: String
    let message: String?
    let error: String?
    
    var localizedDescription: String {
        return message ?? error ?? "Error desconocido en la API"
    }
}
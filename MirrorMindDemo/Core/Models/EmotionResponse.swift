//
//  EmotionResponse.swift
//  MirrorMindDemo
//
//  Created on Phase 3 - Bluetooth Integration
//  Simple emotion response model for local use (no Firebase dependencies)
//

import Foundation

/// Model representing an emotion recognition response from a local API
struct EmotionResponse: Codable, Identifiable, Equatable {
    let id = UUID()
    let emotion: String
    let confidence: Float
    let message: String
    let timestamp: Date
    
    /// Initializer for emotion response
    init(emotion: String, confidence: Float, message: String) {
        self.emotion = emotion
        self.confidence = confidence
        self.message = message
        self.timestamp = Date()
    }
    
    /// Coding keys for JSON serialization (excluding computed properties)
    private enum CodingKeys: String, CodingKey {
        case emotion, confidence, message
    }
    
    /// Custom decoder to handle timestamp
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        emotion = try container.decode(String.self, forKey: .emotion)
        confidence = try container.decode(Float.self, forKey: .confidence)
        message = try container.decode(String.self, forKey: .message)
        timestamp = Date()
    }
    
    /// Encode to JSON (excluding local timestamp)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(emotion, forKey: .emotion)
        try container.encode(confidence, forKey: .confidence)
        try container.encode(message, forKey: .message)
    }
}

// MARK: - Computed Properties
extension EmotionResponse {
    /// Confidence percentage as integer
    var confidencePercentage: Int {
        return Int(confidence * 100)
    }
    
    /// Emotion category for UI display
    var emotionCategory: EmotionCategory {
        switch emotion.lowercased() {
        case "happy", "joy", "happiness", "alegre", "feliz":
            return .positive
        case "sad", "sadness", "triste", "tristeza":
            return .negative
        case "angry", "anger", "enojado", "ira":
            return .negative
        case "surprised", "surprise", "sorprendido", "sorpresa":
            return .neutral
        case "fear", "afraid", "miedo", "asustado":
            return .negative
        case "disgust", "disgusted", "asco", "disgusto":
            return .negative
        case "neutral", "normal", "neutro":
            return .neutral
        default:
            return .unknown
        }
    }
    
    /// System image name for the emotion
    var systemImageName: String {
        switch emotionCategory {
        case .positive:
            return "face.smiling"
        case .negative:
            return "face.dashed"
        case .neutral:
            return "face.dashed.fill"
        case .unknown:
            return "questionmark.circle"
        }
    }
    
    /// Color for UI display
    var displayColor: String {
        switch emotionCategory {
        case .positive:
            return "green"
        case .negative:
            return "red"
        case .neutral:
            return "blue"
        case .unknown:
            return "gray"
        }
    }
}

// MARK: - Supporting Enums
enum EmotionCategory: String, CaseIterable {
    case positive = "Positive"
    case negative = "Negative"
    case neutral = "Neutral"
    case unknown = "Unknown"
    
    var description: String {
        return rawValue
    }
}

// MARK: - Sample Data
extension EmotionResponse {
    /// Sample emotion responses for testing and UI previews
    static let sampleData: [EmotionResponse] = [
        EmotionResponse(emotion: "happy", confidence: 0.85, message: "Feliz/Contento"),
        EmotionResponse(emotion: "sad", confidence: 0.72, message: "Triste/Melancólico"),
        EmotionResponse(emotion: "surprised", confidence: 0.91, message: "Sorprendido"),
        EmotionResponse(emotion: "neutral", confidence: 0.65, message: "Neutral/Normal"),
        EmotionResponse(emotion: "angry", confidence: 0.78, message: "Enojado/Molesto")
    ]
    
    /// Sample happy emotion
    static let sampleHappy = EmotionResponse(
        emotion: "happy",
        confidence: 0.85,
        message: "Feliz/Contento"
    )
    
    /// Sample sad emotion
    static let sampleSad = EmotionResponse(
        emotion: "sad",
        confidence: 0.72,
        message: "Triste/Melancólico"
    )
    
    /// Sample neutral emotion
    static let sampleNeutral = EmotionResponse(
        emotion: "neutral",
        confidence: 0.65,
        message: "Neutral/Normal"
    )
}

// MARK: - Validation
extension EmotionResponse {
    /// Validate the emotion response data
    var isValid: Bool {
        return !emotion.isEmpty &&
               confidence >= 0.0 &&
               confidence <= 1.0 &&
               !message.isEmpty
    }
    
    /// Check if confidence is high enough to be considered reliable
    var isHighConfidence: Bool {
        return confidence >= 0.7
    }
    
    /// Check if this is a positive emotion
    var isPositiveEmotion: Bool {
        return emotionCategory == .positive
    }
    
    /// Check if this is a negative emotion
    var isNegativeEmotion: Bool {
        return emotionCategory == .negative
    }
}

// MARK: - Equatable Implementation
extension EmotionResponse {
    static func == (lhs: EmotionResponse, rhs: EmotionResponse) -> Bool {
        return lhs.emotion == rhs.emotion &&
               lhs.confidence == rhs.confidence &&
               lhs.message == rhs.message
    }
}
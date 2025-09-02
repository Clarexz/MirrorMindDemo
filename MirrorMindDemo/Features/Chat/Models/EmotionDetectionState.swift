//
//  EmotionDetectionState.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//


//
//  EmotionDetection.swift
//  MirrorMind
//
//  Created by Camera Integration Lead on 21/08/25.
//

import Foundation

// MARK: - Emotion Detection State
enum EmotionDetectionState: Equatable {
    case idle
    case processing
    case detected(DetectedEmotion)
    case failed(String)
    case noFaceDetected
}

// MARK: - Detected Emotion
struct DetectedEmotion: Codable, Equatable {
    let emotionName: String // name del Emotion (ej: "happy", "sad")
    let confidence: Double
    let timestamp: Date
    let faceLandmarks: [FaceLandmark]?
    
    init(emotionName: String, confidence: Double, faceLandmarks: [FaceLandmark]? = nil) {
        self.emotionName = emotionName
        self.confidence = confidence
        self.timestamp = Date()
        self.faceLandmarks = faceLandmarks
    }
    
    // Conveniencia para obtener el Emotion completo
    var emotion: Emotion? {
        return Emotion.emotion(named: emotionName)
    }
}

// MARK: - Face Landmark
struct FaceLandmark: Codable, Equatable {
    let x: Double
    let y: Double
    let z: Double?
    let type: LandmarkType
    
    enum LandmarkType: String, Codable, CaseIterable {
        case leftEye = "left_eye"
        case rightEye = "right_eye"
        case nose = "nose"
        case mouth = "mouth"
        case leftEyebrow = "left_eyebrow"
        case rightEyebrow = "right_eyebrow"
        case jawline = "jawline"
    }
}

// MARK: - Frame Processing
struct CameraFrame {
    let image: Data
    let timestamp: Date
    let metadata: FrameMetadata
    
    init(image: Data, metadata: FrameMetadata = FrameMetadata()) {
        self.image = image
        self.timestamp = Date()
        self.metadata = metadata
    }
}

struct FrameMetadata {
    let width: Int
    let height: Int
    let orientation: FrameOrientation
    
    init(width: Int = 640, height: Int = 480, orientation: FrameOrientation = .portrait) {
        self.width = width
        self.height = height
        self.orientation = orientation
    }
}

enum FrameOrientation: String, Codable {
    case portrait
    case landscape
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
}

// MARK: - Detection Configuration
struct DetectionConfiguration {
    let processingInterval: Double // segundos entre procesamientos
    let confidenceThreshold: Double // mínima confianza para detectar emoción
    let enableLandmarks: Bool // si capturar landmarks faciales
    let maxFramesPerSecond: Int // máximo FPS para procesamiento
    
    static let `default` = DetectionConfiguration(
        processingInterval: 0.5, // procesar cada 500ms
        confidenceThreshold: 0.7, // 70% de confianza mínima
        enableLandmarks: true,
        maxFramesPerSecond: 2 // 2 FPS para procesamiento
    )
    
    static let performance = DetectionConfiguration(
        processingInterval: 1.0, // procesar cada segundo
        confidenceThreshold: 0.8, // 80% de confianza mínima
        enableLandmarks: false,
        maxFramesPerSecond: 1 // 1 FPS para mejor rendimiento
    )
}
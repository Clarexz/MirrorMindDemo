//
//  EmotionalData.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//


import Foundation

// MARK: - EmotionalData Model
struct EmotionalData: Identifiable, Codable {
    let id: UUID
    let date: Date
    let emotion: String // displayName de la emoción
    let intensity: Double // 0.0 - 1.0 (qué tan intensa fue esa emoción)
    let timestamp: Date
    
    init(date: Date, emotion: String, intensity: Double) {
        self.id = UUID()
        self.date = date
        self.emotion = emotion
        self.intensity = intensity
        self.timestamp = Date()
    }
}

// MARK: - WeeklyEmotionalSummary
struct WeeklyEmotionalSummary: Identifiable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    let dailyData: [DailyEmotionalData]
    let predominantEmotion: String
    let predominantEmotionCount: Int
    
    var weekDescription: String {
        switch predominantEmotion.lowercased() {
        case "feliz":
            return "Has estado mayormente feliz esta semana"
        case "calmado":
            return "Has mantenido la calma esta semana"
        case "ansioso":
            return "Has sentido ansiedad esta semana"
        case "enojado":
            return "Has experimentado enojo esta semana"
        case "triste":
            return "Has estado triste esta semana"
        case "nervioso":
            return "Has estado nervioso esta semana"
        default:
            return "Has tenido emociones variadas esta semana"
        }
    }
}

// MARK: - DailyEmotionalData
struct DailyEmotionalData: Identifiable {
    let id = UUID()
    let date: Date
    let dayOfWeek: String
    let emotion: String
    let intensity: Double
    let color: String // Para mapear al color de la emoción
    let isToday: Bool
    let isFutureDay: Bool
    
    var dayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "E"
        let day = formatter.string(from: date)
        
        // Convertir a abreviaciones más cortas
        switch day.lowercased() {
        case "lun":
            return "L"
        case "mar":
            return "M"
        case "mié":
            return "M"
        case "jue":
            return "J"
        case "vie":
            return "V"
        case "sáb":
            return "S"
        case "dom":
            return "D"
        default:
            return String(day.prefix(1)).uppercased()
        }
    }
}
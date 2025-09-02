//
//  WeeklyDataViewModel.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//


import Foundation
import SwiftUI
import Combine

// MARK: - WeeklyDataViewModel
class WeeklyDataViewModel: ObservableObject {
    @Published var currentWeeklySummary: WeeklyEmotionalSummary
    @Published var isLoading: Bool = false
    
    // Datos mock para desarrollo
    private let mockEmotionalData: [EmotionalData]
    
    init() {
        // Generar datos mock para los últimos 7 días
        self.mockEmotionalData = WeeklyDataViewModel.generateMockData()
        self.currentWeeklySummary = WeeklyDataViewModel.createWeeklySummary(from: mockEmotionalData)
    }
    
    // MARK: - Mock Data Generation
    private static func generateMockData() -> [EmotionalData] {
        let calendar = Calendar.current
        let today = Date()
        var mockData: [EmotionalData] = []
        
        // Emociones disponibles del sistema
        let emotions = ["Feliz", "Calmado", "Ansioso", "Triste", "Enojado", "Nervioso"]
        
        // Calcular el lunes de la semana actual
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        // Generar datos solo para algunos días (simular uso real)
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                // Solo generar datos para días pasados y hoy
                if dayDate <= today {
                    // Simular que algunos días el usuario no usó la app (70% probabilidad de tener datos)
                    let hasData = (i + dayDate.hashValue) % 10 < 7
                    
                    if hasData {
                        // Seleccionar emoción de manera pseudo-aleatoria pero realista
                        let emotionIndex = abs(i + dayDate.hashValue) % emotions.count
                        let selectedEmotion = emotions[emotionIndex]
                        
                        // Generar intensidad realista (0.4 - 1.0)
                        let intensity = 0.4 + Double(abs(dayDate.hashValue % 60)) / 100.0
                        
                        let emotionalData = EmotionalData(
                            date: dayDate,
                            emotion: selectedEmotion,
                            intensity: intensity
                        )
                        
                        mockData.append(emotionalData)
                    }
                }
            }
        }
        
        return mockData.sorted { $0.date < $1.date }
    }
    
    // MARK: - Weekly Summary Creation
    private static func createWeeklySummary(from data: [EmotionalData]) -> WeeklyEmotionalSummary {
        let calendar = Calendar.current
        let sortedData = data.sorted { $0.date < $1.date }
        
        guard let firstDate = sortedData.first?.date,
              let lastDate = sortedData.last?.date else {
            return createEmptyWeeklySummary()
        }
        
        // Crear datos diarios
        let dailyData = createDailyData(from: sortedData)
        
        // Encontrar emoción predominante
        let emotionCounts = Dictionary(grouping: sortedData, by: { $0.emotion })
            .mapValues { $0.count }
        
        let predominantEmotion = emotionCounts.max { $0.value < $1.value }?.key ?? "Variado"
        let predominantCount = emotionCounts[predominantEmotion] ?? 0
        
        return WeeklyEmotionalSummary(
            startDate: firstDate,
            endDate: lastDate,
            dailyData: dailyData,
            predominantEmotion: predominantEmotion,
            predominantEmotionCount: predominantCount
        )
    }
    
    private static func createDailyData(from data: [EmotionalData]) -> [DailyEmotionalData] {
        let calendar = Calendar.current
        let today = Date()
        var dailyData: [DailyEmotionalData] = []
        
        // Calcular el lunes de la semana actual
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        // Crear datos para 7 días (Lunes a Domingo)
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                // Determinar si es día actual o futuro
                let isToday = calendar.isDate(dayDate, inSameDayAs: today)
                let isFutureDay = dayDate > today
                
                // Buscar datos para este día (solo si es pasado o actual)
                let dayData = data.first { calendar.isDate($0.date, inSameDayAs: dayDate) }
                
                let emotion: String
                let intensity: Double
                let color: String
                
                if isFutureDay {
                    // Días futuros en gris
                    emotion = "Sin datos"
                    intensity = 0.5
                    color = "gray"
                } else if let existingData = dayData {
                    // Día con datos reales
                    emotion = existingData.emotion
                    intensity = existingData.intensity
                    color = getColorNameForEmotion(existingData.emotion)
                } else {
                    // Día pasado sin datos (usuario no usó la app)
                    emotion = "Sin datos"
                    intensity = 0.5
                    color = "gray"
                }
                
                let daily = DailyEmotionalData(
                    date: dayDate,
                    dayOfWeek: "",
                    emotion: emotion,
                    intensity: intensity,
                    color: color,
                    isToday: isToday,
                    isFutureDay: isFutureDay
                )
                
                dailyData.append(daily)
            }
        }
        
        return dailyData
    }
    
    private static func createEmptyWeeklySummary() -> WeeklyEmotionalSummary {
        let today = Date()
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        
        return WeeklyEmotionalSummary(
            startDate: weekAgo,
            endDate: today,
            dailyData: [],
            predominantEmotion: "Neutral",
            predominantEmotionCount: 0
        )
    }
    
    // MARK: - Color Mapping
    private static func getColorNameForEmotion(_ emotion: String) -> String {
        switch emotion.lowercased() {
        case "feliz":
            return "happy"
        case "calmado":
            return "calm"
        case "ansioso":
            return "anxious"
        case "triste":
            return "sad"
        case "enojado":
            return "angry"
        case "nervioso":
            return "nervous"
        default:
            return "calm"
        }
    }
    
    // MARK: - Public Methods
    func refreshWeeklyData() {
        isLoading = true
        
        // Simular carga de datos
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // En una implementación real, aquí cargaríamos datos desde Core Data o API
            let newMockData = WeeklyDataViewModel.generateMockData()
            self.currentWeeklySummary = WeeklyDataViewModel.createWeeklySummary(from: newMockData)
            self.isLoading = false
        }
    }
    
    func getColorForEmotion(_ emotionName: String) -> Color {
        switch emotionName.lowercased() {
        case "happy":
            return Color.Emotions.happy
        case "calm":
            return Color.Emotions.calm
        case "anxious":
            return Color.Emotions.anxious
        case "sad":
            return Color.Emotions.sad
        case "angry":
            return Color.Emotions.angry
        case "nervous":
            return Color.Emotions.nervous
        case "gray":
            return Color.gray.opacity(0.3)
        default:
            return Color.gray.opacity(0.3)
        }
    }
}
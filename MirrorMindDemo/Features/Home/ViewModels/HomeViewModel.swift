//
//  HomeViewModel.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedEmotion: Emotion? = nil
    
    // MARK: - Ejercicios Mock Data
        private let allExercises: [Exercise] = [
            // Ejercicios generales (sin emoción específica)
            Exercise(name: "Respiración básica", description: "Ejercicio simple de respiración", duration: 300, category: .breathing, thumbnail: "general_1", emotions: [], isFavorite: false),
            Exercise(name: "Estiramiento suave", description: "Movimientos básicos", duration: 240, category: .movement, thumbnail: "general_2", emotions: [], isFavorite: false),
            Exercise(name: "Meditación inicial", description: "Introducción a la meditación", duration: 420, category: .meditation, thumbnail: "general_3", emotions: [], isFavorite: false),
            Exercise(name: "Reflexión diaria", description: "Momento de introspección", duration: 180, category: .reflection, thumbnail: "general_4", emotions: [], isFavorite: false),
            
            // Ejercicios para FELIZ
            Exercise(name: "Energía positiva", description: "Mantén tu buen estado", duration: 360, category: .growth, thumbnail: "happy_1", emotions: ["feliz"], isFavorite: false),
            Exercise(name: "Movimiento alegre", description: "Ejercicios dinámicos", duration: 480, category: .movement, thumbnail: "happy_2", emotions: ["feliz"], isFavorite: false),
            Exercise(name: "Gratitud activa", description: "Reflexión sobre lo positivo", duration: 300, category: .reflection, thumbnail: "happy_3", emotions: ["feliz"], isFavorite: false),
            Exercise(name: "Respiración energizante", description: "Técnica para mantener energía", duration: 240, category: .breathing, thumbnail: "happy_4", emotions: ["feliz"], isFavorite: false),
            
            // Ejercicios para TRISTE
            Exercise(name: "Respiración calmante", description: "Técnica para elevar el ánimo", duration: 420, category: .breathing, thumbnail: "sad_1", emotions: ["triste"], isFavorite: false),
            Exercise(name: "Meditación reconfortante", description: "Encuentra paz interior", duration: 600, category: .meditation, thumbnail: "sad_2", emotions: ["triste"], isFavorite: false),
            Exercise(name: "Movimiento suave", description: "Activación física gentil", duration: 360, category: .movement, thumbnail: "sad_3", emotions: ["triste"], isFavorite: false),
            Exercise(name: "Auto-compasión", description: "Reflexión sobre el cuidado personal", duration: 480, category: .reflection, thumbnail: "sad_4", emotions: ["triste"], isFavorite: false),
            
            // Ejercicios para ENOJADO
            Exercise(name: "Respiración calmante", description: "Técnica para reducir ira", duration: 300, category: .breathing, thumbnail: "angry_1", emotions: ["enojado"], isFavorite: false),
            Exercise(name: "Liberación de tensión", description: "Movimientos para descargar energía", duration: 360, category: .movement, thumbnail: "angry_2", emotions: ["enojado"], isFavorite: false),
            Exercise(name: "Meditación de paciencia", description: "Cultivar la calma interior", duration: 480, category: .meditation, thumbnail: "angry_3", emotions: ["enojado"], isFavorite: false),
            Exercise(name: "Reflexión constructiva", description: "Canalizar emociones positivamente", duration: 420, category: .reflection, thumbnail: "angry_4", emotions: ["enojado"], isFavorite: false),
            
            // Ejercicios para ANSIOSO
            Exercise(name: "Respiración 4-7-8", description: "Técnica anti-ansiedad", duration: 360, category: .breathing, thumbnail: "anxious_1", emotions: ["ansioso"], isFavorite: false),
            Exercise(name: "Mindfulness presente", description: "Conexión con el momento actual", duration: 540, category: .meditation, thumbnail: "anxious_2", emotions: ["ansioso"], isFavorite: false),
            Exercise(name: "Estiramiento relajante", description: "Movimientos para soltar tensión", duration: 300, category: .movement, thumbnail: "anxious_3", emotions: ["ansioso"], isFavorite: false),
            Exercise(name: "Pensamientos positivos", description: "Reenfoque mental constructivo", duration: 480, category: .growth, thumbnail: "anxious_4", emotions: ["ansioso"], isFavorite: false),
            
            // Ejercicios para NERVIOSO
            Exercise(name: "Respiración abdominal", description: "Calmar el sistema nervioso", duration: 300, category: .breathing, thumbnail: "nervous_1", emotions: ["nervioso"], isFavorite: false),
            Exercise(name: "Relajación progresiva", description: "Técnica músculo por músculo", duration: 600, category: .meditation, thumbnail: "nervous_2", emotions: ["nervioso"], isFavorite: false),
            Exercise(name: "Movimiento consciente", description: "Ejercicios de coordinación", duration: 420, category: .movement, thumbnail: "nervous_3", emotions: ["nervioso"], isFavorite: false),
            Exercise(name: "Confianza interior", description: "Fortalecer la autoestima", duration: 360, category: .growth, thumbnail: "nervous_4", emotions: ["nervioso"], isFavorite: false),
            
            // Ejercicios para CALMADO
            Exercise(name: "Respiración profunda", description: "Mantener la serenidad", duration: 240, category: .breathing, thumbnail: "calm_1", emotions: ["calmado"], isFavorite: false),
            Exercise(name: "Meditación zen", description: "Profundizar la paz interior", duration: 720, category: .meditation, thumbnail: "calm_2", emotions: ["calmado"], isFavorite: false),
            Exercise(name: "Yoga suave", description: "Movimientos armoniosos", duration: 540, category: .movement, thumbnail: "calm_3", emotions: ["calmado"], isFavorite: false),
            Exercise(name: "Reflexión serena", description: "Contemplación tranquila", duration: 480, category: .reflection, thumbnail: "calm_4", emotions: ["calmado"], isFavorite: false)
        ]
    
    // MARK: - Computed Properties
    
    /// Mensaje dinámico que cambia según la emoción seleccionada
    var dynamicMessage: String {
        guard let emotion = selectedEmotion else {
            return "Qué podemos hacer el día de hoy..."
        }
        
        switch emotion.name {
        case "happy":
            return "¡Mantén tu energía positiva!"
        case "sad":
            return "Vamos a mejorar tu día"
        case "angry":
            return "Respiremos y calmemos"
        case "anxious":
            return "Tranquilicemos la mente"
        case "nervous":
            return "Relajemos los nervios"
        case "calm":
            return "Mantén esa tranquilidad"
        default:
            return "Qué podemos hacer el día de hoy..."
        }
    }
    
    /// Ejercicios sugeridos según la emoción seleccionada
    var suggestedExercises: [Exercise] {
        guard let emotion = selectedEmotion else {
            // Sin emoción seleccionada: mostrar ejercicios generales
            return Array(allExercises.filter { $0.emotions.isEmpty }.prefix(4))
        }
        
        // Con emoción seleccionada: filtrar ejercicios para esa emoción
        let emotionExercises = allExercises.filter { exercise in
            exercise.emotions.contains { exerciseEmotion in
                exerciseEmotion.lowercased() == emotion.displayName.lowercased()
            }
        }
        
        // Tomar los primeros 4 ejercicios de la emoción
        return Array(emotionExercises.prefix(4))
    }
    
    /// Verifica si una emoción específica está seleccionada
    func isEmotionSelected(_ emotion: Emotion) -> Bool {
        return selectedEmotion?.id == emotion.id
    }
    
    // MARK: - Actions
    
    /// Selecciona una emoción (o la deselecciona si ya estaba seleccionada)
    func selectEmotion(_ emotion: Emotion) {
        if selectedEmotion?.id == emotion.id {
            // Si ya está seleccionada, la deseleccionamos
            selectedEmotion = nil
        } else {
            // Seleccionamos la nueva emoción
            selectedEmotion = emotion
        }
    }
}

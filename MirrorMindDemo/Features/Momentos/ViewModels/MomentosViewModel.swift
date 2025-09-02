//
//  MomentosViewModel.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI
import Combine

/// ViewModel para la vista de Momentos que maneja filtros y ejercicios
class MomentosViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showFavoritesOnly: Bool = false
    @Published var selectedEmotionFilter: Emotion? = nil
    @Published var isEmotionFilterMenuOpen: Bool = false
    
    // MARK: - Private Properties
    private let favoritesKey = "MirrorMind_FavoriteExercises"
    @Published private var favoriteExerciseIDs: Set<String> = []
    
    // MARK: - Initializer
    init() {
        loadFavorites()
    }
    
    // MARK: - Computed Properties
    
    /// Todos los ejercicios disponibles (usando la misma base de datos del Home)
    var allExercises: [Exercise] {
        return MockExerciseDatabase.allExercises
    }
    
    /// Ejercicios filtrados según los filtros activos
    var filteredExercises: [Exercise] {
        var exercises = allExercises
        
        // Filtrar por favoritos si está activo
        if showFavoritesOnly {
            exercises = exercises.filter { favoriteExerciseIDs.contains($0.id.uuidString) }
        }
        
        // Filtrar por emoción si está seleccionada
        if let selectedEmotion = selectedEmotionFilter {
            exercises = exercises.filter { exercise in
                exercise.emotions.contains(selectedEmotion.displayName.lowercased())
            }
        }
        
        return exercises
    }
    
    /// Texto del botón de filtros (cambia según el estado)
    var filterButtonText: String {
        if let selectedEmotion = selectedEmotionFilter {
            return selectedEmotion.displayName
        }
        return "Filtros"
    }
    
    /// Color del botón de filtros (cambia según la emoción seleccionada)
    var filterButtonColor: Color {
        if let selectedEmotion = selectedEmotionFilter {
            return selectedEmotion.color
        }
        return Color.white
    }
    
    /// Indica si hay algún filtro activo
    var hasActiveFilters: Bool {
        return showFavoritesOnly || selectedEmotionFilter != nil
    }
    
    // MARK: - Favorites Management
    
    /// Verifica si un ejercicio está marcado como favorito
    func isFavorite(_ exercise: Exercise) -> Bool {
        return favoriteExerciseIDs.contains(exercise.id.uuidString)
    }
    
    /// Marca/desmarca un ejercicio como favorito
    func toggleFavorite(_ exercise: Exercise) {
        let exerciseID = exercise.id.uuidString
        
        if favoriteExerciseIDs.contains(exerciseID) {
            favoriteExerciseIDs.remove(exerciseID)
        } else {
            favoriteExerciseIDs.insert(exerciseID)
        }
        
        saveFavorites()
    }
    
    /// Carga los favoritos desde UserDefaults
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteExerciseIDs = favorites
        }
    }
    
    /// Guarda los favoritos en UserDefaults
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteExerciseIDs) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    // MARK: - Filter Actions
    
    /// Alterna el filtro de favoritos
    func toggleFavoritesFilter() {
        showFavoritesOnly.toggle()
    }
    
    /// Selecciona una emoción para filtrar (toggle si ya está seleccionada)
    func selectEmotionFilter(_ emotion: Emotion) {
        if selectedEmotionFilter?.id == emotion.id {
            // Si ya está seleccionada, la deseleccionamos
            selectedEmotionFilter = nil
        } else {
            // Si no está seleccionada, la seleccionamos
            selectedEmotionFilter = emotion
        }
        // NO cerramos automáticamente el menú
    }
    
    /// Limpia el filtro de emoción
    func clearEmotionFilter() {
        selectedEmotionFilter = nil
        isEmotionFilterMenuOpen = false
    }
    
    /// Alterna el menú de filtros de emoción
    func toggleEmotionFilterMenu() {
        isEmotionFilterMenuOpen.toggle()
    }
    
    /// Limpia todos los filtros
    func clearAllFilters() {
        showFavoritesOnly = false
        selectedEmotionFilter = nil
        isEmotionFilterMenuOpen = false
    }
}

// MARK: - Mock Exercise Database

/// Base de datos mock de ejercicios para Momentos (reutiliza la del Home)
struct MockExerciseDatabase {
    static let allExercises: [Exercise] = [
        // Ejercicios generales (sin emoción específica)
        Exercise(name: "Respiración básica", description: "Ejercicio simple de respiración", duration: 300, category: .breathing, thumbnail: "general_1", emotions: [], isFavorite: false),
        Exercise(name: "Estiramiento suave", description: "Movimientos básicos", duration: 240, category: .movement, thumbnail: "general_2", emotions: [], isFavorite: false),
        Exercise(name: "Meditación inicial", description: "Introducción a la meditación", duration: 420, category: .meditation, thumbnail: "general_3", emotions: [], isFavorite: false),
        Exercise(name: "Reflexión diaria", description: "Momento de introspección", duration: 180, category: .reflection, thumbnail: "general_4", emotions: [], isFavorite: false),
        
        // Ejercicios para FELIZ
        Exercise(name: "Energía positiva", description: "Mantén tu buen estado", duration: 360, category: .growth, thumbnail: "happy_1", emotions: ["feliz"], isFavorite: false),
        Exercise(name: "Movimiento alegre", description: "Ejercicios dinámicos", duration: 480, category: .movement, thumbnail: "happy_2", emotions: ["feliz"], isFavorite: false),
        Exercise(name: "Gratitud activa", description: "Reflexión sobre lo positivo", duration: 300, category: .reflection, thumbnail: "happy_3", emotions: ["feliz"], isFavorite: false),
        Exercise(name: "Respiración energizante", description: "Técnica para mantener vitalidad", duration: 240, category: .breathing, thumbnail: "happy_4", emotions: ["feliz"], isFavorite: false),
        
        // Ejercicios para TRISTE
        Exercise(name: "Meditación de compasión", description: "Autocompasión y sanación", duration: 600, category: .meditation, thumbnail: "sad_1", emotions: ["triste"], isFavorite: false),
        Exercise(name: "Respiración calmante", description: "Técnica para estabilizar emociones", duration: 360, category: .breathing, thumbnail: "sad_2", emotions: ["triste"], isFavorite: false),
        Exercise(name: "Reflexión gentil", description: "Procesamiento emocional suave", duration: 450, category: .reflection, thumbnail: "sad_3", emotions: ["triste"], isFavorite: false),
        Exercise(name: "Autocuidado emocional", description: "Prácticas de sanación personal", duration: 540, category: .growth, thumbnail: "sad_4", emotions: ["triste"], isFavorite: false),
        
        // Ejercicios para ENOJADO
        Exercise(name: "Liberación de tensión", description: "Ejercicios físicos para liberar ira", duration: 420, category: .movement, thumbnail: "angry_1", emotions: ["enojado"], isFavorite: false),
        Exercise(name: "Respiración de calma", description: "Técnica para reducir la ira", duration: 300, category: .breathing, thumbnail: "angry_2", emotions: ["enojado"], isFavorite: false),
        Exercise(name: "Reflexión sobre la ira", description: "Entender y procesar el enojo", duration: 480, category: .reflection, thumbnail: "angry_3", emotions: ["enojado"], isFavorite: false),
        Exercise(name: "Meditación de paciencia", description: "Desarrollar tolerancia emocional", duration: 600, category: .meditation, thumbnail: "angry_4", emotions: ["enojado"], isFavorite: false),
        
        // Ejercicios para ANSIOSO
        Exercise(name: "Respiración 4-7-8", description: "Técnica calmante para reducir ansiedad", duration: 480, category: .breathing, thumbnail: "anxious_1", emotions: ["ansioso"], isFavorite: false),
        Exercise(name: "Grounding 5-4-3-2-1", description: "Técnica de conexión con el presente", duration: 360, category: .meditation, thumbnail: "anxious_2", emotions: ["ansioso"], isFavorite: false),
        Exercise(name: "Movimiento suave", description: "Ejercicios ligeros para liberar tensión", duration: 300, category: .movement, thumbnail: "anxious_3", emotions: ["ansioso"], isFavorite: false),
        Exercise(name: "Reflexión tranquila", description: "Exploración calmada de pensamientos", duration: 420, category: .reflection, thumbnail: "anxious_4", emotions: ["ansioso"], isFavorite: false),
        
        // Ejercicios para NERVIOSO
        Exercise(name: "Preparación mental", description: "Técnicas para eventos importantes", duration: 240, category: .growth, thumbnail: "nervous_1", emotions: ["nervioso"], isFavorite: false),
        Exercise(name: "Respiración de confianza", description: "Técnica para generar seguridad", duration: 300, category: .breathing, thumbnail: "nervous_2", emotions: ["nervioso"], isFavorite: false),
        Exercise(name: "Movimiento expresivo", description: "Liberar energía nerviosa", duration: 360, category: .movement, thumbnail: "nervous_3", emotions: ["nervioso"], isFavorite: false),
        Exercise(name: "Meditación de serenidad", description: "Encontrar calma interior", duration: 480, category: .meditation, thumbnail: "nervous_4", emotions: ["nervioso"], isFavorite: false),
        
        // Ejercicios para CALMADO
        Exercise(name: "Meditación profunda", description: "Profundizar el estado de paz", duration: 900, category: .meditation, thumbnail: "calm_1", emotions: ["calmado"], isFavorite: false),
        Exercise(name: "Respiración contemplativa", description: "Técnica para mantener serenidad", duration: 600, category: .breathing, thumbnail: "calm_2", emotions: ["calmado"], isFavorite: false),
        Exercise(name: "Reflexión sabia", description: "Contemplación profunda y clara", duration: 720, category: .reflection, thumbnail: "calm_3", emotions: ["calmado"], isFavorite: false),
        Exercise(name: "Crecimiento interior", description: "Desarrollo personal en calma", duration: 540, category: .growth, thumbnail: "calm_4", emotions: ["calmado"], isFavorite: false)
    ]
}

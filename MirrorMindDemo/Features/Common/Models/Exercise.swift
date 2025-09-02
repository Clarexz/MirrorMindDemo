//
//  Exercise.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//


import SwiftUI

struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let duration: TimeInterval // En segundos
    let category: ExerciseCategory
    let thumbnail: String // Nombre del asset o URL
    let emotions: [String] // Emociones para las que es recomendado
    let isFavorite: Bool
    
    // Computed property para duración formateada
    var formattedDuration: String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
}

enum ExerciseCategory: String, CaseIterable {
    case breathing = "respirar"
    case meditation = "meditar" 
    case movement = "moverte"
    case reflection = "reflexionar"
    case growth = "crecer"
    
    var displayName: String {
        return "Momentos para \(self.rawValue)"
    }
    
    var color: Color {
        switch self {
        case .breathing:
            return Color.Emotions.happy // Verde
        case .meditation:
            return Color.Emotions.calm // Lavanda
        case .movement:
            return Color.Emotions.nervous // Naranja
        case .reflection:
            return Color.Emotions.sad // Azul
        case .growth:
            return Color.Emotions.anxious // Amarillo
        }
    }
    
    var iconName: String {
        switch self {
        case .breathing:
            return "lungs"
        case .meditation:
            return "figure.mind.and.body"
        case .movement:
            return "figure.walk"
        case .reflection:
            return "brain.head.profile"
        case .growth:
            return "star"
        }
    }
}

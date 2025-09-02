//
//  Emotions.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

extension Color {
    
    // MARK: - Colores de Emociones
    /// Paleta de colores para representar cada emoción
    struct Emotions {
        static let sad = Color("SadBlue")
        static let angry = Color("AngryRed")
        static let anxious = Color("AnxiousYellow")
        static let nervous = Color("NervousOrange")
        static let happy = Color("HappyGreen")
        static let calm = Color("CalmLavanda")
        
        /// Retorna el color asociado a una emoción específica
        static func color(for emotion: String) -> Color {
            switch emotion.lowercased() {
            case "triste", "sad":
                return sad
            case "enojado", "angry":
                return angry
            case "ansioso", "anxious":
                return anxious
            case "nervioso", "nervous":
                return nervous
            case "feliz", "happy":
                return happy
            case "calmado", "calm":
                return calm
            default:
                return Color.gray
            }
        }
    }
    
    // MARK: - Colores Principales
    /// Colores principales de la aplicación
    struct Primary {
        static let background = Color("bgWhite")
        static let brand = Color("PrimaryGreen")
    }
    
    // MARK: - Colores de Texto
    /// Jerarquía de colores para texto
    struct Text {
        static let primary = Color("TextPrimary")
        static let secondary = Color("TextSecondary")
    }
}

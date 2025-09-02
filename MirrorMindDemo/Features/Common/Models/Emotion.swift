//
//  Emotion.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

/// Modelo que representa una emoción en la aplicación
struct Emotion: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    let color: Color
    
    /// Emociones predefinidas según el diseño
    static let emotions: [Emotion] = [
        Emotion(name: "sad", displayName: "Triste", color: Color.Emotions.sad),
        Emotion(name: "angry", displayName: "Enojado", color: Color.Emotions.angry),
        Emotion(name: "anxious", displayName: "Ansioso", color: Color.Emotions.anxious),
        Emotion(name: "nervous", displayName: "Nervioso", color: Color.Emotions.nervous),
        Emotion(name: "happy", displayName: "Feliz", color: Color.Emotions.happy),
        Emotion(name: "calm", displayName: "Calmado", color: Color.Emotions.calm)
    ]
    
    /// Busca una emoción por su nombre
    static func emotion(named: String) -> Emotion? {
        return emotions.first { $0.name.lowercased() == named.lowercased() }
    }
}

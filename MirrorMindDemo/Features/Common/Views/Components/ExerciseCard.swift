//
//  ExerciseCard.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

/// Tarjeta de ejercicio para vista Home (diseño original pequeño)
struct ExerciseCard: View {
    let exercise: Exercise
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Thumbnail con color de categoría (diseño original)
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(exercise.category.color)
                        .frame(width: 90, height: 110)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Nombre del ejercicio
                Text(exercise.name)
                    .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
                    .foregroundColor(Color.Text.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 100)
                
                // Duración del ejercicio
                Text("\(Int(exercise.duration / 60)) min")
                    .font(.system(size: 10, weight: DesignConstants.Typography.regularWeight))
                    .foregroundColor(Color.Text.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

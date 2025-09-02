//
//  MomentsExerciseCard.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

/// Tarjeta de ejercicio específica para vista Momentos con favoritos y etiquetas
struct MomentsExerciseCard: View {
    let exercise: Exercise
    let viewModel: MomentosViewModel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Fondo con color de categoría SIN overlay
                RoundedRectangle(cornerRadius: DesignConstants.Radius.card)
                    .fill(exercise.category.color)
                    .frame(height: 140)
                
                VStack(spacing: 0) {
                    // Header con botón de favoritos
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleFavorite(exercise)
                        }) {
                            Image(systemName: viewModel.isFavorite(exercise) ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(viewModel.isFavorite(exercise) ? .pink : .white)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 30, height: 30)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                    
                    Spacer()
                    
                    // Contenido central
                    VStack(spacing: 6) {
                        // Icono de play
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        
                        // Título
                        Text(exercise.name)
                            .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.boldWeight))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        // Información: duración y categoría apiladas verticalmente
                        VStack(spacing: 4) {
                            // Duración
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("\(Int(exercise.duration / 60)) min")
                                    .font(.system(size: 11, weight: DesignConstants.Typography.mediumWeight))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            // Etiqueta de categoría (solo cuando hay filtros activos)
                            if viewModel.hasActiveFilters {
                                Text(exercise.category.displayName)
                                    .font(.system(size: 10, weight: DesignConstants.Typography.mediumWeight))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.25))
                                    )
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(
            color: DesignConstants.Shadow.card,
            radius: DesignConstants.Shadow.cardRadius,
            x: DesignConstants.Shadow.cardOffset.width,
            y: DesignConstants.Shadow.cardOffset.height
        )
    }
}

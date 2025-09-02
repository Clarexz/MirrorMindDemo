//
//  EmotionFilters.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

/// Componente de filtros emocionales para la vista de Momentos
struct EmotionFilters: View {
    @ObservedObject var viewModel: MomentosViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Título del menú
            Text("Filtrar por emoción:")
                .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.boldWeight))
                .foregroundColor(Color.Text.primary)
                .padding(.horizontal, DesignConstants.Spacing.containerPadding)
            
            // Grid de emociones con diseño del PDF
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(Emotion.emotions) { emotion in
                    EmotionFilterButton(
                        emotion: emotion,
                        isSelected: viewModel.selectedEmotionFilter?.id == emotion.id,
                        action: {
                            viewModel.selectEmotionFilter(emotion)
                        }
                    )
                }
            }
            .padding(.horizontal, DesignConstants.Spacing.containerPadding)
            
            // Botones de acción
            HStack(spacing: 12) {
                // Botón para limpiar filtro
                if viewModel.selectedEmotionFilter != nil {
                    Button(action: {
                        viewModel.clearEmotionFilter()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.Text.secondary)
                            
                            Text("Limpiar filtro")
                                .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
                                .foregroundColor(Color.Text.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.Text.secondary.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, DesignConstants.Spacing.containerPadding)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(
                    color: DesignConstants.Shadow.card,
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .padding(.horizontal, DesignConstants.Spacing.containerPadding)
    }
}

// MARK: - Botón individual de emoción
struct EmotionFilterButton: View {
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Icono de emoción
                Image(systemName: emotion.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : emotion.color)
                
                // Nombre de emoción
                Text(emotion.displayName)
                    .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
                    .foregroundColor(isSelected ? .white : Color.Text.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? emotion.color : emotion.color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(emotion.color, lineWidth: isSelected ? 0 : 1)
            )
            .scaleEffect(1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extension para iconos de emociones
extension Emotion {
    var icon: String {
        switch displayName.lowercased() {
        case "feliz":
            return "face.smiling"
        case "triste":
            return "face.dashed"
        case "enojado":
            return "face.dashed.fill"
        case "ansioso":
            return "face.dashed"
        case "nervioso":
            return "face.dashed"
        case "calmado":
            return "face.smiling.inverse"
        default:
            return "face.smiling"
        }
    }
}

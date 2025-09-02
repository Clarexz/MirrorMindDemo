//
//  ExercisePlayerView.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//


//
//  ExercisePlayerView.swift
//  MirrorMind
//
//  Created by Exercise Player Lead on 20/08/25.
//

import SwiftUI

struct ExercisePlayerView: View {
    let exercise: Exercise
    let categoryColor: Color
    @StateObject private var viewModel = ExercisePlayerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Fondo con gradiente sutil usando color de categoría
            LinearGradient(
                colors: [
                    Color.Primary.background,
                    categoryColor.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header con navegación
                headerView
                
                // Contenido principal centrado
                VStack(spacing: 30) {
                    Spacer()
                        .frame(maxHeight: 0) // Limitar el spacer de arriba
                    
                    // Video player mock
                    videoPlayerView
                    
                    // Controles de reproducción
                    playbackControlsView
                    
                    Spacer() // Este se queda flexible para centrar
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Botón regresar
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.Text.primary)
            }
            
            Spacer()
            
            // Título del ejercicio (truncado)
            Text(exercise.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.Text.primary)
                .lineLimit(1)
            
            Spacer()
            
            // Botón favorito
            Button(action: { viewModel.toggleFavorite() }) {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(viewModel.isFavorite ? .red : Color.Text.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.Primary.background.opacity(0.95))
    }
    
    // MARK: - Video Player View
    private var videoPlayerView: some View {
        VStack(spacing: 0) {
            // Área del video (formato vertical)
            ZStack {
                // Fondo del video
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black)
                    .frame(width: 280, height: 400) // Formato vertical
                
                // Overlay con botón play
                ZStack {
                    // Botón de play central
                    if !viewModel.isPlaying {
                        Button(action: { viewModel.togglePlayback() }) {
                            ZStack {
                                Circle()
                                    .fill(categoryColor.opacity(0.9))
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .scaleEffect(viewModel.isPlaying ? 0.8 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.isPlaying)
                    }
                }
                .frame(width: 280, height: 400) // Mismo tamaño que el fondo
            }
            .cornerRadius(16)
            .shadow(
                color: DesignConstants.Shadow.card,
                radius: DesignConstants.Shadow.cardRadius,
                x: DesignConstants.Shadow.cardOffset.width,
                y: DesignConstants.Shadow.cardOffset.height
            )
        }
    }
    
    // MARK: - Playback Controls View
    private var playbackControlsView: some View {
        VStack(spacing: 20) {
            // Barra de progreso
            VStack(spacing: 8) {
                // Línea de progreso interactiva
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Fondo de la barra
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 6)
                        
                        // Progreso actual
                        RoundedRectangle(cornerRadius: 3)
                            .fill(categoryColor)
                            .frame(width: max(0, geometry.size.width * viewModel.progress), height: 6)
                            .animation(.linear(duration: viewModel.isDragging ? 0.0 : 0.5), value: viewModel.progress)
                    }
                    .overlay(
                        // Indicador de posición (overlay para no afectar layout)
                        Group {
                            if viewModel.isDragging {
                                Circle()
                                    .fill(categoryColor)
                                    .frame(width: 12, height: 12)
                                    .position(
                                        x: geometry.size.width * viewModel.progress,
                                        y: 3 // Centrado con la barra de 6pts
                                    )
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let progress = max(0, min(1, value.location.x / geometry.size.width))
                                viewModel.seekToProgress(progress)
                            }
                            .onEnded { _ in
                                viewModel.endSeeking()
                            }
                    )
                }
                .frame(height: 20) // Área táctil más grande, pero altura fija
                
                // Tiempos
                HStack {
                    Text(viewModel.currentTimeFormatted)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.Text.secondary)
                    
                    Spacer()
                    
                    Text(viewModel.totalTimeFormatted)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.Text.secondary)
                }
            }
            
            // Controles de reproducción
            HStack(spacing: 40) {
                // Botón anterior (15 segundos)
                Button(action: { viewModel.skipBackward() }) {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color.Text.primary)
                }
                
                // Botón play/pause principal
                Button(action: { viewModel.togglePlayback() }) {
                    ZStack {
                        Circle()
                            .fill(categoryColor)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(viewModel.isPlaying ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isPlaying)
                
                // Botón siguiente (15 segundos)
                Button(action: { viewModel.skipForward() }) {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color.Text.primary)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(
            color: DesignConstants.Shadow.card,
            radius: DesignConstants.Shadow.cardRadius,
            x: DesignConstants.Shadow.cardOffset.width,
            y: DesignConstants.Shadow.cardOffset.height
        )
    }
}

#Preview {
    ExercisePlayerView(
        exercise: Exercise(
            name: "Respiración 4-7-8",
            description: "Técnica calmante para reducir ansiedad y mejorar el bienestar",
            duration: 300,
            category: .breathing,
            thumbnail: "breathing_1",
            emotions: ["ansioso"],
            isFavorite: false
        ),
        categoryColor: Color.Emotions.happy
    )
}
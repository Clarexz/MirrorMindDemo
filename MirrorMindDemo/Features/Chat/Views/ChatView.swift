//
//  ChatView.swift
//  MirrorMindDemo
//
//  Created by Demo Firebase Chat Lead on 21/08/25.
//  Modified for demo - uses ChatViewModel instead of CameraViewModel
//

import SwiftUI

struct ChatView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con título Olivia
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Olivia")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.Text.primary)
                    
                    Text("Tu compañera de bienestar")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.Text.secondary)
                }
                
                Spacer()
                
                // Avatar de Olivia
                Circle()
                    .fill(Color.Primary.brand)
                    .frame(width: 45, height: 45)
                    .overlay(
                        Text("O")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            .padding(.horizontal, DesignConstants.Spacing.containerPadding)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color.Primary.background)
            
            // Contenido principal
            ScrollView {
                VStack(spacing: DesignConstants.Spacing.sectionMargin) {
                    // Preview de cámara mock
                    VStack(spacing: 16) {
                        Text("Vista en vivo")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.Text.primary)
                        
                        CameraPreview(viewModel: chatViewModel, onFrameCaptured: { data in
                            // Handle captured frame data
                        })
                    }
                    
                    // Conexión SmartBand - Centrado
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            chatViewModel.toggleSmartband()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: chatViewModel.isSmartbandConnected ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text(chatViewModel.isSmartbandConnected ? "Smartband conectada" : "Conectar smartband")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.Primary.brand)
                            .foregroundColor(.white)
                            .cornerRadius(DesignConstants.Radius.button)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                    
                    // Display biométrico mock
                    VStack(spacing: 16) {
                        Text("Datos biométricos")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.Text.primary)
                        
                        BiometricDisplayMock(chatViewModel: chatViewModel)
                    }
                    .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                    
                    // Sugerencias de video basadas en emoción Firebase
                    VStack(spacing: 16) {
                        HStack {
                            Text("Sugerencias para ti")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.Text.primary)
                            
                            Spacer()
                            
                            // Indicador de estado del sistema
                            Text("Estado: \(chatViewModel.getSystemStatus())")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(chatViewModel.emotionService.isSystemOn ? Color.Primary.brand : .red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background((chatViewModel.emotionService.isSystemOn ? Color.Primary.brand : Color.red).opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        if chatViewModel.isLoadingSuggestions {
                            ProgressView("Cargando sugerencias...")
                                .frame(height: 100)
                        } else if !chatViewModel.canGenerateSuggestions() {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.orange)
                                
                                Text("No se pueden generar sugerencias")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.Text.primary)
                                
                                Text("Se requiere sistema encendido y SmartBand conectada")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.Text.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(height: 100)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(chatViewModel.currentSuggestions) { suggestion in
                                    VideoSuggestionCard(suggestion: suggestion)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                    
                    // Espaciado para navbar flotante
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
        .onAppear {
            // Cargar sugerencias iniciales
            chatViewModel.getSuggestions()
        }
    }
}

// MARK: - BiometricDisplayMock
struct BiometricDisplayMock: View {
    @ObservedObject var chatViewModel: ChatViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            // Heart Rate
            VStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                
                Text(chatViewModel.getFormattedBiometrics().heartRate)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.Text.primary)
                
                Text("Frecuencia")
                    .font(.system(size: 12))
                    .foregroundColor(Color.Text.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(DesignConstants.Radius.card)
            .shadow(color: DesignConstants.Shadow.card, radius: 4, x: 0, y: 2)
            
            // Stress Level
            VStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                
                Text(chatViewModel.getFormattedBiometrics().stress)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.Text.primary)
                
                Text("Estrés")
                    .font(.system(size: 12))
                    .foregroundColor(Color.Text.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(DesignConstants.Radius.card)
            .shadow(color: DesignConstants.Shadow.card, radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - VideoSuggestionCard
struct VideoSuggestionCard: View {
    let suggestion: VideoSuggestion
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail placeholder
            Rectangle()
                .fill(Color.Primary.brand.opacity(0.2))
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.Primary.brand)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.Text.primary)
                    .lineLimit(1)
                
                Text(suggestion.description)
                    .font(.system(size: 12))
                    .foregroundColor(Color.Text.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(suggestion.category)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.Primary.brand)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.Primary.brand.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(suggestion.duration)
                        .font(.system(size: 10))
                        .foregroundColor(Color.Text.secondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(DesignConstants.Radius.card)
        .shadow(color: DesignConstants.Shadow.card, radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ChatView()
        .background(Color.Primary.background)
}

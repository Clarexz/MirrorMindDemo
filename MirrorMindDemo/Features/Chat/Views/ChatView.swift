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
                    
                    // Tarjeta de SmartBand (mismo componente que Inicio)
                    SmartBandCard(biometricManager: chatViewModel.biometricManager)
                    
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
    
    // Helper functions eliminadas - ahora usa BiometricDashboardView directamente
}

// MARK: - SmartBandCard
struct SmartBandCard: View {
    @ObservedObject var biometricManager: BiometricManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Banner de conexión
            HStack {
                Circle()
                    .fill(connectionStatusColor)
                    .frame(width: 12, height: 12)
                
                Text(biometricManager.connectionStatus.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if biometricManager.isActive, let stats = biometricManager.getCurrentSessionStats() {
                    Text(formatDuration(stats.duration))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(connectionStatusColor.opacity(0.1))
            .cornerRadius(20)
            
            // Botón de conectar/desconectar
            Button(action: {
                biometricManager.toggleSession()
            }) {
                HStack {
                    Image(systemName: biometricManager.isActive ? "stop.circle.fill" : "play.circle.fill")
                    Text(biometricManager.isActive ? "Stop Session" : "Start Session")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(biometricManager.isActive ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            // Datos en tiempo real si está conectado
            if biometricManager.isActive, let currentData = biometricManager.currentBiometricData {
                HStack(spacing: 16) {
                    // Heart Rate Card
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                        
                        Text(currentData.validHeartRate ? "\(Int(currentData.heartRate)) BPM" : "Calculating...")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Heart Rate")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Temperature Card
                    VStack(spacing: 8) {
                        Image(systemName: "thermometer")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                        
                        Text(currentData.formattedTemperature)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Temperature")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    private var connectionStatusColor: Color {
        switch biometricManager.connectionStatus {
        case .disconnected: return .red
        case .scanning: return .orange
        case .connecting: return .yellow
        case .connected: return .green
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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

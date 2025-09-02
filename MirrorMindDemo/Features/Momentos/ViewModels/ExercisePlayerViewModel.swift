//
//  ExercisePlayerViewModel.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI
import Combine

class ExercisePlayerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0.0
    @Published var currentTime: TimeInterval = 0.0
    @Published var isFavorite: Bool = false
    @Published var isDragging: Bool = false
    
    // MARK: - Private Properties
    private var exercise: Exercise?
    private var timer: Timer?
    private var totalDuration: TimeInterval = 0
    
    // MARK: - Computed Properties
    var currentTimeFormatted: String {
        formatTime(currentTime)
    }
    
    var totalTimeFormatted: String {
        formatTime(totalDuration)
    }
    
    // MARK: - Public Methods
    func setupExercise(_ exercise: Exercise) {
        self.exercise = exercise
        self.totalDuration = exercise.duration
        self.isFavorite = exercise.isFavorite
        
        // Reset al estado inicial
        self.currentTime = 0.0
        self.progress = 0.0
        self.isPlaying = false
    }
    
    func togglePlayback() {
        isPlaying.toggle()
        
        if isPlaying {
            startPlayback()
        } else {
            pausePlayback()
        }
    }
    
    func skipForward() {
        let newTime = min(currentTime + 15.0, totalDuration)
        updateCurrentTime(newTime)
    }
    
    func skipBackward() {
        let newTime = max(currentTime - 15.0, 0.0)
        updateCurrentTime(newTime)
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
        // TODO: Persistir el estado de favorito (Integración con Core Data)
        print("Favorito cambiado para \(exercise?.name ?? "ejercicio"): \(isFavorite)")
    }
    
    func seekToProgress(_ newProgress: Double) {
        isDragging = true
        let wasPlaying = isPlaying
        
        // Pausar temporalmente durante el drag
        if isPlaying {
            pausePlayback()
        }
        
        // Actualizar posición
        progress = max(0, min(1, newProgress))
        currentTime = progress * totalDuration
        
        // Store the playing state to resume later
        if wasPlaying {
            // We'll resume when drag ends
        }
    }
    
    func endSeeking() {
        isDragging = false
        // Resume playback if it was playing before seeking
        if !isPlaying {
            // Check if user was playing before seeking by checking if we're not at the very beginning
            // For now, we'll let the user manually resume
        }
    }
    
    // MARK: - Private Methods
    private func startPlayback() {
        // Verificar si ya terminó
        if currentTime >= totalDuration {
            currentTime = 0.0
            progress = 0.0
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            self.currentTime += 0.1
            self.updateProgress()
            
            // Verificar si terminó
            if self.currentTime >= self.totalDuration {
                self.finishPlayback()
            }
        }
    }
    
    private func pausePlayback() {
        timer?.invalidate()
        timer = nil
    }
    
    private func finishPlayback() {
        currentTime = totalDuration
        progress = 1.0
        isPlaying = false
        pausePlayback()
        
        // Feedback háptico de finalización
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        print("Ejercicio '\(exercise?.name ?? "")' completado!")
    }
    
    private func updateCurrentTime(_ newTime: TimeInterval) {
        currentTime = newTime
        updateProgress()
    }
    
    private func updateProgress() {
        guard totalDuration > 0 else {
            progress = 0.0
            return
        }
        progress = currentTime / totalDuration
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Cleanup
    deinit {
        timer?.invalidate()
    }
}

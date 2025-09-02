//
//  SmartBandViewModel.swift
//  MirrorMindDemo
//
//  Created by Demo Home Lead on 21/08/25.
//

import SwiftUI
import Combine

class SmartBandViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var connectionState: SmartBandConnectionState = .disconnected
    @Published var currentReading: LiveBiometricData?
    @Published var isConnecting: Bool = false
    
    // MARK: - Private Properties
    private var biometricTimer: Timer?
    private var connectionTimer: Timer?
    
    // MARK: - Public Methods
    
    /// Iniciar proceso de conexión del SmartBand
    func connectDevice() {
        guard connectionState == .disconnected else { return }
        
        isConnecting = true
        connectionState = .connecting
        
        // Simular proceso de conexión (2-3 segundos)
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            self?.completeConnection()
        }
    }
    
    /// Desconectar el SmartBand
    func disconnectDevice() {
        connectionState = .disconnected
        isConnecting = false
        currentReading = nil
        
        // Limpiar timers
        biometricTimer?.invalidate()
        connectionTimer?.invalidate()
    }
    
    // MARK: - Private Methods
    
    private func completeConnection() {
        connectionState = .connected
        isConnecting = false
        
        // Generar primera lectura
        generateNewReading()
        
        // Iniciar timer para datos biométricos cada 3 segundos
        startBiometricTimer()
    }
    
    private func startBiometricTimer() {
        biometricTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.generateNewReading()
        }
    }
    
    private func generateNewReading() {
        // Generar datos biométricos realistas con variación
        let baseTemp = 36.5
        let baseHR = 75
        
        let tempVariation = Double.random(in: -0.5...0.5)
        let hrVariation = Int.random(in: -10...15)
        
        let newReading = LiveBiometricData(
            temperature: baseTemp + tempVariation,
            heartRate: baseHR + hrVariation
        )
        
        currentReading = newReading
        
    }
    
    // MARK: - Deinitializer
    deinit {
        biometricTimer?.invalidate()
        connectionTimer?.invalidate()
    }
}

//
//  SmartBandConnectionState.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//


import Foundation

// Estados posibles del SmartBand
enum SmartBandConnectionState {
    case disconnected
    case connecting
    case connected
    
    var displayText: String {
        switch self {
        case .disconnected:
            return "Desconectado"
        case .connecting:
            return "Conectando"
        case .connected:
            return "Conectada"
        }
    }
    
    var statusColor: String {
        switch self {
        case .disconnected:
            return "red"
        case .connecting:
            return "yellow"
        case .connected:
            return "green"
        }
    }
}

// Datos biométricos en tiempo real (para UI)
struct LiveBiometricData {
    let temperature: Double
    let heartRate: Int
    let timestamp: Date
    
    init(temperature: Double = 36.5, heartRate: Int = 75) {
        self.temperature = temperature
        self.heartRate = heartRate
        self.timestamp = Date()
    }
    
    var formattedTemperature: String {
        return String(format: "%.1f°C", temperature)
    }
    
    var formattedHeartRate: String {
        return "\(heartRate) LPM"
    }
}
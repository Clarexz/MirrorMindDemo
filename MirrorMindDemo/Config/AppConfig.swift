//
//  AppConfig.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import Foundation

/// Configuraciones generales de la aplicación
struct AppConfig {
    
    // MARK: - Información de la App
    static let appName = "MirrorMind"
    static let version = "1.0"
    static let teamName = "TecNM Reynosa"
    
    // MARK: - Configuración de Usuario
    static let defaultUserName = "Usuario"
    static let maxFavoriteExercises = 50
    
    // MARK: - Configuración de SmartBand
    static let smartBandConnectionTimeout: TimeInterval = 10.0
    static let biometricUpdateInterval: TimeInterval = 2.0
    
    // MARK: - Configuración de Emociones
    static let availableEmotions = ["Triste", "Enojado", "Ansioso", "Nervioso", "Feliz", "Calmado"]
    
    // MARK: - Configuración de Ejercicios
    static let exerciseCategories = [
        "Momentos para respirar",
        "Momentos para meditar", 
        "Momentos para moverte",
        "Momentos para reflexionar",
        "Momentos para crecer"
    ]
}

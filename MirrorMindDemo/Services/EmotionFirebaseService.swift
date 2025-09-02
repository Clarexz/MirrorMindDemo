//
//  EmotionFirebaseService.swift
//  MirrorMindDemo
//
//  Created by Demo Firebase Chat Lead on 21/08/25.
//

import Foundation
import Combine

/// Servicio para conexión REAL con Firebase Realtime Database
/// Lee el estado emocional desde: Emociones/estadoActual
class EmotionFirebaseService: ObservableObject {
    @Published var currentEmotion: String = ""
    @Published var isSystemOn: Bool = false
    @Published var isConnected: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let databaseURL = "https://emociones-8d92c-default-rtdb.firebaseio.com"
    
    init() {
        startListening()
    }
    
    /// Inicia la escucha REAL de cambios en Firebase
    func startListening() {
        isConnected = true
        startRealFirebasePolling()
    }
    
    /// Polling real a Firebase Realtime Database
    private func startRealFirebasePolling() {
        // Polling cada 3 segundos a Firebase
        Timer.publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchDataFromFirebase()
            }
            .store(in: &cancellables)
        
        // Hacer fetch inicial inmediato
        fetchDataFromFirebase()
    }
    
    /// Fetch real de datos de Firebase
    private func fetchDataFromFirebase() {
        // Crear URLs para los endpoints
        let emotionURL = URL(string: "\(databaseURL)/Emociones/estadoActual.json")!
        let systemURL = URL(string: "\(databaseURL)/Emociones/encendido.json")!
        
        // Fetch estado del sistema (encendido/apagado)
        fetchSystemStatus(from: systemURL) { [weak self] isOn in
            if isOn {
                // Si está encendido, buscar la emoción
                self?.fetchEmotion(from: emotionURL) { emotion in
                    DispatchQueue.main.async {
                        self?.isSystemOn = true
                        self?.currentEmotion = emotion
                    }
                }
            } else {
                // Si está apagado, limpiar datos
                DispatchQueue.main.async {
                    self?.isSystemOn = false
                    self?.currentEmotion = ""
                }
            }
        }
    }
    
    /// Fetch del estado del sistema desde Firebase
    private func fetchSystemStatus(from url: URL, completion: @escaping (Bool) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            
            let dataString = String(data: data, encoding: .utf8) ?? "Unable to decode"
            
            do {
                // Permitir fragmentos JSON (valores primitivos como true/false)
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                
                if let value = jsonObject as? Bool {
                    completion(value)
                } else if dataString.contains("null") {
                    completion(false)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }.resume()
    }
    
    /// Fetch de la emoción desde Firebase
    private func fetchEmotion(from url: URL, completion: @escaping (String) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error fetching emotion: \(error.localizedDescription)")
                completion("")
                return
            }
            
            guard let data = data else {
                print("❌ No data received for emotion")
                completion("")
                return
            }
            
            let dataString = String(data: data, encoding: .utf8) ?? "Unable to decode"
            
            do {
                // Permitir fragmentos JSON (valores primitivos como strings)
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                
                if let value = jsonObject as? String {
                    completion(value)
                } else if dataString.contains("null") {
                    print("⚠️ Emotion is null, treating as empty")
                    completion("")
                } else {
                    print("⚠️ Emotion format unexpected: \(jsonObject), treating as empty")
                    completion("")
                }
            } catch {
                print("❌ Error parsing emotion JSON: \(error)")
                completion("")
            }
        }.resume()
    }
    
    /// Obtiene la emoción actual
    func getCurrentEmotion() -> String {
        return currentEmotion
    }
    
    /// Verifica si el sistema está encendido
    func getSystemStatus() -> Bool {
        return isSystemOn
    }
    
    /// Verifica si hay datos válidos para generar sugerencias
    func hasValidData() -> Bool {
        return isSystemOn && !currentEmotion.isEmpty
    }
}

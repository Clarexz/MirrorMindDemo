//
//  EmotionFirebaseService.swift
//  MirrorMindDemo
//
//  Created by Demo Firebase Chat Lead on 21/08/25.
//  Modified by Emotion API Lead on 01/09/25.
//

import Foundation
import Combine

/// Servicio para conexión REAL con Firebase Realtime Database
/// Lee y ESCRIBE el estado emocional desde/hacia: Emociones/estadoActual
class EmotionFirebaseService: ObservableObject {
    @Published var currentEmotion: String = ""
    @Published var isSystemOn: Bool = false
    @Published var isConnected: Bool = false
    @Published var lastWriteTimestamp: Date?
    @Published var writeError: String?
    
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
    
    // MARK: - Emotion Writing Methods
    
    /// Escribe una emoción detectada a Firebase
    func writeEmotion(_ emotion: String, confidence: Double, description: String) {
        // Preparar datos para escribir
        let emotionData: [String: Any] = [
            "emotion": emotion,
            "confidence": confidence,
            "description": description,
            "timestamp": ServerValue.timestamp,
            "source": "api_recognition"
        ]
        
        // URLs para escritura
        let emotionURL = URL(string: "\(databaseURL)/Emociones/estadoActual.json")!
        let historyURL = URL(string: "\(databaseURL)/Emociones/historial.json")!
        
        // Escribir emoción actual
        writeToFirebase(url: emotionURL, data: description) { [weak self] success in
            if success {
                print("✅ Firebase: Emoción actualizada - \(description)")
                DispatchQueue.main.async {
                    self?.lastWriteTimestamp = Date()
                    self?.writeError = nil
                }
                
                // También agregar al historial
                self?.appendToHistory(url: historyURL, data: emotionData)
            } else {
                DispatchQueue.main.async {
                    self?.writeError = "Error escribiendo emoción actual"
                }
            }
        }
    }
    
    /// Escribe datos a Firebase usando PUT
    private func writeToFirebase(url: URL, data: Any, completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData: Data
            if let stringData = data as? String {
                // Para strings simples, enviar como string JSON
                jsonData = try JSONSerialization.data(withJSONObject: stringData)
            } else {
                // Para objetos complejos
                jsonData = try JSONSerialization.data(withJSONObject: data)
            }
            
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Firebase Write Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    completion(true)
                } else {
                    print("❌ Firebase Write HTTP Error: \(response.debugDescription)")
                    completion(false)
                }
            }.resume()
            
        } catch {
            print("❌ Firebase JSON Serialization Error: \(error)")
            completion(false)
        }
    }
    
    /// Agrega entrada al historial de emociones
    private func appendToHistory(url: URL, data: [String: Any]) {
        // Generar timestamp único para la clave
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let historyEntryURL = URL(string: "\(url.absoluteString.replacingOccurrences(of: ".json", with: ""))/\(timestamp).json")!
        
        writeToFirebase(url: historyEntryURL, data: data) { success in
            if success {
                print("✅ Firebase: Entrada agregada al historial")
            } else {
                print("❌ Firebase: Error agregando al historial")
            }
        }
    }
    
    /// Verifica si la escritura está funcionando correctamente
    func getWriteStatus() -> (isWorking: Bool, lastWrite: Date?, error: String?) {
        return (writeError == nil, lastWriteTimestamp, writeError)
    }
}

// MARK: - Firebase ServerValue Helper
private enum ServerValue {
    static let timestamp: [String: String] = [".sv": "timestamp"]
}

//
//  EmotionAPIService.swift
//  MirrorMindDemo
//
//  Created by Emotion API Lead on 01/09/25.
//

import Foundation
import UIKit
import Combine

/// Servicio para comunicación con la API de reconocimiento emocional
class EmotionAPIService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isConnected: Bool = false
    @Published var lastEmotionDetected: String = ""
    @Published var lastConfidence: Double = 0.0
    @Published var lastDescription: String = ""
    @Published var connectionError: String?
    
    // MARK: - Private Properties
    private let apiURL = "http://127.0.0.1:5000/api/recognition/polling"
    private let session = URLSession.shared
    private let timeout: TimeInterval = 10.0
    private var cancellables = Set<AnyCancellable>()
    
    // Frame processing queue
    private let processingQueue = DispatchQueue(label: "emotion.api.processing", qos: .userInitiated)
    
    init() {
        setupNetworkConfiguration()
    }
    
    // MARK: - Public Methods
    
    /// Envía un frame a la API para reconocimiento emocional
    func processFrame(_ imageData: Data) {
        processingQueue.async { [weak self] in
            self?.sendFrameToAPI(imageData)
        }
    }
    
    /// Verifica la conectividad con la API
    func testConnection() {
        guard let url = URL(string: apiURL) else {
            updateConnectionStatus(false, error: "URL inválida")
            return
        }
        
        // Crear una imagen de prueba pequeña (1x1 pixel)
        let testImage = createTestImage()
        guard let testImageData = testImage.jpegData(compressionQuality: 0.1) else {
            updateConnectionStatus(false, error: "No se pudo crear imagen de prueba")
            return
        }
        
        processingQueue.async { [weak self] in
            self?.sendFrameToAPI(testImageData, isTest: true)
        }
    }
    
    /// Obtiene el último resultado de emoción detectada
    func getLastEmotion() -> (emotion: String, confidence: Double, description: String) {
        return (lastEmotionDetected, lastConfidence, lastDescription)
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkConfiguration() {
        // Configurar timeout y otras propiedades de red si es necesario
    }
    
    private func sendFrameToAPI(_ imageData: Data, isTest: Bool = false) {
        guard let url = URL(string: apiURL) else {
            updateConnectionStatus(false, error: "URL inválida")
            return
        }
        
        // Crear request multipart/form-data
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Crear body del request
        let httpBody = createMultipartBody(imageData: imageData, boundary: boundary)
        request.httpBody = httpBody
        
        // Realizar request
        session.dataTask(with: request) { [weak self] data, response, error in
            self?.handleAPIResponse(data: data, response: response, error: error, isTest: isTest)
        }.resume()
    }
    
    private func createMultipartBody(imageData: Data, boundary: String) -> Data {
        var body = Data()
        
        // Agregar imagen
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"frame.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Cerrar boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    private func handleAPIResponse(data: Data?, response: URLResponse?, error: Error?, isTest: Bool) {
        // Manejar errores de red
        if let error = error {
            let errorMessage = "Error de conexión: \(error.localizedDescription)"
            print("❌ EmotionAPI Error: \(errorMessage)")
            updateConnectionStatus(false, error: errorMessage)
            return
        }
        
        // Verificar respuesta HTTP
        guard let httpResponse = response as? HTTPURLResponse else {
            updateConnectionStatus(false, error: "Respuesta HTTP inválida")
            return
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = "HTTP Error: \(httpResponse.statusCode)"
            print("❌ EmotionAPI HTTP Error: \(errorMessage)")
            updateConnectionStatus(false, error: errorMessage)
            return
        }
        
        // Verificar datos
        guard let data = data else {
            updateConnectionStatus(false, error: "No se recibieron datos")
            return
        }
        
        // Parsear respuesta JSON
        do {
            let response = try JSONDecoder().decode(EmotionAPIResponse.self, from: data)
            handleSuccessfulResponse(response, isTest: isTest)
        } catch {
            // Intentar parsear como error de API
            do {
                let errorResponse = try JSONDecoder().decode(EmotionAPIError.self, from: data)
                updateConnectionStatus(false, error: errorResponse.localizedDescription)
            } catch {
                let parseError = "Error parsing JSON: \(error.localizedDescription)"
                print("❌ EmotionAPI Parse Error: \(parseError)")
                updateConnectionStatus(false, error: parseError)
            }
        }
    }
    
    private func handleSuccessfulResponse(_ response: EmotionAPIResponse, isTest: Bool) {
        guard response.isSuccessful else {
            updateConnectionStatus(false, error: "API devolvió status: \(response.status)")
            return
        }
        
        // Si es test de conexión, solo actualizar estado
        if isTest {
            updateConnectionStatus(true, error: nil)
            print("✅ EmotionAPI: Conexión exitosa")
            return
        }
        
        // Actualizar datos de emoción solo si no es test
        DispatchQueue.main.async { [weak self] in
            self?.lastEmotionDetected = response.emotion
            self?.lastConfidence = response.confidence
            self?.lastDescription = response.localizedEmotion
            self?.isConnected = true
            self?.connectionError = nil
            
            print("✅ EmotionAPI: \(response.localizedEmotion) (confianza: \(String(format: "%.2f", response.confidence)))")
        }
    }
    
    private func updateConnectionStatus(_ connected: Bool, error: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = connected
            self?.connectionError = error
        }
    }
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.black.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - Extensions
extension EmotionAPIService {
    /// Verifica si el servicio está listo para procesar frames
    var isReady: Bool {
        return isConnected && connectionError == nil
    }
    
    /// Obtiene el estado de conexión como string para UI
    var connectionStatusText: String {
        if isConnected {
            return "Conectado"
        } else if let error = connectionError {
            return "Error: \(error)"
        } else {
            return "Desconectado"
        }
    }
}
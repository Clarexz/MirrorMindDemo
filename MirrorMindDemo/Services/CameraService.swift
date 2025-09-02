//
//  CameraService.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 01/09/25.
//

import AVFoundation
import UIKit
import Combine

class CameraService: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isCameraActive = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    private let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var cancellables = Set<AnyCancellable>()
    
    // Frame capture properties
    private var frameTimer: Timer?
    private var onFrameCaptured: ((Data) -> Void)?
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    // MARK: - Permission Management
    private func checkPermissions() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorizationStatus {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            requestPermission()
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                self?.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
    
    // MARK: - Camera Session Management
    func startCamera() {
        guard isAuthorized else {
            print("Camera not authorized")
            return
        }
        
        guard !session.isRunning else {
            print("Session already running")
            DispatchQueue.main.async {
                self.isCameraActive = true
            }
            return
        }
        
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }
    
    func stopCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            self.stopFrameCapture()
            DispatchQueue.main.async {
                self.isCameraActive = false
            }
        }
    }
    
    private func configureSession() {
        // Don't reconfigure if session is already configured with inputs
        if !session.inputs.isEmpty && !session.outputs.isEmpty {
            session.startRunning()
            DispatchQueue.main.async { [weak self] in
                self?.isCameraActive = true
            }
            return
        }
        
        session.beginConfiguration()
        
        // Configure session preset
        if session.canSetSessionPreset(.medium) {
            session.sessionPreset = .medium
        }
        
        // Add video input only if not already added
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Failed to create video input")
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            print("Failed to add video input")
            session.commitConfiguration()
            return
        }
        
        // Configure video output only if not already added
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        } else {
            print("Failed to add video output")
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        session.startRunning()
        
        DispatchQueue.main.async { [weak self] in
            self?.isCameraActive = true
        }
    }
    
    // MARK: - Frame Capture
    func startFrameCapture(interval: TimeInterval = 2.0, onFrameCaptured: @escaping (Data) -> Void) {
        self.onFrameCaptured = onFrameCaptured
        
        frameTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.captureCurrentFrame()
        }
    }
    
    func stopFrameCapture() {
        frameTimer?.invalidate()
        frameTimer = nil
        onFrameCaptured = nil
    }
    
    private func captureCurrentFrame() {
        // Frame capture will be handled in the delegate method
    }
    
    // MARK: - Session Access
    var captureSession: AVCaptureSession {
        return session
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let onFrameCaptured = onFrameCaptured else { return }
        
        // Convert sample buffer to UIImage and then to Data
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage)
        
        // Convert to JPEG data for API transmission
        guard let imageData = uiImage.jpegData(compressionQuality: 0.7) else { return }
        
        DispatchQueue.main.async {
            onFrameCaptured(imageData)
        }
    }
}

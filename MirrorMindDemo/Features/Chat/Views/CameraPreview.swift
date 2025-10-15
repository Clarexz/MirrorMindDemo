import SwiftUI
import AVFoundation

struct CameraPreview: View {
    @StateObject private var cameraService = CameraService()
    @ObservedObject var viewModel: ChatViewModel
    let onFrameCaptured: ((Data) -> Void)?
    
    init(viewModel: ChatViewModel, onFrameCaptured: ((Data) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onFrameCaptured = onFrameCaptured
    }
    
    private var isCameraActive: Bool {
        viewModel.isCameraOn
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Toggle button above the camera frame
            Button(action: {
                viewModel.isCameraOn.toggle()
            }) {
                Text(isCameraActive ? "Apagar cámara" : "Encender cámara")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isCameraActive ? Color.red : Color.blue)
                    .cornerRadius(8)
            }
            
            // Camera frame
            ZStack {
                if cameraService.isAuthorized && isCameraActive {
                    // Real camera preview
                    CameraPreviewLayer(session: cameraService.captureSession)
                        .cornerRadius(12)
                        .clipped()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                cameraService.startCamera()
                                if let onFrameCaptured = onFrameCaptured {
                                    cameraService.startFrameCapture(onFrameCaptured: onFrameCaptured)
                                }
                            }
                        }
                        .onDisappear {
                            cameraService.stopCamera()
                        }
                    
                } else if cameraService.authorizationStatus == .denied || cameraService.authorizationStatus == .restricted {
                    // Permission denied state
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                        
                        Text("Acceso a cámara denegado")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text("Ve a Configuración para activar")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button("Abrir Configuración") {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .cornerRadius(12)
                    
                } else if cameraService.authorizationStatus == .notDetermined {
                    // Requesting permissions
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                        
                        Text("Solicitando permisos...")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .onAppear {
                        print("Requesting camera permissions...")
                    }
                    .cornerRadius(12)
                } else {
                    // Camera inactive state - just black rectangle
                    Rectangle()
                        .fill(Color.black)
                        .cornerRadius(12)
                }
            }
            .aspectRatio(3/4, contentMode: .fit)  // Vertical aspect ratio
            .frame(maxHeight: 300)
            .cornerRadius(12)
            .clipped()
        }
        .onChange(of: isCameraActive) { oldValue, newValue in
            if newValue && cameraService.isAuthorized {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    cameraService.startCamera()
                    if let onFrameCaptured = onFrameCaptured {
                        cameraService.startFrameCapture(onFrameCaptured: onFrameCaptured)
                    }
                }
            } else {
                cameraService.stopCamera()
            }
        }
    }
}

// MARK: - UIViewRepresentable for AVCaptureVideoPreviewLayer
struct CameraPreviewLayer: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // Update handled by PreviewView automatically
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

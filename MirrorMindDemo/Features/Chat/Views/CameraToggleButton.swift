//
//  CameraToggleButton.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//


//
//  CameraToggleButton.swift
//  MirrorMind
//
//  Created by Caleb Martinez Cavazos on 21/08/25.
//
import SwiftUI

struct CameraToggleButton: View {
    @Binding var isCameraOn: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isCameraOn.toggle()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: isCameraOn ? "video.fill" : "video.slash")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 16, height: 16) // Tamaño fijo para el icono
                
                Text(isCameraOn ? "Desactivar cámara" : "Activar cámara")
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(height: 30) // Altura fija para todo el botón
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(buttonBackgroundColor)
            .foregroundColor(.white)
            .cornerRadius(DesignConstants.Radius.button)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var buttonBackgroundColor: Color {
        isCameraOn ? Color.red : Color.Primary.brand
    }
}

#Preview {
    VStack(spacing: 20) {
        CameraToggleButton(isCameraOn: .constant(false))
        CameraToggleButton(isCameraOn: .constant(true))
    }
    .padding()
    .background(Color.Primary.background)
}
//
//  Navbar.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

struct Navbar: View {
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        ZStack {
            // Fondo principal que ocupa toda la pantalla
            Color.Primary.background
                .ignoresSafeArea(.all)
            
            // Contenido principal SIN TabView limitante
            Group {
                switch selectedTab {
                case .home:
                    HomeScreen()
                case .momentos:
                    MomentosScreen()
                case .chat:
                    ChatScreen()
                case .perfil:
                    TemporaryPerfilView()
                }
            }
            
            // Navbar flotante en la parte inferior
            VStack {
                Spacer()
                
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }
        }
    }
}

#Preview {
    Navbar()
}

struct TemporaryPerfilView: View {
    var body: some View {
        ZStack {
            Color.Primary.background
                .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.Text.secondary)
                
                Text("Vista Perfil")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.Text.primary)
                
                Text("Aquí irá la configuración\ny datos del usuario")
                    .font(.system(size: 16))
                    .foregroundColor(Color.Text.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

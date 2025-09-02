//
//  DesignConstants.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

/// Constantes de diseño para mantener consistencia visual
struct DesignConstants {
    
    // MARK: - Tipografía
    struct Typography {
        static let fontFamily = "Roboto"
        
        // Tamaños según jerarquía del PDF
        static let heading1Size: CGFloat = 18
        static let heading2Size: CGFloat = 16
        static let heading3Size: CGFloat = 14
        static let heading4Size: CGFloat = 12
        
        // Pesos de fuente
        static let boldWeight = Font.Weight.semibold
        static let mediumWeight = Font.Weight.medium
        static let regularWeight = Font.Weight.regular
    }
    
    // MARK: - Espaciado
    struct Spacing {
        static let containerPadding: CGFloat = 30
        static let sectionMargin: CGFloat = 30
        static let cardPadding: CGFloat = 16
        static let gridGap: CGFloat = 16
        static let buttonPadding: CGFloat = 8
    }
    
    // MARK: - Border Radius
    struct Radius {
        static let card: CGFloat = 16
        static let button: CGFloat = 12
        static let buttonLarge: CGFloat = 20
        static let emotion: CGFloat = 16
    }
    
    // MARK: - Sombras
    struct Shadow {
        static let card = Color.black.opacity(0.08)
        static let cardOffset = CGSize(width: 0, height: 2)
        static let cardRadius: CGFloat = 12
        
        static let buttonHover = Color.black.opacity(0.15)
        static let buttonHoverOffset = CGSize(width: 0, height: 4)
        static let buttonHoverRadius: CGFloat = 16
    }
    
    // MARK: - Animaciones
        struct Animation {
            static let defaultDuration: Double = 0.3
            static let defaultEasing = SwiftUI.Animation.easeInOut(duration: defaultDuration)
            static let bounceEasing = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
        }
    
    // MARK: - Dimensiones
    struct Dimensions {
        static let emotionButtonAspectRatio: CGFloat = 1.0
        static let navbarHeight: CGFloat = 80
        static let tabBarIconSize: CGFloat = 24
        static let exerciseCardHeight: CGFloat = 120
    }
}

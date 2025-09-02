//
//  CategoryCardView.swift
//  MirrorMind
//
//  Created by Moments Structure Lead on 20/08/25.
//

import SwiftUI

struct CategoryCardView: View {
    let category: MomentCategory
    var isFullWidth: Bool = false
    
    var body: some View {
        Group {
            if isFullWidth {
                // Layout horizontal para la quinta tarjeta (centrado)
                HStack(spacing: 16) {
                    // Icono a la izquierda
                    Image(systemName: category.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                    
                    // Texto a la derecha
                    VStack(spacing: 2) {
                        Text(category.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(category.subtitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            } else {
                // Layout vertical para las primeras 4 tarjetas
                VStack(spacing: 12) {
                    // Icono
                    Image(systemName: category.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                    
                    // Texto
                    VStack(spacing: 2) {
                        Text(category.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(category.subtitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(category.color)
        .cornerRadius(DesignConstants.Radius.card)
        .shadow(
            color: DesignConstants.Shadow.card,
            radius: DesignConstants.Shadow.cardRadius,
            x: DesignConstants.Shadow.cardOffset.width,
            y: DesignConstants.Shadow.cardOffset.height
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        // Preview de categoría normal
        CategoryCardView(
            category: MomentCategory.allCategories[0]
        )
        
        // Preview de categoría full width
        CategoryCardView(
            category: MomentCategory.allCategories[4],
            isFullWidth: true
        )
    }
    .padding()
    .background(Color.Primary.background)
}

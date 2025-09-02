//
//  TabBarButton.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

struct TabBarButton: View {
    let item: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? item.iconNameFilled : item.iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
                
                Text(item.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconColor: Color {
            isSelected ? .white : Color.white.opacity(0.6)
        }
        
    private var textColor: Color {
        isSelected ? .white : Color.white.opacity(0.6)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Estado activo
        TabBarButton(
            item: .home,
            isSelected: true,
            action: {}
        )
        
        // Estado inactivo
        TabBarButton(
            item: .momentos,
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color.Primary.background)
}

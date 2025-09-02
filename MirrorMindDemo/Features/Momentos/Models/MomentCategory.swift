//
//  MomentCategory.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

// MARK: - MomentCategory Model
struct MomentCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let icon: String
    let color: Color
    let categoryType: CategoryType
    
    enum CategoryType: String, CaseIterable {
        case respirar = "respirar"
        case meditar = "meditar"
        case moverte = "moverte"
        case reflexionar = "reflexionar"
        case crecer = "crecer"
    }
}

// MARK: - Predefined Categories
extension MomentCategory {
    static let allCategories: [MomentCategory] = [
        MomentCategory(
            name: "Momentos",
            subtitle: "para respirar",
            icon: "lungs.fill",
            color: Color.Emotions.happy, // Verde menta
            categoryType: .respirar
        ),
        MomentCategory(
            name: "Momentos",
            subtitle: "para meditar",
            icon: "figure.mind.and.body",
            color: Color.Emotions.calm, // Lavanda suave
            categoryType: .meditar
        ),
        MomentCategory(
            name: "Momentos",
            subtitle: "para moverte",
            icon: "figure.walk",
            color: Color.Emotions.nervous, // Durazno cálido
            categoryType: .moverte
        ),
        MomentCategory(
            name: "Momentos",
            subtitle: "para reflexionar",
            icon: "brain.head.profile",
            color: Color.Emotions.sad, // Azul sereno
            categoryType: .reflexionar
        ),
        MomentCategory(
            name: "Momentos",
            subtitle: "para crecer",
            icon: "tree.fill",
            color: Color.Emotions.anxious, // Mostaza suave
            categoryType: .crecer
        )
    ]
}

// MARK: - Helper Methods
extension MomentCategory {
    static func category(for type: CategoryType) -> MomentCategory? {
        return allCategories.first { $0.categoryType == type }
    }
    
    static func randomTip() -> String {
        let tips = [
            "La meditación de solo 10 minutos diarios mejora la concentración en un 14%.",
            "Respirar profundamente durante 3 minutos reduce el estrés hasta en un 30%.",
            "El ejercicio moderado libera endorfinas que mejoran el estado de ánimo.",
            "Reflexionar sobre el día ayuda a procesar las emociones de manera saludable.",
            "Aprender algo nuevo cada día fortalece las conexiones neuronales."
        ]
        return tips.randomElement() ?? tips[0]
    }
}

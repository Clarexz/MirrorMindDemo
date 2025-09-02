//
//  CategoryView.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI
import Combine

struct CategoryView: View {
    let category: MomentCategory
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button("← Regresar") {
                    dismiss()
                }
                Spacer()
            }
            .padding()
            
            // Título
            Text("Ejercicios de \(category.name)")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            
            // Lista de ejercicios con scroll que ocupa todo el espacio
            ScrollView {
                VStack(spacing: 16) {
                    // Ejercicio 1 para cualquier categoría
                    NavigationLink(destination: ExercisePlayerView(
                        exercise: Exercise(
                            name: getFirstExerciseName(),
                            description: getFirstExerciseDescription(),
                            duration: 180,
                            category: .breathing,
                            thumbnail: "test",
                            emotions: [],
                            isFavorite: false
                        ),
                        categoryColor: category.color
                    )) {
                        makeExerciseCard(
                            name: getFirstExerciseName(),
                            description: getFirstExerciseDescription(),
                            duration: "3 min"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Ejercicio 2 para cualquier categoría
                    NavigationLink(destination: ExercisePlayerView(
                        exercise: Exercise(
                            name: getSecondExerciseName(),
                            description: getSecondExerciseDescription(),
                            duration: 300,
                            category: .breathing,
                            thumbnail: "test",
                            emotions: [],
                            isFavorite: false
                        ),
                        categoryColor: category.color
                    )) {
                        makeExerciseCard(
                            name: getSecondExerciseName(),
                            description: getSecondExerciseDescription(),
                            duration: "5 min"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Ejercicio 3 para cualquier categoría
                    NavigationLink(destination: ExercisePlayerView(
                        exercise: Exercise(
                            name: getThirdExerciseName(),
                            description: getThirdExerciseDescription(),
                            duration: 240,
                            category: .breathing,
                            thumbnail: "test",
                            emotions: [],
                            isFavorite: false
                        ),
                        categoryColor: category.color
                    )) {
                        makeExerciseCard(
                            name: getThirdExerciseName(),
                            description: getThirdExerciseDescription(),
                            duration: "4 min"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100) // Espacio para navbar
            }
            
            Spacer(minLength: 0) // Esto asegura que el ScrollView use todo el espacio
        }
        .background(Color.gray.opacity(0.1))
        .navigationBarHidden(true)
    }
    
    // MARK: - Helper Function
    private func makeExerciseCard(name: String, description: String, duration: String) -> some View {
        HStack(spacing: 16) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 8)
                .fill(category.color.opacity(0.3))
                .frame(width: 60, height: 80)
                .overlay(
                    Image(systemName: "play.fill")
                        .foregroundColor(category.color)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Text(duration)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
    
    // MARK: - Exercise Names by Category
    private func getFirstExerciseName() -> String {
        switch category.categoryType {
        case .respirar: return "Respiración 4-7-8"
        case .meditar: return "Meditación Guiada"
        case .moverte: return "Yoga Energizante"
        case .reflexionar: return "Diario Emocional"
        case .crecer: return "Visualización de Metas"
        }
    }
    
    private func getFirstExerciseDescription() -> String {
        switch category.categoryType {
        case .respirar: return "Técnica calmante para reducir ansiedad"
        case .meditar: return "Sesión de meditación para principiantes"
        case .moverte: return "Secuencia de yoga para activar el cuerpo"
        case .reflexionar: return "Reflexión guiada sobre emociones"
        case .crecer: return "Ejercicio para clarificar objetivos"
        }
    }
    
    private func getSecondExerciseName() -> String {
        switch category.categoryType {
        case .respirar: return "Respiración Profunda"
        case .meditar: return "Mindfulness Básico"
        case .moverte: return "Estiramiento Suave"
        case .reflexionar: return "Gratitud Diaria"
        case .crecer: return "Autoafirmaciones"
        }
    }
    
    private func getSecondExerciseDescription() -> String {
        switch category.categoryType {
        case .respirar: return "Ejercicio básico de respiración consciente"
        case .meditar: return "Ejercicio de atención plena"
        case .moverte: return "Ejercicios de estiramiento para relajar"
        case .reflexionar: return "Ejercicio de apreciación y gratitud"
        case .crecer: return "Práctica de refuerzo positivo personal"
        }
    }
    
    private func getThirdExerciseName() -> String {
        switch category.categoryType {
        case .respirar: return "Respiración Cuadrada"
        case .meditar: return "Meditación Zen"
        case .moverte: return "Tai Chi Básico"
        case .reflexionar: return "Autocompasión"
        case .crecer: return "Planificación del Futuro"
        }
    }
    
    private func getThirdExerciseDescription() -> String {
        switch category.categoryType {
        case .respirar: return "Técnica de respiración rítmica"
        case .meditar: return "Práctica tradicional de meditación"
        case .moverte: return "Movimientos suaves y meditativos"
        case .reflexionar: return "Práctica de amor propio y aceptación"
        case .crecer: return "Ejercicio de visión y planeación"
        }
    }
}

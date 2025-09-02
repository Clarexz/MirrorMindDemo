//
//  MomentosView.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

struct MomentosView: View {
    @StateObject private var viewModel = MomentosViewModel()
    
    var body: some View {
        ZStack {
            Color.Primary.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header con avatar y pregunta
                HStack {
                    // Avatar circular
                    Circle()
                        .fill(Color.Primary.brand)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        )
                    
                    Spacer()
                    
                    // Burbuja de pregunta
                    Text("¿Qué necesitas hoy?")
                        .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.mediumWeight))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.Primary.brand)
                        .cornerRadius(20)
                }
                .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                .padding(.top, 10)
                
                // Contenido con scroll
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: DesignConstants.Spacing.sectionMargin) {
                        
                        // SECCIÓN MODIFICADA: Botones de filtro con funcionalidad
                        HStack(spacing: 12) {
                            // Botón Favoritos - FUNCIONAL
                            Button(action: {
                                viewModel.toggleFavoritesFilter()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(viewModel.showFavoritesOnly ? .white : Color.Text.primary)
                                    
                                    Text("Favoritos")
                                        .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
                                        .foregroundColor(viewModel.showFavoritesOnly ? .white : Color.Text.primary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(viewModel.showFavoritesOnly ? .pink : Color.white)
                                .cornerRadius(20)
                                .shadow(
                                    color: DesignConstants.Shadow.card,
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
                            }
                            
                            // Botón Filtros - FUNCIONAL con estados dinámicos
                            Button(action: {
                                viewModel.toggleEmotionFilterMenu()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: viewModel.selectedEmotionFilter != nil ? "face.smiling" : "slider.horizontal.3")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(viewModel.selectedEmotionFilter != nil ? .white : Color.Primary.brand)
                                    
                                    Text(viewModel.filterButtonText)
                                        .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
                                        .foregroundColor(viewModel.selectedEmotionFilter != nil ? .white : Color.Text.primary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(viewModel.filterButtonColor)
                                .cornerRadius(20)
                                .shadow(
                                    color: DesignConstants.Shadow.card,
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                        
                        // NUEVA SECCIÓN: Menú desplegable de filtros emocionales mejorado
                        if viewModel.isEmotionFilterMenuOpen {
                            EmotionFilters(viewModel: viewModel)
                        }
                        
                        // NUEVA SECCIÓN: Lista de ejercicios filtrados
                        if viewModel.hasActiveFilters {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(viewModel.showFavoritesOnly ? "Tus ejercicios favoritos" : "Ejercicios filtrados")
                                    .font(.system(size: DesignConstants.Typography.heading2Size, weight: DesignConstants.Typography.boldWeight))
                                    .foregroundColor(Color.Text.primary)
                                    .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                                
                                if viewModel.filteredExercises.isEmpty {
                                    // Estado vacío
                                    VStack(spacing: 16) {
                                        Image(systemName: viewModel.showFavoritesOnly ? "heart" : "magnifyingglass")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color.Text.secondary)
                                        
                                        Text(viewModel.showFavoritesOnly ? "No hay ejercicios disponibles" : "No se encontraron ejercicios")
                                            .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.mediumWeight))
                                            .foregroundColor(Color.Text.primary)
                                        
                                        Text(viewModel.showFavoritesOnly ? "Aún no has marcado ningún ejercicio como favorito" : "Intenta con otro filtro")
                                            .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.regularWeight))
                                            .foregroundColor(Color.Text.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.vertical, 40)
                                    .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                                } else {
                                    // Grid de ejercicios en 2 columnas
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                        ForEach(viewModel.filteredExercises) { exercise in
                                            MomentsExerciseCard(exercise: exercise, viewModel: viewModel) {
                                                // TODO: Navegación a reproductor (Fase 10)
                                                print("Tapped exercise: \(exercise.name)")
                                            }
                                        }
                                    }
                                    .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                                }
                            }
                        } else {
                            // SECCIÓN ORIGINAL: Grid de categorías (cuando no hay filtros activos)
                            VStack(spacing: DesignConstants.Spacing.sectionMargin) {
                                // Grid de categorías (código original sin cambios)
                                VStack(spacing: 12) {
                                    // Grid 2x2 para las primeras 4 categorías
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                        ForEach(Array(MomentCategory.allCategories.prefix(4))) { category in
                                            NavigationLink(destination: CategoryView(category: category)) {
                                                CategoryCardView(category: category, isFullWidth: false)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    
                                    // Quinta categoría con ancho completo
                                    if let fifthCategory = MomentCategory.allCategories.last {
                                        NavigationLink(destination: CategoryView(category: fifthCategory)) {
                                            CategoryCardView(category: fifthCategory, isFullWidth: true)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                                
                                // Dato curioso (código original sin cambios)
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 20))
                                        
                                        Text("Dato curioso")
                                            .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.boldWeight))
                                            .foregroundColor(Color.Text.primary)
                                        
                                        Spacer()
                                    }
                                    
                                    Text(MomentCategory.randomTip())
                                        .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.regularWeight))
                                        .foregroundColor(Color.Text.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(DesignConstants.Spacing.cardPadding)
                                .background(Color.white)
                                .cornerRadius(DesignConstants.Radius.card)
                                .shadow(
                                    color: DesignConstants.Shadow.card,
                                    radius: DesignConstants.Shadow.cardRadius,
                                    x: DesignConstants.Shadow.cardOffset.width,
                                    y: DesignConstants.Shadow.cardOffset.height
                                )
                                .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                            }
                        }
                    }
                    .padding(.top, DesignConstants.Spacing.sectionMargin)
                    .padding(.bottom, 160) // Espacio para navbar flotante
                }
            }
        }
    }
}


#Preview {
    MomentosView()
}

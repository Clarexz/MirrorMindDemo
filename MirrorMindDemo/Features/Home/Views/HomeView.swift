//
//  HomeView.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            // Fondo que llega hasta los bordes
            Color.Primary.background
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Barra superior fija
                VStack(spacing: 0) {
                    // Espacio para status bar
                    Color.Primary.background
                        .frame(height: 0)
                    
                    // Contenido de la barra
                    HStack {
                        // Avatar
                        Circle()
                            .fill(Color.Primary.brand)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                            )
                        
                        Text("¡Buenas tardes, Caleb!")
                            .font(.system(size: DesignConstants.Typography.heading1Size, weight: DesignConstants.Typography.boldWeight))
                            .foregroundColor(Color.Text.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                    .padding(.vertical, 12)
                    .background(Color.Primary.background)
                }
                
                // Contenido scrolleable
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: DesignConstants.Spacing.sectionMargin) {
                        // Contenido principal
                        LazyVStack(spacing: DesignConstants.Spacing.sectionMargin) {
                            EmotionSelectorCardView(viewModel: viewModel)
                            ExerciseSuggestionsCardView(viewModel: viewModel)
                            SmartBandCardView()
                            WeeklyChart()
                            OliviaTipsCardView(homeViewModel: viewModel)
                        }
                        .padding(.horizontal, DesignConstants.Spacing.containerPadding)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 160) // Espacio para navbar
                }
            }
        }
    }
}

// MARK: - Emotion Selector Card View Interactiva
struct EmotionSelectorCardView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: DesignConstants.Spacing.cardPadding) {
            Text("¿Cómo te sientes en este momento?")
                .font(.system(size: DesignConstants.Typography.heading2Size, weight: DesignConstants.Typography.mediumWeight))
                .foregroundColor(Color.Text.primary)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DesignConstants.Spacing.gridGap), count: 3), spacing: DesignConstants.Spacing.gridGap) {
                ForEach(Emotion.emotions) { emotion in
                    Button(action: {
                        viewModel.selectEmotion(emotion)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: DesignConstants.Radius.emotion)
                                .fill(emotion.color)
                                .frame(height: 90)
                            
                            VStack(spacing: 4) {
                                if viewModel.isEmotionSelected(emotion) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Text(emotion.displayName)
                                    .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.mediumWeight))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .buttonStyle(NoHighlightButtonStyle())
                }
            }
            .frame(height: 200)
        }
        .padding(DesignConstants.Spacing.cardPadding)
        .background(Color.Primary.background)
        .cornerRadius(DesignConstants.Radius.card)
        .shadow(
            color: DesignConstants.Shadow.card,
            radius: DesignConstants.Shadow.cardRadius,
            x: DesignConstants.Shadow.cardOffset.width,
            y: DesignConstants.Shadow.cardOffset.height
        )
    }
}

// MARK: - Custom Button Style
struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct ExerciseSuggestionsCardView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: DesignConstants.Spacing.cardPadding) {
            Text(viewModel.dynamicMessage)
                .font(.system(size: DesignConstants.Typography.heading2Size, weight: DesignConstants.Typography.boldWeight))
                .foregroundColor(Color.Text.primary)
            
            // Scroll horizontal de ejercicios con ExerciseCard
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: DesignConstants.Spacing.gridGap) {
                    ForEach(viewModel.suggestedExercises) { exercise in
                        ExerciseCard(exercise: exercise) {
                            // TODO: Navegación a reproductor de ejercicio
                            print("Tapped exercise: \(exercise.name)")
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
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
    }
}

struct SmartBandCardView: View {
    @StateObject private var smartBandViewModel = SmartBandViewModel()
    
    var body: some View {
        VStack(spacing: DesignConstants.Spacing.cardPadding) {
            // Header con estado
            HStack {
                Text("Smartband")
                    .font(.system(size: DesignConstants.Typography.heading2Size, weight: DesignConstants.Typography.boldWeight))
                    .foregroundColor(Color.Text.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(stateColor)
                        .frame(width: 8, height: 8)
                    
                    Text(smartBandViewModel.connectionState.displayText)
                        .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
                        .foregroundColor(stateColor)
                }
            }
            
            // Contenido según estado
            contentView
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
    }
    
    // MARK: - Computed Properties
    
    private var stateColor: Color {
        switch smartBandViewModel.connectionState {
        case .disconnected:
            return .red
        case .connecting:
            return .orange
        case .connected:
            return .green
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch smartBandViewModel.connectionState {
        case .disconnected:
            disconnectedView
        case .connecting:
            connectingView
        case .connected:
            connectedView
        }
    }
    
    // MARK: - State Views
    
    private var disconnectedView: some View {
        Button("Conectar") {
            smartBandViewModel.connectDevice()
        }
        .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.boldWeight))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.blue)
        .cornerRadius(DesignConstants.Radius.button)
    }
    
    private var connectingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            
            Text("Conectando...")
                .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.mediumWeight))
                .foregroundColor(Color.Text.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
    
    private var connectedView: some View {
        HStack {
            // Temperatura
            HStack(spacing: 4) {
                Image(systemName: "thermometer")
                    .foregroundColor(.orange)
                    .font(.system(size: 16))
                
                Text(smartBandViewModel.currentReading?.formattedTemperature ?? "--°C")
                    .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.boldWeight))
                    .foregroundColor(Color.Text.primary)
            }
            
            Spacer()
            
            // Heart Rate
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 16))
                
                Text(smartBandViewModel.currentReading?.formattedHeartRate ?? "-- LPM")
                    .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.boldWeight))
                    .foregroundColor(Color.Text.primary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - OliviaTipsCardView Dinámico
// Reemplazar el componente actual en HomeView.swift

struct OliviaTipsCardView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject private var weeklyDataViewModel = WeeklyDataViewModel()
    @State private var currentTip: OliviaTip?
    @State private var isRefreshing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.cardPadding) {
            // Header con avatar de Olivia
            HStack(spacing: 12) {
                // Avatar de Olivia
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.Primary.brand.opacity(0.8), Color.Primary.brand],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Olivia sugiere...")
                        .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.boldWeight))
                        .foregroundColor(Color.Text.primary)
                    
                    if let emotion = homeViewModel.selectedEmotion {
                        Text("Para tu estado \(emotion.displayName.lowercased())")
                            .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
                            .foregroundColor(Color.Text.secondary)
                    } else {
                        Text("Consejo personalizado")
                            .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
                            .foregroundColor(Color.Text.secondary)
                    }
                }
                
                Spacer()
                
                // Botón de refresh
                Button(action: refreshTip) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.Primary.brand)
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                        .animation(.easeInOut(duration: 0.5), value: isRefreshing)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Contenido del tip
            if let tip = currentTip {
                VStack(alignment: .leading, spacing: 12) {
                    Text(tip.title)
                        .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.boldWeight))
                        .foregroundColor(Color.Text.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(tip.content)
                        .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.mediumWeight))
                        .foregroundColor(Color.Text.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    
                    // Categoría del tip
                    HStack {
                        Image(systemName: categoryIcon(for: tip.category))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.Primary.brand)
                        
                        Text(tip.category.displayName)
                            .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
                            .foregroundColor(Color.Primary.brand)
                        
                        Spacer()
                        
                        // Indicador de contexto emocional
                        if let emotion = homeViewModel.selectedEmotion,
                           tip.targetEmotion?.lowercased() == emotion.displayName.lowercased() {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(emotionColor(for: emotion))
                                    .frame(width: 8, height: 8)
                                
                                Text("Personalizado")
                                    .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
                                    .foregroundColor(Color.Text.secondary)
                            }
                        }
                    }
                }
            } else {
                // Estado de carga
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(Color.Primary.brand)
                    
                    Text("Olivia está pensando...")
                        .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.mediumWeight))
                        .foregroundColor(Color.Text.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            
            // Botón de acción
            Button(action: {
                // TODO: Navegación hacia Chat completo (Fase futura)
                print("Navegando a Chat con Olivia...")
            }) {
                HStack {
                    Text("Quiero saber más")
                        .font(.system(size: DesignConstants.Typography.heading3Size, weight: DesignConstants.Typography.boldWeight))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.Primary.brand)
                .cornerRadius(DesignConstants.Radius.button)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(DesignConstants.Spacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.Radius.card)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignConstants.Radius.card)
                        .stroke(
                            LinearGradient(
                                colors: [Color.Primary.brand.opacity(0.2), Color.Primary.brand.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.Primary.brand.opacity(0.1),
                    radius: DesignConstants.Shadow.cardRadius,
                    x: DesignConstants.Shadow.cardOffset.width,
                    y: DesignConstants.Shadow.cardOffset.height
                )
        )
        .onAppear {
            loadAppropiateTip()
        }
        .onChange(of: homeViewModel.selectedEmotion) { _, _ in
            loadAppropiateTip()
        }
    }
    
    // MARK: - Private Methods
    
    /// Carga un tip apropiado según el contexto emocional actual
    private func loadAppropiateTip() {
        // Determinar contexto emocional
        let selectedEmotionName = homeViewModel.selectedEmotion?.displayName
        
        // Por ahora solo usar emoción seleccionada, análisis semanal en versión futura
        let targetEmotion = selectedEmotionName
        
        // Obtener tip apropiado
        currentTip = OliviaTipsDatabase.shared.getRandomTip(for: targetEmotion)
    }
    
    /// Refresca el tip actual con animación
    private func refreshTip() {
        isRefreshing = true
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTip = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            loadAppropiateTip()
            isRefreshing = false
        }
    }
    
    /// Iconos para cada categoría de tip
    private func categoryIcon(for category: OliviaTip.TipCategory) -> String {
        switch category {
        case .breathing:
            return "lungs"
        case .mindfulness:
            return "brain.head.profile"
        case .movement:
            return "figure.walk"
        case .social:
            return "person.2"
        case .selfCare:
            return "heart"
        case .growth:
            return "arrow.up.right"
        }
    }
    
    /// Color de la emoción seleccionada
    private func emotionColor(for emotion: Emotion) -> Color {
        switch emotion.displayName.lowercased() {
        case "feliz":
            return Color.Emotions.happy
        case "triste":
            return Color.Emotions.sad
        case "enojado":
            return Color.Emotions.angry
        case "ansioso":
            return Color.Emotions.anxious
        case "nervioso":
            return Color.Emotions.nervous
        case "calmado":
            return Color.Emotions.calm
        default:
            return Color.Primary.brand
        }
    }
}

#Preview {
    HomeView()
}

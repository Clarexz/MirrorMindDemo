//
//  WeeklyChart.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import SwiftUI

struct WeeklyChart: View {
    @StateObject private var weeklyDataViewModel = WeeklyDataViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.cardPadding) {
            // Header
            Text("Tu semana emocional")
                .font(.system(size: DesignConstants.Typography.heading2Size, weight: DesignConstants.Typography.boldWeight))
                .foregroundColor(Color.Text.primary)
            
            // Chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weeklyDataViewModel.currentWeeklySummary.dailyData) { day in
                    VStack(spacing: 4) {
                        // Barra emocional
                        RoundedRectangle(cornerRadius: 4)
                            .fill(getColorForEmotion(day.emotion))
                            .frame(width: 24, height: CGFloat(day.intensity * 60 + 20))
                        
                        // Día de la semana
                        Text(day.dayAbbreviation)
                            .font(.system(size: 10, weight: DesignConstants.Typography.mediumWeight))
                            .foregroundColor(day.isToday ? Color.Primary.brand : Color.Text.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            
            // Resumen
            Text(weeklyDataViewModel.currentWeeklySummary.weekDescription)
                .font(.system(size: DesignConstants.Typography.heading4Size, weight: DesignConstants.Typography.mediumWeight))
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
    }
    
    private func getColorForEmotion(_ emotion: String) -> Color {
        switch emotion.lowercased() {
        case "feliz":
            return Color.Emotions.happy
        case "triste":
            return Color.Emotions.sad
        case "ansioso":
            return Color.Emotions.anxious
        case "enojado":
            return Color.Emotions.angry
        case "nervioso":
            return Color.Emotions.nervous
        case "calmado":
            return Color.Emotions.calm
        default:
            return Color.gray
        }
    }
}

#Preview {
    WeeklyChart()
        .padding()
        .background(Color.Primary.background)
}

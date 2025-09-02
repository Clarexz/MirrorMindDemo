//
//  OliviaTip.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//

import Foundation

// MARK: - Olivia Tip Model
struct OliviaTip: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let targetEmotion: String? // nil = tip general
    let category: TipCategory
    let priority: Int // 1-5, mayor prioridad = se muestra más frecuente
    
    init(title: String, content: String, targetEmotion: String?, category: TipCategory, priority: Int) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.targetEmotion = targetEmotion
        self.category = category
        self.priority = priority
    }
    
    enum TipCategory: String, CaseIterable, Codable {
        case breathing = "respiracion"
        case mindfulness = "mindfulness"
        case movement = "movimiento"
        case social = "social"
        case selfCare = "autocuidado"
        case growth = "crecimiento"
        
        var displayName: String {
            switch self {
            case .breathing: return "Respiración"
            case .mindfulness: return "Mindfulness"
            case .movement: return "Movimiento"
            case .social: return "Social"
            case .selfCare: return "Autocuidado"
            case .growth: return "Crecimiento Personal"
            }
        }
    }
}

// MARK: - Olivia Tips Database
class OliviaTipsDatabase {
    static let shared = OliviaTipsDatabase()
    private init() {}
    
    // Base de datos mock de tips de Olivia
    private let allTips: [OliviaTip] = [
        
        // TIPS GENERALES (sin emoción específica)
        OliviaTip(
            title: "¡Hora de moverte!",
            content: "Has probado salir a caminar? El aire fresco puede ayudar a mantener tu bienestar emocional.",
            targetEmotion: nil,
            category: .movement,
            priority: 3
        ),
        OliviaTip(
            title: "Momento de respirar",
            content: "Toma 3 respiraciones profundas conmigo. Inhala... exhala... siente cómo tu cuerpo se relaja.",
            targetEmotion: nil,
            category: .breathing,
            priority: 4
        ),
        OliviaTip(
            title: "Conecta contigo",
            content: "¿Qué tal si dedicamos unos minutos a reflexionar sobre tu día? La introspección es clave para el crecimiento.",
            targetEmotion: nil,
            category: .growth,
            priority: 2
        ),
        
        // TIPS PARA TRISTEZA
        OliviaTip(
            title: "Abraza tus emociones",
            content: "Es normal sentirse triste a veces. Permítete experimentar esta emoción, es parte del proceso de sanación.",
            targetEmotion: "triste",
            category: .selfCare,
            priority: 5
        ),
        OliviaTip(
            title: "Pequeños pasos",
            content: "Cuando todo se siente pesado, comienza con algo pequeño. Una sonrisa, una respiración profunda, un paso a la vez.",
            targetEmotion: "triste",
            category: .growth,
            priority: 4
        ),
        OliviaTip(
            title: "Llama a alguien especial",
            content: "¿Hay alguien que te haga sentir mejor? A veces una conversación puede iluminar nuestro día.",
            targetEmotion: "triste",
            category: .social,
            priority: 4
        ),
        OliviaTip(
            title: "Movimiento suave",
            content: "Un paseo tranquilo o estiramiento suave puede ayudar a liberar endorfinas naturales. Tu cuerpo te lo agradecerá.",
            targetEmotion: "triste",
            category: .movement,
            priority: 3
        ),
        
        // TIPS PARA ENOJO
        OliviaTip(
            title: "Pausa y respira",
            content: "Antes de reaccionar, toma 5 respiraciones profundas. El enojo es válido, pero podemos manejarlo con calma.",
            targetEmotion: "enojado",
            category: .breathing,
            priority: 5
        ),
        OliviaTip(
            title: "Libera la tensión",
            content: "¿Sientes tensión en tu cuerpo? Prueba ejercicios de liberación física como apretar y soltar los puños.",
            targetEmotion: "enojado",
            category: .movement,
            priority: 4
        ),
        OliviaTip(
            title: "Escribe tus pensamientos",
            content: "A veces sacar los pensamientos de la cabeza y ponerlos en papel nos ayuda a verlos con más claridad.",
            targetEmotion: "enojado",
            category: .selfCare,
            priority: 3
        ),
        OliviaTip(
            title: "Reflexiona sobre el origen",
            content: "¿Qué hay detrás de este enojo? A menudo hay otras emociones esperando ser reconocidas.",
            targetEmotion: "enojado",
            category: .growth,
            priority: 4
        ),
        
        // TIPS PARA ANSIEDAD
        OliviaTip(
            title: "Técnica 5-4-3-2-1",
            content: "Identifica 5 cosas que ves, 4 que tocas, 3 que escuchas, 2 que hueles y 1 que saboreas. Esto te conecta con el presente.",
            targetEmotion: "ansioso",
            category: .mindfulness,
            priority: 5
        ),
        OliviaTip(
            title: "Respiración cuadrada",
            content: "Inhala por 4, mantén por 4, exhala por 4, mantén por 4. Repite hasta sentir más calma.",
            targetEmotion: "ansioso",
            category: .breathing,
            priority: 5
        ),
        OliviaTip(
            title: "Enfócate en lo controlable",
            content: "Cuando la ansiedad aparece, pregúntate: ¿Qué puedo controlar ahora? Enfoca tu energía ahí.",
            targetEmotion: "ansioso",
            category: .growth,
            priority: 4
        ),
        OliviaTip(
            title: "Movimiento calmante",
            content: "El yoga suave o estiramientos pueden ayudar a reducir la tensión física que acompaña la ansiedad.",
            targetEmotion: "ansioso",
            category: .movement,
            priority: 3
        ),
        
        // TIPS PARA NERVIOSISMO
        OliviaTip(
            title: "Prepárate mentalmente",
            content: "Si hay algo específico que te pone nervioso, visualiza el resultado positivo. Tu mente es tu aliada.",
            targetEmotion: "nervioso",
            category: .growth,
            priority: 4
        ),
        OliviaTip(
            title: "Respiración relajante",
            content: "Inhala lentamente por la nariz y exhala por la boca como si fueras a soplar una vela. Repite 10 veces.",
            targetEmotion: "nervioso",
            category: .breathing,
            priority: 5
        ),
        OliviaTip(
            title: "Reconoce tu fortaleza",
            content: "Recuerda momentos donde superaste desafíos similares. Tienes más fortaleza de la que crees.",
            targetEmotion: "nervioso",
            category: .selfCare,
            priority: 4
        ),
        OliviaTip(
            title: "Relajación muscular",
            content: "Tensa y relaja cada grupo muscular por 5 segundos. Comienza con los pies y sube hasta la cabeza.",
            targetEmotion: "nervioso",
            category: .movement,
            priority: 3
        ),
        
        // TIPS PARA FELICIDAD
        OliviaTip(
            title: "Comparte tu alegría",
            content: "¡Qué hermoso verte así! ¿Qué tal si compartes esta energía positiva con alguien que aprecias?",
            targetEmotion: "feliz",
            category: .social,
            priority: 4
        ),
        OliviaTip(
            title: "Captura este momento",
            content: "Haz una pausa para realmente sentir esta felicidad. ¿Qué la causó? Estos detalles son tesoros para el futuro.",
            targetEmotion: "feliz",
            category: .mindfulness,
            priority: 5
        ),
        OliviaTip(
            title: "Energía en movimiento",
            content: "¡Usa esta energía positiva! Un baile, una caminata energética o ejercicio pueden potenciar tu bienestar.",
            targetEmotion: "feliz",
            category: .movement,
            priority: 3
        ),
        OliviaTip(
            title: "Gratitud activa",
            content: "Mientras te sientes bien, ¿qué tal si piensas en 3 cosas por las que te sientes agradecido hoy?",
            targetEmotion: "feliz",
            category: .growth,
            priority: 4
        ),
        
        // TIPS PARA CALMA
        OliviaTip(
            title: "Mantén esta serenidad",
            content: "Qué hermoso verte en calma. ¿Cómo puedes recordar esta sensación para momentos más intensos?",
            targetEmotion: "calmado",
            category: .mindfulness,
            priority: 4
        ),
        OliviaTip(
            title: "Profundiza la calma",
            content: "Ya que estás sereno, es el momento perfecto para una meditación más profunda o respiración consciente.",
            targetEmotion: "calmado",
            category: .breathing,
            priority: 4
        ),
        OliviaTip(
            title: "Reflexión serena",
            content: "En estos momentos de calma es cuando podemos ver las cosas con más claridad. ¿Hay algo que quieras reflexionar?",
            targetEmotion: "calmado",
            category: .growth,
            priority: 5
        ),
        OliviaTip(
            title: "Cultiva la paciencia",
            content: "Esta calma es un regalo. Practica llevar esta misma energía a las actividades de tu día.",
            targetEmotion: "calmado",
            category: .selfCare,
            priority: 3
        ),
    ]
    
    // MARK: - Public Methods
    
    /// Obtiene tips para una emoción específica
    func getTips(for emotion: String?) -> [OliviaTip] {
        if let emotion = emotion {
            let emotionTips = allTips.filter { $0.targetEmotion?.lowercased() == emotion.lowercased() }
            let generalTips = allTips.filter { $0.targetEmotion == nil }
            
            // Combinar tips específicos y generales, ordenar por prioridad
            return (emotionTips + generalTips).sorted { $0.priority > $1.priority }
        } else {
            // Solo tips generales si no hay emoción seleccionada
            return allTips.filter { $0.targetEmotion == nil }.sorted { $0.priority > $1.priority }
        }
    }
    
    /// Obtiene un tip aleatorio para la emoción especificada
    func getRandomTip(for emotion: String?) -> OliviaTip? {
        let availableTips = getTips(for: emotion)
        
        // Weighted random: tips con mayor prioridad tienen más chance
        let weightedTips = availableTips.flatMap { tip in
            Array(repeating: tip, count: tip.priority)
        }
        
        return weightedTips.randomElement()
    }
    
    /// Obtiene tips por categoría
    func getTips(by category: OliviaTip.TipCategory) -> [OliviaTip] {
        return allTips.filter { $0.category == category }.sorted { $0.priority > $1.priority }
    }
    
    /// Obtiene todas las categorías disponibles
    func getAllCategories() -> [OliviaTip.TipCategory] {
        return OliviaTip.TipCategory.allCases
    }
}

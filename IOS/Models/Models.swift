// Models.swift
import Foundation

struct Dream: Identifiable {
    let id: UUID
    let text: String
    let timestamp: Date
    let soundscapeURL: URL?
    let emotions: [Emotion]
    let archetypes: [String]
    var analysis: DreamAnalysis {
        DreamAnalysis(emotions: emotions, archetypes: archetypes)
    }
}

struct DreamAnalysis {
    let emotions: [Emotion]
    let archetypes: [String]
    
    var dominantEmotion: Emotion? {
        emotions.max(by: { $0.score < $1.score })
    }
    
    var commonArchetype: String? {
        archetypes.first
    }
}

struct Emotion: Identifiable {
    let id = UUID()
    let label: String
    let score: Float
    var color: String {
        switch label.lowercased() {
        case "joy": return "#FFD700"
        case "fear": return "#800080"
        case "anger": return "#FF0000"
        case "sadness": return "#1E90FF"
        case "surprise": return "#FFA500"
        case "disgust": return "#008000"
        default: return "#808080"
        }
    }
}

struct SleepData {
    let deepSleepMin: Double
    let remSleepMin: Double
    let sleepScore: Double
}
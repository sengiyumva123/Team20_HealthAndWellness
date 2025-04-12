// DreamAnalyzer.swift
import NaturalLanguage

class DreamAnalyzer {
    private let tagger = NLTagger(tagSchemes: [.tokenType, .lemma])
    private let emotionalWords: [String: String] = [
        "happy": "joy",
        "joyful": "joy",
        "scared": "fear",
        "angry": "anger",
        "sad": "sadness",
        "surprised": "surprise",
        "disgusted": "disgust"
    ]
    
    func analyze(text: String) -> DreamAnalysis {
        let emotions = detectEmotions(text: text)
        let archetypes = detectArchetypes(text: text)
        
        return DreamAnalysis(emotions: emotions, archetypes: archetypes)
    }
    
    private func detectEmotions(text: String) -> [Emotion] {
        var emotions = [String: Float]()
        
        tagger.string = text.lowercased()
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, 
                            unit: .word,
                            scheme: .lemma,
                            options: [.omitPunctuation, .omitWhitespace]) { tag, range in
            if let lemma = tag?.rawValue {
                if let emotion = emotionalWords[lemma] {
                    emotions[emotion] = (emotions[emotion] ?? 0) + 1
                }
            }
            return true
        }
        
        // Normalize scores
        let maxCount = emotions.values.max() ?? 1
        return emotions.map { Emotion(label: $0.key, score: Float($0.value) / Float(maxCount)) }
    }
    
    private func detectArchetypes(text: String) -> [String] {
        var archetypes = Set<String>()
        let patterns = [
            "falling": ["fall", "slip", "trip", "plummet"],
            "chased": ["chase", "pursue", "flee", "escape"],
            "water": ["water", "ocean", "swim", "drown"],
            "flying": ["fly", "float", "soar", "airborne"],
            "naked": ["naked", "nude", "exposed", "undressed"],
            "test": ["exam", "test", "fail", "study"]
        ]
        
        for (archetype, keywords) in patterns {
            if keywords.contains(where: { text.lowercased().contains($0) }) {
                archetypes.insert(archetype)
            }
        }
        
        return Array(archetypes)
    }
}
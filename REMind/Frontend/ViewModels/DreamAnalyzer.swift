import NaturalLanguage

class DreamAnalyzer {
    private let emotionalWords: [String: String] = [
        "happy": "joy",
        "joyful": "joy",
        "scared": "fear",
        "angry": "anger",
        "sad": "sadness",
        "surprised": "surprise",
        "disgusted": "disgust"
    ]
    
    private let archetypePatterns: [String: [String]] = [
        "falling": ["fall", "drop", "plummet"],
        "chased": ["chase", "pursue", "flee"],
        "water": ["water", "ocean", "drown"],
        "flying": ["fly", "soar", "float"],
        "naked": ["naked", "exposed", "nude"],
        "test": ["exam", "test", "fail"]
    ]
    
    func analyze(text: String) -> DreamAnalysis {
        let emotions = detectEmotions(text: text)
        let archetypes = detectArchetypes(text: text)
        return DreamAnalysis(emotions: emotions, archetypes: archetypes)
    }
    
    private func detectEmotions(text: String) -> [Emotion] {
        var emotions = [String: Float]()
        let tagger = NLTagger(tagSchemes: [.tokenType, .lemma])
        tagger.string = text.lowercased()
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma) { tag, range in
            if let lemma = tag?.rawValue, let emotion = emotionalWords[lemma] {
                emotions[emotion] = (emotions[emotion] ?? 0) + 1
            }
            return true
        }
        
        let maxCount = emotions.values.max() ?? 1
        return emotions.map { Emotion(label: $0.key, score: Float($0.value) / Float(maxCount)) }
    }
    
    private func detectArchetypes(text: String) -> [String] {
        var archetypes = Set<String>()
        let textLower = text.lowercased()
        
        for (archetype, keywords) in archetypePatterns {
            if keywords.contains(where: { textLower.contains($0) }) {
                archetypes.insert(archetype)
            }
        }
        
        return Array(archetypes)
    }
}

struct DreamAnalysis {
    let emotions: [Emotion]
    let archetypes: [String]
}
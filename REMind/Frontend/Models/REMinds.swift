/*import Foundation

struct Dream: Identifiable, Encodable, Hashable {
    let id: UUID
    var text: String
    var timestamp: Date
    var soundscapeURL: URL?
    var emotions: [Emotion]
    var archetypes: [String]
    var sleepQuality: Int?
    var voiceMemoURL: URL?
    
    init(id: UUID = UUID(), 
         text: String, 
         timestamp: Date = Date(), 
         soundscapeURL: URL? = nil, 
         emotions: [Emotion] = [], 
         archetypes: [String] = [], 
         sleepQuality: Int? = nil, 
         voiceMemoURL: URL? = nil) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.soundscapeURL = soundscapeURL
        self.emotions = emotions
        self.archetypes = archetypes
        self.sleepQuality = sleepQuality
        self.voiceMemoURL = voiceMemoURL
    }
}

struct Emotion: Identifiable, Codable, Hashable {
    let id = UUID()
    var label: String
    var score: Float
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

struct WeeklyReport: Codable, Hashable {
    var dreamCount: Int
    var dominantEmotion: String?
    var commonArchetype: String?
    var avgSleepQuality: Double?
    var emotionDistribution: [String: Int]
    var archetypeFrequency: [String: Int]
}
*/

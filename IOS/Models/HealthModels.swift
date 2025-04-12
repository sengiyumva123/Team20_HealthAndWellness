struct HealthUploadResponse: Codable {
    let status: String
}

struct HealthCorrelation: Codable, Identifiable {
    let id: String
    let dreamEmotion: String
    let hrv: Double?
    let heartRate: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "dream_id"
        case dreamEmotion = "emotion"
        case hrv
        case heartRate
    }
}
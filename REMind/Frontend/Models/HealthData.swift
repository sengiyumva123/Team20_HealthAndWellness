import HealthKit

struct HealthDataPoint: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var sleepHours: Double
    var heartRate: Double?
    var hrv: Double?
    
    static let sampleData: [HealthDataPoint] = [
        HealthDataPoint(date: Date().addingTimeInterval(-86400), sleepHours: 7.5),
        HealthDataPoint(date: Date().addingTimeInterval(-172800), sleepHours: 6.8)
    ]
}
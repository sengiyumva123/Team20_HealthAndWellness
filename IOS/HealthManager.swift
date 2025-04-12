import HealthKit

class HealthManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthError.notAvailable
        }
        
        let typesToRead: Set = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]
        
        try await healthStore.requestAuthorization(toShare: nil, read: typesToRead)
    }
    
    // Fetch sleep data
    func fetchSleepData() async throws -> [HKCategorySample] {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: nil,
                limit: 7,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let samples = samples as? [HKCategorySample] {
                    continuation.resume(returning: samples)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func prepareHealthData(samples: [HKCategorySample]) -> [String: Any] {
        var result = [String: Any]()
        
        result["sleep"] = samples.map { sample in
            [
                "start": ISO8601DateFormatter().string(from: sample.startDate),
                "end": ISO8601DateFormatter().string(from: sample.endDate),
                "value": sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue ? "asleep" : "inBed"
            ]
        }
        
        return result
    }
    
    enum HealthError: Error {
        case notAvailable
        case authorizationFailed
    }
}
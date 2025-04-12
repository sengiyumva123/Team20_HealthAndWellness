// HealthIntegration.swift
import HealthKit

protocol HealthIntegration {
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    func getSleepData(completion: @escaping (Result<SleepData, Error>) -> Void)
}

class HealthKitIntegration: HealthIntegration {
    private let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "com.yourapp", code: 2, userInfo: [NSLocalizedDescriptionKey: "Health data not available"]))
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    func getSleepData(completion: @escaping (Result<SleepData, Error>) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(.failure(NSError(domain: "com.yourapp", code: 3, userInfo: [NSLocalizedDescriptionKey: "Sleep analysis not available"])))
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        ) { _, samples, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Process sleep data
            let sleepData = self.processSleepSamples(samples: samples as? [HKCategorySample] ?? [])
            DispatchQueue.main.async {
                completion(.success(sleepData))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func processSleepSamples(samples: [HKCategorySample]) -> SleepData {
        // Implement actual sleep data processing
        return SleepData(deepSleepMin: 120, remSleepMin: 90, sleepScore: 85)
    }
}
// DreamViewModel.swift
import Combine
import SwiftUI

class DreamViewModel: ObservableObject {
    @Published var dreams: [Dream] = []
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var showError = false
    
    private let dreamStorage: DreamStorage
    private let dreamAnalyzer: DreamAnalyzer
    private let soundGenerator: SoundGenerator
    private let healthIntegration: HealthIntegration
    
    init(
        dreamStorage: DreamStorage = CoreDataDreamStorage(),
        dreamAnalyzer: DreamAnalyzer = DreamAnalyzer(),
        soundGenerator: SoundGenerator = SoundGenerator(),
        healthIntegration: HealthIntegration = HealthKitIntegration()
    ) {
        self.dreamStorage = dreamStorage
        self.dreamAnalyzer = dreamAnalyzer
        self.soundGenerator = soundGenerator
        self.healthIntegration = healthIntegration
        loadDreams()
    }
    
    func addDream(text: String) {
        isLoading = true
        
        // Analyze dream
        let analysis = dreamAnalyzer.analyze(text: text)
        
        // Generate soundscape
        let soundscapeURL = soundGenerator.generateSound(for: text)
        
        // Create dream object
        let dream = Dream(
            id: UUID(),
            text: text,
            timestamp: Date(),
            soundscapeURL: soundscapeURL,
            emotions: analysis.emotions,
            archetypes: analysis.archetypes
        )
        
        // Save to storage
        do {
            try dreamStorage.saveDream(dream)
            dreams.insert(dream, at: 0)
        } catch {
            self.error = AppError.dreamSaveError
            self.showError = true
        }
        
        isLoading = false
    }
    
    func deleteDream(_ dream: Dream) {
        do {
            try dreamStorage.deleteDream(dream.id)
            dreams.removeAll { $0.id == dream.id }
        } catch {
            self.error = AppError.dreamDeleteError
            self.showError = true
        }
    }
    
    private func loadDreams() {
        do {
            dreams = try dreamStorage.fetchDreams()
        } catch {
            self.error = AppError.dreamLoadError
            self.showError = true
        }
    }
    
    func requestHealthAuthorization() {
        healthIntegration.requestAuthorization { success, error in
            DispatchQueue.main.async {
                if !success {
                    self.error = AppError.healthKitError(error?.localizedDescription ?? "Unknown error")
                    self.showError = true
                }
            }
        }
    }
    
    func getSleepData() {
        healthIntegration.getSleepData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    // Handle sleep data
                    break
                case .failure(let error):
                    self.error = AppError.healthKitError(error.localizedDescription)
                    self.showError = true
                }
            }
        }
    }
}

enum AppError: LocalizedError {
    case dreamSaveError
    case dreamLoadError
    case dreamDeleteError
    case healthKitError(String)
    
    var errorDescription: String? {
        switch self {
        case .dreamSaveError: return "Failed to save dream"
        case .dreamLoadError: return "Failed to load dreams"
        case .dreamDeleteError: return "Failed to delete dream"
        case .healthKitError(let message): return "HealthKit error: \(message)"
        }
    }
}
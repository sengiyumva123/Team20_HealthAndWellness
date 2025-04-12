import SwiftUI
import HealthKit

struct HealthIntegrationView: View {
    @StateObject private var healthManager = HealthManager()
    @State private var healthData: [String: Any]?
    @State private var showCorrelations = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Connect Apple Health") {
                Task {
                    do {
                        try await healthManager.requestAuthorization()
                        let samples = try await healthManager.fetchSleepData()
                        healthData = healthManager.prepareHealthData(samples: samples)
                    } catch {
                        print("HealthKit error: \(error)")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            if let healthData {
                Button("Upload Health Data") {
                    Task {
                        try await APIService.shared.uploadHealthData(healthData)
                        showCorrelations = true
                    }
                }
                
                NavigationLink(
                    "View Correlations", 
                    isActive: $showCorrelations,
                    destination: { HealthCorrelationsView() }
                )
            }
        }
        .padding()
    }
}
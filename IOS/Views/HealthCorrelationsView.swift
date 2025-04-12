import SwiftUI
import Charts

struct HealthCorrelationsView: View {
    @State private var correlations: [HealthCorrelation] = []
    
    var body: some View {
        List {
            Section("Sleep Quality vs Dream Emotions") {
                Chart {
                    ForEach(correlations) { correlation in
                        BarMark(
                            x: .value("Emotion", correlation.dreamEmotion),
                            y: .value("HRV", correlation.hrv ?? 0)
                        )
                        .foregroundStyle(by: .value("Type", "HRV"))
                    }
                }
                .frame(height: 200)
            }
        }
        .task {
            do {
                correlations = try await APIService.shared.fetchHealthCorrelations(userId: "current_user_id")
            } catch {
                print("Failed to load correlations: \(error)")
            }
        }
    }
}
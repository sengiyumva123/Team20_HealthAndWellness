/*import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var dreams: [Dream] = []
    @Published var showPopup = false
    
    func addDream(text: String) {
        let newDream = Dream(
            id: UUID(),
            text: text,
            timestamp: Date(),
            emotions: [Emotion(label: "neutral", score: 0.5)],
            archetypes: ["common"]
        )
        dreams.append(newDream)
    }
    
    func deleteDream(_ dream: Dream) {
        dreams.removeAll { $0.id == dream.id }
    }
}
*/

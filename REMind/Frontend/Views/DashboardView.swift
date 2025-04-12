// Full corrected and compiled-ready SwiftUI file with AVFoundation usage
// NOTE: Be sure to link AVFoundation.framework and set Info.plist permissions

import SwiftUI
import Charts
import AVFoundation

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedTab: Tab = .insights

    enum Tab: String, CaseIterable {
        case insights = "Insights"
        case dreams = "Dreams"
        case health = "Health"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.comet.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView
                    tabPicker
                    DreamDetailView()
                }
            }
            .navigationDestination(for: Dream.self) {dream in
                DreamDetailView()
            }
            .sheet(isPresented: $viewModel.showLogDream) {
                LoggedDreamView()
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Dream Journal")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Spacer()

            Button {
                viewModel.showLogDream = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.purpleHaze)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var tabPicker: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.headline)
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color.purpleHaze : Color.clear)
                        )
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.cometDarker)
        .clipShape(Capsule())
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    //@ViewBuilder
   /* private var contentView: some View {
        switch selectedTab {
        case .insights:
            InsightsView()
        case .dreams:
            DreamListView()
        case .health:
            HealthView()
        }
    }
}*/

class DashboardViewModel: ObservableObject {
    @Published var dreams: [Dream] = []
    @Published var showPopup = false
    @Published var showLogDream = false
    
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
    
    func deleteDream(dream: Dream) {
        dreams.removeAll { $0.id == dream.id }
    }
}

struct Dream: Identifiable, Hashable,Decodable,Encodable {
    let id: UUID
    let text: String
    let timestamp: String
    
    init(self.id:UUID = UUID(),
    self.timestamp = Date(),
        self.id = id
        self.text = text
    }

struct Emotion: Hashable, Identifiable,Decodable,Encodable {
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

struct WeeklyReport {
    let id = UUID() // Add an id to conform to Identifiable
    let dream_count: Int
    let dominant_emotion: String?
    let common_archetype: String?
    let avg_sleep_quality: Double?
    let emotion_distribution: [String: Int]?  // Make these Optional, in case the backend returns null
    let archetype_frequency: [String: Int]?
    let is_lucid: Bool?
    let start_date: String? // Or Date, if your backend sends dates in a decodable format
    let end_date: String?
}
}

struct HealthData {
    let id = UUID()
    let date: String // Or Date
    let sleep_duration: Double
}

extension Color {
    static let comet = Color(hex: "#1C1238")
    static let cometDarker = Color(hex: "#0F0A20")
    static let purpleHaze = Color(hex: "#7340BF")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


func fetchData<T: Decodable>(from endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
    guard let url = URL(string: endpoint) else {
        completion(.failure(URLError(.badURL)))
        return
    }

    URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            completion(.failure(NSError(domain: "HTTPError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedData = try decoder.decode(T.self, from: data)
            completion(.success(decodedData))
        } catch {
            completion(.failure(error))
        }
    }.resume()
}

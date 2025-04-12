import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:8000"
    
    private init() {}
    
    func fetchDreams() async throws -> [Dream] {
        guard let url = URL(string: "\(baseURL)/api/dreams") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Dream].self, from: data)
    }
    
    func uploadDream(_ dream: Dream) async throws {
        guard let url = URL(string: "\(baseURL)/api/dreams") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData = try JSONEncoder().encode(dream)
        let (_, response) = try await URLSession.shared.upload(for: request, from: requestData)
        
        guard let httpResponse = response as? HTTPURLResponse, 
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func deleteDream(_ id: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/api/dreams/\(id.uuidString)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func uploadAudio(_ audioURL: URL) async throws -> URL {
        guard let url = URL(string: "\(baseURL)/api/audio") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        // Add the audio file data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"recording.wav\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        data.append(try Data(contentsOf: audioURL))
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        let (responseData, _) = try await URLSession.shared.upload(for: request, from: data)
        let response = try JSONDecoder().decode(AudioUploadResponse.self, from: responseData)
        return URL(string: response.filePath)!
    }
}

struct AudioUploadResponse: Codable {
    let filePath: String
}

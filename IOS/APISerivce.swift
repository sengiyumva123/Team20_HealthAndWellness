extension APIService {
    func uploadHealthData(_ data: [String: Any]) async throws -> HealthUploadResponse {
        let url = URL(string: "\(baseURL)/api/health/import")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData = try JSONSerialization.data(withJSONObject: data)
        let (responseData, _) = try await URLSession.shared.upload(for: request, from: requestData)
        return try JSONDecoder().decode(HealthUploadResponse.self, from: responseData)
    }
    
    func fetchHealthCorrelations(userId: String) async throws -> [HealthCorrelation] {
        let url = URL(string: "\(baseURL)/api/health/correlations/\(userId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([HealthCorrelation].self, from: data)
    }
}
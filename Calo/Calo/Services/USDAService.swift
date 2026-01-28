//
//  USDAService.swift
//  Calo
//
//  Created on 2026-01-27.
//

import Foundation

// MARK: - USDAService

actor USDAService {
    // MARK: - Properties
    
    private let session: URLSession
    private let baseURL = "https://api.nal.usda.gov/fdc/v1/foods/search"
    private let apiKey: String?
    
    // MARK: - Initialization
    
    init(apiKey: String? = nil, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    // MARK: - Public Methods
    
    func searchFood(query: String) async throws -> [NutritionData] {
        guard !query.isEmpty else {
            return []
        }
        
        // If no API key, return empty (graceful degradation)
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            return []
        }
        
        // Build URL with query parameters
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "dataType", value: "Foundation,SR Legacy"),
            URLQueryItem(name: "pageSize", value: "10"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue("calo-app/1.0", forHTTPHeaderField: "User-Agent")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        // Execute request
        let (data, response) = try await session.data(for: request)
        
        // Check response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Decode response
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(USDAResponse.self, from: data)
        
        // Convert to NutritionData
        let results = apiResponse.foods.compactMap { $0.toNutritionData() }
        
        return results
    }
}

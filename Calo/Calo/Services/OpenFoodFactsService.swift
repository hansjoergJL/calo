//
//  OpenFoodFactsService.swift
//  Calo
//
//  Created on 2026-01-27.
//

import Foundation

// MARK: - OpenFoodFactsService

actor OpenFoodFactsService {
    // MARK: - Properties
    
    private let session: URLSession
    private let baseURL = "https://world.openfoodfacts.org/cgi/search.pl"
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    
    func searchFood(query: String) async throws -> [NutritionData] {
        guard !query.isEmpty else {
            return []
        }
        
        // Build URL with query parameters
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "10"),
            URLQueryItem(name: "fields", value: "code,product_name,product_name_de,product_name_en,nutriments")
        ]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15  // Increased timeout for slower connections
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
        let apiResponse = try decoder.decode(OpenFoodFactsResponse.self, from: data)
        
        // Convert to NutritionData
        let results = apiResponse.products.compactMap { $0.toNutritionData() }
        
        return results
    }
}

// MARK: - APIError

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    case noResults
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ungültige URL"
        case .invalidResponse:
            return "Ungültige Antwort vom Server"
        case .serverError(let code):
            return "Serverfehler: \(code)"
        case .decodingError:
            return "Fehler beim Verarbeiten der Daten"
        case .noResults:
            return "Keine Ergebnisse gefunden"
        case .networkError:
            return "Netzwerkfehler - Bitte Internetverbindung prüfen"
        }
    }
}

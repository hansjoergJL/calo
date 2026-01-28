//
//  NutritionData.swift
//  Calo
//
//  Created on 2026-01-27.
//

import Foundation

// MARK: - NutritionData

struct NutritionData: Identifiable, Codable {
    let id: String
    let name: String
    let nameEnglish: String?
    let caloriesPer100g: Double
    let protein: Double?
    let carbs: Double?
    let fat: Double?
    let source: String
    
    // MARK: - Computed Properties
    
    var displayName: String {
        name
    }
    
    func calculateCalories(for grams: Double) -> Int {
        Int((caloriesPer100g / 100.0) * grams)
    }
}

// MARK: - API Response Models

// OpenFoodFacts Response
struct OpenFoodFactsResponse: Codable {
    let products: [OpenFoodFactsProduct]
    let count: Int
}

struct OpenFoodFactsProduct: Codable {
    let code: String?
    let productName: String?
    let productNameDe: String?
    let productNameEn: String?
    let nutriments: OpenFoodFactsNutriments?
    
    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case productNameDe = "product_name_de"
        case productNameEn = "product_name_en"
        case nutriments
    }
    
    func toNutritionData() -> NutritionData? {
        guard let name = productNameDe ?? productName,
              !name.isEmpty,
              let nutriments = nutriments,
              let calories = nutriments.energyKcal100g else {
            return nil
        }
        
        return NutritionData(
            id: code ?? UUID().uuidString,
            name: name,
            nameEnglish: productNameEn,
            caloriesPer100g: calories,
            protein: nutriments.proteins100g,
            carbs: nutriments.carbohydrates100g,
            fat: nutriments.fat100g,
            source: "OpenFoodFacts"
        )
    }
}

struct OpenFoodFactsNutriments: Codable {
    let energyKcal100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?
    
    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
    }
}

// USDA Response
struct USDAResponse: Codable {
    let foods: [USDAFood]
}

struct USDAFood: Codable {
    let fdcId: Int
    let description: String
    let foodNutrients: [USDANutrient]
    
    func toNutritionData() -> NutritionData? {
        // Find energy nutrient (calories)
        guard let energyNutrient = foodNutrients.first(where: { nutrient in
            nutrient.nutrientName.lowercased().contains("energy")
        }),
              let caloriesPer100g = energyNutrient.value else {
            return nil
        }
        
        let protein = foodNutrients.first { $0.nutrientName.lowercased().contains("protein") }?.value
        let carbs = foodNutrients.first { $0.nutrientName.lowercased().contains("carbohydrate") }?.value
        let fat = foodNutrients.first { $0.nutrientName.lowercased().contains("fat") }?.value
        
        return NutritionData(
            id: String(fdcId),
            name: description,
            nameEnglish: description,
            caloriesPer100g: caloriesPer100g,
            protein: protein,
            carbs: carbs,
            fat: fat,
            source: "USDA"
        )
    }
}

struct USDANutrient: Codable {
    let nutrientName: String
    let value: Double?
}

//
//  FoodEntry.swift
//  Calo
//
//  Created on 2026-01-27.
//

import Foundation
import SwiftData

@Model
final class FoodEntry {
    // MARK: - Properties
    
    var id: UUID
    var timestamp: Date
    var amount: Double
    var measure: String // MeasureUnit as String for SwiftData compatibility
    var foodName: String
    var foodNameEnglish: String?
    var calories: Int
    var meal: String? // MealType as String (optional)
    var protein: Double?
    var carbs: Double?
    var fat: Double?
    var apiSource: String
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        amount: Double,
        measure: String,
        foodName: String,
        foodNameEnglish: String? = nil,
        calories: Int,
        meal: String? = nil,
        protein: Double? = nil,
        carbs: Double? = nil,
        fat: Double? = nil,
        apiSource: String = "manual"
    ) {
        self.id = id
        self.timestamp = timestamp
        self.amount = amount
        self.measure = measure
        self.foodName = foodName
        self.foodNameEnglish = foodNameEnglish
        self.calories = calories
        self.meal = meal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.apiSource = apiSource
    }
}

// MARK: - MeasureUnit Enum

enum MeasureUnit: String, CaseIterable, Codable {
    case grams = "g"
    case milliliters = "ml"
    case pieces = "Stück"
    case slices = "Scheibe"
    case tablespoons = "EL"
    case teaspoons = "TL"
    case servings = "Portion"
    
    var localizedName: String {
        switch self {
        case .grams:
            return NSLocalizedString("measure.grams", comment: "Grams unit")
        case .milliliters:
            return NSLocalizedString("measure.milliliters", comment: "Milliliters unit")
        case .pieces:
            return NSLocalizedString("measure.pieces", comment: "Pieces unit")
        case .slices:
            return NSLocalizedString("measure.slices", comment: "Slices unit")
        case .tablespoons:
            return NSLocalizedString("measure.tablespoons", comment: "Tablespoons unit")
        case .teaspoons:
            return NSLocalizedString("measure.teaspoons", comment: "Teaspoons unit")
        case .servings:
            return NSLocalizedString("measure.servings", comment: "Servings unit")
        }
    }
}

// MARK: - MealType Enum

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Frühstück"
    case lunch = "Mittagessen"
    case dinner = "Abendessen"
    case snack = "Snack"
    
    var localizedName: String {
        switch self {
        case .breakfast:
            return NSLocalizedString("meal.breakfast", comment: "Breakfast")
        case .lunch:
            return NSLocalizedString("meal.lunch", comment: "Lunch")
        case .dinner:
            return NSLocalizedString("meal.dinner", comment: "Dinner")
        case .snack:
            return NSLocalizedString("meal.snack", comment: "Snack")
        }
    }
}

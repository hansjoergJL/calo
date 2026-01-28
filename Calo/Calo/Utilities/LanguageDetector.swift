//
//  LanguageDetector.swift
//  Calo
//
//  Created on 2026-01-27.
//

import Foundation
import NaturalLanguage

// MARK: - DetectedLanguage

enum DetectedLanguage {
    case german
    case english
    case unknown
}

// MARK: - LanguageDetector

struct LanguageDetector {
    // MARK: - Methods
    
    func detect(_ text: String) -> DetectedLanguage {
        guard !text.isEmpty else {
            return .unknown
        }
        
        // Use NaturalLanguage framework for detection
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        guard let dominantLanguage = recognizer.dominantLanguage else {
            // Fallback: Check for German-specific characters
            return fallbackDetection(text)
        }
        
        switch dominantLanguage {
        case .german:
            return .german
        case .english:
            return .english
        default:
            return fallbackDetection(text)
        }
    }
    
    // MARK: - Private Methods
    
    private func fallbackDetection(_ text: String) -> DetectedLanguage {
        let lowercased = text.lowercased()
        
        // German-specific characters
        let germanCharacters = CharacterSet(charactersIn: "äöüß")
        let hasGermanChars = lowercased.rangeOfCharacter(from: germanCharacters) != nil
        
        if hasGermanChars {
            return .german
        }
        
        // Common German food words
        let germanFoodWords = [
            "käse", "wurst", "brot", "brötchen", "schnitzel",
            "spätzle", "kuchen", "joghurt", "quark", "müsli"
        ]
        
        for word in germanFoodWords {
            if lowercased.contains(word) {
                return .german
            }
        }
        
        // Default to German (app is German-first)
        return .german
    }
}

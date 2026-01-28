//
//  WeightEntry.swift
//  Calo
//
//  Created on 2026-01-27.
//

import Foundation
import SwiftData

@Model
final class WeightEntry {
    // MARK: - Properties
    
    var id: UUID
    var date: Date
    var weight: Double // in kilograms
    var notes: String?
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        weight: Double,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.notes = notes
    }
}

//
//  FoodRowView.swift
//  Calo
//
//  Created on 2026-01-27.
//

import SwiftUI

struct FoodRowView: View {
    // MARK: - Properties
    
    let entry: FoodEntry
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            // Amount & Measure
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatAmount(entry.amount))
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                Text(entry.measure)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60, alignment: .trailing)
            
            // Food Name
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.foodName)
                    .font(.body)
                if let meal = entry.meal {
                    Text(meal)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Calories
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.calories)")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                Text("kcal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Helper Methods
    
    private func formatAmount(_ amount: Double) -> String {
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", amount)
        } else {
            return String(format: "%.1f", amount)
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        FoodRowView(entry: FoodEntry(
            amount: 300,
            measure: "g",
            foodName: "Joghurt",
            calories: 250
        ))
        
        FoodRowView(entry: FoodEntry(
            amount: 150.5,
            measure: "ml",
            foodName: "Milch",
            foodNameEnglish: "Milk",
            calories: 95,
            meal: "Frühstück"
        ))
        
        FoodRowView(entry: FoodEntry(
            amount: 2,
            measure: "Stück",
            foodName: "Apfel",
            calories: 104
        ))
    }
}

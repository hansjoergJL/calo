//
//  DailySummaryView.swift
//  Calo
//
//  Created on 2026-01-27.
//

import SwiftUI
import SwiftData

struct DailySummaryView: View {
    // MARK: - Properties
    
    let date: Date
    let foodEntries: [FoodEntry]
    
    // MARK: - Query
    
    @Query private var weightEntries: [WeightEntry]
    
    // MARK: - State
    
    @State private var showWeightEntry = false
    
    // MARK: - Computed Properties
    
    private var totalCalories: Int {
        foodEntries.reduce(0) { $0 + $1.calories }
    }
    
    private var todaysWeight: WeightEntry? {
        let calendar = Calendar.current
        return weightEntries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12) {
            // Date Display
            Text(date, format: .dateTime.day().month(.wide).year())
                .font(.headline)
                .foregroundStyle(.secondary)
                .environment(\.locale, Locale(identifier: "de_DE"))
            
            HStack(spacing: 40) {
                // Calories
                VStack(spacing: 4) {
                    Text("\(totalCalories)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Weight (if entered)
                if let weight = todaysWeight {
                    Divider()
                        .frame(height: 50)
                    
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", weight.weight))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("kg")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Food Count
            if !foodEntries.isEmpty {
                Text("\(foodEntries.count) \(foodEntries.count == 1 ? "Eintrag" : "Einträge")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Weight Button
            Button {
                showWeightEntry = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: todaysWeight != nil ? "scalemass.fill" : "scalemass")
                    Text(todaysWeight != nil ? "Gewicht bearbeiten" : "Gewicht hinzufügen")
                }
                .font(.caption)
                .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        }
        .sheet(isPresented: $showWeightEntry) {
            WeightEntryView(date: date, existingWeight: todaysWeight)
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: FoodEntry.self, WeightEntry.self,
        configurations: config
    )
    
    // Sample data
    let entry1 = FoodEntry(
        amount: 100,
        measure: "g",
        foodName: "Joghurt",
        calories: 150
    )
    let entry2 = FoodEntry(
        amount: 200,
        measure: "ml",
        foodName: "Milch",
        calories: 100
    )
    let weight = WeightEntry(weight: 75.5)
    
    container.mainContext.insert(entry1)
    container.mainContext.insert(entry2)
    container.mainContext.insert(weight)
    
    return DailySummaryView(
        date: Date(),
        foodEntries: [entry1, entry2]
    )
    .modelContainer(container)
    .padding()
}

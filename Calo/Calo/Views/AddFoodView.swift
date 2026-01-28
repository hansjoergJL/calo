//
//  AddFoodView.swift
//  Calo
//
//  Created on 2026-01-27.
//

import SwiftUI
import SwiftData

struct AddFoodView: View {
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    
    @State private var amount: String = ""
    @State private var selectedMeasure: MeasureUnit = .grams
    @State private var foodName: String = ""
    @State private var searchResults: [NutritionData] = []
    @State private var selectedFood: NutritionData?
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var manualCalories: String = ""
    @State private var showManualEntry = false
    @State private var recentFoods: [FoodEntry] = []
    @FocusState private var isManualCaloriesFocused: Bool
    
    @Query(sort: \FoodEntry.timestamp, order: .reverse) private var allFoodEntries: [FoodEntry]
    
    private let openFoodFactsService = OpenFoodFactsService()
    private let usdaService = USDAService(apiKey: ProcessInfo.processInfo.environment["USDA_API_KEY"])
    private let languageDetector = LanguageDetector()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Menge") {
                    HStack {
                        TextField("Menge", text: $amount)
                            .keyboardType(.decimalPad)
                        
                        Picker("Einheit", selection: $selectedMeasure) {
                            ForEach(MeasureUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Lebensmittel") {
                    TextField("Name", text: $foodName)
                        .autocorrectionDisabled()
                        .onChange(of: foodName) { _, newValue in
                            updateRecentFoods(for: newValue)
                        }
                    
                    Button(action: calculateCalories) {
                        HStack {
                            Text("Kalorien berechnen")
                            Spacer()
                            if isSearching {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(foodName.isEmpty || isSearching)
                }
                
                // Recent Foods (if any match)
                if !recentFoods.isEmpty {
                    Section("Zuletzt verwendet") {
                        ForEach(recentFoods) { entry in
                            Button {
                                selectRecentFood(entry)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(entry.foodName)
                                            .foregroundStyle(.primary)
                                        Text("\(entry.calories) kcal (gespeichert)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        if entry.apiSource != "manual" {
                                            Text(entry.apiSource)
                                                .font(.caption2)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }
                
                // Search Results
                if !searchResults.isEmpty {
                    Section {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(searchResults) { result in
                                    Button {
                                        selectedFood = result
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(result.name)
                                                    .foregroundStyle(.primary)
                                                Text("\(Int(result.caloriesPer100g)) kcal / 100g")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                Text(result.source)
                                                    .font(.caption2)
                                                    .foregroundStyle(.tertiary)
                                            }
                                            Spacer()
                                            if selectedFood?.id == result.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(.blue)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if result.id != searchResults.last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                    } header: {
                        HStack {
                            Text("Ergebnisse")
                            Spacer()
                            Text("\(searchResults.count) gefunden")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Calculated Calories Display
                if let selected = selectedFood, let amountValue = Double(amount) {
                    Section("Berechnung") {
                        HStack {
                            Text("Kalorien")
                            Spacer()
                            Text("\(calculatedCalories) kcal")
                                .fontWeight(.semibold)
                        }
                        Text("Für \(formatAmount(amountValue)) \(selectedMeasure.rawValue) \(selected.name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Manual Entry Option (auto-enabled when no results)
                if errorMessage != nil || (searchResults.isEmpty && !isSearching && !foodName.isEmpty && recentFoods.isEmpty) {
                    Section {
                        Toggle("Kalorien manuell eingeben", isOn: $showManualEntry)
                        
                        if showManualEntry {
                            TextField("kcal (optional)", text: $manualCalories)
                                .keyboardType(.numberPad)
                                .focused($isManualCaloriesFocused)
                        }
                    }
                    .onChange(of: showManualEntry) { _, newValue in
                        if newValue {
                            // Auto-focus the manual calories field when enabled
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isManualCaloriesFocused = true
                            }
                        }
                    }
                }
                
                // Error Message
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
                // Save Button
                Section {
                    Button("Hinzufügen") {
                        saveEntry()
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Eintrag hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValid: Bool {
        guard let amountValue = Double(amount),
              amountValue > 0,
              !foodName.isEmpty else {
            return false
        }
        
        // Either have selected food OR manual calories OR neither (allow 0 calories)
        return true
    }
    
    private var calculatedCalories: Int {
        guard let selected = selectedFood,
              let amountValue = Double(amount) else {
            return 0
        }
        
        // Convert to grams if needed
        let gramsAmount = convertToGrams(amountValue, unit: selectedMeasure)
        return selected.calculateCalories(for: gramsAmount)
    }
    
    // MARK: - Methods
    
    private func calculateCalories() {
        Task {
            isSearching = true
            errorMessage = nil
            searchResults = []
            selectedFood = nil
            
            do {
                // Detect language
                let language = languageDetector.detect(foodName)
                
                // Query appropriate API based on language
                var results: [NutritionData] = []
                
                if language == .german {
                    // Try OpenFoodFacts first (best for German)
                    results = try await openFoodFactsService.searchFood(query: foodName)
                    
                    // If no results and USDA available, try USDA as fallback
                    if results.isEmpty {
                        let usdaResults = try await usdaService.searchFood(query: foodName)
                        results.append(contentsOf: usdaResults)
                    }
                } else {
                    // Try both APIs in parallel for English/unknown
                    async let openFoodResults = openFoodFactsService.searchFood(query: foodName)
                    async let usdaResults = usdaService.searchFood(query: foodName)
                    
                    let (offResults, usdaRes) = try await (openFoodResults, usdaResults)
                    results.append(contentsOf: offResults)
                    results.append(contentsOf: usdaRes)
                }
                
                await MainActor.run {
                    if results.isEmpty {
                        errorMessage = "Keine Ergebnisse gefunden. Bitte manuell eingeben."
                        showManualEntry = true  // Auto-enable manual entry
                    } else {
                        searchResults = results
                    }
                    isSearching = false
                }
            } catch let error as URLError {
                await MainActor.run {
                    if error.code == .timedOut {
                        errorMessage = "Zeitüberschreitung - Bitte erneut versuchen oder manuell eingeben."
                    } else if error.code == .notConnectedToInternet {
                        errorMessage = "Keine Internetverbindung - Bitte manuell eingeben."
                    } else {
                        errorMessage = "Netzwerkfehler - Bitte manuell eingeben."
                    }
                    showManualEntry = true  // Auto-enable manual entry on error
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Fehler bei der Suche - Bitte manuell eingeben."
                    showManualEntry = true  // Auto-enable manual entry on error
                    isSearching = false
                }
            }
        }
    }
    
    private func saveEntry() {
        guard let amountValue = Double(amount) else {
            return
        }
        
        // Determine calories: calculated > manual > 0
        let finalCalories: Int
        if let selected = selectedFood {
            finalCalories = calculatedCalories
        } else if let manual = Int(manualCalories), manual >= 0 {
            finalCalories = manual
        } else {
            finalCalories = 0
        }
        
        let entry = FoodEntry(
            amount: amountValue,
            measure: selectedMeasure.rawValue,
            foodName: foodName,
            calories: finalCalories,
            apiSource: selectedFood?.source ?? "manual"
        )
        
        modelContext.insert(entry)
        dismiss()
    }
    
    private func convertToGrams(_ amount: Double, unit: MeasureUnit) -> Double {
        // Simple conversion - for now just return amount
        // In production, you'd have proper conversion tables
        switch unit {
        case .grams:
            return amount
        case .milliliters:
            return amount // Assume 1ml ≈ 1g for liquids
        case .pieces:
            return amount * 100 // Assume 1 piece ≈ 100g
        case .slices:
            return amount * 30 // Assume 1 slice ≈ 30g
        case .tablespoons:
            return amount * 15 // 1 EL ≈ 15g
        case .teaspoons:
            return amount * 5 // 1 TL ≈ 5g
        case .servings:
            return amount * 150 // 1 portion ≈ 150g
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", amount)
        } else {
            return String(format: "%.1f", amount)
        }
    }
    
    private func updateRecentFoods(for query: String) {
        guard !query.isEmpty else {
            recentFoods = []
            return
        }
        
        // Find recent foods that match the query (case-insensitive)
        let lowercaseQuery = query.lowercased()
        recentFoods = allFoodEntries
            .filter { $0.foodName.lowercased().contains(lowercaseQuery) }
            .reduce(into: [FoodEntry]()) { result, entry in
                // Deduplicate by food name (keep most recent)
                if !result.contains(where: { $0.foodName == entry.foodName }) {
                    result.append(entry)
                }
            }
            .prefix(3)  // Show max 3 recent entries
            .map { $0 }
    }
    
    private func selectRecentFood(_ entry: FoodEntry) {
        // Use the stored entry's data as a template
        foodName = entry.foodName
        
        // Calculate calories per 100g from the stored entry
        // Formula: stored_calories = (amount / 100) * caloriesPer100g
        // Therefore: caloriesPer100g = (stored_calories * 100) / amount
        let gramsAmount = convertToGrams(entry.amount, unit: MeasureUnit(rawValue: entry.measure) ?? .grams)
        let caloriesPer100g = gramsAmount > 0 ? (Double(entry.calories) * 100.0) / gramsAmount : Double(entry.calories)
        
        // Create a NutritionData from the recent entry for proper calculation
        let recentAsNutrition = NutritionData(
            id: entry.id.uuidString,
            name: entry.foodName,
            nameEnglish: entry.foodNameEnglish,
            caloriesPer100g: caloriesPer100g,  // Properly calculated per 100g
            protein: entry.protein,
            carbs: entry.carbs,
            fat: entry.fat,
            source: "Zuletzt verwendet"
        )
        selectedFood = recentAsNutrition
        
        // Clear manual entry since we're using calculated values now
        showManualEntry = false
        manualCalories = ""
    }
}

// MARK: - Preview

#Preview {
    AddFoodView()
        .modelContainer(for: [FoodEntry.self], inMemory: true)
}

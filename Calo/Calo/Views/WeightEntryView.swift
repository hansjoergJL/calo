//
//  WeightEntryView.swift
//  Calo
//
//  Created on 2026-01-27.
//

import SwiftUI
import SwiftData

struct WeightEntryView: View {
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Properties
    
    let date: Date
    let existingWeight: WeightEntry?
    
    // MARK: - State
    
    @State private var weight: String
    @State private var notes: String
    @FocusState private var isWeightFocused: Bool
    
    // MARK: - Initialization
    
    init(date: Date = Date(), existingWeight: WeightEntry? = nil) {
        self.date = date
        self.existingWeight = existingWeight
        
        // Initialize with existing values if available
        if let existing = existingWeight {
            _weight = State(initialValue: String(format: "%.1f", existing.weight))
            _notes = State(initialValue: existing.notes ?? "")
        } else {
            _weight = State(initialValue: "")
            _notes = State(initialValue: "")
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("Gewicht", text: $weight)
                            .keyboardType(.decimalPad)
                            .focused($isWeightFocused)
                            .multilineTextAlignment(.trailing)
                        
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Gewicht am \(formattedDate)")
                        .textCase(nil)
                }
                
                Section("Notizen (optional)") {
                    TextField("z.B. vor/nach dem Training", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if existingWeight != nil {
                    Section {
                        Button(role: .destructive) {
                            deleteWeight()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Gewicht löschen")
                            }
                        }
                    }
                }
            }
            .navigationTitle(existingWeight != nil ? "Gewicht bearbeiten" : "Gewicht hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(existingWeight != nil ? "Aktualisieren" : "Hinzufügen") {
                        saveWeight()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                // Auto-focus weight field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isWeightFocused = true
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValid: Bool {
        guard let weightValue = Double(weight),
              weightValue > 0,
              weightValue < 500 else {  // Sanity check: weight must be reasonable
            return false
        }
        return true
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    // MARK: - Methods
    
    private func saveWeight() {
        guard let weightValue = Double(weight) else {
            return
        }
        
        if let existing = existingWeight {
            // Update existing entry
            existing.weight = weightValue
            existing.notes = notes.isEmpty ? nil : notes
        } else {
            // Create new entry
            let entry = WeightEntry(
                date: date,
                weight: weightValue,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(entry)
        }
        
        dismiss()
    }
    
    private func deleteWeight() {
        if let existing = existingWeight {
            modelContext.delete(existing)
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview("New Entry") {
    WeightEntryView()
        .modelContainer(for: [WeightEntry.self], inMemory: true)
}

#Preview("Edit Entry") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WeightEntry.self, configurations: config)
    
    let existingEntry = WeightEntry(weight: 75.5, notes: "Nach dem Training")
    container.mainContext.insert(existingEntry)
    
    return WeightEntryView(existingWeight: existingEntry)
        .modelContainer(container)
}

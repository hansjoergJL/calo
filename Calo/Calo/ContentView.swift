//
//  ContentView.swift
//  Calo
//
//  Created by Hans-Jörg Jödike on 27.01.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodEntry.timestamp, order: .reverse) private var foodEntries: [FoodEntry]
    
    // MARK: - State
    
    @State private var selectedDate = Date()
    @State private var showAddFood = false
    @State private var showHelp = false
    @State private var showStatistics = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Daily Summary
                DailySummaryView(
                    date: selectedDate,
                    foodEntries: todaysFoodEntries
                )
                .padding()
                
                Divider()
                
                // Food List
                List {
                    ForEach(todaysFoodEntries) { entry in
                        FoodRowView(entry: entry)
                    }
                    .onDelete(perform: deleteEntries)
                }
                .listStyle(.plain)
            }
            .navigationTitle("calo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showHelp = true
                    } label: {
                        Label("Hilfe", systemImage: "questionmark.circle")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        showStatistics = true
                    } label: {
                        Label("Statistiken", systemImage: "chart.xyaxis.line")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddFood = true
                    } label: {
                        Label("Add Food", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddFood) {
                AddFoodView()
            }
            .sheet(isPresented: $showHelp) {
                HelpView()
            }
        }
        .overlay {
            if showStatistics {
                StatisticsWindowView(isPresented: $showStatistics)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var todaysFoodEntries: [FoodEntry] {
        let calendar = Calendar.current
        return foodEntries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: selectedDate)
        }
    }
    
    // MARK: - Methods
    
    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            let entry = todaysFoodEntries[index]
            modelContext.delete(entry)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [FoodEntry.self, WeightEntry.self], inMemory: true)
}

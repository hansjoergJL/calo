//
//  StatisticsView.swift
//  Calo
//
//  Created by Hans-Jörg Jödike on 28.01.26.
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \FoodEntry.timestamp, order: .reverse) private var foodEntries: [FoodEntry]
    @Query(sort: \WeightEntry.date, order: .reverse) private var weightEntries: [WeightEntry]
    
    // MARK: - State
    
    @State private var selectedPeriod: TimePeriod = .week
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Period Selector
                    Picker("Zeitraum", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Calorie Chart
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                            Text("Kalorienverbrauch")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        if calorieDataPoints.isEmpty {
                            EmptyChartView(message: "Keine Kaloriendaten für diesen Zeitraum")
                        } else {
                            Chart {
                                ForEach(calorieDataPoints) { dataPoint in
                                    LineMark(
                                        x: .value("Datum", dataPoint.date),
                                        y: .value("Kalorien", dataPoint.value)
                                    )
                                    .foregroundStyle(.orange)
                                    .interpolationMethod(.catmullRom)
                                    
                                    AreaMark(
                                        x: .value("Datum", dataPoint.date),
                                        y: .value("Kalorien", dataPoint.value)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange.opacity(0.3), .orange.opacity(0.05)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .interpolationMethod(.catmullRom)
                                    
                                    PointMark(
                                        x: .value("Datum", dataPoint.date),
                                        y: .value("Kalorien", dataPoint.value)
                                    )
                                    .foregroundStyle(.orange)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisValueLabel {
                                        if let intValue = value.as(Int.self) {
                                            Text("\(intValue)")
                                                .font(.caption)
                                        }
                                    }
                                    AxisGridLine()
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel(format: selectedPeriod.dateFormat)
                                        .font(.caption)
                                    AxisGridLine()
                                }
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                            
                            // Statistics
                            HStack(spacing: 20) {
                                StatBox(
                                    title: "Durchschnitt",
                                    value: String(format: "%.0f", averageCalories),
                                    unit: "kcal",
                                    color: .orange
                                )
                                
                                StatBox(
                                    title: "Maximum",
                                    value: String(format: "%.0f", maxCalories),
                                    unit: "kcal",
                                    color: .red
                                )
                                
                                StatBox(
                                    title: "Minimum",
                                    value: String(format: "%.0f", minCalories),
                                    unit: "kcal",
                                    color: .green
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Weight Chart
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "scalemass.fill")
                                .foregroundStyle(.purple)
                            Text("Gewichtsverlauf")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        if weightDataPoints.isEmpty {
                            EmptyChartView(message: "Keine Gewichtsdaten für diesen Zeitraum")
                        } else {
                            Chart {
                                ForEach(weightDataPoints) { dataPoint in
                                    LineMark(
                                        x: .value("Datum", dataPoint.date),
                                        y: .value("Gewicht", dataPoint.value)
                                    )
                                    .foregroundStyle(.purple)
                                    .interpolationMethod(.catmullRom)
                                    
                                    AreaMark(
                                        x: .value("Datum", dataPoint.date),
                                        y: .value("Gewicht", dataPoint.value)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.purple.opacity(0.3), .purple.opacity(0.05)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .interpolationMethod(.catmullRom)
                                    
                                    PointMark(
                                        x: .value("Datum", dataPoint.date),
                                        y: .value("Gewicht", dataPoint.value)
                                    )
                                    .foregroundStyle(.purple)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisValueLabel {
                                        if let doubleValue = value.as(Double.self) {
                                            Text(String(format: "%.1f", doubleValue))
                                                .font(.caption)
                                        }
                                    }
                                    AxisGridLine()
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel(format: selectedPeriod.dateFormat)
                                        .font(.caption)
                                    AxisGridLine()
                                }
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                            
                            // Statistics
                            HStack(spacing: 20) {
                                StatBox(
                                    title: "Durchschnitt",
                                    value: String(format: "%.1f", averageWeight),
                                    unit: "kg",
                                    color: .purple
                                )
                                
                                StatBox(
                                    title: "Höchstes",
                                    value: String(format: "%.1f", maxWeight),
                                    unit: "kg",
                                    color: .red
                                )
                                
                                StatBox(
                                    title: "Niedrigstes",
                                    value: String(format: "%.1f", minWeight),
                                    unit: "kg",
                                    color: .green
                                )
                            }
                            .padding(.horizontal)
                            
                            // Weight change
                            if let change = weightChange {
                                HStack {
                                    Image(systemName: change >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                        .foregroundStyle(change >= 0 ? .red : .green)
                                    
                                    Text("Veränderung: \(change >= 0 ? "+" : "")\(String(format: "%.1f", change)) kg")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistiken")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        let start: Date
        switch selectedPeriod {
        case .week:
            start = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            start = calendar.date(byAdding: .month, value: -1, to: now)!
        case .threeMonths:
            start = calendar.date(byAdding: .month, value: -3, to: now)!
        case .year:
            start = calendar.date(byAdding: .year, value: -1, to: now)!
        }
        
        return (start, now)
    }
    
    private var calorieDataPoints: [ChartDataPoint] {
        let calendar = Calendar.current
        let range = dateRange
        
        // Group food entries by date
        var dailyCalories: [Date: Double] = [:]
        
        for entry in foodEntries {
            guard entry.timestamp >= range.start && entry.timestamp <= range.end else { continue }
            
            let day = calendar.startOfDay(for: entry.timestamp)
            dailyCalories[day, default: 0] += Double(entry.calories)
        }
        
        // Convert to sorted array
        return dailyCalories.map { ChartDataPoint(date: $0.key, value: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    private var weightDataPoints: [ChartDataPoint] {
        let range = dateRange
        
        return weightEntries
            .filter { $0.date >= range.start && $0.date <= range.end }
            .map { ChartDataPoint(date: $0.date, value: $0.weight) }
            .sorted { $0.date < $1.date }
    }
    
    private var averageCalories: Double {
        guard !calorieDataPoints.isEmpty else { return 0 }
        let total = calorieDataPoints.reduce(0) { $0 + $1.value }
        return total / Double(calorieDataPoints.count)
    }
    
    private var maxCalories: Double {
        calorieDataPoints.map { $0.value }.max() ?? 0
    }
    
    private var minCalories: Double {
        calorieDataPoints.map { $0.value }.min() ?? 0
    }
    
    private var averageWeight: Double {
        guard !weightDataPoints.isEmpty else { return 0 }
        let total = weightDataPoints.reduce(0) { $0 + $1.value }
        return total / Double(weightDataPoints.count)
    }
    
    private var maxWeight: Double {
        weightDataPoints.map { $0.value }.max() ?? 0
    }
    
    private var minWeight: Double {
        weightDataPoints.map { $0.value }.min() ?? 0
    }
    
    private var weightChange: Double? {
        guard weightDataPoints.count >= 2 else { return nil }
        let first = weightDataPoints.first!.value
        let last = weightDataPoints.last!.value
        return last - first
    }
}

// MARK: - Supporting Types

enum TimePeriod: String, CaseIterable, Identifiable {
    case week = "7d"
    case month = "30d"
    case threeMonths = "90d"
    case year = "1y"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .week: return "7 Tage"
        case .month: return "30 Tage"
        case .threeMonths: return "90 Tage"
        case .year: return "1 Jahr"
        }
    }
    
    var dateFormat: Date.FormatStyle {
        switch self {
        case .week:
            return .dateTime.day().month(.abbreviated)
        case .month:
            return .dateTime.day().month(.abbreviated)
        case .threeMonths:
            return .dateTime.day().month(.abbreviated)
        case .year:
            return .dateTime.month(.abbreviated).year()
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Supporting Views

struct StatBox: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
                
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct EmptyChartView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Preview

#Preview {
    StatisticsView()
        .modelContainer(for: [FoodEntry.self, WeightEntry.self], inMemory: true)
}

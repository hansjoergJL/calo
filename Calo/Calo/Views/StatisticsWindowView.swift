//
//  StatisticsWindowView.swift
//  Calo
//
//  Created by Hans-Jörg Jödike on 28.01.26.
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsWindowView: View {
    @Binding var isPresented: Bool
    @State private var windowSize = CGSize(width: 600, height: 700)
    @State private var windowPosition = CGPoint(x: 100, y: 100)
    @State private var isDragging = false
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Don't dismiss on backdrop click - only via Fertig button
                }
            
            // Floating window
            VStack(spacing: 0) {
                // Custom title bar for dragging
                HStack {
                    Image(systemName: "chart.xyaxis.line")
                        .foregroundStyle(.primary)
                    
                    Text("Statistiken")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(.background)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            dragOffset = value.translation
                        }
                        .onEnded { _ in
                            windowPosition.x += dragOffset.width
                            windowPosition.y += dragOffset.height
                            dragOffset = .zero
                            isDragging = false
                        }
                )
                
                Divider()
                
                // Statistics content
                StatisticsContentView(onDismiss: { isPresented = false })
            }
            .frame(width: windowSize.width, height: windowSize.height)
            .background(.background)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            .overlay(
                // Resize handle
                ResizeHandle(size: $windowSize)
                    .frame(width: 20, height: 20)
                    .position(x: windowSize.width - 10, y: windowSize.height - 10)
            )
            .position(
                x: windowPosition.x + windowSize.width / 2 + dragOffset.width,
                y: windowPosition.y + windowSize.height / 2 + dragOffset.height
            )
        }
    }
}

// MARK: - Resize Handle

struct ResizeHandle: View {
    @Binding var size: CGSize
    @State private var isDragging = false
    
    var body: some View {
        Circle()
            .fill(Color.secondary.opacity(0.5))
            .overlay(
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 8))
                    .foregroundStyle(.white)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let newWidth = max(400, size.width + value.translation.width)
                        let newHeight = max(500, size.height + value.translation.height)
                        size = CGSize(width: newWidth, height: newHeight)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
    }
}

// MARK: - Statistics Content (without NavigationStack)

struct StatisticsContentView: View {
    let onDismiss: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodEntry.timestamp, order: .reverse) private var foodEntries: [FoodEntry]
    @Query(sort: \WeightEntry.date, order: .reverse) private var weightEntries: [WeightEntry]
    
    @State private var selectedPeriod: TimePeriod = .week
    
    var body: some View {
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
                        CalorieChartView(dataPoints: calorieDataPoints, selectedPeriod: selectedPeriod)
                        
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
                        WeightChartView(dataPoints: weightDataPoints, selectedPeriod: selectedPeriod)
                        
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
            }
            .padding(.vertical)
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
        
        var dailyCalories: [Date: Double] = [:]
        
        for entry in foodEntries {
            guard entry.timestamp >= range.start && entry.timestamp <= range.end else { continue }
            
            let day = calendar.startOfDay(for: entry.timestamp)
            dailyCalories[day, default: 0] += Double(entry.calories)
        }
        
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

// MARK: - Chart Views

struct CalorieChartView: View {
    let dataPoints: [ChartDataPoint]
    let selectedPeriod: TimePeriod
    
    var body: some View {
        Chart {
            ForEach(dataPoints) { dataPoint in
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
    }
}

struct WeightChartView: View {
    let dataPoints: [ChartDataPoint]
    let selectedPeriod: TimePeriod
    
    var body: some View {
        Chart {
            ForEach(dataPoints) { dataPoint in
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
    }
}

#Preview {
    StatisticsWindowView(isPresented: .constant(true))
        .modelContainer(for: [FoodEntry.self, WeightEntry.self], inMemory: true)
}

//
//  HelpView.swift
//  Calo
//
//  Created by Hans-Jörg Jödike on 28.01.26.
//

import SwiftUI

struct HelpView: View {
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // App Icon and Title
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.green)
                            
                            Text("calo")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Ihr persönlicher Kalorienzähler")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                    
                    // What is calo?
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Was ist calo?")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("calo ist Ihre einfache und intelligente App zum Tracken von Kalorien. Erfassen Sie Ihre Mahlzeiten, lassen Sie Kalorien automatisch berechnen und behalten Sie den Überblick über Ihre tägliche Ernährung.")
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Funktionen")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        FeatureRow(
                            icon: "magnifyingglass",
                            color: .blue,
                            title: "Intelligente Kaloriensuche",
                            description: "Automatische Kalorienberechnung über mehrere kostenlose Nährwert-Datenbanken (OpenFoodFacts für deutsche Lebensmittel, USDA für internationale)"
                        )
                        
                        FeatureRow(
                            icon: "clock.arrow.circlepath",
                            color: .orange,
                            title: "Kürzlich gegessene Lebensmittel",
                            description: "Schnelles Wiederverwenden bereits eingetragener Lebensmittel mit automatischer Neuberechnung der Kalorien"
                        )
                        
                        FeatureRow(
                            icon: "scalemass",
                            color: .purple,
                            title: "Gewichtstracking",
                            description: "Optional können Sie Ihr tägliches Gewicht in kg erfassen und mit Notizen versehen"
                        )
                        
                        FeatureRow(
                            icon: "icloud",
                            color: .cyan,
                            title: "iCloud-Synchronisierung",
                            description: "Alle Ihre Daten werden automatisch über iCloud zwischen iPhone und Mac synchronisiert"
                        )
                        
                        FeatureRow(
                            icon: "globe",
                            color: .green,
                            title: "Mehrsprachig",
                            description: "Automatische Erkennung der Sprache Ihrer Lebensmittelnamen (Deutsch/Englisch) und entsprechende API-Auswahl"
                        )
                        
                        FeatureRow(
                            icon: "ruler",
                            color: .red,
                            title: "Flexible Maßeinheiten",
                            description: "Unterstützt g, ml, Stück, Scheibe, EL (Esslöffel), TL (Teelöffel) und Portion mit intelligenter Umrechnung"
                        )
                        
                        FeatureRow(
                            icon: "hand.tap",
                            color: .indigo,
                            title: "Manuelle Eingabe möglich",
                            description: "Falls keine Kaloriendaten gefunden werden, können Sie die Kalorien manuell eingeben oder einfach 0 speichern"
                        )
                    }
                    
                    Divider()
                    
                    // Quick Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Schnellstart")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(number: "1", text: "Tippen Sie auf '+' um ein neues Lebensmittel hinzuzufügen")
                            TipRow(number: "2", text: "Geben Sie Menge, Einheit und Namen ein")
                            TipRow(number: "3", text: "Tippen Sie auf 'Kalorien berechnen' für automatische Suche")
                            TipRow(number: "4", text: "Wählen Sie aus den Ergebnissen oder nutzen Sie kürzlich gegessene Lebensmittel")
                            TipRow(number: "5", text: "Optional: Erfassen Sie Ihr Gewicht über das Waagen-Symbol")
                        }
                    }
                    
                    Divider()
                    
                    // Footer
                    VStack(spacing: 4) {
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("Made with ❤️ for healthy living")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Hilfe & Info")
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
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TipRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(.green))
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    HelpView()
}

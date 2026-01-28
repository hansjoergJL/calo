//
//  CaloApp.swift
//  Calo
//
//  Created by Hans-Jörg Jödike on 27.01.26.
//

import SwiftUI
import SwiftData

@main
struct CaloApp: App {
    // MARK: - Properties
    
    let modelContainer: ModelContainer
    
    // MARK: - Initialization
    
    init() {
        do {
            // Configure SwiftData with iCloud sync
            let schema = Schema([
                FoodEntry.self,
                WeightEntry.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}

// MARK: - Settings View

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .frame(width: 300, height: 200)
    }
}

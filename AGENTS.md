# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**calo** is a cross-platform (iOS + macOS) calorie tracking app built with SwiftUI and SwiftData. The app integrates with multiple free nutrition APIs (OpenFoodFacts for German foods, USDA for international) and features mandatory iCloud sync for seamless data sharing between devices.

**Key characteristics:**
- German-first UI with English support
- Metric units only (g, ml, kg)
- Optional calorie entry (can save entries with 0 calories if API fails)
- Recent foods feature for quick re-entry
- Clean MVVM architecture with protocol-based dependency injection

## Build & Run Commands

### Building
```bash
# Navigate to project directory
cd /Users/hans-jorgjodike/Development/Swift/calo/Calo

# Build for macOS
xcodebuild -project Calo.xcodeproj -scheme Calo -destination 'platform=macOS' build

# Build for iOS Simulator
xcodebuild -project Calo.xcodeproj -scheme Calo -destination 'platform=iOS Simulator,name=iPhone 15' build

# Clean build folder
xcodebuild -project Calo.xcodeproj -scheme Calo clean
```

### Running in Xcode
- **Build**: `⌘B`
- **Run**: `⌘R`
- **Clean**: `⌘⇧K`
- **Stop**: `⌘.`

### Target Selection
- Choose **"My Mac"** for native macOS testing
- Choose **"iPhone 15"** (or similar) simulator for iOS testing

## Architecture Overview

### MVVM Pattern
```
Views → ViewModels → Services → Models
  ↓         ↓           ↓
 UI     Business    Data/Network
       Logic
```

**Critical rule:** Views are "dumb" - NO business logic. All calculations, API calls, and data manipulation happen in ViewModels or Services.

### Data Flow

#### SwiftData + iCloud Sync
- **ModelContainer** configured in `CaloApp.swift` with `.cloudKitDatabase: .automatic`
- All data models use `@Model` macro
- Queries use `@Query` property wrapper in views
- **Sync is mandatory** - all data automatically syncs via CloudKit

#### API Integration Flow
1. User enters food name in `AddFoodView`
2. `OpenFoodFactsService` (actor) queries API asynchronously
3. Results displayed as selectable list
4. User selects → calories calculated based on amount + unit
5. `FoodEntry` saved to SwiftData → auto-syncs to iCloud

#### Recent Foods Logic
- As user types, `AddFoodView` filters `allFoodEntries` via `@Query`
- Deduplicates by food name (shows most recent only)
- Tapping recent entry **recalculates** calories for new amount (doesn't use stored value directly)
- Formula: `caloriesPer100g = (stored_calories * 100) / grams_amount`

### Key Architecture Decisions

**Why actor for API service?**
- Thread-safe by design
- Prevents data races in async/await contexts
- Enforces serial access to network state

**Why store measure as String instead of enum in SwiftData?**
- SwiftData compatibility - enums with associated values can be problematic
- Converted to/from `MeasureUnit` enum in business logic

**Why optional calories?**
- User experience: Can save entry even if API fails or food unknown
- Manual fallback: Toggle auto-enables on API errors
- Real-world usage: Not all foods have complete nutrition data

## Project Structure

```
Calo/Calo/
├── CaloApp.swift              # App entry, ModelContainer with iCloud
├── ContentView.swift          # Main view: list + daily summary
├── Models/
│   ├── FoodEntry.swift        # @Model: amount, measure, foodName, calories
│   ├── WeightEntry.swift      # @Model: date, weight (kg)
│   └── NutritionData.swift    # API response model (non-persisted)
├── Views/
│   ├── AddFoodView.swift      # Complex form with API integration + recent foods
│   ├── DailySummaryView.swift # Daily calories + optional weight display
│   └── FoodRowView.swift      # 4-column list item
└── Services/
    └── OpenFoodFactsService.swift  # Actor-based API client
```

## Critical Implementation Details

### Unit Conversion
All calculations use grams. Conversion table in `AddFoodView.convertToGrams()`:
- `g` → 1:1
- `ml` → 1:1 (assumes water-like density)
- `Stück` (piece) → 100g
- `Scheibe` (slice) → 30g
- `EL` (tbsp) → 15g
- `TL` (tsp) → 5g
- `Portion` → 150g

**Important:** These are approximations. When selecting from API results, always use API's per-100g value, not conversion estimates.

### Error Handling Pattern
```swift
do {
    let results = try await apiService.searchFood(query: foodName)
    // Handle results
} catch let error as URLError {
    // Specific handling for timeout, no internet, etc.
    if error.code == .timedOut {
        errorMessage = "Zeitüberschreitung - Bitte erneut versuchen oder manuell eingeben."
    }
    showManualEntry = true  // Auto-enable fallback
} catch {
    // Generic error handling
    showManualEntry = true
}
```

**Always auto-enable manual entry on errors** - improves UX.

### SwiftUI State Management
- `@State` for local view state
- `@Query` for SwiftData queries
- `@FocusState` for keyboard/cursor management
- `@Environment(\.modelContext)` for data mutations
- Never use `@StateObject` for API services (use actor instead)

## Common Development Tasks

### Adding a New API Service
1. Create service as `actor` in `Services/` directory
2. Follow pattern from `OpenFoodFactsService.swift`:
   - Private `URLSession` property
   - Public `async throws` methods
   - Proper error mapping to `APIError` enum
3. Add response models to `NutritionData.swift`
4. Update `AddFoodView` to query new service

### Modifying Data Models
**Critical:** SwiftData models cannot be easily migrated. Changing model structure requires:
1. Update `@Model` class
2. Delete app from simulator/device (wipes old database)
3. Reinstall - fresh database with new schema
4. For production: Implement proper migration strategy

### Testing API Integration
```bash
# Test OpenFoodFacts with German query
curl "https://world.openfoodfacts.org/cgi/search.pl?search_terms=Joghurt&json=1&page_size=5&fields=product_name,product_name_de,nutriments"

# Check response structure matches NutritionData model
```

### Debugging iCloud Sync Issues
1. Check CloudKit capability is enabled (Signing & Capabilities tab)
2. Verify signed into same iCloud account on both devices
3. Check Console.app for CloudKit errors
4. Wait 30 seconds for initial sync (not instant)
5. Force sync: Add entry on device A, wait, check device B

## Language & Localization

### Current Implementation
- UI strings are **hardcoded in German** (e.g., "Eintrag hinzufügen", "Kalorien berechnen")
- Error messages in German with fallback to English
- Food names: Stores German (primary) + English (optional) from API

### Future: Localizable.strings
When implementing full localization:
1. Create `de.lproj/Localizable.strings` and `en.lproj/Localizable.strings`
2. Replace all hardcoded strings with `NSLocalizedString("key", comment: "")`
3. Use `LocalizedStringKey` for SwiftUI `Text()` views
4. Test with both German and English system language

## API Integration Notes

### OpenFoodFacts API
- **No API key required** (open-source database)
- **Best for:** German/European branded foods
- **Timeout:** 15 seconds
- **Endpoint:** `https://world.openfoodfacts.org/cgi/search.pl`
- **Rate limit:** None (respectful usage assumed)
- **Response:** German product names in `product_name_de` field

### USDA API (Not Yet Implemented)
- Requires free API key: https://fdc.nal.usda.gov/api-key-signup.html
- Store in `Config.xcconfig` (git-ignored)
- Best for generic foods (fruits, vegetables, meat)
- 1000 requests/hour limit

## Testing Strategy

### Manual Testing Checklist
1. **Basic CRUD:**
   - Add entry (API + manual)
   - View list
   - Delete entry (swipe)
   - Verify persistence after app restart

2. **Recent Foods:**
   - Add "Joghurt" → Close form → Type "Jo" → Recent appears
   - Change amount → Verify calories recalculate (not fixed value)

3. **Error Handling:**
   - Search invalid food → Manual entry auto-enables
   - Disconnect WiFi → Proper error message in German

4. **iCloud Sync:**
   - Add entry on Mac → Appears on iPhone within 30s
   - Works both directions

### Unit Testing (Future)
- Test `convertToGrams()` conversion logic
- Test calorie calculation formulas
- Mock `OpenFoodFactsService` for offline testing
- Verify deduplication logic in recent foods

## Deployment Requirements

### Minimum Versions
- **iOS:** 17.0+ (SwiftData requirement)
- **macOS:** 14.0+ (SwiftData requirement)
- **Swift:** 5.9+
- **Xcode:** 15.0+

### Capabilities Required
- iCloud (CloudKit container)
- Network access for API calls

### Privacy Considerations
- All data stored in user's iCloud (private)
- API calls contain only food search terms (no personal data)
- No analytics or tracking
- GDPR compliant

## Known Limitations & Future Work

### Current Limitations
1. **Calories optional but not validated:** Can save negative calories
2. **No barcode scanning:** Manual entry or search only
3. **No meal plans or goals:** Just daily tracking
4. **Single language detection:** No auto-switch based on food name
5. **Basic unit conversions:** Approximations, not precise

### Planned Features
- USDA API integration for English food names
- Language auto-detection (query OpenFoodFacts for German, USDA for English)
- Weight tracking graph (kg over time)
- Export to CSV/PDF
- HealthKit integration
- Widgets for iOS

## Development Workflow Tips

### When Adding New Views
1. Create separate file in `Views/` directory
2. Use `// MARK: -` comments to organize code sections
3. Always include `#Preview` at bottom for Xcode canvas
4. Extract reusable components to `Views/Components/` (create if needed)

### When Modifying API Logic
1. Test with real API first (not mocked)
2. Check timeout behavior (try slow network)
3. Verify error messages are in German
4. Ensure manual entry fallback works

### Git Workflow
- **Branch naming:** `feature/description` or `bugfix/description`
- **Commit format:** `[Type] Brief description` (e.g., `[Feature] Add recent foods quick select`)
- **Never commit:** `Config.xcconfig`, `DerivedData/`, `.DS_Store`

## Troubleshooting Common Issues

### "Cannot find type 'FoodEntry' in scope"
→ Models folder not added to Xcode target. Select file → File Inspector → Check target membership.

### Build succeeds but app crashes on launch
→ SwiftData model mismatch. Delete app, clean build folder (`⌘⇧K`), reinstall.

### iCloud sync not working
→ Check: 1) CloudKit capability enabled, 2) Signed into iCloud, 3) Wait 30s, 4) Check Console for CloudKit errors.

### API timeout on "Olivenöl" query
→ Increased timeout to 15s. If still fails, error handling auto-enables manual entry.

### Recent food shows wrong calories for different amount
→ Bug fixed. Now recalculates using `caloriesPer100g` formula, not stored value.

## Contact & Support

- **Project Location:** `/Users/hans-jorgjodike/Development/Swift/calo/`
- **Xcode Project:** `Calo/Calo.xcodeproj`
- **Documentation:** See `SETUP.md`, `PROGRESS.md`, `QUICKSTART.md`

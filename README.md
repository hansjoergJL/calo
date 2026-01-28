# calo

> A minimalist calorie and weight tracker for iOS and macOS

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B%20%7C%20macOS%2014%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

**calo** is a cross-platform calorie tracking application built with SwiftUI and SwiftData. It features automatic nutrition lookup from multiple free databases, smart recent food suggestions, and seamless iCloud sync between your iPhone and Mac.

## Features

### Core Functionality
- **Automatic Calorie Lookup** - Search foods in German and English using OpenFoodFacts and USDA databases
- **Recent Foods** - Quick re-entry of previously logged items with automatic calorie recalculation
- **Weight Tracking** - Optional daily weight logging with notes
- **Charts** - Calorie consumption and weight trends with customizable time periods
- **iCloud Sync** - Seamless data synchronization across all your devices
- **Offline Support** - Manual calorie entry when APIs are unavailable

### Smart Features
- **Language Detection** - Automatically routes queries to the best database based on detected language
- **Unit Conversion** - Support for grams, milliliters, pieces, slices, tablespoons, and portions
- **German-First UI** - Native German interface with metric units throughout
- **Daily Summary** - At-a-glance view of total calories and current weight
- **Floating Statistics Window** - Resizable, draggable chart view (macOS)
- **Built-in Help** - Comprehensive feature guide and quick start instructions

### Technical Highlights
- Built with SwiftUI and SwiftData for modern iOS/macOS development
- Actor-based API services for thread-safe network operations
- MVVM architecture with protocol-based dependency injection
- Comprehensive error handling with graceful fallbacks

## Screenshots

*Coming soon*

## Requirements

- **iOS**: 17.0 or later
- **macOS**: 14.0 (Sonoma) or later
- **Xcode**: 15.0 or later
- iCloud account for data synchronization

## Installation

### Clone the Repository
```bash
git clone https://github.com/yourusername/calo.git
cd calo
```

### Open in Xcode
```bash
open Calo/Calo.xcodeproj
```

### Configure iCloud
1. Select the project in Xcode's navigator
2. Choose the "Calo" target
3. Go to "Signing & Capabilities"
4. Click "+ Capability" and add "iCloud"
5. Enable "CloudKit" in the iCloud settings
6. Select your development team

### Optional: USDA API Key
For enhanced international food database access:

1. Sign up for a free API key at https://fdc.nal.usda.gov/api-key-signup.html
2. Create `Config.xcconfig` in the project root:
   ```
   USDA_API_KEY = your_api_key_here
   ```
3. Add `Config.xcconfig` to `.gitignore` (already included)

### Build and Run
1. Select your target device (iPhone or Mac)
2. Press `⌘R` to build and run

## Usage

### Adding Food Entries
1. Tap the **+** button in the main view
2. Enter the amount and select the unit
3. Type the food name (German or English)
4. Tap **"Kalorien berechnen"** to search databases
5. Select from the results or enter calories manually
6. Tap **"Hinzufügen"** to save

### Tracking Weight
1. Tap **"Gewicht hinzufügen"** in the daily summary
2. Enter your weight in kilograms
3. Optionally add notes (e.g., "before breakfast")
4. Tap **"Hinzufügen"** to save

### Using Recent Foods
1. Start typing a food name you've entered before
2. Tap the recent entry when it appears
3. Adjust the amount if needed - calories recalculate automatically

## Architecture

```
calo/
├── Models/           SwiftData models (FoodEntry, WeightEntry)
├── Views/            SwiftUI views
├── Services/         API clients (OpenFoodFacts, USDA)
├── Utilities/        Helper classes (LanguageDetector)
└── Resources/        Assets and configuration
```

The app follows MVVM architecture with clear separation between UI, business logic, and data layers. All network operations use Swift's modern concurrency with actors for thread safety.

## Data Privacy

- All data is stored locally on your device and in your personal iCloud account
- No user data is collected or shared with third parties
- API requests contain only food search terms, no personal information
- Weight data remains completely private within your iCloud storage

## API Sources

- **OpenFoodFacts** - Open-source food database with strong European/German coverage
- **USDA FoodData Central** - U.S. Department of Agriculture nutrition database (optional, requires API key)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Development

### Code Quality
The project uses SwiftLint for code quality enforcement:

```bash
# Install SwiftLint
brew install swiftlint

# Run linting
swiftlint

# Auto-fix issues
swiftlint --fix
```

### Building from Source
```bash
cd Calo
xcodebuild -project Calo.xcodeproj -scheme Calo -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Roadmap

- [ ] Full English localization
- [ ] Barcode scanning for packaged foods
- [ ] Daily calorie goals and tracking
- [x] Weight trend charts
- [x] Calorie consumption charts
- [ ] HealthKit integration
- [ ] iOS widgets
- [ ] Export data to CSV/PDF

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [OpenFoodFacts](https://world.openfoodfacts.org/) - Open food database
- [USDA FoodData Central](https://fdc.nal.usda.gov/) - Nutrition data
- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/) and [SwiftData](https://developer.apple.com/documentation/swiftdata/)

## Contact

For questions or feedback, please open an issue on GitHub.

---

**Note**: This is a personal project focused on simplicity and privacy. It is not intended to provide medical or dietary advice. Always consult with healthcare professionals for nutrition guidance.

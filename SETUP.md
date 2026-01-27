# calo - Xcode Project Setup Instructions

## Step 1: Create Xcode Project

1. **In Xcode (should be open now):**
   - File → New → Project
   - Select **"Multiplatform"** tab at the top
   - Choose **"App"** template
   - Click **Next**

2. **Project Configuration:**
   - **Product Name**: `calo`
   - **Team**: Select your Apple Developer team (or leave as "None" for now)
   - **Organization Identifier**: `com.yourname` (e.g., `com.joedike`)
   - **Bundle Identifier**: Will auto-generate as `com.yourname.calo`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: SwiftData
   - **Include Tests**: ✅ (checked)
   - Click **Next**

3. **Save Location:**
   - Choose: `/Users/hans-jorgjodike/Development/Swift/calo`
   - **Create Git repository**: ✅ (checked)
   - Click **Create**

## Step 2: Enable iCloud Capability

1. **Select the project** in the navigator (top item named "calo")
2. **Select the "calo" target** (iOS app target)
3. Go to **"Signing & Capabilities"** tab
4. Click **"+ Capability"** button
5. Add **"iCloud"**
6. In iCloud settings:
   - Check **"CloudKit"**
   - Container: Use default (`iCloud.com.yourname.calo`)
7. **Repeat for macOS target** (if present)

## Step 3: Replace Default Files

The Xcode template will create some default files. Replace them with our implementation:

### Delete These Default Files:
- `ContentView.swift` (we have a better one)
- `Item.swift` (sample model - not needed)

### Copy Our Files Into Project:

We have already created these files in the `calo/` subdirectory:

```
calo/
├── App/
│   ├── caloApp.swift ✅
│   └── ContentView.swift ✅
├── Models/
│   ├── FoodEntry.swift ✅
│   └── WeightEntry.swift ✅
└── Views/
    ├── DailySummaryView.swift ✅
    ├── FoodRowView.swift ✅
    └── AddFoodView.swift ✅
```

**Action Required:**
1. In Finder, navigate to `/Users/hans-jorgjodike/Development/Swift/calo/calo/`
2. Drag the folders (`App`, `Models`, `Views`) into your Xcode project
3. When prompted:
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to both targets (iOS and macOS)

## Step 4: Configure Build Settings

1. **Select Project** → **Build Settings**
2. Search for **"Swift Language Version"**
   - Ensure it's set to **Swift 5** or later
3. Search for **"iOS Deployment Target"**
   - Set to **iOS 17.0** or later
4. Search for **"macOS Deployment Target"**
   - Set to **macOS 14.0** or later

## Step 5: Add Config File for API Keys

1. Right-click on project root → **New File**
2. Choose **Configuration Settings File**
3. Name it: `Config.xcconfig`
4. Add this content:
```
// API Keys - DO NOT COMMIT TO GIT
USDA_API_KEY = YOUR_KEY_HERE
```

5. **Add to .gitignore:**
```
Config.xcconfig
```

## Step 6: Build and Test

1. **Select Target**: Choose **"calo (iOS)"** or **"calo (Mac)"** from scheme menu
2. **Build**: ⌘B
3. **Run**: ⌘R

### Expected Result:
- App launches successfully
- Shows empty food list with "0 kcal" summary
- Clicking "+" button opens Add Food form
- Can manually enter food and save

## Step 7: Test iCloud Sync (After Basic App Works)

1. Build and run on iPhone (simulator or device)
2. Add a food entry
3. Build and run on Mac
4. Verify the food entry appears (may take a few seconds to sync)

## Troubleshooting

### Build Errors:
- **"Cannot find type 'FoodEntry'"**: Make sure all model files are added to both targets
- **"Module 'SwiftData' not found"**: Check deployment target (iOS 17+, macOS 14+)
- **CloudKit errors**: Sign in to iCloud in Simulator/Device settings

### iCloud Not Syncing:
- Ensure you're signed into the same iCloud account on both devices
- Check iCloud Drive is enabled in System Settings
- Wait up to 30 seconds for initial sync

## Next Steps

Once the basic app compiles and runs:

1. ✅ Test adding food entries manually
2. ✅ Test deletion (swipe left on entries)
3. ⏭️ Implement OpenFoodFacts API service
4. ⏭️ Implement USDA API service
5. ⏭️ Add language detection
6. ⏭️ Implement Recent Foods feature
7. ⏭️ Add Weight tracking
8. ⏭️ Add German/English localization

---

**Current Status**: Basic structure created, ready for Xcode project setup
**Next Task**: Create Xcode project following steps above

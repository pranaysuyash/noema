# noema: Xcode Project Setup Guide

## Version 1.0 | Last Updated: 2025-11-18

This guide will walk you through setting up the Xcode project for noema from the codebase we've created.

---

## Overview

The noema codebase is organized with Swift Package Manager and follows Clean Architecture. All source code is in `noema-ios/Sources/` organized by layers.

**Current Status:**
- ✅ Domain layer complete (entities, protocols, value objects)
- ✅ Data layer complete (Core Data stack, repositories)
- ✅ Presentation layer complete (coordinators, ViewModels, Views)
- ✅ Application layer partially complete (use cases)
- ⚠️ Xcode project file needs to be created
- ⚠️ Info.plist needs configuration
- ⚠️ Entitlements need to be added
- ⚠️ Assets need to be created

---

## Step 1: Create Xcode Project

### Option A: Create from Scratch (Recommended)

1. **Open Xcode 15.2+**
   - Go to File → New → Project
   - Select iOS → App
   - Click Next

2. **Configure Project**
   - Product Name: `noema`
   - Team: Select your Apple Developer Team
   - Organization Identifier: `com.noema` (or your own)
   - Bundle Identifier: `com.noema.app`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None (we're using Core Data manually)
   - ☑ Include Tests
   - Click Next

3. **Save Location**
   - Navigate to `/home/user/noema/noema-ios/`
   - Click Create

4. **Project Structure**
   - Delete the default `ContentView.swift` and `NoemaApp.swift` if created
   - The project will use our existing source files

### Option B: Import Existing Source

1. **Add Source Groups**
   - Right-click project root → Add Files to "noema"
   - Navigate to `noema-ios/Sources/`
   - Select all folders: `Domain/`, `Data/`, `Presentation/`, `Application/`, `App/`
   - ☑ Create groups
   - ☑ Add to target: noema
   - Click Add

2. **Verify Structure**
   Your project navigator should show:
   ```
   noema/
   ├── App/
   │   └── NoemaApp.swift
   ├── Domain/
   │   ├── Entities/
   │   ├── ValueObjects/
   │   └── RepositoryProtocols/
   ├── Data/
   │   ├── CoreData/
   │   └── Repositories/
   ├── Application/
   │   └── UseCases/
   ├── Presentation/
   │   ├── Coordinators/
   │   ├── ViewModels/
   │   └── Views/
   └── Resources/
       ├── Assets.xcassets
       ├── Localizable.strings
       └── Info.plist
   ```

---

## Step 2: Configure Target Settings

### General Tab

1. **Identity**
   - Display Name: `noema`
   - Bundle Identifier: `com.noema.app`
   - Version: `1.0`
   - Build: `1`

2. **Deployment Info**
   - Minimum Deployments: iOS 17.0
   - Device: iPhone
   - ☑ Portrait
   - ☑ Landscape Left
   - ☑ Landscape Right
   - ☐ Upside Down

3. **Frameworks, Libraries, and Embedded Content**
   - No external frameworks needed (using SPM in code)

### Signing & Capabilities

1. **Signing**
   - ☑ Automatically manage signing
   - Team: Select your Apple Developer Team
   - Signing Certificate: Development/Distribution

2. **Add Capabilities**
   Click "+ Capability" and add:

   **a. iCloud**
   - ☑ CloudKit
   - ☑ Key-value storage
   - Containers: `iCloud.com.noema.app`

   **b. Push Notifications**
   - Automatically configured

   **c. Background Modes**
   - ☑ Remote notifications
   - ☑ Background fetch
   - ☑ Background processing

   **d. Sign in with Apple**
   - Automatically configured

   **e. App Groups** (for widget/watch extension later)
   - `group.com.noema.app`

### Build Settings

1. **Search for "Swift Language Version"**
   - Set to: Swift 6

2. **Search for "Swift Concurrency"**
   - ☑ Enable Actor Data-Race Safety Checks

3. **Search for "Optimization Level"**
   - Debug: -Onone
   - Release: -O

4. **Search for "User Script Sandboxing"**
   - Set to: No

---

## Step 3: Create Info.plist

Create `/home/user/noema/noema-ios/Resources/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Information -->
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>noema</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>$(MARKETING_VERSION)</string>
    <key>CFBundleVersion</key>
    <string>$(CURRENT_PROJECT_VERSION)</string>

    <!-- Privacy Permissions -->
    <key>NSMicrophoneUsageDescription</key>
    <string>noema needs access to your microphone to record voice notes</string>
    <key>NSUserTrackingUsageDescription</key>
    <string>We use tracking data to provide personalized insights and improve your experience</string>
    <key>NSCameraUsageDescription</key>
    <string>noema needs access to your camera to capture photos for notes</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>noema needs access to your photo library to save images with notes</string>

    <!-- App Transport Security -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>

    <!-- Supported Interface Orientations -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

    <!-- Scene Configuration -->
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <true/>
        <key>UISceneConfigurations</key>
        <dict/>
    </dict>

    <!-- Required Device Capabilities -->
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
        <string>metal</string>
    </array>

    <!-- Status Bar Style -->
    <key>UIStatusBarStyle</key>
    <string>UIStatusBarStyleDefault</string>
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <true/>

    <!-- Launch Screen -->
    <key>UILaunchScreen</key>
    <dict>
        <key>UIImageName</key>
        <string>LaunchImage</string>
        <key>UIColorName</key>
        <string>LaunchColor</string>
    </dict>

    <!-- Core ML -->
    <key>NSCoreMLUsageDescription</key>
    <string>noema uses on-device AI to analyze your mood and provide insights</string>
</dict>
</plist>
```

**Set Info.plist in Build Settings:**
- Select project → Target → Build Settings
- Search for "Info.plist"
- Set path to: `Resources/Info.plist`

---

## Step 4: Create Asset Catalog

Create `/home/user/noema/noema-ios/Resources/Assets.xcassets`:

### App Icon

1. **Create Icon Set**
   - Open Assets.xcassets
   - Right-click → App Icons & Launch Images → New iOS App Icon
   - Name it `AppIcon`

2. **Required Sizes**
   You need to create app icons in these sizes:
   - 20x20 @2x, @3x
   - 29x29 @2x, @3x
   - 40x40 @2x, @3x
   - 60x60 @2x, @3x
   - 1024x1024 (App Store)

3. **Design Requirements**
   - Square with no transparency
   - Rounded corners applied by iOS
   - No text or words
   - Professional and clean

### Color Assets

Add these color sets:

```
AccentColor
├── Any Appearance: #007AFF
└── Dark Appearance: #0A84FF

LaunchColor
├── Any Appearance: #FFFFFF
└── Dark Appearance: #000000

PrimaryBackground
├── Any Appearance: #FFFFFF
└── Dark Appearance: #000000

SecondaryBackground
├── Any Appearance: #F2F2F7
└── Dark Appearance: #1C1C1E
```

---

## Step 5: Create Entitlements File

Create `/home/user/noema/noema-ios/Resources/noema.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- iCloud -->
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.noema.app</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>com.apple.developer.ubiquity-kvstore-identifier</key>
    <string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>

    <!-- Push Notifications -->
    <key>aps-environment</key>
    <string>development</string>

    <!-- App Groups -->
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.noema.app</string>
    </array>

    <!-- Sign in with Apple -->
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>

    <!-- Data Protection -->
    <key>com.apple.developer.default-data-protection</key>
    <string>NSFileProtectionComplete</string>
</dict>
</plist>
```

**Link Entitlements:**
- Target → Build Settings
- Search for "Code Signing Entitlements"
- Set to: `Resources/noema.entitlements`

---

## Step 6: Configure Core Data

Since we created Core Data programmatically, no `.xcdatamodeld` file is needed. But verify:

1. **CoreDataStack.swift** exists in `Data/CoreData/`
2. **All entity definitions** are programmatic
3. **CloudKit sync** is configured in CoreDataStack

---

## Step 7: Build and Run

1. **Select Simulator or Device**
   - Choose iPhone 15 Pro or newer
   - Or your physical device

2. **Build (⌘B)**
   - Resolve any import errors
   - Fix any compilation issues

3. **Run (⌘R)**
   - App should launch
   - Onboarding should appear for first launch

---

## Common Build Issues

### Issue: "Cannot find 'CoreDataStack' in scope"
**Solution:** Ensure all source files are added to the target

### Issue: "Ambiguous use of 'Note'"
**Solution:** Check for naming conflicts with Apple frameworks

### Issue: "No such module 'Combine'"
**Solution:** Add `import Combine` where needed

### Issue: "CloudKit container not found"
**Solution:**
1. Enable iCloud capability
2. Create CloudKit container in Apple Developer Portal
3. Add container ID to entitlements

---

## Next Steps

After successful build:

1. ✅ Test onboarding flow
2. ✅ Test note creation
3. ✅ Test mood logging
4. ✅ Verify Core Data persistence
5. ✅ Test CloudKit sync (requires physical device)
6. → Follow APP_STORE_SUBMISSION.md for release process

---

## Resources

- [Xcode Documentation](https://developer.apple.com/documentation/xcode)
- [Swift Package Manager](https://swift.org/package-manager/)
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)
- [CloudKit Quick Start](https://developer.apple.com/icloud/cloudkit/)

---

**Document Control:**
- Version: 1.0
- Last Updated: 2025-11-18
- Next Review: After first build
- Owner: Technical Lead


# Deployment Guide

This guide covers deploying Noema to the App Store.

## Prerequisites

- Xcode 15.0 or later
- Apple Developer Account ($99/year)
- macOS Sonoma or later
- Code signing certificates configured

## Pre-Deployment Checklist

### 1. Code Quality
- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Code reviewed and approved
- [ ] CHANGELOG.md updated
- [ ] Version number incremented

### 2. App Store Assets
- [ ] App icon (1024x1024)
- [ ] Screenshots for all device sizes
- [ ] App preview videos (optional but recommended)
- [ ] App Store description
- [ ] Keywords for SEO
- [ ] Privacy policy URL
- [ ] Support URL

### 3. Privacy & Compliance
- [ ] Privacy policy reviewed
- [ ] Info.plist usage descriptions complete
- [ ] GDPR compliance verified
- [ ] Data handling documented

### 4. Performance
- [ ] App size optimized (<150MB ideal)
- [ ] Launch time <2 seconds
- [ ] No memory leaks
- [ ] Battery usage acceptable

## Build Configuration

### 1. Update Version & Build Number

```bash
# Increment version (e.g., 1.0.0 -> 1.0.1)
agvtool new-marketing-version 1.0.1

# Increment build number
agvtool next-version -all
```

### 2. Configure Build Settings

**Release Configuration:**
- Build Configuration: Release
- Code Optimization: Fastest, Smallest [-Os]
- Strip Debug Symbols: Yes
- Enable Bitcode: No (deprecated)
- Dead Code Stripping: Yes

### 3. Configure Signing

1. Open Xcode project
2. Select target → Signing & Capabilities
3. Enable "Automatically manage signing"
4. Select your team
5. Or manually configure provisioning profiles

## TestFlight Deployment

### 1. Create Archive

```bash
# Clean build folder
xcodebuild clean -scheme Noema -configuration Release

# Create archive
xcodebuild archive \
  -scheme Noema \
  -configuration Release \
  -archivePath "./build/Noema.xcarchive"
```

### 2. Export for App Store

```bash
xcodebuild -exportArchive \
  -archivePath "./build/Noema.xcarchive" \
  -exportPath "./build/" \
  -exportOptionsPlist ExportOptions.plist
```

**ExportOptions.plist:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
</dict>
</plist>
```

### 3. Upload to App Store Connect

```bash
xcrun altool --upload-app \
  --type ios \
  --file "./build/Noema.ipa" \
  --username "your@email.com" \
  --password "@keychain:AC_PASSWORD"
```

Or use Xcode:
1. Window → Organizer
2. Select archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Follow prompts

### 4. Submit for TestFlight

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to TestFlight tab
3. Add internal/external testers
4. Submit for beta review (external testers only)

## App Store Submission

### 1. Prepare App Store Listing

**Required Information:**
- App name (30 characters max)
- Subtitle (30 characters max)
- Description (4000 characters max)
- Keywords (100 characters max)
- Support URL
- Marketing URL (optional)
- Privacy Policy URL

**Screenshots Required:**
- iPhone 6.7" (iPhone 14 Pro Max)
- iPhone 6.5" (iPhone 11 Pro Max)
- iPhone 5.5" (iPhone 8 Plus)
- iPad Pro 12.9" (3rd gen)
- iPad Pro 12.9" (2nd gen)

### 2. Configure App Store Connect

1. **App Information:**
   - Privacy Policy URL
   - Category: Health & Fitness / Lifestyle
   - Content Rights: Own or licensed
   - Age Rating: 4+

2. **Pricing & Availability:**
   - Price tier (Free with IAP)
   - Available territories
   - Pre-order (optional)

3. **App Privacy:**
   - Data collection practices
   - Data usage
   - Data linking
   - Tracking (not applicable for Noema)

### 3. Submit for Review

1. Select build from TestFlight
2. Fill in "What's New" section
3. Add screenshots
4. Submit for review

**Review Process:**
- Initial review: 24-48 hours
- Appeals: 1-2 days
- Expedited review: Request if urgent

### 4. App Review Tips

**Common Rejection Reasons:**
- Crashes on launch
- Broken features
- Privacy violations
- Misleading descriptions
- Incomplete functionality

**Best Practices:**
- Test on real devices
- Provide demo account if needed
- Include detailed notes for reviewer
- Respond quickly to rejections

## Post-Launch

### 1. Monitor Metrics

**App Analytics:**
- Downloads
- Active users
- Retention rate
- Crash reports
- Reviews & ratings

**Performance:**
- Crash-free rate >99.5%
- Launch time
- Memory usage
- Battery impact

### 2. Crash Reporting

Configure crash reporting:
```swift
// In AppDelegate or NoemaApp
import FirebaseCrashlytics // or preferred service

func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    // Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
}
```

### 3. Update Cycle

**Cadence:**
- Bug fixes: As needed (1-2 weeks)
- Minor updates: Monthly
- Major updates: Quarterly

**Update Checklist:**
- [ ] Test on latest iOS version
- [ ] Update CHANGELOG.md
- [ ] Increment version number
- [ ] Create release notes
- [ ] Submit to TestFlight
- [ ] Beta test for 1 week
- [ ] Submit to App Store

## CI/CD with GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to TestFlight

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.0'

      - name: Build Archive
        run: |
          xcodebuild archive \
            -scheme Noema \
            -configuration Release \
            -archivePath build/Noema.xcarchive

      - name: Export IPA
        run: |
          xcodebuild -exportArchive \
            -archivePath build/Noema.xcarchive \
            -exportPath build \
            -exportOptionsPlist ExportOptions.plist

      - name: Upload to TestFlight
        env:
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APP_PASSWORD: ${{ secrets.APP_PASSWORD }}
        run: |
          xcrun altool --upload-app \
            --type ios \
            --file build/Noema.ipa \
            --username "$APPLE_ID" \
            --password "$APP_PASSWORD"
```

## Troubleshooting

### Build Failures

**Code Signing Issues:**
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset provisioning profiles
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles
```

**Archive Issues:**
- Ensure scheme is shared
- Check build settings
- Verify deployment target

### App Store Rejections

**Common Fixes:**
- Add missing privacy strings
- Fix crashes in core functionality
- Update screenshots to match current UI
- Clarify app description

## Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [TestFlight Beta Testing](https://developer.apple.com/testflight/)

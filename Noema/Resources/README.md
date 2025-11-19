# Noema Resources

This directory contains all app resources including assets, localization files, and launch screens.

## Directory Structure

```
Resources/
├── Assets.xcassets/          # Asset catalog
│   ├── AppIcon.appiconset/   # App icons
│   └── Colors/               # Color assets
├── Localization/             # Localization files
│   └── en.lproj/             # English localization
└── LaunchScreen/             # Launch screen storyboard
```

## Assets.xcassets

Contains all image and color assets for the app:

- **AppIcon.appiconset**: App icons for all device sizes
- **Colors**: Custom color assets (NoemaPrimary, NoemaSecondary, etc.)

### Creating App Icons

To generate app icons:

1. Create a 1024x1024px master icon
2. Use an icon generator tool or Xcode's asset catalog
3. Export all required sizes

**Required Sizes:**
- iPhone: 20pt, 29pt, 40pt, 60pt (@2x and @3x)
- App Store: 1024pt (@1x)

## Localization

The app currently supports:
- **English (en)**: Base language

### Adding New Languages

1. Create new `.lproj` directory (e.g., `es.lproj` for Spanish)
2. Copy `en.lproj/Localizable.strings`
3. Translate all strings
4. Add language to Xcode project settings

Example for Spanish:
```bash
mkdir -p Localization/es.lproj
cp Localization/en.lproj/Localizable.strings Localization/es.lproj/
# Edit and translate
```

### Localization Keys

All localization keys follow a hierarchical naming convention:

```
<feature>.<screen>.<element>
```

Examples:
- `notes.title` - Notes feature title
- `mood.empty` - Empty state message for mood
- `error.network` - Network error message

## Launch Screen

The launch screen (`LaunchScreen.storyboard`) displays:
- App icon (centered)
- App name
- Tagline: "Your Emotional Intelligence Companion"

### Customizing Launch Screen

To customize:
1. Open `LaunchScreen.storyboard` in Xcode
2. Modify labels, images, or colors
3. Keep it simple (no animations or complex layouts)
4. Test on different device sizes

## Asset Guidelines

### App Icon
- Size: 1024x1024px
- Format: PNG (no transparency)
- Safe area: Keep important elements within 88% of canvas
- Colors: Use brand colors, high contrast

### Color Assets
- Use semantic names (e.g., "NoemaPrimary" not "Blue")
- Support both light and dark modes
- Maintain WCAG AA contrast ratio (4.5:1)

### Images
- Use vector PDFs when possible
- Provide @1x, @2x, @3x for raster images
- Optimize file sizes
- Use asset compression

## Best Practices

1. **Localization**
   - Always use localized strings (never hard-code)
   - Keep strings short and contextual
   - Avoid concatenation (different grammar rules)

2. **Assets**
   - Use asset catalogs (not file references)
   - Name assets descriptively
   - Organize with folders/groups

3. **Colors**
   - Define colors in asset catalog
   - Use semantic naming
   - Support dark mode

4. **Performance**
   - Compress large images
   - Use appropriate formats (PNG for transparency, JPEG for photos)
   - Lazy-load large assets

## Tool Recommendations

- **Icon Generator**: [App Icon Generator](https://appicon.co)
- **Image Optimization**: [TinyPNG](https://tinypng.com)
- **Localization**: Xcode's built-in localization tools
- **Color Picker**: Xcode's color picker with hex support

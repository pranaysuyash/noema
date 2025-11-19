# Xcode Configuration Files

This directory contains Xcode configuration files (.xcconfig) for managing build settings.

## Files

- **Debug.xcconfig** - Debug build configuration
- **Release.xcconfig** - Release/production build configuration

## Usage

These .xcconfig files should be assigned to their respective build configurations in Xcode:

1. Open Noema.xcodeproj
2. Select project → Info tab
3. Under "Configurations", assign:
   - Debug → Debug.xcconfig
   - Release → Release.xcconfig

## Key Settings

### Debug Configuration
- Optimization: None (`-Onone`)
- Debug symbols: Included
- Testability: Enabled
- Only active arch: Yes (faster builds)

### Release Configuration
- Optimization: Size (`-Os`)
- Debug symbols: dSYM (for crash reports)
- Dead code stripping: Enabled
- Whole module compilation: Enabled

## Customization

To override settings for specific targets, create target-specific .xcconfig files:

```
Noema-Debug.xcconfig
Noema-Release.xcconfig
NoemaTests-Debug.xcconfig
```

## Best Practices

1. **Never commit secrets** to .xcconfig files
2. Use `#include` to share common settings
3. Document all custom build settings
4. Keep configuration DRY (Don't Repeat Yourself)

## Environment Variables

You can use these in .xcconfig files:

```
// Example: Custom flag based on configuration
MY_CUSTOM_FLAG = $(inherited) -DMY_FLAG=1
```

## Troubleshooting

### Build fails after adding .xcconfig
- Ensure file is added to project (not just file system)
- Check for syntax errors (no trailing spaces)
- Verify configuration assignment in project settings

### Settings not taking effect
- Clean build folder (Cmd+Shift+K)
- Check configuration is selected correctly
- Verify setting isn't overridden at target level

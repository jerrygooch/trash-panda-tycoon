# Porting to Android and iOS

## Android (Can Be Done from Windows)

### Prerequisites
- Godot 4.7 standard (already in use)
- **Android Studio** (includes SDK Manager, AVD emulator, command-line tools)
- Android SDK (API 34–36) + NDK (installed via Android Studio SDK Manager)
- Android export template for Godot 4.7 (`hermes tools` or Godot → Editor Settings → Export → Android → Install Templates)
- Java/JDK 17+ (bundled with Android Studio or standalone)

### Setup Steps

1. **Install Android Studio**
   - Download from https://developer.android.com/studio
   - During installation, ensure SDK components are selected
   - Note the SDK path (default: `C:\Users\<you>\AppData\Local\Android\Sdk`)

2. **Configure Godot**
   - Open Godot → Editor → Editor Settings → Export → Android
   - Set the Android SDK path to your SDK location
   - Set the Android NDK path (bundled with SDK via SDK Manager)
   - Godot will auto-detect the JDK from Android Studio
   - Install Android export templates if prompted

3. **Verify the export preset**
   - The project includes `export_presets.cfg` with an "Android Debug" preset
   - Package name: `com.jerrygooch.trashpandatycoon`
   - Min SDK: 23 (Android 6.0), Target SDK: 36 (Android 16)
   - Architecture: arm64-v8a only (no x86/x86_64 for smaller APK)
   - No signing keystore is configured — Android Studio generates a debug keystore automatically
   - **Do not add release keystore credentials to `export_presets.cfg`**

### Building a Debug APK

```bash
# Method 1: Godot Editor
# Project → Export → Android Debug → Export Project
# Save as .apk or .aab

# Method 2: Command line (Godot headless)
godot --headless --export-debug "Android Debug" builds/trash-panda-tycoon-debug.apk
```

### Installing on a Device
- Enable Developer Options and USB Debugging on the Android device
- Connect via USB or use ADB wireless debugging
- Run: `adb install builds/trash-panda-tycoon-debug.apk`

### Android-Specific Notes for This Project

- **Touch input**: `TrashItem.gd` handles both `InputEventMouse*` and `InputEventScreenTouch/Drag`
- **Safe areas**: Stretch mode is `canvas_items` with `expand` aspect — works on most screen ratios
- **Orientation**: Portrait locked (`window/handheld/orientation=1` in project.godot)
- **Debug overlay**: Tap the "DBG" button in the HUD to show FPS, item count, spawn rate, and input mode
- **No real plugins**: No Google Play Services, no ad SDKs, no IAP SDKs are included

### Current Android Limitations
- Touch input is structurally ready but untested on real hardware
- No safe-area/notch/punch-hole handling
- No performance profiling on mobile hardware
- No real ad or IAP SDK
- Placeholder art only — no texture-optimized assets
- No controller or keyboard support for mobile

### Signing for Release
1. Generate a release keystore: `keytool -genkey -v -keystore release.keystore -alias trashpanda -keyalg RSA -keysize 2048 -validity 10000`
2. Add to export preset: Project → Export → Android → Keystore → Release → point to `release.keystore`
3. **Never commit** the keystore file or its passwords — they are ignored by `.gitignore` (`*.keystore`, `*.jks`)

## iOS (Requires macOS)

### Prerequisites
- A Mac (real hardware or Mac VM)
- Xcode (latest stable, from Mac App Store)
- Apple Developer Program membership ($99/year)
- iOS export template for Godot 4.7

### Steps
1. On the Mac:
   - Install Xcode
   - Install Godot 4.7 on the Mac
   - Install iOS export templates
   - Open the project on the Mac
2. Set up signing:
   - Apple Developer account
   - App ID / Bundle Identifier
   - Signing certificate
   - Provisioning profile
3. Create an iOS export preset:
   - Project → Export → Add → iOS
   - Set bundle identifier, app store icon, etc.
4. Export Xcode project:
   - Export → Export iOS → generates an .xcodeproj
5. Open in Xcode, configure signing, build to device or TestFlight

### What the MVP Does NOT Do for iOS
- No StoreKit integration
- No iOS-specific ad SDK
- No iOS push notifications
- No Game Center
- No iOS file system considerations
- No notch/dynamic island safe area handling

## Platform-Agnostic Architecture

The project is structured so gameplay code never calls platform SDKs directly:

- `PlatformService` (autoload) is the single entry point
- Gameplay scripts call `PlatformService.show_rewarded_ad()`, etc.
- When real SDKs are added, only the platform/ folder changes
- All game logic stays platform-agnostic

## No iOS/Mac Work Should Be Attempted in This MVP

- The project is Windows-first
- Android export is the next step (Windows-compatible)
- iOS requires a separate machine and Apple Developer account
- Do not add iOS-specific code, entitlements, or Xcode projects to this MVP

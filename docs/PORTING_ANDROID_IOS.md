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

## Android-Specific Notes for This Project

### Export Readiness Report (Batch 007 — July 2026)

**Status: BLOCKED — Android SDK not installed**

| Component | Required | Found | Action |
|-----------|----------|-------|--------|
| Java/JDK 17+ | Yes | ✅ `/mnt/c/Program Files/Eclipse Adoptium/jdk-17.0.19.10-hotspot/` | — |
| Android Studio / SDK | Yes | ❌ Not installed | Install from developer.android.com/studio |
| Godot Android export templates | Yes | ❌ Not installed | Install via Godot → Editor Settings → Export → Android |
| ANDROID_HOME env var | Yes | ❌ Not set | Set to SDK path after install |
| ADB | Yes | ❌ Not installed | Comes with Android SDK |
| keytool | Yes | ❌ Not found (JDK not in PATH) | Add JDK bin/ to PATH |
| Gradle (bundled with Godot) | Bundled | — | Handled by Godot export process |

**To enable Android export:**

1. Install Android Studio from https://developer.android.com/studio
2. Open SDK Manager → install Android SDK 34–36 + NDK
3. Note SDK path (default: `C:\Users\<you>\AppData\Local\Android\Sdk`)
4. Set env vars (or configure in Godot Editor):
   ```bash
   export ANDROID_HOME="/mnt/c/Users/<you>/AppData/Local/Android/Sdk"
   export PATH="$ANDROID_HOME/platform-tools:$PATH"
   ```
5. In Godot: Editor → Editor Settings → Export → Android → point to SDK path
6. Install Android export templates when prompted
7. Export APK:
   ```bash
   godot --headless --export-debug "Android Debug" exports/trash-panda-tycoon-debug.apk
   ```

### First-Device Playtest Checklist

- **Touch input**: `TrashItem.gd` handles both `InputEventMouse*` and `InputEventScreenTouch/Drag`
- **Safe areas**: Stretch mode is `canvas_items` with `expand` aspect — works on most screen ratios
- **Orientation**: Portrait locked (`window/handheld/orientation=1` in project.godot)
- **Debug overlay**: Tap the "DBG" button in the HUD to show FPS, item count, spawn rate, and input mode
- **No real plugins**: No Google Play Services, no ad SDKs, no IAP SDKs are included

### First-Device Playtest Checklist

- [ ] Touch drag works on real device
- [ ] Items snap back correctly on missed drop
- [ ] Bins are large enough for finger taps
- [ ] No UI elements clipped by notch/punch-hole
- [ ] Debug overlay toggles via DBG button
- [ ] FPS stays above 30 during gameplay
- [ ] Save/load works after app restart
- [ ] Daily reward resets correctly (local calendar)
- [ ] Mission progress persists
- [ ] Settings (sound toggle) saved and restored

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

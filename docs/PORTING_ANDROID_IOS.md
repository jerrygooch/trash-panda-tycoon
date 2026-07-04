# Porting to Android and iOS

## Android (Can Be Done from Windows)

### Prerequisites
- Godot 4.7 standard (already in use)
- Java/JDK (version 17 recommended)
- Android SDK + NDK
- Android export template for Godot 4.7

### Steps
1. Install Android SDK (Android Studio or command-line tools)
2. Install Android export templates in Godot:
   - Editor → Editor Settings → Export → Android
   - Point to Android SDK path
   - Install the Android platform
3. Create an Android export preset:
   - Project → Export → Add → Android
   - Set package name (e.g., `com.tigerninjachan.trashpandatycoon`)
   - Configure minimum SDK, target SDK
   - Sign with a debug keystore for testing
4. Build an APK:
   - Export → Export Android → Export Project
   - Transfer to Android device or use ADB install
5. Before release:
   - Set up a release keystore
   - Set version code and number
   - Configure Google Play Console listing

### MVP Limitations for Android
- No touch input tuning yet (mouse drag structure should work with touch)
- No real ad SDK (stub returns success)
- No real IAP (stub logs only)
- No screen size adaptation testing yet
- No performance profiling for mobile hardware

## iOS (Requires macOS)

### Prerequisites
- A Mac (real hardware or Mac VM — no Hackintosh for Xcode)
- Xcode (latest stable)
- Apple Developer Program membership ($99/year)
- iOS export template for Godot 4.7

### Steps
1. On the Mac:
   - Install Xcode from Mac App Store
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

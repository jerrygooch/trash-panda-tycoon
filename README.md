# Trash Panda Tycoon

A stupid, addictive mobile sorting/merge/idle game. Play as a raccoon running a trash empire — sort items into bins, earn coins, and upgrade your operation.

## How to Open the Project

1. Open Godot 4.7 (standard, not Mono)
2. Click "Import" or "Open Project"
3. Navigate to `trash-panda-tycoon/`
4. Select `project.godot`
5. Click "Open"

## How to Run on Windows

- Open the project in Godot (as above)
- Click the Play button (triangle) in the top-right toolbar
- The game launches at 720x1280 portrait resolution

No build/export is required for development testing.

## How to Test the MVP Loop

1. Click **New Game** on the title screen
2. Trash items spawn on the conveyor belt
3. **Drag** items with the mouse into one of three bins at the bottom:
   - Food (🍲) — accepts Banana Peel, Pizza Slice
   - Metal (⚙) — accepts Soda Can, Tin Can
   - Plastic (📦) — accepts Plastic Bottle, Plastic Bag
4. Correct sort → coins increase with green feedback
5. Wrong sort or item missed → mess meter increases
6. Mess meter full or 30-second timer expires → round ends
7. Results screen shows your stats
8. Click **Next Round** to continue
9. Click **Upgrade** to spend coins on permanent upgrades
10. Click **Watch Ad x2** to double your round earnings (stubbed)

## What Is Stubbed

- **Rewarded ads** — returns success after a tiny fake delay (no real SDK)
- **Interstitial ads** — logs to console only
- **IAP** — logs to console, flags stored in memory
- **Offline Earnings** upgrade — saved but has no runtime effect yet
- **Art** — placeholder ColorRect/emoji graphics only
- **Audio** — no sounds or music

## What Should Be Done Before Android Export

1. Add Android export preset in Godot
2. Install Android SDK / JDK
3. Add real ad SDK integration (AdMob, Unity Ads, AppLovin)
4. Add real IAP (Google Play Billing)
5. Replace placeholder art with real assets
6. Add audio
7. Tweak touch input sensitivity
8. Test on a physical Android device

## What Must Wait Until iOS/Mac/Apple Developer Account

- iOS export preset requires macOS + Xcode
- Apple Developer Program membership ($99/year) for distribution
- StoreKit integration for iOS IAP
- Any iOS-specific ad SDK integration
- Notarization / TestFlight setup

## What's New in Batch 002

### Gameplay Feel Improvements
- **Combo/Streak mechanic** — consecutive correct sorts build a combo counter. Every 5-combo milestone gives a bonus. Combo resets on wrong/miss. HUD shows "x2+" when active.
- **Sorting feedback juice** — floating coin text, item pop/scale on removal, green bin flash on correct, red bin flash + screen shake on wrong, mess meter pulse.
- **Conveyor animation** — scrolling stripes with lane markers create the illusion of a moving belt.
- **Spawn rate tuning** — base interval 1.8s (was 2.0s), minimum 0.5s (was 0.4s), gentler curve.
- **Rewarded ad one-claim** — Watch Ad x2 can only be used once per round. Button changes to "Reward Claimed" permanently.
- **Pause/restart** — pause button in the HUD opens a menu with Resume, Restart Round, and Main Menu.
- **Offline earnings** — saves timestamp, calculates coins based on Offline Earnings upgrade level (up to 2h cap).
- **Debug overlay** — tap "DBG" in HUD to show FPS, item count, spawn rate, input mode
- **Touch input** — structurally ready for mobile (mouse + touch events handled)
- **Max item cap** — 30 items max to prevent performance issues
- **Sound placeholders** — procedural sine wave beeps for correct/wrong/coin events
- **Drag reliability** — bin drop zones expanded by 15px on each side for forgiveness

## Known Limitations

### Batch 003 — Android Export Status
- **Android export preset** scaffolded (`export_presets.cfg`) — debug mode, no signing secrets
- **Not tested on real Android hardware** — SDK setup and USB/ADB install required
- **No safe-area/notch handling** — canvas_items stretch works but not notch-optimized
- **No performance profiling** on mobile hardware
- **No real ads or IAP SDKs** — Google Play Billing omitted intentionally
- **Placeholder art only**
- **No audio on Android** — procedural sounds work but untested

### What Must Wait Until iOS/Mac/Apple Developer Account

- iOS export preset requires macOS + Xcode
- Apple Developer Program membership ($99/year) for distribution
- StoreKit integration for iOS IAP
- Any iOS-specific ad SDK integration
- Notarization / TestFlight setup

## Tech Stack

- **Engine:** Godot 4.7 (standard, no Mono/C#)
- **Language:** Typed GDScript only
- **Resolution:** 720x1280 portrait (9:16)
- **Input:** Mouse drag (touch-compatible structure)
- **Save:** Local JSON file
- **Monetization:** Fake stubs — no real SDKs

## Project Structure

```
trash-panda-tycoon/
├── Main.tscn                  # Entry point scene
├── project.godot              # Godot project config
├── .gitignore
├── README.md
├── data/
│   ├── trash_items.json       # Data-driven trash item definitions
│   ├── upgrades.json          # Upgrade definitions
│   └── bins.json              # Bin definitions
├── scripts/
│   ├── main.gd                # Scene switcher
│   ├── game_state.gd          # Autoload — persistent game state
│   ├── save_system.gd         # Autoload — JSON save/load
│   ├── game/
│   │   ├── game_manager.gd    # Round controller
│   │   ├── trash_item.gd      # Draggable trash object
│   │   ├── conveyor.gd        # Conveyor belt visual
│   │   └── bin.gd             # Drop target bin
│   ├── ui/
│   │   ├── main_menu.gd       # Title screen
│   │   ├── hud.gd             # In-game HUD
│   │   ├── results_screen.gd  # Round results
│   │   └── upgrade_screen.gd  # Upgrade shop
│   └── platform/
│       ├── platform_service.gd  # Platform abstraction
│       ├── fake_ads_service.gd  # Stub ads
│       └── fake_iap_service.gd  # Stub IAP
├── scenes/
│   ├── ui/
│   │   ├── MainMenu.tscn
│   │   ├── Hud.tscn
│   │   ├── ResultsScreen.tscn
│   │   └── UpgradeScreen.tscn
│   └── game/
│       ├── Game.tscn
│       ├── Conveyor.tscn
│       ├── TrashItem.tscn
│       └── Bin.tscn
├── art/
│   ├── placeholders/          # Placeholder assets
│   ├── generated/             # AI-generated assets (optional)
│   └── ... (future)
├── audio/                     # Sound effects / music (future)
└── docs/
    ├── GAME_DESIGN.md
    ├── PORTING_ANDROID_IOS.md
    ├── MONETIZATION_STUBS.md
    ├── ASSET_PIPELINE.md
    ├── NEXT_STEPS.md
    └── PLAYTEST_CHECKLIST.md
```

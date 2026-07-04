# Trash Panda Tycoon — Kanban Board

Use these issues to track the MVP and post-MVP work on GitHub.

## Column: Backlog

### Epic: Core MVP (playable build)

### Issue 1: Project scaffold
- [ ] Create project.godot with 720x1280 portrait config
- [ ] Create folder structure (scenes/, scripts/, data/, art/, docs/)
- [ ] Create autoload scripts (GameState, SaveSystem, PlatformService)
- [ ] Create data JSON files (trash_items, upgrades, bins)
- [ ] Create Main.tscn entry point
- **Labels:** scaffold, mvp
- **Priority:** P0

### Issue 2: Core gameplay loop
- [ ] Implement conveyor spawning
- [ ] Implement draggable TrashItem behavior
- [ ] Implement Bin detection with category matching
- [ ] Implement correct/wrong sort feedback
- [ ] Implement missed item detection
- [ ] Implement 30-second round timer
- [ ] Implement mess meter with early round-end
- [ ] Implement results calculation
- **Labels:** gameplay, mvp
- **Priority:** P0

### Issue 3: Economy and upgrades
- [ ] Implement coin tracking (round + total)
- [ ] Implement 4 upgrades (Trash Value, Spawn Rate, Mess Capacity, Offline Earnings)
- [ ] Implement upgrade cost scaling
- [ ] Implement upgrade effects on gameplay
- [ ] Implement upgrade screen UI
- **Labels:** economy, mvp
- **Priority:** P0

### Issue 4: Save/load system
- [ ] Implement JSON save to user://
- [ ] Save coins, upgrades, best score, flags
- [ ] Load on Continue
- [ ] Reset Save with confirmation
- **Labels:** save, mvp
- **Priority:** P0

### Issue 5: Fake monetization stubs
- [ ] Create PlatformService abstraction
- [ ] Create FakeAdsService (rewarded + interstitial)
- [ ] Create FakeIAPService (purchase + ownership)
- [ ] Wire Watch Ad x2 to double earnings
- **Labels:** monetization, mvp
- **Priority:** P0

### Issue 6: UI layout and HUD
- [ ] Portrait-first 720x1280 layout
- [ ] HUD with coins, timer, mess meter, round number
- [ ] Large touch-friendly buttons
- [ ] Safe margins for mobile future
- [ ] Results screen with stats
- **Labels:** ui, mvp
- **Priority:** P0

### Issue 7: Start/menu screens
- [ ] Title screen with Trash Panda Tycoon branding
- [ ] New Game button
- [ ] Continue button (enabled when save exists)
- [ ] Reset Save with confirmation prompt
- **Labels:** ui, mvp
- **Priority:** P0

### Issue 8: Documentation
- [ ] README.md with how to run and test
- [ ] GAME_DESIGN.md
- [ ] PORTING_ANDROID_IOS.md
- [ ] MONETIZATION_STUBS.md
- [ ] ASSET_PIPELINE.md
- [ ] NEXT_STEPS.md
- [ ] PLAYTEST_CHECKLIST.md
- **Labels:** docs, mvp
- **Priority:** P0

## Column: In Progress

(none — MVP scaffold complete)

## Column: Done

All MVP issues above are implemented in `main`.

## Column: Post-MVP

### Issue 9: Tune gameplay feel
- [ ] Adjust spawn rate curve (start slow, ramp up)
- [ ] Add conveyor belt animation (shader or tiled sprite)
- [ ] Add bin highlight on hover/drag
- [ ] Add combo counter for consecutive correct sorts
- [ ] Add screen shake on wrong sort / full mess
- [ ] Add coin fly animation
- **Labels:** polish, gameplay
- **Priority:** P1

### Issue 10: Generate real art assets
- [ ] Generate raccoon mascot (Animagine XL 4.0)
- [ ] Generate trash item sprites (Pixel Art Diffusion XL)
- [ ] Generate bin UI graphics
- [ ] Replace ColorRect placeholders with textures
- [ ] Add particle effects for feedback
- **Labels:** art, assets
- **Priority:** P1

### Issue 11: Add audio
- [ ] Add correct sort sound
- [ ] Add wrong sort sound
- [ ] Add coin earned sound
- [ ] Add round end jingle
- [ ] Add background music
- **Labels:** audio
- **Priority:** P1

### Issue 12: Android export
- [ ] Add Android export preset
- [ ] Install Android SDK/JDK/NDK
- [ ] Test on physical Android device
- [ ] Tune touch input sensitivity
- [ ] Handle safe areas / notch
- [ ] Performance profiling for mobile
- **Labels:** android, export
- **Priority:** P1

### Issue 13: Real ad SDK integration
- [ ] Add AdMob or Unity Ads plugin
- [ ] Implement real rewarded ads
- [ ] Implement real interstitial ads
- [ ] Remove fake ad stubs
- **Labels:** monetization, ads
- **Priority:** P2

### Issue 14: Real IAP integration
- [ ] Add Google Play Billing plugin
- [ ] Implement remove_ads purchase
- [ ] Test purchase flow
- **Labels:** monetization, iap
- **Priority:** P2

### Issue 15: iOS support
- [ ] Requires macOS + Xcode
- [ ] iOS export preset
- [ ] StoreKit integration
- [ ] iOS ad SDK
- [ ] TestFlight distribution
- **Labels:** ios
- **Priority:** P3

### Issue 16: Feature additions
- [ ] More trash types (paper, glass, e-waste)
- [ ] More bins
- [ ] Bin upgrades (auto-sort, faster processing)
- [ ] Daily rewards
- [ ] Real offline earnings
- [ ] Leaderboards (Google Play / Game Center)
- [ ] Achievements
- [ ] Raccoon customisation
- **Labels:** feature
- **Priority:** P2

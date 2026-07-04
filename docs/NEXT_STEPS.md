# Next Steps (Post-MVP)

## Priority 1 — Gameplay Feel (Batch 002)
- Tune spawn rate ramp: start slow, get faster
- Conveyor belt animation (scrolling stripes)
- Combo/streak mechanic with milestone bonuses
- Sorting feedback juice (floating text, bin flash, screen shake)
- Pause/restart round flow
- Rewarded ad one-claim per round
- Offline earnings with 2h cap and claim popup
- Procedural sound placeholders

**Status:** ✅ Complete

## Priority 2 — Android Export (Batch 003)
- Android export preset (debug, no signing secrets committed)
- Touch input support (mouse + touch events in TrashItem)
- Mobile debug overlay (FPS, item count, spawn rate, input mode)
- Max active item cap (30) to prevent mobile performance issues
- Portrait orientation lock
- Android Studio SDK setup documentation
- Save/load uses `user://` (platform-agnostic, no Windows-specific paths)

**Status:** ✅ Complete

## Priority 3 — Real Assets
- Generate raccoon mascot icon via ComfyUI (Animagine XL 4.0)
- Generate trash item sprites (Pixel Art Diffusion XL)
- Replace ColorRect placeholders with real textures
- Add particle effects for sorting feedback

## Priority 4 — Juice & Feedback
- Better sound effects (correct sort, wrong sort, round end, coin earned)
- Background music
- Coin-animation (fly to total)
- Round start / end transitions
- Mess meter visual effects (pulsing red at high mess)

## Priority 5 — Real Monetization
- Add AdMob (or Unity Ads) plugin for Android
- Implement real rewarded ads
- Implement real interstitial ads
- Add Google Play Billing for remove_ads IAP
- Remove fake stubs

## Priority 6 — iOS
- Requires macOS + Xcode
- Apple Developer Program membership
- iOS export preset
- StoreKit integration for IAP
- iOS-specific ad SDK
- TestFlight distribution

## Priority 7 — Features
- More trash types (paper, glass, e-waste)
- More bins
- Bin upgrades (auto-sort, faster processing)
- Daily rewards
- Offline earnings (improved — boost multipliers, compound interest)
- Leaderboards (Google Play / Game Center)
- Achievements
- Raccoon customisation
- Themed conveyor belts

# Playtest Checklist

Use this checklist to validate the MVP after each build.

## Basic Flow
- [ ] Game launches without errors
- [ ] Main menu appears with title "Trash Panda Tycoon"
- [ ] New Game button works
- [ ] Continue button is disabled if no save exists
- [ ] Continue button works if save exists
- [ ] Reset Save works with confirmation prompt

## Gameplay
- [ ] Items spawn on the conveyor belt
- [ ] Items can be dragged with mouse
- [ ] Items snap back if not dropped on a bin
- [ ] Dropping a correct item on the matching bin gives coins
- [ ] Dropping a wrong item on a bin increases mess meter
- [ ] Items that fall off the bottom increase mess meter
- [ ] 30-second round timer counts down
- [ ] Round ends when timer expires
- [ ] Round ends early when mess meter fills
- [ ] Feedback text appears on correct/wrong sort

## Results Screen
- [ ] Results screen shows after round ends
- [ ] Coins earned are displayed
- [ ] Correct sorts count is displayed
- [ ] Wrong sorts count is displayed
- [ ] Missed items count is displayed
- [ ] Total coins are displayed
- [ ] Next Round button starts a new round
- [ ] Upgrade button opens upgrade screen

## Upgrades
- [ ] Upgrade screen shows 4 upgrades
- [ ] Each upgrade shows name, description, level, cost
- [ ] Buying an upgrade reduces coin total
- [ ] Trash Value upgrade increases coins per sort
- [ ] Spawn Rate upgrade makes items appear faster
- [ ] Mess Capacity upgrade increases max mess
- [ ] Maxed upgrade shows "MAXED" and is disabled
- [ ] Upgrade costs increase per level
- [ ] Back button returns to results screen

## Save / Load
- [ ] Coins persist after closing and reopening the game
- [ ] Upgrade levels persist after closing and reopening
- [ ] Best round score persists
- [ ] Reset Save clears all progress
- [ ] Save file uses `user://` path (no Windows hardcode)

## Platform Stubs
- [ ] "Watch Ad x2" button works and doubles earnings
- [ ] Doubled amount matches the tooltip
- [ ] Console shows [FakeAds] log messages
- [ ] Console shows [FakeIAP] log messages if applicable

## Batch 002 Specific
- [ ] Combo counter increases on correct streak
- [ ] Combo resets on wrong/miss
- [ ] HUD shows combo when 2x+
- [ ] Combo milestone bonus awarded at x5, x10, etc.
- [ ] Combo shown on results screen
- [ ] Watch Ad x2 can only be claimed once per round
- [ ] Watch Ad x2 button says "Reward Claimed" after use
- [ ] Watch Ad x2 resets for next round
- [ ] Pause button visible during gameplay
- [ ] Pause menu shows Resume, Restart Round, Main Menu
- [ ] Resume unpauses timers correctly
- [ ] Restart Round starts fresh without corrupting save
- [ ] Main Menu returns to title screen
- [ ] Offline earnings do not crash save/load
- [ ] Offline earnings popup shows on next round after idle
- [ ] Conveyor belt animates (scrolling stripes)
- [ ] Green flash on correct bin hit
- [ ] Red flash + screen shake on wrong bin
- [ ] Item pop/scale effect before removal
- [ ] Sound plays on correct sort
- [ ] Sound plays on wrong sort
- [ ] Drag feels forgiving (expanded bin hit zones)
- [ ] No C# files created
- [ ] No Mono dependencies

## Batch 003 — Android Export & Mobile Sanity
- [ ] Android export preset exists (`export_presets.cfg`)
- [ ] Preset uses debug mode (no signing secrets)
- [ ] `.gitignore` protects `*.keystore` and `*.jks`
- [ ] No keystore or private signing files committed
- [ ] `project.godot` has portrait orientation lock
- [ ] `project.godot` has package name set
- [ ] Items can be dragged with **touch** (if on mobile/touch device)
- [ ] Items can still be dragged with **mouse** (Windows)
- [ ] Debug overlay toggles via DBG button
- [ ] Debug overlay shows FPS, item count, spawn rate, input mode
- [ ] Max active items capped at 30 (no unbounded buildup)
- [ ] Console has no runaway tween/node warnings
- [ ] `user://` saves work on desktop (cross-platform path)
- [ ] No real ad/IAP SDKs or plugins
- [ ] No Google Play Services dependencies
- [ ] No addons/ or android/ folders committed

## Structural
- [ ] No C# files in the project
- [ ] No Mono dependencies
- [ ] All scripts are typed GDScript
- [ ] project.godot has `dotnet/enabled=false`
- [ ] No real SDKs or plugins in project.godot
- [ ] Portrait 720x1280 resolution
- [ ] All scenes load without errors

## Notes for Testing
- Run from Godot editor (F5)
- Check Output panel for errors and log messages
- Check Debugger panel for script errors
- Test on windowed mode at 720x1280
- For Android: export APK via `godot --headless --export-debug "Android Debug" build.apk`
- Enable debug overlay by tapping "DBG" button in HUD (top-right)

## Mobile Layout Checks
- [ ] Top HUD elements not clipped by status bar area (>40px from top edge)
- [ ] Bottom buttons not clipped by nav bar area (>40px from bottom edge)
- [ ] Pause button (top-right) reachable with thumb
- [ ] Debug button (top-right, below pause) reachable
- [ ] Results screen buttons large enough to tap (~48px min)
- [ ] Upgrade rows readable and scrollable
- [ ] Mission text readable on 5" phone screen
- [ ] Daily reward button clearly claims/unclaimed
- [ ] Settings toggles tappable
- [ ] Touch drag starts correctly within item bounds
- [ ] Items snap back on missed drop
- [ ] Landscape does not reorient (locked portrait)
- [ ] Debug overlay shows viewport size + margin values
- [ ] LayoutHelper.SAFE_TOP/SAFE_BOTTOM/SAFE_SIDE prevent edge clipping
- [ ] Minimum touch target (44px) respected on all buttons
- [ ] Color is not the only indicator — text labels accompany all icons
- [ ] Font sizes readable at arm's length (14px min, 16px+ body)

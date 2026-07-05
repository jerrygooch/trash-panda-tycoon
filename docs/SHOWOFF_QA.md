# Show-Off QA Checklist — Trash Panda Tycoon

## How to Run
```bash
/usr/local/bin/godot /path/to/project.godot
```
Or open Godot, Import Project, navigate to the folder, select project.godot.

## What to Check

### Main Menu
- [ ] Title "Trash Panda Tycoon" with raccoon mascot visible
- [ ] "Play" button largest, gold hover color
- [ ] "Continue" button disabled for fresh saves
- [ ] "Daily Reward" button (gold)
- [ ] "Reset Save" in red
- [ ] Tagline readable
- [ ] "Prototype Build" label visible

### Gameplay
- [ ] Conveyor belt visible
- [ ] Trash items appear on belt
- [ ] Item icons render (generated art or emoji fallback)
- [ ] Bins show category labels with emoji
- [ ] Bin icons render if imported
- [ ] Drag item → correct bin → green flash, coins, combo
- [ ] Drag item → wrong bin → red flash, mess increases
- [ ] Item falls off belt → mess increases
- [ ] HUD shows coins, timer, mess bar, level
- [ ] Combo counter appears after 2+ correct sorts
- [ ] Mess danger label appears when mess >70%
- [ ] Pause button works (top-right)

### Results Screen
- [ ] Round results displayed (coins, correct, wrong, missed)
- [ ] Best combo and empire level shown
- [ ] Missions progress visible
- [ ] "Watch Ad x2" button works once per round
- [ ] "Next Round" starts new round
- [ ] "Upgrade" opens upgrade screen

### Upgrade Screen
- [ ] 4 upgrades visible with level and cost
- [ ] "Buy" works if affordable
- [ ] "Back" returns to results
- [ ] Next-level effect preview shown

### Settings / Pause
- [ ] Sound toggle works
- [ ] Debug overlay toggle works
- [ ] Vibration toggle exists (placeholder)
- [ ] Resume returns to game
- [ ] Restart works
- [ ] Main Menu returns to menu

### Save / Load
- [ ] "Continue" works if save exists
- [ ] "Reset Save" clears data
- [ ] Coins persist between sessions

### Known Visual Limitations
- Textures only show after Godot editor opens project once
- Headless import creates .import files but textures may be blank until editor runs
- ComfyUI-generated assets may have minor AI artifacts
- Contact sheet is reference only, not in game
- No real device testing done
- Android APK blocked by missing SDK

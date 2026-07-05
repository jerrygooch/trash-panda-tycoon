# Batch 015 Screenshots

## Location
screenshots/batch015/

## Status
Viewport screenshots cannot be captured in Godot headless mode (no renderer).
For actual screenshots, one of:

1. Run Godot editor: `/usr/local/bin/godot /mnt/c/Users/jerry/projects/trash-panda-tycoon/project.godot`
2. Press F5 to play
3. Use `computer_use` Hermes tool to capture screen during gameplay

## Verification (headless)
All 16 assets/scenes verified via ResourceLoader.exists() and scene instantiation:

| Check | Result |
|-------|--------|
| MainMenu script loads | ✅ |
| Mascot texture exists | ✅ |
| 6 item icon textures | ✅ |
| 3 bin icon textures | ✅ |
| Contact sheet exists | ✅ |
| Game scene loads | ✅ |
| ResultsScreen loads | ✅ |
| UpgradeScreen loads | ✅ |
| SettingsScreen loads | ✅ |

Commit: 6a852ba (base) + current batch commit

## What each screenshot would prove

| Screenshot | What to check |
|------------|--------------|
| main_menu.png | Mascot renders, Play button visible, title clear |
| gameplay_start.png | Conveyor, bins (with bin icons), HUD visible |
| gameplay_with_items.png | Item icons render correctly during gameplay |
| results_screen.png | Mission progress, ad button, next round button |
| upgrade_screen.png | Purchase flow, level display, cost display |
| settings_screen.png | Toggle controls visible and responsive |

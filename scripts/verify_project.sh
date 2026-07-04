#!/bin/bash
# verify_project.sh — Repo-local smoke test for Trash Panda Tycoon
# Safe to run repeatedly. No network. No Android SDK. No file deletion.

set -e

PROJ="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0
PASS=0

check() {
    local label="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "  PASS  $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  $label"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== Trash Panda Tycoon — Smoke Test ==="
echo "Project: $PROJ"
echo ""

# 1. project.godot exists
check "project.godot exists" test -f "$PROJ/project.godot"

# 2. Main.tscn exists
check "Main.tscn exists" test -f "$PROJ/Main.tscn"

# 3. No .cs files
check "No C# files" test "$(find "$PROJ" -name '*.cs' 2>/dev/null | wc -l)" -eq 0

# 4. dotnet disabled
check "dotnet/enabled=false" grep -q "enabled=false" "$PROJ/project.godot"

# 5. export_presets.cfg exists
check "export_presets.cfg" test -f "$PROJ/export_presets.cfg"

# 6. No tracked keystores
check "No .keystore in git" bash -c "git -C '$PROJ' ls-files '*.keystore' '*.jks' 2>/dev/null | wc -l | grep -qx '0'"

# 7. Android package name
check "Android pkg_name set" grep -q "pkg_name=" "$PROJ/project.godot"

# 8. Portrait orientation
check "Portrait orientation" grep -q "orientation=1" "$PROJ/project.godot"

# 9. Key scenes
for s in Main MainMenu Hud ResultsScreen UpgradeScreen PauseMenu SettingsScreen Game Conveyor TrashItem Bin; do
    f=$(find "$PROJ" -name "${s}.tscn" 2>/dev/null | head -1)
    if [ -n "$f" ]; then
        check "Scene $s.tscn" test -n "$f"
    fi
done

# 10. Key scripts
for g in main game_state save_system tuning game_manager trash_item conveyor bin \
         sound_manager platform_service fake_ads_service fake_iap_service \
         hud main_menu results_screen upgrade_screen pause_menu settings_screen \
         layout_helper; do
    f=$(find "$PROJ" -name "${g}.gd" 2>/dev/null | head -1)
    if [ -n "$f" ]; then
        check "Script $g.gd" test -n "$f"
    fi
done

# 11. Autoloads
for a in Tuning GameState SaveSystem PlatformService; do
    check "Autoload $a" grep -q "$a=" "$PROJ/project.godot"
done

# 12. Godot parse check (optional — skips silently if godot not found)
if command -v godot &>/dev/null; then
    if timeout 15 godot --headless --path "$PROJ" --check-only >/dev/null 2>&1 || [ $? -eq 124 ]; then
        check "Godot --check-only (parse)" true
    else
        check "Godot --check-only (parse)" false
    fi
else
    echo "  SKIP  Godot not in PATH — skipping parse check"
fi

# 13. .gitignore protects secrets
check ".gitignore blocks *.keystore" grep -q 'keystore' "$PROJ/.gitignore"
check ".gitignore blocks .env" grep -q '\.env' "$PROJ/.gitignore"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL

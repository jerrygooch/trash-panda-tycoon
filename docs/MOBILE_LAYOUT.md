# Mobile Layout Notes — Trash Panda Tycoon

## Target Resolution

- **Logical:** 720x1280 (9:16 portrait)
- **Stretch mode:** `canvas_items` with `expand` aspect
- **Orientation:** Locked to portrait via `window/handheld/orientation=1`

This means the game canvas scales to fill the device width while maintaining
the 9:16 aspect ratio. On taller phones (20:9, 21:9) the top and bottom
will letterbox slightly. On wider tablets the sides will pillarbox.

## Safe-Area Assumptions

The project uses `LayoutHelper` (`scripts/ui/layout_helper.gd`) for safe-area
constants. Current defaults are conservative for development:

| Edge | Default margin | Purpose |
|------|---------------|---------|
| Top | 40px | Status bar + breathing room |
| Bottom | 40px | Navigation bar + breathing room |
| Sides | 16px | Left/right inset |

These are **not** based on real device measurements. They prevent the most
obvious edge-clipping on common phones. A real device test pass should
measure actual notch/punch-hole/nav-bar dimensions and update the constants
in `LayoutHelper`.

## What Has Been Tested (Desktop Only)

- Windowed 720x1280 in Godot editor
- Window resize to simulate various aspect ratios
- Debug overlay shows viewport size and safe-area constants
- All UI screens render at correct logical resolution

## What Needs Real Phone Validation

- Notch / punch-hole / dynamic island clipping
- Nav bar overlapping bottom buttons
- Status bar overlapping top HUD
- Touch drag accuracy (works in theory, untested on glass)
- Gesture navigation vs button navigation
- Very small phones (~5") vs large phones (~7")
- Landscape prevention (should not rotate)

## Using Debug Overlay During Device Test

1. Tap the **DBG** button in the HUD (top-right)
2. Debug line shows: `FPS Items Spawn ViewportSize SafeMargins`
3. Watch FPS to spot performance issues
4. Note viewport size — confirms safe-area negotiation
5. Verify margins prevent UI clipping

## Accessibility Notes

- Minimum touch target: 44px (Material Design guideline)
- Font sizes: 14px smallest (debug), 16px body, 20px+ for interactive labels
- Color is not the only indicator — all categories have text labels
- Emoji icons are supplementary, not the sole identifier
- Future: colorblind-safe palette, screen reader support, adjustable font size

## Known Screen-Size Issues (not yet addressed)

- Very tall phones (21:9) — bins may be pushed down, conveyor area shrinks
- Tablets (4:3) — side letterboxing, bins may feel narrow
- Foldables — aspect ratio changes mid-session (not handled)
- Desktop resize — currently allowed, could break layout

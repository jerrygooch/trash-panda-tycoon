# Asset Pipeline

## Principle: Placeholder-First

The MVP uses simple Godot ColorRect, Polygon2D, and Label nodes for all visuals. No external art is required. The game must be playable with zero external assets.

- All trash items are colored rectangles with emoji characters
- Bins are colored rectangles with emoji icons
- UI elements use themed Godot controls
- No image files, no sprite sheets, no textures needed

## Optional ComfyUI Art Route

After the core game loop is confirmed working, local AI art generation is available for first-pass assets.

### Available Setup

- ComfyUI at `~/ComfyUI/` on port 8188
- Available models:
  - **Animagine XL 4.0** — best for cute character art and UI elements
  - **Pixel Art Diffusion XL - Sprite Shader** — good for clean pixel-art icons
  - **SDXL Base 1.0** — fallback
- Do NOT use Flux1-Schnell FP8 (system RAM risk)

### Tools

- `~/redbubble-factory/tools/render_comfy.py` — queue a ComfyUI workflow
- `~/redbubble-factory/tools/void_reclaimer_assets.py` — batch asset generation
- `~/redbubble-factory/tools/make_contact_sheet.py` — collate outputs
- `~/redbubble-factory/tools/remove_bg.py` — background removal
- `~/redbubble-factory/tools/upscale.py` — upscale outputs

### Recommended First Assets

1. Raccoon mascot icon (Animagine XL 4.0) — `art/generated/mascot.png`
2. Trash item icons (Pixel Art Diffusion XL) — `art/generated/items/`
3. Bin UI graphics (Animagine XL 4.0) — `art/generated/bins/`
4. Upgrade panel background (Animagine XL 4.0) — `art/generated/ui/`

### Asset Style

- Cute, readable, mobile-friendly 2D art
- Sticker-like or clean pixel art
- Avoid complicated backgrounds
- Transparent PNG with clear subject

### What Not to Do Yet

- Do not use Flux1-Schnell (RAM risk)
- Do not block MVP completion on asset generation
- Do not spend time on final polish
- Do not use external image generation APIs without approval
- Do not replace placeholder assets until the game loop is working

### Generated Asset Placement

Generated assets go in `art/generated/`. The actual Godot resources (imported/destination) go in `art/generated/.godot/import/`. Reference them from scenes by dragging the imported texture to the relevant ColorRect or Sprite2D's texture property.

## Asset Naming Convention

```
art/
├── placeholders/        # Hand-made placeholder textures (if any)
├── generated/           # AI-generated output (ComfyUI)
└── final/               # Final polished assets (future)
```

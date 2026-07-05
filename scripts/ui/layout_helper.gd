extends Node

# LayoutHelper — centralized safe-area and margin constants for mobile-ready UI
# These are conservative defaults. Once tested on a real device, adjust per
# actual notch/status-bar/nav-bar measurements from that device.

# --- Safe margins (pixels at 720x1280 logical) ---
const SAFE_TOP: int = 48      # status bar + extra breathing room for notch
const SAFE_BOTTOM: int = 56   # nav bar + extra breathing room for gesture hints
const SAFE_SIDE: int = 20     # left/right edge margin

# --- Minimum touch target (40px per Material Design guideline) ---
const MIN_TOUCH: int = 44

# --- Minimum readable font sizes ---
const FONT_SMALL: int = 14
const FONT_BODY: int = 16
const FONT_LARGE: int = 20
const FONT_TITLE: int = 26
const FONT_HERO: int = 38

# --- Button minimum sizes ---
const BTN_MIN_WIDTH: int = 48
const BTN_MIN_HEIGHT: int = 48

# --- Layout bands (at 720x1280) ---
const HUD_HEIGHT: int = 200
const CONVEYOR_TOP: int = 200
const CONVEYOR_HEIGHT: int = 580
const BINS_TOP: int = 800
const BINS_HEIGHT: int = 380


static func apply_safe_margins(node: Control, top: bool = false, bottom: bool = false, side: bool = false) -> void:
	## Apply safe-area margins to a Control node.
	## Call from _ready() on overlay/fullscreen panels.
	if top:
		node.position.y = SAFE_TOP
	if bottom:
		var vs: Vector2 = node.get_viewport().get_visible_rect().size if node.get_viewport() else Vector2(720, 1280)
		node.size.y = vs.y - SAFE_TOP - SAFE_BOTTOM
	if side:
		node.position.x = SAFE_SIDE
		if node.get_viewport():
			node.size.x = node.get_viewport().get_visible_rect().size.x - SAFE_SIDE * 2


static func viewport_size_string() -> String:
	var vs: Vector2 = Vector2(720, 1280)
	var vp = Engine.get_main_loop()
	if vp and vp.root:
		vs = vp.root.get_visible_rect().size
	return "%dx%d" % [vs.x, vs.y]


static func safe_margin_string() -> String:
	return "T:%d B:%d S:%d" % [SAFE_TOP, SAFE_BOTTOM, SAFE_SIDE]


static func is_portrait() -> bool:
	var vs: Vector2 = Vector2(720, 1280)
	var vp = Engine.get_main_loop()
	if vp and vp.root:
		vs = vp.root.get_visible_rect().size
	return vs.y >= vs.x

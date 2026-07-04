extends Control

# SettingsScreen — sound, debug overlay, vibration placeholder, reset save

signal settings_closed()

@onready var _sfx_toggle: CheckBox = %SfxToggle
@onready var _debug_toggle: CheckBox = %DebugToggle
@onready var _vibration_toggle: CheckBox = %VibrationToggle


func _ready() -> void:
	_load_settings()


func _load_settings() -> void:
	var s: Dictionary = GameState.settings
	_sfx_toggle.button_pressed = s.get("sfx_enabled", true)
	_debug_toggle.button_pressed = s.get("debug_overlay", false)
	_vibration_toggle.button_pressed = s.get("vibration_enabled", false)


func _on_sfx_toggled(toggled: bool) -> void:
	GameState.settings.sfx_enabled = toggled
	SaveSystem.save_game()


func _on_debug_toggled(toggled: bool) -> void:
	GameState.settings.debug_overlay = toggled
	SaveSystem.save_game()
	# Update HUD debug overlay visibility
	var hud = get_node_or_null("/root/Game/%Hud")
	if hud and hud.has_method("_toggle_debug"):
		hud._toggle_debug()


func _on_vibration_toggled(toggled: bool) -> void:
	GameState.settings.vibration_enabled = toggled
	SaveSystem.save_game()


func _on_back_pressed() -> void:
	hide()
	settings_closed.emit()

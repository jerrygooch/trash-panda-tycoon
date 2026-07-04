extends Control

# HUD — coins, timer, mess meter, round, combo, debug overlay, empire level, mess danger

signal pause_pressed()

var _combo_visible: bool = false
const DEBUG_ENABLED: bool = false
var _debug_visible: bool = false
var _mess_danger_shown: bool = false

@onready var _coins_label: Label = %CoinsLabel
@onready var _timer_label: Label = %TimerLabel
@onready var _mess_bar: ProgressBar = %MessBar
@onready var _mess_label: Label = %MessLabel
@onready var _round_label: Label = %RoundLabel
@onready var _level_label: Label = %LevelLabel
@onready var _combo_label: Label = %ComboLabel
@onready var _pause_btn: Button = %PauseButton
@onready var _debug_btn: Button = %DebugButton
@onready var _debug_label: Label = %DebugLabel
@onready var _danger_label: Label = %DangerLabel


func _ready() -> void:
	if _combo_label: _combo_label.hide()
	if _debug_label: _debug_label.hide()
	if _danger_label: _danger_label.hide()
	if _pause_btn: _pause_btn.pressed.connect(_on_pause_pressed)
	if _debug_btn: _debug_btn.pressed.connect(_toggle_debug)
	_debug_visible = DEBUG_ENABLED
	if DEBUG_ENABLED and _debug_label: _debug_label.show()


func update_display(coins: int, time_left: int, mess: int, max_mess: int,
		round_num: int, combo: int, active_items: int = 0,
		spawn_interval: float = 0.0, empire_level: int = 0) -> void:
	_coins_label.text = "\U0001FA99 " + str(coins)
	var secs: int = maxi(time_left, 0)
	_timer_label.text = "\U000023F1 %02d" % secs
	_mess_bar.max_value = max_mess
	_mess_bar.value = mess

	if mess >= max_mess:
		_mess_bar.modulate = Color.RED
	elif mess >= max_mess * 0.7:
		_mess_bar.modulate = Color.ORANGE
	else:
		_mess_bar.modulate = Color.GREEN

	_mess_label.text = "Mess: %d / %d" % [mess, max_mess]
	_round_label.text = "R%d" % round_num
	if _level_label:
		_level_label.text = "Lv.%d" % empire_level

	# Combo
	if combo >= 2 and _combo_label:
		_combo_label.text = "\U0001F525 x%d" % combo
		_combo_label.show()
		_combo_visible = true
		_combo_label.scale = Vector2(1, 1) * (1.0 + minf(0.3, combo * 0.02))
	elif _combo_visible and combo < 2 and _combo_label:
		_combo_label.hide()
		_combo_visible = false

	# Mess danger
	var danger_pct: float = float(mess) / max_mess if max_mess > 0 else 0.0
	if danger_pct >= 0.7 and _danger_label:
		if not _mess_danger_shown:
			_danger_label.show()
			_danger_label.text = "\U000026A0 Mess Critical!" if danger_pct >= 0.85 else "\U000026A0 High Mess!"
			_mess_danger_shown = true
	elif _mess_danger_shown and danger_pct < 0.7:
		_mess_danger_shown = false
		if _danger_label: _danger_label.hide()

	# Debug
	if _debug_visible and _debug_label:
		var fps: float = Engine.get_frames_per_second()
		_debug_label.text = "FPS:%d Items:%d Spawn:%.2fs" % [fps, active_items, spawn_interval]


func _on_pause_pressed() -> void: pause_pressed.emit()
func _toggle_debug() -> void:
	_debug_visible = not _debug_visible
	if _debug_label: _debug_label.visible = _debug_visible


func show_offline_message(coins: int) -> void:
	var label: Label = Label.new()
	label.text = "\U0001F4B0 Welcome back! +" + str(coins) + " offline!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
	label.position = Vector2(60, 150)
	label.size = Vector2(600, 40)
	label.z_index = 50
	add_child(label)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", 130.0, 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(1.0)
	tween.finished.connect(label.queue_free)

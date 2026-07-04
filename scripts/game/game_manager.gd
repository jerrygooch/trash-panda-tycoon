extends Node
class_name GameManager

# GameManager — controls a single round of gameplay
# Batch 002: combo, ad one-claim, pause/restart, juice, sound, offline earnings display

const ROUND_DURATION: float = 30.0
const COMBO_MILESTONE: int = 5
const COMBO_BONUS: int = 5

var _round_active: bool = false
var _paused: bool = false
var _time_remaining: float = 0.0
var _mess_level: int = 0
var _max_mess: int = 5
var _items_on_belt: Array = []
var _trash_data: Array = []
var _spawn_timer: Timer
var _round_timer: Timer
var _mess_check_timer: Timer
var _spawn_interval: float = 1.8
var _trash_value_mult: int = 1
var _round_earnings_multiplier: int = 1
var _combo_last_bonus_at: int = 0

@onready var _hud: Control = %Hud
@onready var _results_screen: Control = %ResultsScreen
@onready var _upgrade_screen: Control = %UpgradeScreen
@onready var _pause_menu: Control = %PauseMenu
@onready var _conveyor_container: Control = %ConveyorContainer
@onready var _bins_container: HBoxContainer = %BinsContainer
@onready var _sound_mgr: Node = %SoundManager


func _ready() -> void:
	_trash_data = _load_json("res://data/trash_items.json")
	_load_bins()
	_setup_timers()
	_connect_signals()


func _load_json(path: String) -> Array:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("[GameManager] Cannot open: ", path)
		return []
	var json: JSON = JSON.new()
	json.parse(file.get_as_text())
	return json.data as Array


func _load_bins() -> void:
	var bin_data: Array = _load_json("res://data/bins.json")
	for bd in bin_data:
		var bin_node: Node = _bins_container.get_node(bd["id"])
		if bin_node and bin_node.has_method("set_data"):
			bin_node.set_data(bd["category"], bd["name"])
		elif bin_node:
			bin_node.category = bd["category"]
			bin_node.bin_name = bd["name"]


func _setup_timers() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = false
	_spawn_timer.timeout.connect(_spawn_item)
	add_child(_spawn_timer)
	
	_round_timer = Timer.new()
	_round_timer.one_shot = true
	_round_timer.timeout.connect(_on_round_timeout)
	add_child(_round_timer)
	
	_mess_check_timer = Timer.new()
	_mess_check_timer.one_shot = false
	_mess_check_timer.wait_time = 0.25
	_mess_check_timer.timeout.connect(_check_missed_items)
	add_child(_mess_check_timer)


func _connect_signals() -> void:
	_results_screen.next_round_requested.connect(_on_next_round)
	_results_screen.upgrade_requested.connect(_on_upgrade_requested)
	_results_screen.watch_ad_requested.connect(_on_watch_ad_requested)
	_upgrade_screen.upgrades_closed.connect(_on_upgrades_closed)
	_pause_menu.resume_requested.connect(_on_resume)
	_pause_menu.restart_requested.connect(_on_restart_round)
	_pause_menu.main_menu_requested.connect(_on_main_menu)
	_hud.pause_pressed.connect(_on_pause)


func start_round() -> void:
	GameState.reset_round()
	_round_earnings_multiplier = 1
	_combo_last_bonus_at = 0
	
	_spawn_interval = GameState.get_spawn_interval()
	_trash_value_mult = GameState.get_trash_value_multiplier()
	_max_mess = GameState.get_mess_capacity()
	
	_round_active = true
	_paused = false
	_mess_level = 0
	_time_remaining = ROUND_DURATION
	_items_on_belt.clear()
	_clear_conveyor()
	
	_hud.show()
	_results_screen.hide()
	_upgrade_screen.hide()
	_pause_menu.hide()
	
	_spawn_timer.wait_time = _spawn_interval
	_spawn_timer.start()
	_round_timer.wait_time = ROUND_DURATION
	_round_timer.start()
	_mess_check_timer.start()
	
	_spawn_item()
	_update_hud()
	
	# Show offline earnings if any
	var offline_coins: int = SaveSystem.claim_offline_earnings_display()
	if offline_coins > 0:
		_hud.show_offline_message(offline_coins)
		print("[GameManager] Offline earnings claimed: ", offline_coins)


func _spawn_item() -> void:
	if not _round_active or _paused:
		return
	
	var item_data: Dictionary = _trash_data.pick_random()
	var item_scene: PackedScene = preload("res://scenes/game/TrashItem.tscn")
	var item: Node = item_scene.instantiate()
	
	item.initialize(item_data, _trash_value_mult)
	
	var belt_width: float = _conveyor_container.size.x - 40.0
	var x_pos: float = randf_range(20.0, maxf(40.0, belt_width))
	item.position = Vector2(x_pos, -60.0)
	
	_conveyor_container.add_child(item)
	_items_on_belt.append(item)
	
	item.item_dropped_on_bin.connect(_on_item_dropped_on_bin.bind(item))


func _on_item_dropped_on_bin(item: Node) -> void:
	if not _round_active or _paused or not is_instance_valid(item):
		return
	
	var drop_pos: Vector2 = item.global_position + Vector2(30, 30)
	var bin: Node = _get_bin_at_position(drop_pos)
	
	if bin and bin.category == item.category:
		_on_correct_sort(item, bin)
	else:
		_on_wrong_sort(item, bin)
	
	_remove_item(item)
	_update_hud()


func _on_correct_sort(item: Node, bin: Node) -> void:
	var coins: int = item.base_value * _trash_value_mult
	GameState.add_coins(coins)
	GameState.add_correct_sort()
	
	# Combo check
	var combo: int = GameState.combo
	if combo > 0 and combo % COMBO_MILESTONE == 0 and combo > _combo_last_bonus_at:
		_combo_last_bonus_at = combo
		var bonus: int = COMBO_BONUS * (combo / COMBO_MILESTONE)
		GameState.add_coins(bonus)
		_show_feedback(item.global_position, "Combo x%d! +%d" % [combo, bonus], Color(1, 0.5, 0, 1))
	elif coins > 0:
		_show_feedback(item.global_position, "+%d" % coins, Color.GREEN)
	
	# Juice
	_sound_mgr.play_correct()
	if bin and bin.has_method("flash_correct"):
		bin.flash_correct()
	_item_pop_effect(item)
	
	print("[Game] Correct: ", item.item_name, " -> ", bin.bin_name if bin else "?")


func _on_wrong_sort(item: Node, bin: Node) -> void:
	GameState.add_wrong_sort()
	_increase_mess_and_check()
	
	_show_feedback(item.global_position, "Wrong!", Color.RED)
	
	# Juice
	_sound_mgr.play_wrong()
	if bin and bin.has_method("flash_wrong"):
		bin.flash_wrong()
	_screen_shake(4.0, 0.15)


func _get_bin_at_position(global_pos: Vector2) -> Node:
	for bin_node in _bins_container.get_children():
		if bin_node.has_method("get_drop_rect"):
			var rect: Rect2 = bin_node.get_drop_rect()
			if rect.has_point(global_pos):
				return bin_node
	return null


func _check_missed_items() -> void:
	if not _round_active or _paused:
		return
	
	var to_remove: Array = []
	var screen_bottom: float = get_viewport().get_visible_rect().size.y + 100.0
	
	for item in _items_on_belt:
		if not is_instance_valid(item):
			to_remove.append(item)
		elif item.global_position.y > screen_bottom:
			to_remove.append(item)
	
	for item in to_remove:
		GameState.add_missed_item()
		_increase_mess_and_check()
		_remove_item(item)
		_update_hud()


func _increase_mess_and_check() -> void:
	_mess_level += 1
	# Mess meter pulse
	var tween: Tween = create_tween()
	tween.tween_property(_hud.get_node_or_null("%MessBar"), "modulate:a", 0.6, 0.05)
	tween.tween_property(_hud.get_node_or_null("%MessBar"), "modulate:a", 1.0, 0.15)
	
	if _mess_level >= _max_mess:
		_end_round()


func _show_feedback(pos: Vector2, text: String, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = pos - Vector2(60, 0)
	label.size = Vector2(120, 30)
	add_child(label)
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50.0, 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.7).set_delay(0.2)
	tween.finished.connect(label.queue_free)


func _item_pop_effect(item: Node) -> void:
	if not is_instance_valid(item):
		return
	var tween: Tween = create_tween()
	tween.tween_property(item, "scale", Vector2(1.3, 1.3), 0.05)
	tween.tween_property(item, "scale", Vector2.ZERO, 0.15)
	tween.tween_property(item, "modulate:a", 0.0, 0.1)
	tween.finished.connect(_remove_item.bind(item))



func _screen_shake(intensity: float, duration: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera:
		var orig: Vector2 = camera.offset
		var tween: Tween = create_tween()
		tween.tween_method(_apply_shake.bind(camera, orig), duration, 0.0, duration)
		tween.finished.connect(_reset_shake.bind(camera, orig))


func _apply_shake(_rem: float, camera: Camera2D, orig: Vector2) -> void:
	camera.offset = orig + Vector2(
		randf_range(-3.0, 3.0),
		randf_range(-3.0, 3.0)
	)


func _reset_shake(camera: Camera2D, orig: Vector2) -> void:
	if is_instance_valid(camera):
		camera.offset = orig


func _remove_item(item: Node) -> void:
	_items_on_belt.erase(item)
	if is_instance_valid(item):
		item.queue_free()


func _clear_conveyor() -> void:
	for item in _items_on_belt:
		if is_instance_valid(item):
			item.queue_free()
	_items_on_belt.clear()


# --- Pause / Resume / Restart ---

func _on_pause() -> void:
	if not _round_active:
		return
	_paused = true
	_spawn_timer.paused = true
	_round_timer.paused = true
	_mess_check_timer.paused = true
	_pause_menu.show()
	_hud.hide()


func _on_resume() -> void:
	_paused = false
	_spawn_timer.paused = false
	_round_timer.paused = false
	_mess_check_timer.paused = false
	_pause_menu.hide()
	_hud.show()


func _on_restart_round() -> void:
	_pause_menu.hide()
	start_round()


func _on_main_menu() -> void:
	_round_active = false
	_paused = false
	_spawn_timer.stop()
	_round_timer.stop()
	_mess_check_timer.stop()
	_clear_conveyor()
	SaveSystem.save_game()
	
	# Go back to main menu via Main node
	var main: Node = get_node("/root/Main")
	if main and main.has_method("_show_main_menu"):
		main._show_main_menu()
	else:
		get_tree().change_scene_to_file("res://Main.tscn")


# --- Round Timer ---

func _on_round_timeout() -> void:
	_end_round()


func _end_round() -> void:
	if not _round_active:
		return
	
	_round_active = false
	_spawn_timer.stop()
	_round_timer.stop()
	_mess_check_timer.stop()
	_pause_menu.hide()
	
	_clear_conveyor()
	GameState.apply_round_earnings()
	SaveSystem.save_game()
	
	var results: Dictionary = {
		"coins": GameState.round_coins * _round_earnings_multiplier,
		"correct": GameState.round_correct,
		"wrong": GameState.round_wrong,
		"missed": GameState.round_missed,
		"total_coins": GameState.total_coins,
		"round_number": GameState.round_number,
		"max_combo": GameState.max_combo
	}
	
	_hud.hide()
	_results_screen.show()
	_results_screen.display_results(results)
	
	print("[GameManager] Round ended — coins: ", results.coins,
		" correct: ", results.correct, " wrong: ", results.wrong,
		" missed: ", results.missed)


# --- Results Screen Handlers ---

func _on_next_round() -> void:
	start_round()


func _on_upgrade_requested() -> void:
	_results_screen.hide()
	_upgrade_screen.show()
	_upgrade_screen._show()


func _on_upgrades_closed() -> void:
	_upgrade_screen.hide()
	_results_screen.show()


func _on_watch_ad_requested() -> void:
	if GameState.round_ad_claimed:
		return
	
	var ad_btn: Button = _results_screen.get_node_or_null("%WatchAdButton")
	if ad_btn:
		ad_btn.disabled = true
		ad_btn.text = "Loading..."
	
	var reward_granted: bool = await PlatformService.show_rewarded_ad("double_earnings")
	
	if reward_granted:
		GameState.round_ad_claimed = true
		_round_earnings_multiplier = 2
		var doubled_coins: int = GameState.round_coins
		GameState.total_coins += doubled_coins
		SaveSystem.save_game()
		
		var results: Dictionary = {
			"coins": GameState.round_coins * 2,
			"correct": GameState.round_correct,
			"wrong": GameState.round_wrong,
			"missed": GameState.round_missed,
			"total_coins": GameState.total_coins,
			"round_number": GameState.round_number,
			"max_combo": GameState.max_combo
		}
		_results_screen.display_results(results)
		_show_feedback(Vector2(360, 600), "Earnings DOUBLED!", Color(1, 0.84, 0, 1))
		_sound_mgr.play_coin()
	
	if ad_btn:
		ad_btn.disabled = true
		ad_btn.text = "Reward Claimed"
		ad_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))


# --- HUD ---

func _update_hud() -> void:
	if not _round_active:
		return
	var time_left: int = ceili(maxf(0.0, _round_timer.time_left))
	_hud.update_display(
		GameState.total_coins,
		time_left,
		_mess_level,
		_max_mess,
		GameState.round_number,
		GameState.combo
	)


func _process(_delta: float) -> void:
	if _round_active and not _paused:
		_update_hud()

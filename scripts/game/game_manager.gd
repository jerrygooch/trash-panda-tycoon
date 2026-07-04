extends Node
class_name GameManager

# GameManager — controls a single round of gameplay
# Manages: conveyor spawning, bin drop detection, timer, mess meter, round results,
# results screen signals, upgrade screen, and watch ad flow.

const ROUND_DURATION: float = 30.0

var _round_active: bool = false
var _time_remaining: float = 0.0
var _mess_level: int = 0
var _max_mess: int = 5
var _items_on_belt: Array = []
var _trash_data: Array = []
var _spawn_timer: Timer
var _round_timer: Timer
var _mess_check_timer: Timer
var _spawn_interval: float = 2.0
var _trash_value_mult: int = 1
var _round_earnings_multiplier: int = 1

@onready var _hud: Control = %Hud
@onready var _results_screen: Control = %ResultsScreen
@onready var _upgrade_screen: Control = %UpgradeScreen
@onready var _conveyor_container: Control = %ConveyorContainer
@onready var _bins_container: HBoxContainer = %BinsContainer


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


func start_round() -> void:
	GameState.reset_round()
	_round_earnings_multiplier = 1
	
	# Apply upgrade effects
	_spawn_interval = GameState.get_spawn_interval()
	_trash_value_mult = GameState.get_trash_value_multiplier()
	_max_mess = GameState.get_mess_capacity()
	
	# Reset state
	_round_active = true
	_mess_level = 0
	_time_remaining = ROUND_DURATION
	_items_on_belt.clear()
	
	# Clear existing items
	_clear_conveyor()
	
	# Hide all overlays
	_hud.show()
	_results_screen.hide()
	_upgrade_screen.hide()
	
	# Start timers
	_spawn_timer.wait_time = _spawn_interval
	_spawn_timer.start()
	_round_timer.wait_time = ROUND_DURATION
	_round_timer.start()
	_mess_check_timer.start()
	
	# Spawn first item
	_spawn_item()
	
	_update_hud()
	print("[GameManager] Round started — interval: ", _spawn_interval, "s, mess cap: ", _max_mess)


func _spawn_item() -> void:
	if not _round_active:
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
	
	# Connect item signal — item reports itself when dropped on a bin
	item.item_dropped_on_bin.connect(_on_item_dropped_on_bin.bind(item))


func _on_item_dropped_on_bin(item: Node) -> void:
	if not _round_active or not is_instance_valid(item):
		return
	
	var drop_pos: Vector2 = item.global_position + Vector2(30, 30)
	var bin: Node = _get_bin_at_position(drop_pos)
	
	if bin and bin.category == item.category:
		# Correct bin
		var coins: int = item.base_value * _trash_value_mult
		GameState.add_coins(coins)
		GameState.add_correct_sort()
		_show_feedback(item.global_position, "+" + str(coins) + " \U0001FA99", Color.GREEN)
	else:
		# Wrong bin (or dropped on no bin — still counts as wrong if we reach here)
		GameState.add_wrong_sort()
		_increase_mess_and_check()
		_show_feedback(item.global_position, "Wrong!", Color.RED)
	
	_remove_item(item)
	_update_hud()


func _get_bin_at_position(global_pos: Vector2) -> Node:
	for bin_node in _bins_container.get_children():
		if bin_node.has_method("get_drop_rect"):
			var rect: Rect2 = bin_node.get_drop_rect()
			if rect.has_point(global_pos):
				return bin_node
	return null


func _check_missed_items() -> void:
	if not _round_active:
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
	if _mess_level >= _max_mess:
		_end_round()


func _show_feedback(pos: Vector2, text: String, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = pos - Vector2(50, 0)
	label.size = Vector2(100, 30)
	add_child(label)
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 60.0, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.finished.connect(label.queue_free)


func _remove_item(item: Node) -> void:
	_items_on_belt.erase(item)
	if is_instance_valid(item):
		item.queue_free()


func _clear_conveyor() -> void:
	for item in _items_on_belt:
		if is_instance_valid(item):
			item.queue_free()
	_items_on_belt.clear()


func _on_round_timeout() -> void:
	_end_round()


func _end_round() -> void:
	if not _round_active:
		return
	
	_round_active = false
	_spawn_timer.stop()
	_round_timer.stop()
	_mess_check_timer.stop()
	
	_clear_conveyor()
	
	GameState.apply_round_earnings()
	
	SaveSystem.save_game()
	
	var results: Dictionary = {
		"coins": GameState.round_coins * _round_earnings_multiplier,
		"correct": GameState.round_correct,
		"wrong": GameState.round_wrong,
		"missed": GameState.round_missed,
		"total_coins": GameState.total_coins,
		"round_number": GameState.round_number
	}
	
	_hud.hide()
	_results_screen.show()
	_results_screen.display_results(results)
	
	print("[GameManager] Round ended — coins: ", results.coins,
		" correct: ", results.correct, " wrong: ", results.wrong,
		" missed: ", results.missed)


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
	# Disable the ad button immediately
	var ad_btn: Button = _results_screen.get_node_or_null("%WatchAdButton")
	if ad_btn:
		ad_btn.disabled = true
		ad_btn.text = "Loading..."
	
	# Call PlatformService — fake implementation returns true instantly
	var reward_granted: bool = await PlatformService.show_rewarded_ad("double_earnings")
	
	if reward_granted:
		_round_earnings_multiplier = 2
		var doubled_coins: int = GameState.round_coins
		# Add the bonus (already applied via GameState.apply_round_earnings, but we add again)
		GameState.total_coins += doubled_coins  # Double the round earnings
		SaveSystem.save_game()
		
		# Update results display
		var results: Dictionary = {
			"coins": GameState.round_coins * 2,
			"correct": GameState.round_correct,
			"wrong": GameState.round_wrong,
			"missed": GameState.round_missed,
			"total_coins": GameState.total_coins,
			"round_number": GameState.round_number
		}
		_results_screen.display_results(results)
		
		# Show ad feedback
		_show_feedback(Vector2(360, 600), "Earnings DOUBLED!", Color(1, 0.84, 0, 1))
	
	if ad_btn:
		ad_btn.disabled = false
		ad_btn.text = "Watch Ad x2"


func _update_hud() -> void:
	if not _round_active:
		return
	var time_left: int = ceili(maxf(0.0, _round_timer.time_left))
	_hud.update_display(GameState.total_coins, time_left, _mess_level, _max_mess, GameState.round_number)


func _process(_delta: float) -> void:
	if _round_active:
		_update_hud()

extends Node

# SaveSystem — handles local JSON save/load
# Data stored in user:// saves (resolved by Godot to OS-specific path)

const SAVE_FILE: String = "user://trash_panda_save.json"


func save_game() -> void:
	var data: Dictionary = {
		"version": "0.1.0",
		"total_coins": GameState.total_coins,
		"best_round_score": GameState.best_round_score,
		"round_number": GameState.round_number,
		"upgrade_levels": GameState.upgrade_levels.duplicate(),
		"remove_ads_owned": GameState.remove_ads_owned,
		"settings": {
			"music_volume": 1.0,
			"sfx_volume": 1.0
		}
	}
	
	var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var json_string: String = JSON.stringify(data, "\t")
		file.store_string(json_string)
		print("[SaveSystem] Game saved successfully")
	else:
		push_error("[SaveSystem] Failed to open save file for writing: ", SAVE_FILE)


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE):
		print("[SaveSystem] No save file found")
		return false
	
	var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if not file:
		push_error("[SaveSystem] Failed to open save file for reading")
		return false
	
	var json_string: String = file.get_as_text()
	var json: JSON = JSON.new()
	var parse_error: Error = json.parse(json_string)
	
	if parse_error != OK:
		push_error("[SaveSystem] Failed to parse save file: ", parse_error)
		return false
	
	var data: Dictionary = json.data as Dictionary
	if data.is_empty():
		push_error("[SaveSystem] Save file is empty or invalid")
		return false
	
	GameState.total_coins = data.get("total_coins", 0)
	GameState.best_round_score = data.get("best_round_score", 0)
	GameState.round_number = data.get("round_number", 0)
	GameState.remove_ads_owned = data.get("remove_ads_owned", false)
	
	var upgrades: Dictionary = data.get("upgrade_levels", {})
	for key in upgrades:
		GameState.upgrade_levels[key] = upgrades[key]
	
	_recache_upgrade_effects()
	
	print("[SaveSystem] Game loaded successfully")
	return true


func reset_save() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
	GameState.total_coins = 0
	GameState.best_round_score = 0
	GameState.round_number = 0
	GameState.round_coins = 0
	GameState.round_correct = 0
	GameState.round_wrong = 0
	GameState.round_missed = 0
	GameState.upgrade_levels.clear()
	GameState.remove_ads_owned = false
	GameState.trash_value_bonus = 0
	GameState.spawn_rate_bonus = 0.0
	GameState.mess_capacity_bonus = 0
	print("[SaveSystem] Save data reset")


func _recache_upgrade_effects() -> void:
	var upgrades_data: Array = _load_upgrades_data()
	for upgrade in upgrades_data:
		var uid: String = upgrade["id"]
		var level: int = GameState.upgrade_levels.get(uid, 0)
		var effect: float = upgrade.get("effect_per_level", 0.0) * level
		
		match uid:
			"trash_value":
				GameState.trash_value_bonus = int(effect)
			"spawn_rate":
				GameState.spawn_rate_bonus = effect
			"mess_capacity":
				GameState.mess_capacity_bonus = int(effect)


func _load_upgrades_data() -> Array:
	var file: FileAccess = FileAccess.open("res://data/upgrades.json", FileAccess.READ)
	if not file:
		push_error("[SaveSystem] Cannot read upgrades.json")
		return []
	
	var json: JSON = JSON.new()
	json.parse(file.get_as_text())
	return json.data as Array

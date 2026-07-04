extends Node

# SaveSystem — handles local JSON save/load + offline earnings + missions + daily reward

const SAVE_FILE: String = "user://trash_panda_save.json"


func save_game() -> void:
	GameState.last_save_timestamp = Time.get_unix_time_from_system()
	GameState.update_mission_progress()

	var data: Dictionary = {
		"version": "0.2.0",
		"total_coins": GameState.total_coins,
		"best_round_score": GameState.best_round_score,
		"round_number": GameState.round_number,
		"empire_level": GameState.empire_level,
		"upgrade_levels": GameState.upgrade_levels.duplicate(),
		"remove_ads_owned": GameState.remove_ads_owned,
		"last_save_timestamp": GameState.last_save_timestamp,
		"last_daily_claim": GameState.last_daily_claim,
		"missions": _serialize_missions(),
		"lifetime_total_sorted": GameState.lifetime_total_sorted,
		"lifetime_best_combo": GameState.lifetime_best_combo,
		"lifetime_rounds_played": GameState.lifetime_rounds_played,
		"lifetime_upgrades_purchased": GameState.lifetime_upgrades_purchased,
		"settings": GameState.settings.duplicate()
	}

	var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var json_string: String = JSON.stringify(data, "\t")
		file.store_string(json_string)
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
	GameState.empire_level = data.get("empire_level", 0)
	GameState.remove_ads_owned = data.get("remove_ads_owned", false)
	GameState.last_save_timestamp = data.get("last_save_timestamp", 0)
	GameState.last_daily_claim = data.get("last_daily_claim", "")
	GameState.lifetime_total_sorted = data.get("lifetime_total_sorted", 0)
	GameState.lifetime_best_combo = data.get("lifetime_best_combo", 0)
	GameState.lifetime_rounds_played = data.get("lifetime_rounds_played", 0)
	GameState.lifetime_upgrades_purchased = data.get("lifetime_upgrades_purchased", 0)

	# Load settings
	var saved_settings: Dictionary = data.get("settings", {})
	for key in saved_settings:
		GameState.settings[key] = saved_settings[key]

	var upgrades: Dictionary = data.get("upgrade_levels", {})
	for key in upgrades:
		GameState.upgrade_levels[key] = upgrades[key]

	_recache_upgrade_effects()

	# Restore missions
	var saved_missions: Dictionary = data.get("missions", {})
	if saved_missions.is_empty():
		GameState.init_missions()
	else:
		GameState.missions = saved_missions

	_calculate_offline_earnings()

	print("[SaveSystem] Game loaded successfully")
	return true


func reset_save() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
	GameState.total_coins = 0
	GameState.best_round_score = 0
	GameState.round_number = 0
	GameState.empire_level = 0
	GameState.round_coins = 0
	GameState.round_correct = 0
	GameState.round_wrong = 0
	GameState.round_missed = 0
	GameState.combo = 0
	GameState.max_combo = 0
	GameState.round_ad_claimed = false
	GameState.offline_earnings_pending = 0
	GameState.last_save_timestamp = 0
	GameState.last_daily_claim = ""
	GameState.missions.clear()
	GameState.lifetime_total_sorted = 0
	GameState.lifetime_best_combo = 0
	GameState.lifetime_rounds_played = 0
	GameState.lifetime_upgrades_purchased = 0
	GameState.upgrade_levels.clear()
	GameState.remove_ads_owned = false
	GameState.trash_value_bonus = 0
	GameState.spawn_rate_bonus = 0.0
	GameState.mess_capacity_bonus = 0


func _calculate_offline_earnings() -> void:
	var rate: float = GameState.get_offline_earnings_rate()
	if rate <= 0.0 or GameState.last_save_timestamp <= 0:
		GameState.offline_earnings_pending = 0
		return

	var now: int = Time.get_unix_time_from_system()
	var elapsed_minutes: float = (now - GameState.last_save_timestamp) / 60.0
	elapsed_minutes = minf(elapsed_minutes, Tuning.OFFLINE_MAX_MINUTES)

	var earned: int = int(elapsed_minutes * rate)
	if earned > 0:
		GameState.offline_earnings_pending = earned
		GameState.total_coins += earned


func claim_offline_earnings_display() -> int:
	var val: int = GameState.offline_earnings_pending
	GameState.offline_earnings_pending = 0
	return val


func _serialize_missions() -> Dictionary:
	var result: Dictionary = {}
	for key in GameState.missions:
		var m: Dictionary = GameState.missions[key]
		result[key] = {
			"progress": m.get("progress", 0),
			"completed": m.get("completed", false),
			"claimed": m.get("claimed", false)
		}
	return result


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

extends Node

# GameState — manages persistent game state + missions + progression + daily reward

# Persistent data
var total_coins: int = 0
var best_round_score: int = 0
var remove_ads_owned: bool = false
var upgrade_levels: Dictionary = {}
var last_save_timestamp: int = 0
var empire_level: int = 0

# Settings (persisted)
var settings: Dictionary = {
	sfx_enabled = true,
	debug_overlay = false,
	vibration_enabled = false
}

# Round-specific (reset each round)
var round_coins: int = 0
var round_correct: int = 0
var round_wrong: int = 0
var round_missed: int = 0
var round_number: int = 0
var combo: int = 0
var max_combo: int = 0
var round_ad_claimed: bool = false

# Upgrade effect cache
var trash_value_bonus: int = 0
var spawn_rate_bonus: float = 0.0
var mess_capacity_bonus: int = 0

# Offline earnings
var offline_earnings_pending: int = 0

# Missions
var missions: Dictionary = {}  # mission_id -> {progress, completed, claimed}

# Daily reward
var last_daily_claim: String = ""  # "YYYY-MM-DD"

# Lifetime stats (for missions)
var lifetime_total_sorted: int = 0
var lifetime_best_combo: int = 0
var lifetime_rounds_played: int = 0
var lifetime_upgrades_purchased: int = 0


func reset_round() -> void:
	round_coins = 0
	round_correct = 0
	round_wrong = 0
	round_missed = 0
	combo = 0
	max_combo = 0
	round_ad_claimed = false
	round_number += 1


func add_coins(amount: int) -> void:
	var val: int = maxi(amount, 0)
	round_coins += val
	total_coins += val


func add_correct_sort() -> void:
	round_correct += 1
	lifetime_total_sorted += 1
	combo += 1
	if combo > max_combo:
		max_combo = combo
	if combo > lifetime_best_combo:
		lifetime_best_combo = combo


func add_wrong_sort() -> void:
	round_wrong += 1
	combo = 0


func add_missed_item() -> void:
	round_missed += 1
	combo = 0


func apply_round_earnings() -> void:
	total_coins += round_coins
	lifetime_rounds_played += 1
	if round_coins > best_round_score:
		best_round_score = round_coins
	# Empire level = rounds completed (cumulative)
	empire_level = lifetime_rounds_played


func add_upgrade_purchase() -> void:
	lifetime_upgrades_purchased += 1


func get_upgrade_level(upgrade_id: String) -> int:
	return upgrade_levels.get(upgrade_id, 0)


func set_upgrade_level(upgrade_id: String, level: int) -> void:
	upgrade_levels[upgrade_id] = level


func get_mess_capacity() -> int:
	var base: int = Tuning.BASE_MESS_CAPACITY + mess_capacity_bonus
	# Extra capacity for first 3 rounds
	if round_number <= 3:
		base += Tuning.EARLY_MESS_EXTRA
	return base


func get_trash_value_multiplier() -> int:
	return 1 + trash_value_bonus


func get_spawn_interval() -> float:
	var interval: float = Tuning.BASE_SPAWN_INTERVAL - spawn_rate_bonus
	# Slower spawns for first 3 rounds
	if round_number <= 3:
		interval += Tuning.EARLY_SPAWN_BONUS
	return maxf(Tuning.MIN_SPAWN_INTERVAL, interval)


func get_offline_earnings_rate() -> float:
	var level: int = upgrade_levels.get("offline_earnings", 0)
	return level * Tuning.OFFLINE_RATE_PER_LEVEL


func is_daily_reward_available() -> bool:
	var today: String = Time.get_date_string_from_system()
	return today != last_daily_claim


func claim_daily_reward() -> int:
	if not is_daily_reward_available():
		return 0
	last_daily_claim = Time.get_date_string_from_system()
	total_coins += Tuning.DAILY_REWARD_AMOUNT
	return Tuning.DAILY_REWARD_AMOUNT


func init_missions() -> void:
	if missions.is_empty():
		missions = {
			"sort_25": {"name": "Sorter Apprentice", "desc": "Sort 25 items", "progress": 0, "req": 25, "reward": Tuning.MISSION_SORT_25_REWARD, "completed": false, "claimed": false},
			"combo_10": {"name": "Combo King", "desc": "Hit a 10x combo", "progress": 0, "req": 10, "reward": Tuning.MISSION_COMBO_10_REWARD, "completed": false, "claimed": false},
			"coins_500": {"name": "Trash Tycoon", "desc": "Earn 500 coins total", "progress": 0, "req": 500, "reward": Tuning.MISSION_COINS_500_REWARD, "completed": false, "claimed": false},
			"rounds_3": {"name": "Dedicated Raccoon", "desc": "Complete 3 rounds", "progress": 0, "req": 3, "reward": Tuning.MISSION_ROUNDS_3_REWARD, "completed": false, "claimed": false},
			"upgrade_1": {"name": "Upgrader", "desc": "Buy 1 upgrade", "progress": 0, "req": 1, "reward": Tuning.MISSION_UPGRADE_1_REWARD, "completed": false, "claimed": false}
		}


func update_mission_progress() -> void:
	if missions.is_empty():
		init_missions()

	_update_mission("sort_25", lifetime_total_sorted)
	_update_mission("combo_10", lifetime_best_combo)
	_update_mission("coins_500", total_coins)
	_update_mission("rounds_3", lifetime_rounds_played)
	_update_mission("upgrade_1", lifetime_upgrades_purchased)


func _update_mission(id: String, value: int) -> void:
	if not missions.has(id):
		return
	var m: Dictionary = missions[id]
	if m.completed:
		return
	m.progress = mini(value, m.req)
	if m.progress >= m.req:
		m.completed = true
		print("[Missions] Completed: ", m.name)


func claim_mission_reward(id: String) -> int:
	if not missions.has(id):
		return 0
	var m: Dictionary = missions[id]
	if not m.completed or m.claimed:
		return 0
	m.claimed = true
	total_coins += m.reward
	print("[Missions] Claimed reward: ", m.name, " +", m.reward)
	return m.reward


func get_missions_list() -> Array:
	if missions.is_empty():
		init_missions()
	var result: Array = []
	for key in missions:
		var m: Dictionary = missions[key].duplicate()
		m.id = key
		result.append(m)
	return result

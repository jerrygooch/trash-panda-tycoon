extends Node

# GameState — manages persistent game state: coins, upgrades, best score, combo, offline earnings
# This is an autoload. Access via GameState from any script.

## Persistent data
var total_coins: int = 0
var best_round_score: int = 0
var remove_ads_owned: bool = false
var upgrade_levels: Dictionary = {}  # upgrade_id -> level
var last_save_timestamp: int = 0     # Unix timestamp of last save (offline earnings)

## Round-specific (reset each round)
var round_coins: int = 0
var round_correct: int = 0
var round_wrong: int = 0
var round_missed: int = 0
var round_number: int = 0
var combo: int = 0          # consecutive correct sorts this round
var max_combo: int = 0      # highest combo reached this round
var round_ad_claimed: bool = false  # prevent double-dip

## Upgrade effect cache (recalculated on load / upgrade purchase)
var trash_value_bonus: int = 0
var spawn_rate_bonus: float = 0.0
var mess_capacity_bonus: int = 0

## Offline earnings state
var offline_earnings_pending: int = 0  # coins earned while away, shown on next visit


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
	combo += 1
	if combo > max_combo:
		max_combo = combo


func add_wrong_sort() -> void:
	round_wrong += 1
	combo = 0


func add_missed_item() -> void:
	round_missed += 1
	combo = 0


func apply_round_earnings() -> void:
	total_coins += round_coins
	if round_coins > best_round_score:
		best_round_score = round_coins


func get_upgrade_level(upgrade_id: String) -> int:
	return upgrade_levels.get(upgrade_id, 0)


func set_upgrade_level(upgrade_id: String, level: int) -> void:
	upgrade_levels[upgrade_id] = level


func get_mess_capacity() -> int:
	return 5 + mess_capacity_bonus


func get_trash_value_multiplier() -> int:
	return 1 + trash_value_bonus


func get_spawn_interval() -> float:
	return maxf(0.5, 1.8 - spawn_rate_bonus)


func get_offline_earnings_rate() -> float:
	# coins per minute per level
	var level: int = upgrade_levels.get("offline_earnings", 0)
	return level * 0.5

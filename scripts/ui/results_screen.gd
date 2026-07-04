extends Control

# ResultsScreen — round results + mission progress

signal next_round_requested()
signal upgrade_requested()
signal watch_ad_requested()

var _results_data: Dictionary = {}


func display_results(results: Dictionary) -> void:
	_results_data = results

	%RoundResultsLabel.text = "Round " + str(results.get("round_number", 0)) + " Complete!"
	%CoinsEarnedLabel.text = "\U0001FA99 " + str(results.get("coins", 0))
	%CorrectLabel.text = "\U00002705 Correct: " + str(results.get("correct", 0))
	%WrongLabel.text = "\U0000274C Wrong: " + str(results.get("wrong", 0))
	%MissedLabel.text = "\U0001F4A8 Missed: " + str(results.get("missed", 0))

	var max_combo: int = results.get("max_combo", 0)
	%ComboLabel.text = "\U0001F525 Best Combo: x" + str(max_combo) if max_combo >= 2 else ""
	%TotalCoinsLabel.text = "Total: \U0001FA99 " + str(results.get("total_coins", 0))
	%EmpireLabel.text = "\U0001F3C6 Empire Level: " + str(results.get("empire_level", 0))

	# Missions
	var missions: Array = results.get("missions", [])
	var mission_text: String = ""
	var any_active: bool = false
	for m in missions:
		var status_icon: String = "\U00002705" if m.completed else "\U000025AB"
		mission_text += "%s %s: %d/%d" % [status_icon, m.name, m.progress, m.req] + "\n"
		if m.completed and not m.claimed:
			any_active = true
	%MissionLabel.text = mission_text.strip_edges()

	# Show claim button if any missions completed but unclaimed
	if %MissionClaimButton:
		%MissionClaimButton.visible = any_active

	# Reset ad button if not claimed
	if GameState and not GameState.round_ad_claimed:
		%WatchAdButton.disabled = false
		%WatchAdButton.text = "Watch Ad x2"
		%WatchAdButton.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))


func _on_claim_missions_pressed() -> void:
	var total: int = 0
	var missions: Array = _results_data.get("missions", [])
	for m in missions:
		if m.completed and not m.claimed:
			total += GameState.claim_mission_reward(m.id)
	if total > 0:
		# Refresh display
		_results_data["total_coins"] = GameState.total_coins
		_results_data["missions"] = GameState.get_missions_list()
		display_results(_results_data)
		SaveSystem.save_game()


func _on_next_round_pressed() -> void: next_round_requested.emit()
func _on_upgrade_pressed() -> void: upgrade_requested.emit()
func _on_watch_ad_pressed() -> void: watch_ad_requested.emit()

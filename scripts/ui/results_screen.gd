extends Control

# ResultsScreen — shows round results with Next Round, Upgrade, Watch Ad buttons

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
	
	# Reset ad button if not already claimed this round
	if GameState and not GameState.round_ad_claimed:
		%WatchAdButton.disabled = false
		%WatchAdButton.text = "Watch Ad x2"
		%WatchAdButton.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))


func _on_next_round_pressed() -> void:
	next_round_requested.emit()


func _on_upgrade_pressed() -> void:
	upgrade_requested.emit()


func _on_watch_ad_pressed() -> void:
	watch_ad_requested.emit()

extends Control

# ResultsScreen — shows round results with Next Round, Upgrade, Watch Ad buttons

signal next_round_requested()
signal upgrade_requested()
signal watch_ad_requested()

var _results_data: Dictionary = {}


func display_results(results: Dictionary) -> void:
	_results_data = results
	
	%CoinsEarnedLabel.text = "\U0001FA99 " + str(results.get("coins", 0))
	%CorrectLabel.text = "Correct: " + str(results.get("correct", 0))
	%WrongLabel.text = "Wrong: " + str(results.get("wrong", 0))
	%MissedLabel.text = "Missed: " + str(results.get("missed", 0))
	%TotalCoinsLabel.text = "Total: \U0001FA99 " + str(results.get("total_coins", 0))
	%RoundResultsLabel.text = "Round " + str(results.get("round_number", 0)) + " Complete!"


func _on_next_round_pressed() -> void:
	next_round_requested.emit()


func _on_upgrade_pressed() -> void:
	upgrade_requested.emit()


func _on_watch_ad_pressed() -> void:
	watch_ad_requested.emit()

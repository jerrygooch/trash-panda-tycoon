extends Control

# MainMenu — title screen with daily reward

signal game_started()


func _ready() -> void:
	var continue_btn: Button = %ContinueButton
	if continue_btn:
		continue_btn.disabled = not FileAccess.file_exists("user://trash_panda_save.json")
	_update_daily_button()


func _update_daily_button() -> void:
	var btn: Button = %DailyRewardButton
	if not btn: return
	if GameState and GameState.is_daily_reward_available():
		btn.text = "\U0001F4B0 Daily Reward (+%d coins)" % Tuning.DAILY_REWARD_AMOUNT
		btn.disabled = false
	else:
		btn.text = "\U00002705 Today's Reward Claimed"
		btn.disabled = true


func _on_daily_reward_pressed() -> void:
	if not GameState or not GameState.is_daily_reward_available(): return
	var amount: int = GameState.claim_daily_reward()
	if amount > 0:
		SaveSystem.save_game()
		_update_daily_button()
		_show_feedback("+" + str(amount) + " daily coins!")


func _show_feedback(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
	label.position = Vector2(160, 460)
	label.size = Vector2(400, 40)
	add_child(label)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", 430.0, 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(0.5)
	tween.finished.connect(label.queue_free)


func _on_new_game_pressed() -> void:
	if FileAccess.file_exists("user://trash_panda_save.json"):
		var dialog: AcceptDialog = AcceptDialog.new()
		dialog.title = "New Game"
		dialog.dialog_text = "Start fresh? Your current save will be overwritten."
		dialog.confirmed.connect(_confirm_new_game)
		add_child(dialog)
		dialog.popup_centered()
	else:
		_confirm_new_game()


func _confirm_new_game() -> void:
	SaveSystem.reset_save()
	game_started.emit()


func _on_continue_pressed() -> void:
	if SaveSystem.load_game():
		game_started.emit()
	else:
		game_started.emit()


func _on_reset_save_pressed() -> void:
	var dialog: ConfirmationDialog = ConfirmationDialog.new()
	dialog.title = "Reset Save"
	dialog.dialog_text = "Are you sure? ALL progress will be lost forever!"
	dialog.confirmed.connect(_do_reset_save)
	add_child(dialog)
	dialog.popup_centered()


func _do_reset_save() -> void:
	SaveSystem.reset_save()
	var continue_btn: Button = %ContinueButton
	if continue_btn: continue_btn.disabled = true
	_update_daily_button()

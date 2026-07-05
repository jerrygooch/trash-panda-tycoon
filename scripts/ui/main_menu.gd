extends Control

# MainMenu — title screen with daily reward
# Defensive signal wiring: connects buttons in _ready() even if scene connections are missing.

signal game_started()


func _ready() -> void:
	_find_and_wire_buttons()
	_update_daily_button()
	print("[MainMenu] Ready — buttons wired")


func _find_and_wire_buttons() -> void:
	# New Game / Play
	var play_btn: Button = %PlayButton
	if play_btn:
		if not play_btn.pressed.is_connected(_on_new_game_pressed):
			play_btn.pressed.connect(_on_new_game_pressed)
		print("[MainMenu] Play button found")
	else:
		push_error("[MainMenu] NewGameButton not found!")

	# Continue
	var cont_btn: Button = %ContinueButton
	if cont_btn:
		cont_btn.disabled = not FileAccess.file_exists("user://trash_panda_save.json")
		if not cont_btn.pressed.is_connected(_on_continue_pressed):
			cont_btn.pressed.connect(_on_continue_pressed)
		print("[MainMenu] Continue button found, disabled=", cont_btn.disabled)
	else:
		push_error("[MainMenu] ContinueButton not found!")

	# Reset Save
	var reset_btn: Button = %ResetSaveButton
	if reset_btn:
		if not reset_btn.pressed.is_connected(_on_reset_save_pressed):
			reset_btn.pressed.connect(_on_reset_save_pressed)
		print("[MainMenu] Reset Save button found")
	else:
		push_error("[MainMenu] ResetSaveButton not found!")

	# Daily Reward
	var daily_btn: Button = %DailyRewardButton
	if daily_btn:
		if not daily_btn.pressed.is_connected(_on_daily_reward_pressed):
			daily_btn.pressed.connect(_on_daily_reward_pressed)
		print("[MainMenu] Daily Reward button found")
	else:
		push_error("[MainMenu] DailyRewardButton not found!")


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
	print("[MainMenu] Daily Reward pressed")
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
	print("[MainMenu] New Game pressed")
	_confirm_new_game()


func _confirm_new_game() -> void:
	print("[MainMenu] Confirming new game")
	SaveSystem.reset_save()
	print("[MainMenu] Emitting game_started")
	game_started.emit()


func _on_continue_pressed() -> void:
	print("[MainMenu] Continue pressed")
	if SaveSystem.load_game():
		print("[MainMenu] Save loaded, emitting game_started")
		game_started.emit()
	else:
		print("[MainMenu] No save found, starting fresh")
		game_started.emit()


func _on_reset_save_pressed() -> void:
	print("[MainMenu] Reset Save pressed")
	var dialog: ConfirmationDialog = ConfirmationDialog.new()
	dialog.title = "Reset Save"
	dialog.dialog_text = "Are you sure? ALL progress will be lost forever!"
	dialog.confirmed.connect(_do_reset_save)
	add_child(dialog)
	dialog.popup_centered()


func _do_reset_save() -> void:
	print("[MainMenu] Resetting save")
	SaveSystem.reset_save()
	var continue_btn: Button = %ContinueButton
	if continue_btn: continue_btn.disabled = true
	_update_daily_button()

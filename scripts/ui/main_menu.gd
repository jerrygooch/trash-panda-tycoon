extends Control

# MainMenu — title screen with New Game / Continue / Reset Save

signal game_started()


func _ready() -> void:
	var continue_btn: Button = %ContinueButton
	if continue_btn:
		continue_btn.disabled = not FileAccess.file_exists("user://trash_panda_save.json")


func _on_new_game_pressed() -> void:
	if FileAccess.file_exists("user://trash_panda_save.json"):
		# Confirm new game
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
		# No save found, just start
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
	if continue_btn:
		continue_btn.disabled = true
	
	print("[MainMenu] Save reset complete")

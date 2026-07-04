extends Control

# PauseMenu — with Settings button

signal resume_requested()
signal restart_requested()
signal main_menu_requested()
signal settings_requested()


func _on_resume_pressed() -> void: resume_requested.emit()
func _on_restart_pressed() -> void: restart_requested.emit()
func _on_main_menu_pressed() -> void: main_menu_requested.emit()
func _on_settings_pressed() -> void: settings_requested.emit()

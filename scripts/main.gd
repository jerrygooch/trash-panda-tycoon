extends Node

# Main — entry point that manages scene transitions

var _main_menu_scene: PackedScene = preload("res://scenes/ui/MainMenu.tscn")
var _game_scene: PackedScene = preload("res://scenes/game/Game.tscn")

var _current_scene: Node = null


func _ready() -> void:
	# Try loading save data on startup
	if FileAccess.file_exists("user://trash_panda_save.json"):
		SaveSystem.load_game()
	
	_show_main_menu()


func _show_main_menu() -> void:
	_clear_scene()
	
	var menu: Node = _main_menu_scene.instantiate()
	add_child(menu)
	_current_scene = menu
	
	menu.connect("game_started", _on_game_started)


func _on_game_started() -> void:
	_clear_scene()
	
	var game: Node = _game_scene.instantiate()
	add_child(game)
	_current_scene = game


func _clear_scene() -> void:
	if _current_scene and is_instance_valid(_current_scene):
		_current_scene.queue_free()
		_current_scene = null

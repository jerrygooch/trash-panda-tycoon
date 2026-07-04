extends Node

func _ready() -> void:
	print("=== FULL MAIN FLOW TEST ===\n")
	
	# 1. Test Main.tscn loading
	var main_scene = preload("res://Main.tscn")
	print("Main.tscn loaded: ", main_scene)
	var main = main_scene.instantiate()
	add_child(main)
	print("Main instantiated and added to tree")
	
	# Wait a frame for _ready to fire
	await get_tree().process_frame
	
	# Now MainMenu should be a child
	var menu = main.get_child(0) if main.get_child_count() > 0 else null
	if menu:
		print("MainMenu children: ", menu.get_children().map(func(c): return c.name))
	else:
		print("WARNING: Main has no children!")
	
	# Check tree structure
	print("Tree print:")
	print_tree_pretty()
	
	# Check if game_started is connected
	if menu and menu.has_signal("game_started"):
		var connections = menu.get_signal_connection_list("game_started")
		if connections.size() > 0:
			print("\ngame_started signal connected to: ", connections[0].get("callable", "unknown"))
		else:
			print("\nWARNING: game_started has NO connections!")
	
	# Now simulate clicking NewGameButton
	if menu:
		print("\n--- Simulating NewGameButton press ---")
		
		# Find NewGameButton directly
		var new_game_btn = menu.get_node_or_null("ButtonContainer/VBox/NewGameButton")
		if new_game_btn:
			print("Found NewGameButton: ", new_game_btn)
			print("NewGameButton text: ", new_game_btn.text)
			print("NewGameButton is disabled: ", new_game_btn.disabled)
		else:
			print("WARNING: Could not find NewGameButton!")
		
		# Find by unique name
		var btn_by_unique = menu.find_child("NewGameButton", true, false)
		print("NewGameButton via find_child: ", btn_by_unique)
		
		# Emit pressed signal to simulate click
		new_game_btn.pressed.emit()
		print("pressed signal emitted")
		
		# Check AcceptDialog
		await get_tree().process_frame
		
		for child in menu.get_children():
			if child is AcceptDialog:
				print("AcceptDialog found: ", child.dialog_text)
				child.confirmed.emit()
				print("OK clicked on AcceptDialog")
				break
		
		await get_tree().process_frame
		
		print("\nTree after New Game:")
		print_tree_pretty()
	
	print("\n=== TEST COMPLETE ===")
	get_tree().quit()

extends SceneTree

const OUT: String = "screenshots/batch015"
var _ok: int = 0
var _bad: int = 0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	print("=== Visual Asset Verification ===")
	
	# 1. MainMenu loads
	var menu = load("res://scenes/ui/MainMenu.tscn").instantiate()
	check(menu.get_script() != null, "MainMenu script")
	root.add_child(menu)
	for i in range(3): await process_frame
	menu.queue_free()
	
	# 2. Mascot texture
	var tp = "res://art/generated/batch013/curated/mascot_raccoon.png"
	check(ResourceLoader.exists(tp), "Mascot texture")
	
	# 3. Item icons
	for item in ["banana_peel", "pizza_slice", "soda_can", "tin_can", "plastic_bottle", "plastic_bag"]:
		var ip = "res://art/generated/batch013/curated/icon_%s.png" % item
		check(ResourceLoader.exists(ip), "Icon %s" % item)
	
	# 4. Bin icons
	for cat in ["food", "metal", "plastic"]:
		var bp = "res://art/generated/batch013/curated/bin_%s.png" % cat
		check(ResourceLoader.exists(bp), "Bin %s" % cat)
	
	# 5. Contact sheet
	check(ResourceLoader.exists("res://art/generated/batch013/contact_sheet.png"), "Contact sheet")
	
	# 6. Game loads
	var gs = load("res://scenes/game/Game.tscn").instantiate()
	check(gs.get_script() != null, "Game scene")
	root.add_child(gs)
	for i in range(3): await process_frame
	gs.queue_free()
	
	# 7. Results loads
	var rs = load("res://scenes/ui/ResultsScreen.tscn").instantiate()
	check(rs.get_script() != null, "ResultsScreen")
	
	# 8. Upgrade loads
	var us = load("res://scenes/ui/UpgradeScreen.tscn").instantiate()
	check(us.get_script() != null, "UpgradeScreen")
	
	# 9. Settings loads
	var ss = load("res://scenes/ui/SettingsScreen.tscn").instantiate()
	check(ss.get_script() != null, "SettingsScreen")
	
	# Report
	var report = "Screenshot note: Viewport capture unsupported in Godot headless mode.\n"
	report += "For actual screenshots: run Godot editor, press F5, then computer_use capture.\n"
	report += "Asset verification: %d pass, %d fail\nRESULT: %s\n" % [_ok, _bad, "ALL CLEAN" if _bad == 0 else "ISSUES FOUND"]
	var f = FileAccess.open(OUT + "/verification_report.txt", FileAccess.WRITE)
	if f: f.store_string(report)
	print("Report: ", OUT, "/verification_report.txt")
	print("\n%d pass, %d fail" % [_ok, _bad])
	if _bad == 0: print("ALL ASSETS VERIFIED")
	else: print("SOME ASSETS MISSING")
	quit()

func check(cond: bool, label: String) -> void:
	if cond: _ok += 1; print("  [PASS] ", label)
	else: _bad += 1; print("  [FAIL] ", label)

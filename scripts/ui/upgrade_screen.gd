extends Control

# UpgradeScreen — purchase upgrades with next-effect preview and feedback

signal upgrades_closed()

var _upgrade_data: Array = []
var _upgrade_widgets: Dictionary = {}


func _ready() -> void:
	_upgrade_data = _load_upgrades()
	_build_upgrade_list()


func _load_upgrades() -> Array:
	var file: FileAccess = FileAccess.open("res://data/upgrades.json", FileAccess.READ)
	if not file:
		push_error("[UpgradeScreen] Cannot open upgrades.json")
		return []
	var json: JSON = JSON.new()
	json.parse(file.get_as_text())
	return json.data as Array


func _build_upgrade_list() -> void:
	var container: VBoxContainer = %UpgradeListContainer
	if not container: return
	for child in container.get_children(): child.queue_free()

	for upgrade in _upgrade_data:
		var panel: Panel = Panel.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_theme_constant_override("separation", 3)
		panel.add_child(vbox)

		# Name
		var name_label: Label = Label.new()
		name_label.text = upgrade["name"]
		name_label.add_theme_font_size_override("font_size", 20)
		name_label.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(name_label)

		# Description + next effect
		var current_level: int = GameState.get_upgrade_level(upgrade["id"])
		var desc_text: String = upgrade["description"]
		if current_level < upgrade["max_level"]:
			var effect_val: float = upgrade.get("effect_per_level", 0.0) * (current_level + 1)
			var unit: String = upgrade.get("effect_unit", "")
			desc_text += "\nNext: %s%d %s" % ["+" if effect_val >= 0 else "", effect_val, unit]
		var desc_label: Label = Label.new()
		desc_label.text = desc_text
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		vbox.add_child(desc_label)

		# Level / max
		var level_label: Label = Label.new()
		level_label.text = "Level %d / %d" % [current_level, upgrade["max_level"]]
		level_label.add_theme_font_size_override("font_size", 14)
		level_label.add_theme_color_override("font_color", Color.ORANGE)
		vbox.add_child(level_label)

		# Buy button
		var buy_btn: Button = Button.new()
		buy_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		buy_btn.custom_minimum_size = Vector2(200, 50)
		buy_btn.pressed.connect(_on_buy_upgrade.bind(upgrade["id"]))
		vbox.add_child(buy_btn)

		_update_button_state(buy_btn, upgrade)
		_upgrade_widgets[upgrade["id"]] = {"button": buy_btn, "level_label": level_label}

		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_all", 6)
		margin.add_child(panel)
		container.add_child(margin)

	_show()


func _on_buy_upgrade(upgrade_id: String) -> void:
	var upgrade: Dictionary = _find_upgrade(upgrade_id)
	if upgrade.is_empty(): return
	var current_level: int = GameState.get_upgrade_level(upgrade_id)
	if current_level >= upgrade["max_level"]: return
	var cost: int = _get_upgrade_cost(upgrade, current_level)
	if GameState.total_coins < cost: return

	GameState.total_coins -= cost
	GameState.set_upgrade_level(upgrade_id, current_level + 1)
	GameState.add_upgrade_purchase()
	SaveSystem._recache_upgrade_effects()

	var widget: Dictionary = _upgrade_widgets.get(upgrade_id, {})
	var btn: Button = widget.get("button")
	var lvl_label: Label = widget.get("level_label")
	if btn: _update_button_state(btn, upgrade)
	if lvl_label:
		lvl_label.text = "Level %d / %d" % [current_level + 1, upgrade["max_level"]]

	_show()
	SaveSystem.save_game()


func _update_button_state(btn: Button, upgrade: Dictionary) -> void:
	var level: int = GameState.get_upgrade_level(upgrade["id"])
	if level >= upgrade["max_level"]:
		btn.text = "MAXED"
		btn.disabled = true
		return
	var cost: int = _get_upgrade_cost(upgrade, level)
	if GameState.total_coins >= cost:
		btn.text = "Buy \U0001FA99 " + str(cost)
		btn.disabled = false
	else:
		btn.text = "\U0001FA99 " + str(cost)
		btn.disabled = true


func _get_upgrade_cost(upgrade: Dictionary, level: int) -> int:
	return int(upgrade.get("base_cost", Tuning.UPGRADE_COST_BASE) * pow(Tuning.UPGRADE_COST_MULTIPLIER, level))


func _find_upgrade(uid: String) -> Dictionary:
	for u in _upgrade_data:
		if u["id"] == uid: return u
	return {}


func _show() -> void:
	var coins_label: Label = %CoinsLabel
	if coins_label:
		coins_label.text = "\U0001FA99 " + str(GameState.total_coins)
	for upgrade in _upgrade_data:
		var widget: Dictionary = _upgrade_widgets.get(upgrade["id"], {})
		var btn: Button = widget.get("button")
		if btn: _update_button_state(btn, upgrade)


func _on_back_pressed() -> void:
	hide()
	upgrades_closed.emit()

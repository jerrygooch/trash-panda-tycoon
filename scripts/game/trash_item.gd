extends Control
class_name TrashItem

# TrashItem — draggable trash object with rounded placeholder visuals
# Supports mouse and touch input.

signal item_dropped_on_bin()

var item_id: String = ""
var item_name: String = ""
var category: String = ""
var base_value: int = 1
var icon_color: Color = Color.WHITE

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _original_pos: Vector2 = Vector2.ZERO
var _value_mult: int = 1
var _drag_touch_index: int = -1

var _bg: ColorRect
var _icon_label: Label
var _border: ColorRect
var _shadow: ColorRect


func initialize(data: Dictionary, value_mult: int = 1) -> void:
	item_id = data.get("id", "")
	item_name = data.get("name", "Trash")
	category = data.get("category", "food")
	base_value = data.get("base_value", 1)
	icon_color = Color(data.get("color", "#FFFFFF"))
	_value_mult = value_mult
	_build_visual()


func _build_visual() -> void:
	custom_minimum_size = Vector2(60, 60)
	mouse_filter = MOUSE_FILTER_PASS

	# Shadow
	_shadow = ColorRect.new()
	_shadow.color = Color(0, 0, 0, 0.25)
	_shadow.size = Vector2(66, 66)
	_shadow.position = Vector2(-3, 3)
	_shadow.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_shadow)

	# Border ring
	_border = ColorRect.new()
	_border.color = icon_color.lightened(0.3)
	_border.size = Vector2(64, 64)
	_border.position = Vector2(-2, -2)
	_border.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_border)

	# Main background
	_bg = ColorRect.new()
	_bg.color = icon_color
	_bg.size = Vector2(60, 60)
	_bg.position = Vector2(0, 0)
	_bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_bg)

	# Icon character
	_icon_label = Label.new()
	_icon_label.text = _get_icon_character()
	_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_icon_label.size = Vector2(60, 60)
	_icon_label.position = Vector2(0, 0)
	_icon_label.add_theme_font_size_override("font_size", 30)
	_icon_label.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_icon_label)


func _get_icon_character() -> String:
	match item_id:
		"banana_peel": return "\U0001F34C"
		"pizza_slice": return "\U0001F355"
		"soda_can": return "\U0001F964"
		"tin_can": return "\U0001F96B"
		"plastic_bottle": return "\U0001F4E6"
		"plastic_bag": return "\U0001F4B0"
		_: return "?"


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: _start_drag(get_global_mouse_position())
			else: _end_drag()
	elif event is InputEventMouseMotion and _dragging:
		_handle_drag_move(event.global_position)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var rect: Rect2 = Rect2(global_position, Vector2(60, 60))
		if event.pressed and rect.has_point(event.position):
			_drag_touch_index = event.index
			_start_drag(event.position)
		elif not event.pressed and event.index == _drag_touch_index:
			_drag_touch_index = -1
			_end_drag()
	elif event is InputEventScreenDrag and _dragging and event.index == _drag_touch_index:
		_handle_drag_move(event.position)


func _start_drag(pos: Vector2) -> void:
	_dragging = true
	_drag_offset = global_position - pos
	_original_pos = global_position
	z_index = 10
	scale = Vector2(1.15, 1.15)
	if _shadow: _shadow.modulate = Color(0, 0, 0, 0.4)


func _end_drag() -> void:
	if not _dragging: return
	_dragging = false
	scale = Vector2.ONE
	z_index = 1
	if _shadow: _shadow.modulate = Color(0, 0, 0, 0.25)
	_check_drop()


func _handle_drag_move(pos: Vector2) -> void:
	var target: Vector2 = pos + _drag_offset
	var vs: Vector2 = get_viewport().get_visible_rect().size
	target.x = clampf(target.x, 0, maxf(0, vs.x - 60))
	target.y = clampf(target.y, 0, maxf(0, vs.y - 60))
	global_position = target


func _check_drop() -> void:
	var game: Node = get_node_or_null("/root/Game")
	if not game: _snap_back(); return
	var bc: Control = game.get_node_or_null("BinsContainer")
	if not bc: _snap_back(); return
	var dp: Vector2 = global_position + Vector2(30, 30)
	for bn in bc.get_children():
		if bn.has_method("get_drop_rect") and bn.get_drop_rect().has_point(dp):
			item_dropped_on_bin.emit()
			return
	_snap_back()


func _snap_back() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", _original_pos, 0.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

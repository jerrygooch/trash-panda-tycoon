extends Control
class_name TrashItem

# TrashItem — a draggable trash object that can be sorted into bins
# Input: supports both mouse (InputEventMouseButton/Motion) and touch
#        (InputEventScreenTouch/Drag). Mouse events come via _gui_input;
#        touch events come via _input (global). Both converge on _check_drop().

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
var _drag_touch_index: int = -1  # track which finger is dragging this item

var _rect: ColorRect
var _label: Label
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
	_shadow = ColorRect.new()
	_shadow.color = Color.BLACK
	_shadow.modulate = Color(0, 0, 0, 0.3)
	_shadow.size = Vector2(64, 64)
	_shadow.position = Vector2(-2, 2)
	_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shadow)

	_rect = ColorRect.new()
	_rect.color = icon_color
	_rect.size = Vector2(60, 60)
	_rect.position = Vector2(0, 0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)

	_label = Label.new()
	_label.text = _get_icon_character()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size = Vector2(60, 60)
	_label.position = Vector2(0, 0)
	_label.add_theme_font_size_override("font_size", 32)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)


func _get_icon_character() -> String:
	match item_id:
		"banana_peel": return "\U0001F34C"
		"pizza_slice": return "\U0001F355"
		"soda_can": return "\U0001F964"
		"tin_can": return "\U0001F96B"
		"plastic_bottle": return "\U0001F4E6"
		"plastic_bag": return "\U0001F4B0"
		_: return "?"


# --- Mouse input (via _gui_input — Control-local coordinates) ---

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _dragging:
		_handle_drag_move(event.global_position)


# --- Touch input (via _input — screen-space coordinates) ---
# Touch events use _input() so they work globally when the item is moving.

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch_touch(event)
	elif event is InputEventScreenDrag and _dragging and event.index == _drag_touch_index:
		_handle_drag_move(event.position)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(get_global_mouse_position())
		else:
			_end_drag()


func _handle_touch_touch(event: InputEventScreenTouch) -> void:
	# Only respond to touches that started in this item's bounds
	var rect: Rect2 = Rect2(global_position, Vector2(60, 60))
	if event.pressed and rect.has_point(event.position):
		_drag_touch_index = event.index
		_start_drag(event.position)
	elif not event.pressed and event.index == _drag_touch_index:
		_drag_touch_index = -1
		_end_drag()


func _start_drag(pos: Vector2) -> void:
	_dragging = true
	_drag_offset = global_position - pos
	_original_pos = global_position
	z_index = 10  # stay above other items while dragging
	scale = Vector2(1.15, 1.15)


func _end_drag() -> void:
	if not _dragging:
		return
	_dragging = false
	scale = Vector2.ONE
	z_index = 1
	_check_drop()


func _handle_drag_move(pos: Vector2) -> void:
	var target: Vector2 = pos + _drag_offset
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	target.x = clampf(target.x, 0, maxf(0, viewport_size.x - 60))
	target.y = clampf(target.y, 0, maxf(0, viewport_size.y - 60))
	global_position = target


func _check_drop() -> void:
	var game: Node = get_node_or_null("/root/Game")
	if not game:
		_snap_back()
		return

	var bins_container: Control = game.get_node_or_null("%BinsContainer")
	if not bins_container:
		_snap_back()
		return

	# Use the center of the item for hit-testing
	var drop_pos: Vector2 = global_position + Vector2(30, 30)
	var dropped_on_bin: bool = false

	for bin_node in bins_container.get_children():
		if bin_node.has_method("get_drop_rect"):
			var rect: Rect2 = bin_node.get_drop_rect()
			if rect.has_point(drop_pos):
				dropped_on_bin = true
				item_dropped_on_bin.emit()
				break

	if not dropped_on_bin:
		_snap_back()


func _snap_back() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", _original_pos, 0.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

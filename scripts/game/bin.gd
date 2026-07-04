extends ColorRect
class_name Bin

# Bin — a drop target that accepts matching trash items

var category: String = "food"
var bin_name: String = "Bin"

@onready var _label: Label = $Label
@onready var _highlight: ColorRect = $Highlight


func _ready() -> void:
	if _label and is_instance_valid(_label):
		_label.text = _get_icon() + "  " + bin_name
	if _highlight:
		_highlight.hide()


func set_data(cat: String, name: String) -> void:
	category = cat
	bin_name = name
	if _label and is_instance_valid(_label):
		_label.text = _get_icon() + "  " + name


func get_drop_rect() -> Rect2:
	# Expanded rect for drag forgiveness — 15px extra on each side
	var inset: float = -15.0
	return Rect2(
		global_position.x - inset,
		global_position.y - inset,
		size.x + inset * 2.0,
		size.y + inset * 2.0
	)


func flash_correct() -> void:
	if not _highlight:
		return
	_highlight.color = Color(0, 1, 0, 0.3)
	_highlight.show()
	var tween: Tween = create_tween()
	tween.tween_property(_highlight, "modulate:a", 0.0, 0.3)
	tween.finished.connect(_highlight.hide)


func flash_wrong() -> void:
	if not _highlight:
		return
	_highlight.color = Color(1, 0, 0, 0.4)
	_highlight.show()
	var tween: Tween = create_tween()
	tween.tween_property(_highlight, "modulate:a", 0.0, 0.3)
	tween.finished.connect(_highlight.hide)


func _get_icon() -> String:
	match category:
		"food": return "\U0001F372"
		"metal": return "\U00002699"
		"plastic": return "\U0001F4E6"
		_: return "?"

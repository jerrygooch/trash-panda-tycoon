extends ColorRect
class_name Bin

# Bin — a drop target that accepts matching trash items

var category: String = "food"
var bin_name: String = "Bin"

@onready var _label: Label = $Label


func _ready() -> void:
	if _label and is_instance_valid(_label):
		_label.text = _get_icon() + "  " + bin_name


func set_data(cat: String, name: String) -> void:
	category = cat
	bin_name = name
	if _label and is_instance_valid(_label):
		_label.text = _get_icon() + "  " + name


func get_drop_rect() -> Rect2:
	# Return the global-space rectangle for drop detection
	return Rect2(global_position, size)


func _get_icon() -> String:
	match category:
		"food": return "\U0001F372"
		"metal": return "\U00002699"
		"plastic": return "\U0001F4E6"
		_: return "?"

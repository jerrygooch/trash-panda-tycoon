extends ColorRect
class_name Bin

# Bin — drop target with highlight states, expanded hit zone, and texture icon support

var category: String = "food"
var bin_name: String = "Bin"

@onready var _label: Label = $Label
@onready var _highlight: ColorRect = $Highlight
@onready var _bottom_bar: ColorRect = $BottomBar
@onready var _icon_texture: TextureRect = $IconTexture


func _ready() -> void:
	_update_label()
	_try_load_texture()
	if _highlight: _highlight.hide()


func set_data(cat: String, name: String) -> void:
	category = cat
	bin_name = name
	_update_label()
	_try_load_texture()


func _update_label() -> void:
	if _label: _label.text = _get_icon() + "  " + bin_name


func _try_load_texture() -> void:
	if not _icon_texture: return
	var tex_path: String = "res://art/generated/batch013/curated/bin_" + category + ".png"
	if ResourceLoader.exists(tex_path):
		var tex: Texture2D = load(tex_path)
		if tex:
			_icon_texture.texture = tex
			_icon_texture.show()
			return
	# Fallback: hide texture rect, emoji label handles it
	_icon_texture.hide()


func get_drop_rect() -> Rect2:
	var inset: float = -15.0
	return Rect2(
		global_position.x - inset, global_position.y - inset,
		size.x + inset * 2.0, size.y + inset * 2.0
	)


func flash_correct() -> void:
	if not _highlight: return
	_highlight.color = Color(0, 1, 0, 0.3)
	_highlight.show()
	var tw: Tween = create_tween()
	tw.tween_property(_highlight, "modulate:a", 0.0, 0.3)
	tw.finished.connect(_highlight.hide)


func flash_wrong() -> void:
	if not _highlight: return
	_highlight.color = Color(1, 0, 0, 0.4)
	_highlight.show()
	var tw: Tween = create_tween()
	tw.tween_property(_highlight, "modulate:a", 0.0, 0.3)
	tw.finished.connect(_highlight.hide)


func _get_icon() -> String:
	match category:
		"food": return "\U0001F372"
		"metal": return "\U00002699"
		"plastic": return "\U0001F4E6"
		_: return "?"

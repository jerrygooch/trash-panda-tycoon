extends Control
class_name ConveyorBelt

# ConveyorBelt — visual conveyor area with scrolling stripe animation

var _scroll_offset: float = 0.0
var _lines: Array = []

@onready var _belt_rect: ColorRect = $BeltRect


func _ready() -> void:
	_build_stripes()


func _build_stripes() -> void:
	for i in range(15):
		var line: ColorRect = ColorRect.new()
		line.color = Color(0.25, 0.25, 0.3, 0.3)
		line.size = Vector2(660, 2)
		line.position = Vector2(30, i * 40)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(line)
		_lines.append(line)
	
	# Center lane markers
	for lane in range(3):
		var marker: ColorRect = ColorRect.new()
		marker.color = Color(0.35, 0.35, 0.4, 0.15)
		marker.size = Vector2(2, 580)
		marker.position = Vector2(120 + lane * 240, 0)
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(marker)


func _process(delta: float) -> void:
	_scroll_offset = fmod(_scroll_offset + delta * 80.0, 40.0)
	
	for i in range(_lines.size()):
		var line: ColorRect = _lines[i]
		var base_y: float = i * 40.0
		var y: float = base_y + _scroll_offset
		if y > 580.0:
			y -= 40.0 * _lines.size()
		line.position.y = y

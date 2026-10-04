## StoryCard — bölüm başında tam ekran hikâye kartı.
##
## `present(header, title, brief, goal)` çağrılır; ekrana dokunma / `attack` /
## `jump` / Enter ile kapanır ve `finished` yayar. Aktifken dünya duraklatılır
## (Main yönetir). Metinler StoryData'dan gelir.
class_name StoryCard
extends CanvasLayer

signal finished

## Yanlışlıkla (basılı tuşla) geçilmesin diye girdinin yok sayıldığı süre.
const MIN_SHOW := 0.7
const WIDTH := 900.0

var _root: Control
var _header: Label
var _title: Label
var _brief: Label
var _goal: Label
var _hint: Label
var _active := false
var _t := 0.0


func _ready() -> void:
	layer = 7
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.03, 0.06, 0.9)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(WIDTH, 0)
	box.add_theme_constant_override(&"separation", 16)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(box)

	_header = _label(box, 20, UIStyle.ACCENT)
	_title = _label(box, 50, Color(0.98, 0.92, 0.84))
	_title.add_theme_color_override(&"font_outline_color", Color(0.5, 0.1, 0.12))
	_title.add_theme_constant_override(&"outline_size", 8)

	var rule := ColorRect.new()
	rule.color = Color(UIStyle.ACCENT, 0.55)
	rule.custom_minimum_size = Vector2(WIDTH, 2)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(rule)

	_brief = _label(box, 26, Color(0.93, 0.93, 0.96))
	_goal = _label(box, 23, Color(1.0, 0.84, 0.4))
	_hint = _label(box, 18, Color(0.75, 0.75, 0.8))


func _label(parent: Control, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.custom_minimum_size = Vector2(WIDTH, 0)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override(&"font_size", font_size)
	label.add_theme_color_override(&"font_color", color)
	parent.add_child(label)
	return label


func is_active() -> bool:
	return _active


func present(header: String, title: String, brief: String, goal: String) -> void:
	_header.text = header
	_title.text = title.to_upper()
	_brief.text = brief
	_goal.text = "HEDEF  ·  %s" % goal if not goal.is_empty() else ""
	_goal.visible = not goal.is_empty()
	_hint.text = ""
	_t = 0.0
	_root.modulate.a = 0.0
	_active = true
	visible = true


func _process(delta: float) -> void:
	if not _active:
		return
	_t += delta
	_root.modulate.a = minf(_t * 4.0, 1.0)
	if _t >= MIN_SHOW:
		_hint.text = "▸  DEVAM ETMEK İÇİN DOKUN" if TouchControls.active_on_device() else "▸  Enter / J"
		_hint.modulate.a = 0.6 + 0.4 * sin(_t * 4.0)


func _input(event: InputEvent) -> void:
	if not _active:
		return
	var pressed: bool = (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or event.is_action_pressed(&"attack") or event.is_action_pressed(&"jump") \
		or event.is_action_pressed(&"ui_accept")
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	if _t >= MIN_SHOW:
		_close()


func _close() -> void:
	_active = false
	visible = false
	finished.emit()

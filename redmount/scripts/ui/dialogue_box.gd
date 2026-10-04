## DialogueBox — alt şeritte konuşan-adı + daktilo efektli replik kutusu (Görev 24).
##
## `play([{speaker, text}, ...])` çağrılır; her replik ekrana dokunma veya
## `attack`/`jump`/Enter ile ilerler. Bitince `finished` yayar. Aktifken dünya duraklatılır (Main dinler).
extends CanvasLayer

signal line_started(speaker: String)
signal finished

const CPS := 42.0  # karakter/sn
## Aynı dokunuş hem ekran olayı hem `attack` eylemi üretir; çift ilerlemeyi önler.
const ADVANCE_GAP_MS := 160
const SPEAKER_COLORS := {
	"REDMOUNT": Color(1.0, 0.72, 0.42),
	"GAZELLE": Color(0.42, 0.9, 0.82),
	"KARAHANLI": Color(1.0, 0.45, 0.4),
}

@onready var _panel: PanelContainer = $Panel
@onready var _name: Label = $Panel/M/Name
@onready var _body: RichTextLabel = $Panel/M/Body
@onready var _hint: Label = $Panel/M/Hint

var _lines: Array = []
var _idx := 0
var _full := ""
var _shown := 0.0
var _active := false
var _next_advance_ms := 0


func _ready() -> void:
	layer = 6
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if TouchControls.active_on_device():
		_panel.offset_right = -190.0  # sağ alttaki DEVAM düğmesine yer bırak
	_style()


func _style() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.06, 0.09, 0.95)
	sb.border_color = Color(1.0, 0.65, 0.4, 0.5)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	_panel.add_theme_stylebox_override(&"panel", sb)
	_name.add_theme_color_override(&"font_color", Color(1.0, 0.72, 0.42))
	_name.add_theme_font_size_override(&"font_size", 24)
	_body.add_theme_font_size_override(&"normal_font_size", 26)
	_hint.add_theme_color_override(&"font_color", Color(0.7, 0.7, 0.75))
	_hint.add_theme_font_size_override(&"font_size", 16)


func is_active() -> bool:
	return _active


func play(lines: Array) -> void:
	if lines.is_empty():
		finished.emit()
		return
	_lines = lines
	_idx = 0
	_active = true
	visible = true
	# Dövüşten kalan tuş/dokunuş ilk repliği atlamasın.
	_next_advance_ms = Time.get_ticks_msec() + 300
	_show_line()


func _show_line() -> void:
	var l: Dictionary = _lines[_idx]
	_name.text = l.get("speaker", "")
	_name.add_theme_color_override(&"font_color",
		SPEAKER_COLORS.get(_name.text, Color(1.0, 0.72, 0.42)))
	_full = l.get("text", "")
	_shown = 0.0
	_body.text = ""
	_hint.text = ""
	line_started.emit(_name.text)


func _process(delta: float) -> void:
	if not _active:
		return
	if _shown < _full.length():
		_shown = minf(_shown + CPS * delta, float(_full.length()))
		_body.text = _full.substr(0, int(_shown))
		if _shown >= _full.length():
			_hint.text = _hint_text()
	if Input.is_action_just_pressed(&"attack") or Input.is_action_just_pressed(&"jump") \
			or Input.is_action_just_pressed(&"ui_accept"):
		_request_advance()


## Telefonda ekranın herhangi bir yerine dokunmak repliği ilerletir.
func _input(event: InputEvent) -> void:
	if not _active:
		return
	if (event is InputEventScreenTouch and event.pressed) \
			or (event is InputEventMouseButton and event.pressed
				and event.button_index == MOUSE_BUTTON_LEFT):
		_request_advance()


func _request_advance() -> void:
	var now := Time.get_ticks_msec()
	if now < _next_advance_ms:
		return
	_next_advance_ms = now + ADVANCE_GAP_MS
	_advance()


func _hint_text() -> String:
	return "▸  DOKUN" if TouchControls.active_on_device() else "▸  Enter / J"


func _advance() -> void:
	if _shown < _full.length():
		_shown = float(_full.length())  # önce tümünü göster
		_body.text = _full
		_hint.text = _hint_text()
		return
	_idx += 1
	if _idx >= _lines.size():
		_active = false
		visible = false
		finished.emit()
	else:
		_show_line()

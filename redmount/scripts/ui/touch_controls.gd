class_name TouchControls
extends CanvasLayer

signal pause_requested
signal retry_requested
signal next_requested
signal menu_requested

# Offsets are measured from the nearest horizontal edge and from the bottom.
const BUTTONS := [
	["move_left", "◀", 67, Vector2(90, 112)],
	["move_right", "▶", 67, Vector2(238, 112)],
	["crouch", "▼", 46, Vector2(164, 248)],
	["dash", "ATIL", 46, Vector2(320, 252)],
	["attack", "VUR", 69, Vector2(-95, 112)],
	["jump", "ZIPLA", 69, Vector2(-245, 112)],
	["heavy_attack", "AĞIR", 46, Vector2(-104, 253)],
	["fire", "ATEŞ", 46, Vector2(-232, 253)],
	["pause", "II", 36, Vector2(0, -52)],  # x = 0: yatayda ortalı
	["retry", "TEKRAR", 80, Vector2(-210, 112)],
	["next", "DEVAM", 80, Vector2(-210, 112)],
	["menu", "MENÜ", 80, Vector2(-410, 112)],
]

var _buttons: Dictionary = {}
var _labels: Dictionary = {}
var _mode := "hidden"
var _has_gun := false
var _can_throw := false


func _ready() -> void:
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = active_on_device()
	if not visible:
		return
	for spec in BUTTONS:
		var key: String = spec[0]
		var radius: int = spec[2]
		var button := TouchScreenButton.new()
		button.name = key
		button.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
		button.texture_normal = _disc(radius, Color(0.08, 0.07, 0.12, 0.48), Color(0.95, 0.76, 0.37, 0.7))
		button.texture_pressed = _disc(radius, Color(0.95, 0.66, 0.19, 0.8), Color(1, 1, 1, 0.95))
		var shape := CircleShape2D.new()
		shape.radius = radius * 1.08
		button.shape = shape
		button.shape_centered = true
		button.passby_press = key in ["move_left", "move_right"]
		if InputMap.has_action(key) and key != "pause":
			button.action = key
		add_child(button)
		var label := Label.new()
		label.text = spec[1]
		label.size = Vector2.ONE * radius * 2
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 33 if spec[1].length() <= 2 else 21)
		label.add_theme_color_override("font_color", Color(1, 0.97, 0.88))
		label.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.08))
		label.add_theme_constant_override("outline_size", 5)
		add_child(label)
		_buttons[key] = button
		_labels[key] = label
	_buttons["pause"].pressed.connect(func() -> void: pause_requested.emit())
	_buttons["retry"].pressed.connect(func() -> void: retry_requested.emit())
	_buttons["next"].pressed.connect(func() -> void: next_requested.emit())
	_buttons["menu"].pressed.connect(func() -> void: menu_requested.emit())
	get_viewport().size_changed.connect(_layout)
	_layout()
	set_mode("play")


func is_enabled() -> bool:
	return visible


## Çentik / yuvarlak köşe payı, görüntü birimiyle: Vector2(sol, sağ).
static func safe_insets(viewport: Viewport) -> Vector2:
	var window := DisplayServer.window_get_size()
	var safe := DisplayServer.get_display_safe_area()
	if window.x <= 0 or safe.size.x <= 0:
		return Vector2.ZERO
	var unit := viewport.get_visible_rect().size.x / float(window.x)
	return Vector2(
		clampf(safe.position.x * unit, 0.0, 140.0),
		clampf((window.x - safe.end.x) * unit, 0.0, 140.0))


static func active_on_device() -> bool:
	return OS.has_feature("mobile") or DisplayServer.is_touchscreen_available() \
		or OS.get_environment("REDMOUNT_TOUCH_CONTROLS") == "1"


## Oyuncunun durumu: silah yokken ATEŞ gizlenir; fırlatılabilir düşman
## yakındayken AĞIR düğmesi FIRLAT olur.
func set_context(has_gun: bool, can_throw: bool) -> void:
	if not visible or (has_gun == _has_gun and can_throw == _can_throw):
		return
	_has_gun = has_gun
	_can_throw = can_throw
	_apply_mode()


func set_mode(mode: String, has_next_level: bool = true) -> void:
	if not visible or _mode == mode:
		return
	_mode = mode
	_apply_mode(has_next_level)


func _apply_mode(has_next_level: bool = true) -> void:
	var mode := _mode
	for key in _buttons:
		var show: bool = (mode == "play" and key not in ["retry", "next", "menu"]
				and (key != "fire" or _has_gun)) \
			or (mode == "dialogue" and key == "attack") \
			or (mode == "dead" and key in ["retry", "pause"]) \
			or (mode == "results" and key in ["next", "menu"])
		_buttons[key].visible = show
		_labels[key].visible = show
		if not show and InputMap.has_action(key):
			Input.action_release(key)
	_labels["attack"].text = "DEVAM" if mode == "dialogue" else "VUR"
	_labels["heavy_attack"].text = "FIRLAT" if _can_throw else "AĞIR"
	_labels["next"].text = "SONRAKİ" if has_next_level else "BAŞTAN"


func _layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var insets := safe_insets(get_viewport())
	for spec in BUTTONS:
		var key: String = spec[0]
		var radius: int = spec[2]
		var offset: Vector2 = spec[3]
		var center := Vector2(
			offset.x + insets.x if offset.x > 0 else viewport_size.x + offset.x - insets.y,
			viewport_size.y - offset.y if offset.y > 0 else -offset.y,
		)
		if is_zero_approx(offset.x):
			center.x = viewport_size.x * 0.5
		_buttons[key].position = center - Vector2.ONE * radius
		_labels[key].position = center - Vector2.ONE * radius


static func _disc(radius: int, fill: Color, ring: Color) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.82, 0.9, 1.0])
	gradient.colors = PackedColorArray([fill, fill, ring, Color(ring, 0.0)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = radius * 2
	texture.height = radius * 2
	return texture

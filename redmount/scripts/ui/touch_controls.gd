class_name TouchControls
extends CanvasLayer

signal pause_requested
signal retry_requested
signal next_requested
signal menu_requested

# Offsets are measured from the nearest horizontal edge and from the bottom.
## [eylem, yazı, yarıçap, konum, piksel düğme dokusu, piksel ikon ("" = yazı)]
const BUTTONS := [
	["move_left", "", 68, Vector2(90, 112), "buyuk", "sol"],
	["move_right", "", 68, Vector2(238, 112), "buyuk", "sag"],
	["crouch", "", 46, Vector2(164, 248), "kucuk", "asagi"],
	["dash", "ATIL", 46, Vector2(320, 252), "kucuk", ""],
	["attack", "VUR", 68, Vector2(-95, 112), "buyuk", ""],
	["jump", "ZIPLA", 68, Vector2(-245, 112), "buyuk", ""],
	["heavy_attack", "AĞIR", 46, Vector2(-104, 253), "kucuk", ""],
	["fire", "ATEŞ", 46, Vector2(-232, 253), "kucuk", ""],
	## Kayma tekmesi kısayolu: telefonda koşarken ▼'a aynı başparmakla basmak zor.
	["slide", "KAY", 46, Vector2(-372, 214), "kucuk", ""],
	["pause", "", 36, Vector2(0, -52), "mini", "durdur"],  # x = 0: yatayda ortalı
	["retry", "TEKRAR", 80, Vector2(-210, 112), "genis", ""],
	["next", "DEVAM", 80, Vector2(-210, 112), "genis", ""],
	["menu", "MENÜ", 80, Vector2(-410, 112), "genis", ""],
]
const ART_DIR := "res://assets/ui/pixel/"
## Dokunma geri bildirimi: kısa, hafif "tık" (ms, güç). Hareket okları hariç —
## başparmak oklar arasında kayarken sürekli vızıldamasın.
const TICK_MS := 12
const TICK_STRENGTH := 0.3
const GAMEPLAY_ACTIONS := ["move_left", "move_right", "crouch", "dash", "attack", "jump", "heavy_attack", "fire", "slide"]

var _buttons: Dictionary = {}
var _labels: Dictionary = {}
var _icons: Dictionary = {}
## Düğme dokusunun ekrandaki ölçeği (sanat pikseli → ekran), _layout ile çarpılır.
var _art_scale: Dictionary = {}
var _mode := "hidden"
var _has_gun := false
var _can_throw := false
var _has_next_level := true


func _ready() -> void:
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = active_on_device()
	if not visible:
		return
	for spec in BUTTONS:
		var key: String = spec[0]
		var radius: int = spec[2]
		var art: String = spec[4]
		var normal := load(ART_DIR + "touch_%s.png" % art) as Texture2D
		var button := TouchScreenButton.new()
		button.name = key
		button.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
		button.texture_normal = normal
		button.texture_pressed = load(ART_DIR + "touch_%s_basili.png" % art) as Texture2D
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var art_size := float(normal.get_width())
		_art_scale[key] = radius * 2.0 / art_size
		var shape := CircleShape2D.new()
		shape.radius = art_size * 0.5 * 1.08
		button.shape = shape
		button.shape_centered = true
		button.passby_press = key in ["move_left", "move_right"]
		if InputMap.has_action(key) and key != "pause":
			button.action = key
		add_child(button)
		var icon := Sprite2D.new()
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.position = Vector2.ONE * art_size * 0.5
		if spec[5] != "":
			icon.texture = load(ART_DIR + "touch_ikon_%s.png" % spec[5]) as Texture2D
		button.add_child(icon)
		var label := Label.new()
		label.text = spec[1]
		label.size = Vector2.ONE * radius * 2
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_override("font", PixelUI.font())
		label.add_theme_font_size_override("font_size", 36 if radius >= 68 else 24)
		label.add_theme_color_override("font_color", Color(1, 0.97, 0.88))
		label.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.08))
		label.add_theme_constant_override("outline_size", 6)
		add_child(label)
		## Basılınca ikon/yazı bir sanat pikseli aşağı iner (düğme gömülür) + tık.
		button.pressed.connect(_on_press.bind(key))
		button.released.connect(_on_release.bind(key))
		_buttons[key] = button
		_labels[key] = label
		_icons[key] = icon
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
	if not OS.has_feature("mobile"):
		return Vector2.ZERO
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
	_apply_mode(_has_next_level)


func set_mode(mode: String, has_next_level: bool = true) -> void:
	if not visible or (_mode == mode and _has_next_level == has_next_level):
		return
	_mode = mode
	_has_next_level = has_next_level
	_apply_mode(has_next_level)


static func release_gameplay_inputs() -> void:
	for action in GAMEPLAY_ACTIONS:
		Input.action_release(action)


func _apply_mode(has_next_level: bool = true) -> void:
	var mode := _mode
	for key in _buttons:
		var show: bool = (mode == "play" and key not in ["retry", "next", "menu"]
				and (key != "fire" or _has_gun)) \
			or (mode == "dialogue" and key == "attack") \
			or (mode == "cutscene" and key in ["attack", "pause"]) \
			or (mode == "dead" and key in ["retry", "pause"]) \
			or (mode == "results" and key in ["next", "menu"])
		_buttons[key].visible = show
		_labels[key].visible = show
		if not show and InputMap.has_action(key):
			Input.action_release(key)
	_labels["attack"].text = "DEVAM" if mode in ["dialogue", "cutscene"] else "VUR"
	_labels["pause"].text = "ATLA" if mode == "cutscene" else ""
	_icons["pause"].visible = mode != "cutscene"
	_labels["heavy_attack"].text = "FIRLAT" if _can_throw else "AĞIR"
	_labels["next"].text = "SONRAKİ" if has_next_level else "BAŞTAN"


func _layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var insets := safe_insets(get_viewport())
	var vertical := safe_vertical_insets(get_viewport())
	var button_scale := clampf(viewport_size.y / 720.0, 0.85, 1.2)
	for spec in BUTTONS:
		var key: String = spec[0]
		var radius: int = spec[2]
		var offset: Vector2 = spec[3]
		var center := Vector2(
			offset.x * button_scale + insets.x if offset.x > 0 else viewport_size.x + offset.x * button_scale - insets.y,
			viewport_size.y - offset.y * button_scale - vertical.y if offset.y > 0 else -offset.y * button_scale + vertical.x,
		)
		if is_zero_approx(offset.x):
			center.x = viewport_size.x * 0.5
		_buttons[key].scale = Vector2.ONE * button_scale * float(_art_scale[key])
		_labels[key].scale = Vector2.ONE * button_scale
		_buttons[key].position = center - Vector2.ONE * radius * button_scale
		_labels[key].position = center - Vector2.ONE * radius * button_scale


static func safe_vertical_insets(viewport: Viewport) -> Vector2:
	if not OS.has_feature("mobile"):
		return Vector2.ZERO
	var window := DisplayServer.window_get_size()
	var safe := DisplayServer.get_display_safe_area()
	if window.y <= 0 or safe.size.y <= 0:
		return Vector2.ZERO
	var unit := viewport.get_visible_rect().size.y / float(window.y)
	return Vector2(
		clampf(safe.position.y * unit, 0.0, 100.0),
		clampf((window.y - safe.end.y) * unit, 0.0, 100.0))


func _on_press(key: String) -> void:
	_icons[key].offset.y = 1.0
	_labels[key].position.y += _labels[key].scale.y * float(_art_scale[key])
	if key not in ["move_left", "move_right"]:
		haptic_tick()


func _on_release(key: String) -> void:
	_icons[key].offset.y = 0.0
	_layout()


## Kısa dokunma titreşimi; ayarlardan kapatılabilir (Save.vibration).
static func haptic_tick() -> void:
	if OS.has_feature("mobile") and Save.vibration:
		Input.vibrate_handheld(TICK_MS, TICK_STRENGTH)

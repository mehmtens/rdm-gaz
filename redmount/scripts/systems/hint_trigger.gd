## HintTrigger — oyuncu girince kısa, ENGELLEMEYEN ipucu gösterir (Görev 28).
##
## DialogueTrigger'ın aksine oyunu duraklatmaz; dünya-uzayında süzülen bir
## baloncuk fade-in yapar, oyuncu çıkınca (+ `linger` sn) fade-out. `once` ile
## bir kez. Öğretici bölümde mekanik ilk gerektiği yere konur. Grup: "hint".
##
## `button` verilirse baloncuğun üstünde o hareketin düğmesi gösterilir:
## telefonda ekrandaki düğmenin adı, klavyede tuş.
class_name HintTrigger
extends Area2D

## hareket → [dokunmatik düğme, klavye tuşu]
const BUTTONS := {
	"move": ["◀  ▶", "A  /  D"],
	"attack": ["VUR", "J"],
	"heavy_attack": ["AĞIR", "K"],
	"jump": ["ZIPLA", "BOŞLUK"],
	"crouch": ["▼  +  ZIPLA", "S  +  BOŞLUK"],
	"dash": ["ATIL", "CTRL"],
	"fire": ["ATEŞ", "L"],
	"shop": ["DOKUN", "E"],
}
const WIDTH := 440.0

@export_multiline var text: String = ""
## BUTTONS anahtarı (boşsa yalnız metin gösterilir).
@export var button: String = ""
@export var once: bool = true
## Oyuncu çıktıktan sonra ipucunun ekranda kalma süresi (sn).
@export var linger: float = 1.8
## Tetik kutusu genişliği (px).
@export var width: float = 110.0

var _bubble: VBoxContainer
var _shown: bool = false
var _inside: bool = false
var _fade: float = 0.0
var _timer: float = 0.0


func _ready() -> void:
	add_to_group(&"hint")
	collision_layer = 0
	collision_mask = 2  # player

	var col := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(width, 300.0)
	col.shape = r
	col.position = Vector2(0, -140.0)
	add_child(col)

	_bubble = VBoxContainer.new()
	_bubble.custom_minimum_size = Vector2(WIDTH, 0.0)
	_bubble.add_theme_constant_override(&"separation", 6)
	_bubble.modulate.a = 0.0
	_bubble.z_index = 40
	add_child(_bubble)

	if BUTTONS.has(button):
		var badge := Label.new()
		badge.text = BUTTONS[button][0 if TouchControls.active_on_device() else 1]
		badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		badge.add_theme_font_size_override(&"font_size", 22)
		badge.add_theme_color_override(&"font_color", Color(1.0, 0.97, 0.88))
		# Ekrandaki dokunmatik düğmelerle aynı görünüm: koyu disk, altın halka.
		badge.add_theme_stylebox_override(&"normal",
			_box(Color(0.08, 0.07, 0.12, 0.92), Color(0.95, 0.76, 0.37), 3, 20))
		_bubble.add_child(badge)

	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override(&"font_color", Color(1.0, 0.96, 0.86))
	label.add_theme_font_size_override(&"font_size", 20)
	label.add_theme_stylebox_override(&"normal",
		_box(Color(0.07, 0.06, 0.11, 0.86), Color(0.72, 0.54, 0.38, 0.9), 2, 4))
	_bubble.add_child(label)

	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)


static func _box(fill: Color, border: Color, border_w: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 7
	sb.content_margin_bottom = 7
	return sb


func _on_enter(b: Node) -> void:
	if not b.is_in_group(&"player"):
		return
	if once and _shown:
		return
	_inside = true
	_shown = true
	_timer = linger


func _on_exit(b: Node) -> void:
	if b.is_in_group(&"player"):
		_inside = false


func _process(delta: float) -> void:
	var target := 0.0
	if _inside:
		target = 1.0
	elif _timer > 0.0:
		_timer -= delta
		target = 1.0
	_fade = move_toward(_fade, target, delta * 3.5)
	_bubble.modulate.a = _fade
	# Baloncuk alt kenarından sabitlenir; metin uzadıkça yukarı doğru büyür.
	_bubble.position = Vector2(-WIDTH * 0.5, -150.0 - _bubble.size.y - _fade * 10.0)
	if _fade <= 0.001 and _shown and not _inside and _timer <= 0.0:
		set_process(false)

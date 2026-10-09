## TouchControls — Dan the Man düzeni: solda ◀ ▶ (parmak kaydırılabilir) ve ▼,
## sağda VUR / ZIPLA, üstte ÖZEL ve tabanca elindeyken ATEŞ. Çoklu dokunuş için TouchScreenButton kullanır.
class_name TouchControls
extends CanvasLayer

const BTN := [
	# action, etiket, yarıçap, kenar ("L"/"R"), merkez ofseti (kenardan, alttan)
	["left", "◀", 84, "L", Vector2(120, 118)],
	["right", "▶", 84, "L", Vector2(300, 118)],
	["down", "▼", 52, "L", Vector2(210, 262)],
	["attack", "VUR", 92, "R", Vector2(318, 112)],
	["jump", "ZIPLA", 84, "R", Vector2(124, 150)],
	["special", "ÖZEL", 60, "R", Vector2(190, 318)],
	["shoot", "ATEŞ", 60, "R", Vector2(330, 300)],
]

var _buttons: Array = [] ## [TouchScreenButton, Label, def]


func _ready() -> void:
	layer = 8
	for d in BTN:
		var r: int = d[2]
		var b := TouchScreenButton.new()
		b.action = d[0]
		b.texture_normal = _disc(r, Color(0.08, 0.05, 0.12, 0.45), Color(1, 0.86, 0.45, 0.55))
		b.texture_pressed = _disc(r, Color(1, 0.82, 0.35, 0.55), Color(1, 1, 1, 0.9))
		var shape := CircleShape2D.new()
		shape.radius = r * 1.12 ## parmak için cömert dokunma alanı
		b.shape = shape
		b.shape_centered = true
		b.passby_press = d[0] in ["left", "right"]
		add_child(b)
		var l := Label.new()
		l.text = d[1]
		l.add_theme_font_size_override("font_size", 44 if d[1].length() == 1 else (30 if r > 70 else 24))
		l.add_theme_color_override("font_color", Color(1, 0.97, 0.9, 0.95))
		l.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.08, 0.9))
		l.add_theme_constant_override("outline_size", 8)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.size = Vector2(r * 2, r * 2)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(l)
		_buttons.append([b, l, d])
	get_viewport().size_changed.connect(_layout)
	_layout()


func _layout() -> void:
	var vp := get_viewport().get_visible_rect().size
	for e in _buttons:
		var d: Array = e[2]
		var r: int = d[2]
		var off: Vector2 = d[4]
		var c := Vector2(off.x if d[3] == "L" else vp.x - off.x, vp.y - off.y)
		e[0].position = c - Vector2(r, r)
		e[1].position = c - Vector2(r, r)


func _process(_dt: float) -> void:
	var p: Player = get_tree().get_first_node_in_group("player")
	var armed := p != null and p.weapon == "pistol"
	for e in _buttons:
		if e[2][0] == "shoot":
			e[0].visible = armed
			e[1].visible = armed
		e[1].scale = Vector2.ONE * (0.92 if e[0].is_pressed() else 1.0)
		e[1].pivot_offset = e[1].size / 2


## Yumuşak kenarlı daire dokusu (radyal gradyan).
static func _disc(r: int, fill: Color, ring: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.84, 0.88, 0.97, 1.0])
	g.colors = PackedColorArray([fill.lightened(0.08), fill, ring, ring, Color(ring, 0.0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = r * 2
	t.height = r * 2
	return t

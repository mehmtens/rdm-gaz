## Backdrop — çok katmanlı paralaks arka plan (Görev 17).
##
## En arkada biome'a göre seçilmiş İstanbul piksel sanatı panoraması (Haliç,
## tersane, surlar, saray) yavaşça kayar; önünde sürüklenen zerreler. Eski
## prosedürel dikdörtgen bina/üçgen dağ silüetleri kaldırıldı — bölümün kendi
## mekân atlası çizilmeyen yerlerde de ekran İstanbul sanatıyla dolu kalır. `biome` her bölümün ruh hâlini belirler. Level.gd bunu
## bölüm yüklenince kendi altına ekler (en arkaya, z_index çok negatif).
class_name Backdrop
extends Node2D

enum Biome { STREET, INDUSTRIAL, FORTRESS, KEEP }

@export var biome: Biome = Biome.STREET
## Bölümün dünya genişliği (silüetleri buna göre serpiştirir).
@export var world_left: float = -400.0
@export var world_right: float = 3600.0

var _cam: Camera2D
var _layers: Array = []  # [{node, fx, fy}]


func _ready() -> void:
	z_index = -100
	z_as_relative = false
	var pal := _palette()

	_add_layer(_SkyLayer.new(pal), 0.0, 0.0)
	_add_layer(_PanoramaLayer.new(biome), 0.06, 0.0)
	_add_layer(_MoteLayer.new(biome, pal), 0.9, 0.9)


func _add_layer(n: Node2D, fx: float, fy: float) -> void:
	add_child(n)
	_layers.append({"node": n, "fx": fx, "fy": fy})


func _process(_delta: float) -> void:
	if _cam == null or not is_instance_valid(_cam):
		_cam = get_viewport().get_camera_2d()
		if _cam == null:
			return
	var c := _cam.get_screen_center_position()
	for L in _layers:
		L.node.position = Vector2(c.x * (1.0 - L.fx), c.y * (1.0 - L.fy))


func _palette() -> Dictionary:
	match biome:
		Biome.INDUSTRIAL:
			return {
				"sky_top": Color(0.16, 0.17, 0.16), "sky_bot": Color(0.29, 0.27, 0.22),
				"far": Color(0.11, 0.12, 0.12), "mid": Color(0.16, 0.16, 0.15),
				"accent": Color(0.85, 0.45, 0.2), "haze": Color(0.3, 0.28, 0.22),
				"mote": Color(0.5, 0.45, 0.35),
			}
		Biome.FORTRESS:
			return {
				"sky_top": Color(0.08, 0.09, 0.13), "sky_bot": Color(0.2, 0.22, 0.3),
				"far": Color(0.09, 0.1, 0.14), "mid": Color(0.13, 0.14, 0.19),
				"accent": Color(0.55, 0.7, 1.0), "haze": Color(0.22, 0.24, 0.32),
				"mote": Color(0.6, 0.7, 0.9),
			}
		Biome.KEEP:
			return {
				"sky_top": Color(0.06, 0.05, 0.09), "sky_bot": Color(0.16, 0.1, 0.16),
				"far": Color(0.09, 0.07, 0.11), "mid": Color(0.14, 0.1, 0.15),
				"accent": Color(1.0, 0.6, 0.25), "haze": Color(0.18, 0.13, 0.19),
				"mote": Color(1.0, 0.7, 0.4),
			}
		_:  # STREET
			return {
				"sky_top": Color(0.1, 0.11, 0.2), "sky_bot": Color(0.4, 0.25, 0.28),
				"far": Color(0.12, 0.13, 0.2), "mid": Color(0.16, 0.17, 0.26),
				"accent": Color(1.0, 0.75, 0.4), "haze": Color(0.28, 0.22, 0.28),
				"mote": Color(0.8, 0.7, 0.55),
			}


# ------------------------------------------------------------------------

class _SkyLayer extends Node2D:
	var _pal: Dictionary
	func _init(pal: Dictionary) -> void:
		_pal = pal
	func _draw() -> void:
		var w := 2400.0
		var h := 1600.0
		var steps := 24
		for i in steps:
			var t0 := float(i) / steps
			var t1 := float(i + 1) / steps
			var col: Color = _pal.sky_top.lerp(_pal.sky_bot, ease(t0, 1.6))
			draw_rect(Rect2(-w, -h + (h * 2.0) * t0, w * 2.0, (h * 2.0) / steps + 1.0), col)


## Biome panoraması: mevcut İstanbul mekân sanatından bir kesit; yatayda
## ayna-döşenir (kenarlar dikişsiz birleşir) ve kamerayla çok yavaş kayar.
class _PanoramaLayer extends Node2D:
	const ART := [
		[preload("res://assets/backgrounds/level01_urban_dusk.png"), Rect2(0, 0, 1, 1)],
		[preload("res://assets/backgrounds/level03_heavy_industry.png"), Rect2(0, 0, 1, 1)],
		[preload("res://assets/backgrounds/level04_fortress_atlas.png"), Rect2(0, 0, 0.5, 0.39)],
		[preload("res://assets/backgrounds/level13_last_atlas.png"), Rect2(0.0, 0.5, 0.5, 0.45)],
	]
	var _tex: Texture2D
	var _src: Rect2

	func _init(biome: int) -> void:
		var entry: Array = ART[clampi(biome, 0, ART.size() - 1)]
		_tex = entry[0]
		var r: Rect2 = entry[1]
		var size := _tex.get_size()
		_src = Rect2(r.position * size, r.size * size)
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _draw() -> void:
		# Ekranı (1280x720, geniş oranlarda daha fazlası) dikeyde dolduracak ölçek.
		var h := 1180.0
		var w := h * _src.size.x / _src.size.y
		var cam := get_viewport().get_camera_2d()
		var center_x: float = -position.x + (cam.get_screen_center_position().x if cam else 0.0)
		var first := floori((center_x - 1600.0) / w)
		for i in range(first, first + int(ceilf(3200.0 / w)) + 2):
			var rect := Rect2(i * w, -h * 0.5 - 60.0, w, h)
			if posmod(i, 2) == 1:
				# Ayna kopya: karo kendi merkezinde yatay çevrilir, kenarlar dikişsiz birleşir.
				draw_set_transform(Vector2(2.0 * i * w + w, 0.0), 0.0, Vector2(-1.0, 1.0))
			draw_texture_rect_region(_tex, rect, _src)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	func _process(_delta: float) -> void:
		queue_redraw()


class _MoteLayer extends Node2D:
	var _biome: int
	var _pal: Dictionary
	var _t: float = 0.0
	var _pts: Array = []
	func _init(biome: int, pal: Dictionary) -> void:
		_biome = biome
		_pal = pal
		var rng := RandomNumberGenerator.new()
		rng.seed = 777
		for i in 46:
			_pts.append({
				"p": Vector2(rng.randf_range(-900, 900), rng.randf_range(-500, 400)),
				"spd": rng.randf_range(6.0, 26.0),
				"r": rng.randf_range(0.8, 2.6),
				"drift": rng.randf_range(-10.0, 10.0),
			})
	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()
	func _draw() -> void:
		var rising := _biome == 1 or _biome == 2  # ember/kıvılcım yukarı
		for m in _pts:
			var y: float = m.p.y + (_t * m.spd) * (-1.0 if rising else 1.0)
			y = fposmod(y + 500.0, 900.0) - 500.0
			var x: float = m.p.x + sin(_t * 0.4 + m.p.y) * m.drift
			x = fposmod(x + 900.0, 1800.0) - 900.0
			draw_circle(Vector2(x, y), m.r,
				Color(_pal.mote.r, _pal.mote.g, _pal.mote.b, 0.35))

## Backdrop — prosedürel çok katmanlı paralaks arka plan (Görev 17).
##
## Yeni sanat gerektirmez: gökyüzü gradyanı + 2 silüet katmanı + sis bandı +
## sürüklenen zerreler, hepsi `_draw` ile çizilir ve aktif `Camera2D`'ye göre
## paralaks kaydırılır. `biome` her bölümün ruh hâlini belirler. Level.gd bunu
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
	_add_layer(_SilhouetteLayer.new(biome, pal, world_left, world_right, 0), 0.12, 0.06)
	_add_layer(_SilhouetteLayer.new(biome, pal, world_left, world_right, 1), 0.34, 0.16)
	_add_layer(_HazeLayer.new(pal), 0.5, 0.36)
	_add_layer(_SilhouetteLayer.new(biome, pal, world_left, world_right, 2), 0.56, 0.28)
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
		# ufuk parıltısı
		draw_circle(Vector2(0, h * 0.55), 520.0, Color(_pal.accent.r, _pal.accent.g, _pal.accent.b, 0.10))


class _SilhouetteLayer extends Node2D:
	var _biome: int
	var _pal: Dictionary
	var _l: float
	var _r: float
	var _tier: int  # 0 = uzak, 1 = orta
	func _init(biome: int, pal: Dictionary, l: float, r: float, tier: int) -> void:
		_biome = biome
		_pal = pal
		_l = l - 600.0
		_r = r + 600.0
		_tier = tier
	func _draw() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = hash("%d-%d" % [_biome, _tier])
		var base_col: Color = _pal.far
		var ground_y := 140.0
		var sz := 1.0
		match _tier:
			1:
				base_col = _pal.mid
				ground_y = 90.0
				sz = 0.85
			2:
				base_col = _pal.mid.darkened(0.35)
				ground_y = 34.0
				sz = 1.25
		var x := _l
		while x < _r:
			var bw := rng.randf_range(70.0, 190.0) * sz
			var bh := rng.randf_range(120.0, 460.0) * (0.7 if _tier == 0 else (1.0 if _tier == 1 else 0.7))
			var col := base_col.lightened(rng.randf_range(-0.04, 0.06))
			match _biome:
				Backdrop.Biome.INDUSTRIAL:  # bacalar + tanklar
					draw_rect(Rect2(x, ground_y - bh, bw, bh), col)
					if rng.randf() < 0.3:
						draw_rect(Rect2(x + bw * 0.3, ground_y - bh - 60.0, bw * 0.35, 60.0), col)
				Backdrop.Biome.FORTRESS:  # dağ sırtı + kuleler
					draw_colored_polygon(PackedVector2Array([
						Vector2(x, ground_y), Vector2(x + bw * 0.5, ground_y - bh),
						Vector2(x + bw, ground_y)]), col)
					if rng.randf() < 0.25:
						draw_rect(Rect2(x + bw * 0.4, ground_y - bh * 0.5, bw * 0.2, bh * 0.5), col)
				Backdrop.Biome.KEEP:  # sur + mazgal
					draw_rect(Rect2(x, ground_y - bh * 0.6, bw, bh * 0.6), col)
					var mx := x
					while mx < x + bw:
						draw_rect(Rect2(mx, ground_y - bh * 0.6 - 16.0, 14.0, 16.0), col)
						mx += 26.0
				_:  # STREET — bina blokları + pencereler
					draw_rect(Rect2(x, ground_y - bh, bw, bh), col)
					if _tier >= 1 and rng.randf() < (0.7 if _tier == 1 else 0.4):
						var wa := 0.5 if _tier == 1 else 0.32
						var wy := ground_y - bh + 24.0
						while wy < ground_y - 20.0:
							var wx := x + 10.0
							while wx < x + bw - 10.0:
								if rng.randf() < (0.28 if _tier == 1 else 0.16):
									draw_rect(Rect2(wx, wy, 7.0, 10.0),
										Color(_pal.accent.r, _pal.accent.g, _pal.accent.b, wa))
								wx += 18.0
							wy += 22.0
			x += bw + rng.randf_range(-30.0, 40.0)


class _HazeLayer extends Node2D:
	var _pal: Dictionary
	func _init(pal: Dictionary) -> void:
		_pal = pal
	func _draw() -> void:
		var w := 2600.0
		for i in 10:
			var t := float(i) / 10.0
			var a: float = 0.06 + 0.10 * t
			draw_rect(Rect2(-w, 40.0 + 120.0 * t, w * 2.0, 40.0),
				Color(_pal.haze.r, _pal.haze.g, _pal.haze.b, a))


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

## Level — bir bölüm sahnesinin kök script'i (Görev 11, 17 görsel geçişi, 24 doku).
##
## Her Level*.tscn kökü bunu kullanır. Bölüme özel ayarları taşır (Main okur);
## ayrıca yüklenince prosedürel **paralaks arka planı** ekler ve tüm zemin/platform
## Polygon2D'lerine **prosedürel malzeme dokusu** (asfalt / metal / taş) + gradyan +
## kenar ışığı + alt gölge verir — düz renk dikdörtgen hissi kalkar.
class_name Level
extends Node2D

@export var display_name: String = "Bölüm"
## Kamera sınırları (Redmount kamerası bunlara kilitlenir).
@export var camera_limit_left: int = -64
@export var camera_limit_right: int = 3200
@export var camera_limit_top: int = -1200
@export var camera_limit_bottom: int = 760
## Bu Y'nin altına düşen oyuncu son spawn'a döner.
@export var fall_respawn_y: float = 900.0
## Rank hesabı için hedef süre (sn). Bunun altında bitirmek S'ye yaklaştırır.
@export var par_time: float = 75.0
## Arka plan ruh hâli. Bkz. backdrop.gd Biome.
@export_enum("Street", "Industrial", "Fortress", "Keep") var biome: int = 0

var edge_light: Color = Color(0.55, 0.72, 0.95, 0.7)

const BIOME_EDGE := [
	Color(1.0, 0.78, 0.45, 0.7),   # Street  — sıcak
	Color(1.0, 0.6, 0.3, 0.65),    # Industrial — turuncu/pas
	Color(0.6, 0.75, 1.0, 0.7),    # Fortress — soğuk mavi
	Color(1.0, 0.66, 0.32, 0.7),   # Keep — meşale
]
## Zemin/platform dokularına uygulanan biome ruh-hâli çarpanı.
const BIOME_TINT := [
	Color(1.02, 0.99, 0.94),   # Street  — hafif sıcak
	Color(1.0, 0.95, 0.86),    # Industrial — soluk/pas
	Color(0.9, 0.94, 1.05),    # Fortress — soğuk
	Color(1.04, 0.9, 0.84),    # Keep — koyu sıcak
]

var _tint: Color = Color.WHITE

## Üretilen dokular bölümler arasında paylaşılır (bir kez üret).
static var _tex_cache: Dictionary = {}


func _ready() -> void:
	edge_light = BIOME_EDGE[clampi(biome, 0, 3)]
	_tint = BIOME_TINT[clampi(biome, 0, 3)]
	_spawn_backdrop()
	for c in get_children():
		_beautify(c)


func _spawn_backdrop() -> void:
	var b := Backdrop.new()
	b.biome = biome
	b.world_left = float(camera_limit_left)
	b.world_right = float(camera_limit_right)
	add_child(b)
	move_child(b, 0)


# --- Zemin/platform güzelleştirme ---------------------------------------

func _beautify(node: Node) -> void:
	# Hareketli platform kendi mekanik görünümünü korur (dokusuz).
	if node is AnimatableBody2D:
		return
	if node is Polygon2D and node.name == "Vis":
		# Tek-yön platform (parent layer 128): doku YOK ama gradyan + altın kapak.
		var p := node.get_parent()
		var oneway := p is StaticBody2D and (p as StaticBody2D).collision_layer == 128
		_dress_polygon(node as Polygon2D, oneway)
	for c in node.get_children():
		_beautify(c)


func _dress_polygon(poly: Polygon2D, no_texture := false) -> void:
	var pts := poly.polygon
	if pts.size() < 3:
		return
	var min_y := pts[0].y
	var max_y := pts[0].y
	var min_x := pts[0].x
	var max_x := pts[0].x
	for p in pts:
		min_y = minf(min_y, p.y)
		max_y = maxf(max_y, p.y)
		min_x = minf(min_x, p.x)
		max_x = maxf(max_x, p.x)
	var span := maxf(max_y - min_y, 1.0)
	var width := maxf(max_x - min_x, 1.0)
	var thin := span <= 60.0
	var wall := width < 90.0 and span > 160.0

	var base_col := Color(0.32, 0.36, 0.44)  # tek-yön platformlar için düz mekanik gri
	if not no_texture:
		# Dünya-hizalı UV → tüm zeminler aynı sürekli dokuyu paylaşır.
		var origin: Vector2 = poly.get_parent().global_position if poly.get_parent() is Node2D else Vector2.ZERO
		var uv := PackedVector2Array()
		for p in pts:
			uv.append(p + origin)
		poly.uv = uv
		poly.texture = _ground_texture()
		poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		base_col = _tint

	# Dikey gradyan (beyaz merkezli — doku gerçek renginde kalsın) × biome tint.
	var hi := 1.28 if not thin else 1.34
	var lo := 0.66 if not thin else 0.9
	if no_texture:
		hi = 1.15
		lo = 0.72
	if wall:
		hi = 0.9
		lo = 0.5
	var vc := PackedColorArray()
	for p in pts:
		var t := (p.y - min_y) / span
		var g: float = lerpf(hi, lo, ease(t, 0.85))
		vc.append(Color(
			clampf(base_col.r * g, 0.0, 1.0),
			clampf(base_col.g * g, 0.0, 1.0),
			clampf(base_col.b * g, 0.0, 1.0), 1.0))
	poly.vertex_colors = vc

	# İnce platformun gövdesini görünür kıl: altına dolgu bir gölge şeridi.
	if thin and not wall:
		var shade := Polygon2D.new()
		shade.polygon = PackedVector2Array([
			Vector2(min_x, min_y + 3.0), Vector2(max_x, min_y + 3.0),
			Vector2(max_x, max_y), Vector2(min_x, max_y)])
		shade.color = Color(0.0, 0.0, 0.0, 0.32)
		shade.z_index = 1
		poly.add_child(shade)

	# Üst kenar boyunca ışık çizgisi + hemen altına ince koyu "lip".
	var top := PackedVector2Array()
	for i in pts.size():
		if pts[i].y <= min_y + span * 0.12:
			top.append(pts[i])
	if top.size() >= 2 and not wall:
		top.sort()
		var glow := Line2D.new()
		glow.points = top
		glow.width = 3.0
		glow.default_color = edge_light
		glow.z_index = 2
		glow.begin_cap_mode = Line2D.LINE_CAP_ROUND
		glow.end_cap_mode = Line2D.LINE_CAP_ROUND
		poly.add_child(glow)

		var lip := Line2D.new()
		lip.points = PackedVector2Array([top[0] + Vector2(0, 4.0), top[top.size() - 1] + Vector2(0, 4.0)])
		lip.width = 3.0
		lip.default_color = Color(0, 0, 0, 0.28)
		lip.z_index = 1
		poly.add_child(lip)


func _ground_texture() -> Texture2D:
	var key := clampi(biome, 0, 3)
	if _tex_cache.has(key):
		return _tex_cache[key]
	var img: Image
	match key:
		1:   img = _make_metal()
		2, 3: img = _make_stone()
		_:   img = _make_asphalt()
	var tex := ImageTexture.create_from_image(img)
	_tex_cache[key] = tex
	return tex


const _TS := 128

func _make_asphalt() -> Image:
	var img := Image.create(_TS, _TS, false, Image.FORMAT_RGB8)
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX
	n.frequency = 0.09
	n.seed = 41
	var grain := FastNoiseLite.new()
	grain.noise_type = FastNoiseLite.TYPE_CELLULAR
	grain.frequency = 0.22
	grain.seed = 7
	var base := Color(0.31, 0.315, 0.34)
	for y in _TS:
		for x in _TS:
			var v := n.get_noise_2d(x, y) * 0.03
			var s: float = maxf(grain.get_noise_2d(x, y), 0.0) * 0.05
			var c := Color(base.r + v + s, base.g + v + s, base.b + v + s * 0.9)
			img.set_pixel(x, y, c)
	# birkaç ince çatlak (yumuşak)
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for i in 3:
		var px := rng.randi_range(0, _TS - 1)
		var py := rng.randi_range(0, _TS - 1)
		var steps := rng.randi_range(20, 54)
		var ang := rng.randf() * TAU
		for _s in steps:
			px = wrapi(px + int(round(cos(ang))), 0, _TS)
			py = wrapi(py + int(round(sin(ang))), 0, _TS)
			ang += rng.randf_range(-0.5, 0.5)
			img.set_pixel(px, py, base.darkened(0.32))
	return img


func _make_metal() -> Image:
	var img := Image.create(_TS, _TS, false, Image.FORMAT_RGB8)
	var streak := FastNoiseLite.new()
	streak.noise_type = FastNoiseLite.TYPE_SIMPLEX
	streak.frequency = 0.015
	streak.seed = 12
	var rust := FastNoiseLite.new()
	rust.noise_type = FastNoiseLite.TYPE_SIMPLEX
	rust.frequency = 0.05
	rust.seed = 88
	var base := Color(0.33, 0.335, 0.36)
	var rust_col := Color(0.45, 0.26, 0.15)
	for y in _TS:
		for x in _TS:
			var br := streak.get_noise_2d(x * 4.0, y) * 0.05
			var c := Color(base.r + br, base.g + br, base.b + br)
			var r: float = rust.get_noise_2d(x, y)
			if r > 0.35:
				var amt: float = (r - 0.35) * 1.4
				c = c.lerp(rust_col, clampf(amt, 0.0, 0.6))
			# yatay plaka dikişi
			if y % 32 == 0 or y % 32 == 1:
				c = c.darkened(0.4)
			img.set_pixel(x, y, c)
	# perçinler
	for sy in range(4, _TS, 32):
		for sx in range(8, _TS, 24):
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					img.set_pixel(wrapi(sx + dx, 0, _TS), wrapi(sy + dy, 0, _TS),
						Color(0.34, 0.35, 0.38))
	return img


func _make_stone() -> Image:
	var img := Image.create(_TS, _TS, false, Image.FORMAT_RGB8)
	var speck := FastNoiseLite.new()
	speck.noise_type = FastNoiseLite.TYPE_SIMPLEX
	speck.frequency = 0.14
	speck.seed = 23
	var base := Color(0.34, 0.34, 0.375)
	var mortar := Color(0.19, 0.19, 0.22)
	var bh := 32
	var bw := 64
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	# blok başı parlaklık sapması
	var bright: Dictionary = {}
	for y in _TS:
		var row := y / bh
		var off := (bw / 2) if row % 2 == 1 else 0
		for x in _TS:
			var col := (x + off) / bw
			var bkey := "%d_%d" % [row, col]
			if not bright.has(bkey):
				bright[bkey] = rng.randf_range(-0.05, 0.05)
			var bo: float = bright[bkey]
			var c := Color(base.r, base.g, base.b).lightened(bo)
			var sp := speck.get_noise_2d(x, y) * 0.05
			c = Color(c.r + sp, c.g + sp, c.b + sp)
			var lx := (x + off) % bw
			var ly := y % bh
			if ly <= 1 or lx <= 1:
				c = mortar
			img.set_pixel(x, y, c)
	return img

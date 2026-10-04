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


## Biome başına İstanbul piksel sanatı zemin dokusu (eski prosedürel asfalt/metal/
## blok taş üreteçlerinin yerine). Dokular dünya hizalı UV ile döşenir.
const GROUND_ART := [
	preload("res://assets/environment/mahalle/stone_fill.png"),   # Street — Arnavut kaldırımı
	preload("res://assets/environment/haddehane_ground.png"),     # Industrial — haddehane zemini
	preload("res://assets/environment/fortress_stone.png"),       # Fortress — sur taşı
	preload("res://assets/environment/corridor_ground.png"),      # Keep — saray koridoru
]


func _ground_texture() -> Texture2D:
	return GROUND_ART[clampi(biome, 0, 3)]

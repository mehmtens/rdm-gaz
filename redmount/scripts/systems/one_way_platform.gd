## OneWayPlatform — yalnız üstten basılan platform (Görev 15).
##
## `collision_layer` 8 ("oneway"); Redmount maskesinde bu bit vardır ve `çömel + zıpla`
## ile kısa süre kapatıp aşağı iner. `width` her örnekte ayarlanır.
##
## `cloud` stili ayrı bir mekaniktir: üstüne basılınca `CLOUD_HOLD` saniye sonra
## dağılır (çarpışma kapanır, oyuncu düşer) ve `CLOUD_RETURN` saniye sonra geri gelir.
extends StaticBody2D

## Bulutun üstünde durulabilen süre ve dağıldıktan sonra geri gelme süresi (sn).
const CLOUD_HOLD := 1.0
const CLOUD_RETURN := 2.6
const CLOUD_PX := 4.0
enum _Cloud { SOLID, FADING, GONE }
const LEDGE := preload("res://assets/environment/mahalle/ledge_l.png")
const ROOF := preload("res://assets/environment/mahalle/roof_a.png")
const AWNING := preload("res://assets/environment/mahalle/market_awning_v2.png")
const SCAFFOLD := preload("res://assets/environment/mahalle/scaffold_deck_v2.png")
const WOOD := preload("res://assets/environment/mahalle/crate_wood_v2.png")
const INDUSTRIAL := preload("res://assets/environment/haddehane_ground.png")
const UNDERGROUND := preload("res://assets/environment/underground_ground.png")
const FORTRESS_PLATFORM := preload("res://assets/environment/fortress_platform.png")
const CORRIDOR := preload("res://assets/environment/corridor_ground.png")
@export var width: float = 200.0
@export_enum("metal", "cloud", "roof", "awning", "scaffold", "wood_shelf", "industrial", "underground", "fortress", "corridor") var style: String = "metal"

@onready var _col: CollisionShape2D = $CollisionShape2D
@onready var _vis: Polygon2D = $Vis

var _cloud_state: int = _Cloud.SOLID
var _cloud_timer := 0.0
var _cloud_sensor: Area2D
## Önbelleğe alınmış bulut pikselleri: [Rect2, Color] çiftleri.
var _cloud_cells: Array = []


func _ready() -> void:
	var s := _col.shape
	if s is RectangleShape2D:
		# Paylaşılan alt-kaynağı bozmamak için kopya.
		var r := (s as RectangleShape2D).duplicate() as RectangleShape2D
		r.size = Vector2(width, 12.0)
		_col.shape = r
	_col.one_way_collision = true
	_col.position = Vector2.ZERO
	var hw := width * 0.5
	_vis.polygon = PackedVector2Array([
		Vector2(-hw, -6), Vector2(hw, -6), Vector2(hw, 6), Vector2(-hw, 6),
	])
	var edge := get_node_or_null(^"Edge")
	if edge is Line2D:
		(edge as Line2D).points = PackedVector2Array([Vector2(-hw, -6), Vector2(hw, -6)])
		(edge as Line2D).visible = false
	_vis.visible = false
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_physics_process(style == "cloud")
	if style == "cloud":
		_setup_cloud()
	queue_redraw()


func _setup_cloud() -> void:
	_cloud_sensor = Area2D.new()
	_cloud_sensor.collision_layer = 0
	_cloud_sensor.collision_mask = 2  # player
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width - 6.0, 24.0)
	col.shape = shape
	col.position = Vector2(0, -20.0)
	_cloud_sensor.add_child(col)
	add_child(_cloud_sensor)
	_build_cloud_cells()


func _physics_process(delta: float) -> void:
	match _cloud_state:
		_Cloud.SOLID:
			for body in _cloud_sensor.get_overlapping_bodies():
				if body is CharacterBody2D and body.is_in_group(&"player") \
						and (body as CharacterBody2D).is_on_floor():
					_cloud_state = _Cloud.FADING
					_cloud_timer = CLOUD_HOLD
					break
		_Cloud.FADING:
			_cloud_timer -= delta
			queue_redraw()
			if _cloud_timer <= 0.0:
				_cloud_state = _Cloud.GONE
				_cloud_timer = CLOUD_RETURN
				_col.set_deferred(&"disabled", true)
				Fx.dust(global_position + Vector2(-width * 0.25, 0), 0, 5, Color("eef3ff"))
				Fx.dust(global_position + Vector2(width * 0.25, 0), 0, 5, Color("eef3ff"))
				Sfx.play(&"dash", 0.7, -9.0)
		_Cloud.GONE:
			_cloud_timer -= delta
			queue_redraw()
			if _cloud_timer <= 0.0:
				_cloud_state = _Cloud.SOLID
				_col.set_deferred(&"disabled", false)


## Dan the Man tarzına yakın, kalın konturlu ve basamaklı gölgeli piksel bulut.
func _build_cloud_cells() -> void:
	_cloud_cells.clear()
	var px := CLOUD_PX
	var cols := int(ceilf(width / px)) + 2
	var rows := 13
	var top := -22.0
	var hw := width * 0.5
	# Tepedeki tombul kümeler: genişliğe göre sayısı artar, yarıçapı sırayla değişir.
	var puffs: Array = []
	var count := maxi(int(roundf(width / 46.0)), 3)
	for i in count:
		var t := (float(i) + 0.5) / float(count)
		var radius := [17.0, 23.0, 19.0, 25.0][i % 4] * (0.82 if i == 0 or i == count - 1 else 1.0)
		puffs.append(Vector3(lerpf(-hw + 20.0, hw - 20.0, t), 8.0 - radius * 0.35, radius))
	var inside: Array = []
	for y in rows:
		var row := PackedByteArray()
		row.resize(cols)
		for x in cols:
			var p := Vector2(-hw - px + (float(x) + 0.5) * px, top + (float(y) + 0.5) * px)
			var hit := false
			if p.y <= 24.0:
				for puff in puffs:
					if Vector2(p.x - puff.x, p.y - puff.y).length() <= puff.z:
						hit = true
						break
				# Alt gövde: kümeleri birleştiren düz taban.
				if not hit and p.y >= 6.0 and absf(p.x) <= hw - 14.0:
					hit = true
			row[x] = 1 if hit else 0
		inside.append(row)
	var outline := Color("34406b")
	for y in rows:
		for x in cols:
			var cell := Rect2(-hw - px + float(x) * px, top + float(y) * px, px, px)
			if inside[y][x] == 1:
				var above: bool = y > 0 and inside[y - 1][x] == 1
				var depth := cell.position.y
				var tone := Color("ffffff") if not above else Color("f1f5ff") if depth < 6.0 \
					else Color("cfdcf7") if depth < 16.0 else Color("9fb4e3")
				_cloud_cells.append([cell, tone])
				continue
			var edge := false
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and nx < cols and ny >= 0 and ny < rows and inside[ny][nx] == 1:
					edge = true
					break
			if edge:
				_cloud_cells.append([cell, outline])
	# Taban konturu ızgaranın dışında kalır; ayrı bir şerit olarak eklenir.
	_cloud_cells.append([Rect2(-hw + 14.0, top + float(rows) * px, width - 28.0, px), outline])


func _draw_cloud() -> void:
	var alpha := 1.0
	var shake := Vector2.ZERO
	match _cloud_state:
		_Cloud.FADING:
			var k := clampf(_cloud_timer / CLOUD_HOLD, 0.0, 1.0)
			# Süre doldukça titrer ve son anlarda yanıp söner.
			shake = Vector2(roundf(sin(_cloud_timer * 55.0) * (1.0 - k) * 3.0), roundf((1.0 - k) * 4.0))
			alpha = 1.0 if k > 0.45 else (0.45 if int(_cloud_timer * 16.0) % 2 == 0 else 0.95)
		_Cloud.GONE:
			# Geri gelmeden hemen önce soluk bir hayalet belirir.
			alpha = clampf(1.0 - _cloud_timer / 0.5, 0.0, 1.0) * 0.6
	if alpha <= 0.01:
		return
	for entry in _cloud_cells:
		var cell: Rect2 = entry[0]
		var tone: Color = entry[1]
		draw_rect(Rect2(cell.position + shake, cell.size), Color(tone, alpha))


func _draw() -> void:
	var hw := width * 0.5
	if style == "cloud":
		_draw_cloud()
		return
	if style == "fortress":
		draw_line(Vector2(-hw + 12, 29), Vector2(-hw + 12, 90), Color("55556b"), 6)
		draw_line(Vector2(hw - 12, 29), Vector2(hw - 12, 90), Color("55556b"), 6)
		draw_texture_rect(FORTRESS_PLATFORM, Rect2(-hw, -6, width, 36), true)
		draw_line(Vector2(-hw, -7), Vector2(hw, -7), Color("9c92a0"), 5)
		return
	if style == "corridor":
		var base := maxf(-position.y, 74.0)
		for x in [-hw + 12.0, hw - 12.0]:
			draw_line(Vector2(x, 26), Vector2(x, base), Color("39404e"), 5)
		draw_line(Vector2(-hw + 12, 26), Vector2(hw - 12, base), Color("59606d"), 3)
		draw_texture_rect(CORRIDOR, Rect2(-hw, -6, width, 36), true)
		draw_line(Vector2(-hw, -7), Vector2(hw, -7), Color("a2a7b7"), 5)
		return
	if style == "awning":
		draw_texture_rect_region(AWNING, Rect2(-hw, -6, width, 62), Rect2(6, 147, 2161, 320))
	elif style == "wood_shelf":
		var base := maxf(-position.y, 74.0)
		for x in [-hw + 13.0, hw - 13.0]:
			draw_line(Vector2(x, 27), Vector2(x, base), Color("4a3026"), 9)
		draw_line(Vector2(-hw + 13, 44), Vector2(hw - 13, base - 12), Color("75503a"), 5)
		draw_texture_rect_region(WOOD, Rect2(-hw, -6, width, 45), Rect2(220, 255, 615, 175))
	elif style in ["scaffold", "industrial", "underground"]:
		var base := maxf(-position.y, 74.0)
		for x in [-hw + 9.0, hw - 9.0]:
			draw_line(Vector2(x, 32), Vector2(x, base), Color("343b40"), 7.0)
		draw_line(Vector2(-hw + 9, 55), Vector2(hw - 9, base - 10), Color("55514a"), 4.0)
		draw_line(Vector2(hw - 9, 55), Vector2(-hw + 9, base - 10), Color("55514a"), 4.0)
		if style in ["industrial", "underground"]:
			var surface := INDUSTRIAL if style == "industrial" else UNDERGROUND
			draw_texture_rect(surface,
				Rect2(-hw, -6, width, 38), true)
		else:
			draw_texture_rect_region(SCAFFOLD, Rect2(-hw, -6, width, 80), Rect2(26, 148, 1931, 535))
	elif style == "roof":
		draw_texture_rect(ROOF, Rect2(-hw, -6, width, 44), false)
	else:
		draw_texture_rect(LEDGE, Rect2(-hw, -6, width, 62), false)

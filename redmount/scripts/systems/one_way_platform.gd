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
## Bulut platformu: mahalle setindeki alacakaranlık tonlu piksel bulut.
const CLOUD_ART := preload("res://assets/environment/mahalle/cloud_puff.png")
const POST := preload("res://assets/environment/kit/scaffold_post.png")
const PILLAR := preload("res://assets/environment/kit/wall_pillar.png")
## Destek ve kenar dokuları (tools/gen_platform_supports.py, ChatGPT tarzı piksel art).
const DIKME_CELIK := preload("res://assets/environment/pixel/dikme_celik.png")
const DIKME_AHSAP := preload("res://assets/environment/pixel/dikme_ahsap.png")
const KUSAK_CELIK := preload("res://assets/environment/pixel/kusak_celik.png")
const KUSAK_AHSAP := preload("res://assets/environment/pixel/kusak_ahsap.png")
const KENAR_TAS := preload("res://assets/environment/pixel/kenar_tas.png")
const KENAR_CELIK := preload("res://assets/environment/pixel/kenar_celik.png")
const KENAR_ISIK := preload("res://assets/environment/pixel/kenar_isik.png")
@export var width: float = 200.0
@export_enum("metal", "cloud", "roof", "awning", "scaffold", "wood_shelf", "industrial", "underground", "fortress", "corridor") var style: String = "metal"

@onready var _col: CollisionShape2D = $CollisionShape2D
@onready var _vis: Polygon2D = $Vis

## Tente / çatı platformunun altındaki katı zemine uzaklık (px); 0 = destek çizilmez.
var _support_depth := 0.0
var _cloud_state: int = _Cloud.SOLID
var _cloud_timer := 0.0
var _cloud_sensor: Area2D


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
	elif style in ["awning", "roof"]:
		_find_support.call_deferred()
	queue_redraw()


## Tente direkleri / çatı duvarı havada asılı kalmasın: altındaki katı zemine kadar uzat.
func _find_support() -> void:
	await get_tree().physics_frame
	if not is_inside_tree():
		return
	var space := get_world_2d().direct_space_state
	var depth := INF
	for dx in [-width * 0.5 + 14.0, width * 0.5 - 14.0]:
		var from := global_position + Vector2(dx, 8.0)
		var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 520.0), 1)
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			return  # bir ucu boşluğa bakıyor (çukur, su): destek çizme
		depth = minf(depth, hit.position.y - global_position.y)
	if depth > 30.0:
		_support_depth = depth
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
	# Sanat bulutun gövdesi platform yüzeyinin biraz üstünden başlar; alt kısmı
	# yüzeyin altına sarkar (ayak bulutun içine gömülür gibi okunur).
	var h := width * CLOUD_ART.get_height() / CLOUD_ART.get_width()
	draw_texture_rect(CLOUD_ART, Rect2(Vector2(-width * 0.5, -h * 0.42) + shake, Vector2(width, h)),
		false, Color(1, 1, 1, alpha))


func _draw() -> void:
	var hw := width * 0.5
	if style == "cloud":
		_draw_cloud()
		return
	if style == "fortress":
		for x in [-hw + 12.0, hw - 12.0]:
			tile_down(self, DIKME_CELIK, Rect2(x - 5.0, 29.0, 10.0, 61.0))
		draw_texture_rect(FORTRESS_PLATFORM, Rect2(-hw, -6, width, 36), true)
		tile_across(self, KENAR_TAS, Rect2(-hw, -9.0, width, 6.0))
		return
	if style == "corridor":
		var base := maxf(-position.y, 74.0)
		_draw_frame(DIKME_CELIK, KUSAK_CELIK, hw - 12.0, 26.0, base, 10.0)
		draw_texture_rect(CORRIDOR, Rect2(-hw, -6, width, 36), true)
		tile_across(self, KENAR_CELIK, Rect2(-hw, -9.0, width, 6.0))
		return
	if style == "awning":
		# Tezgâh tentesi iki ahşap direğe oturur.
		if _support_depth > 0.0:
			for px in [-hw + 6.0, hw - 22.0]:
				draw_texture_rect(POST, Rect2(px, 20.0, 16.0, _support_depth - 20.0), false)
		draw_texture_rect_region(AWNING, Rect2(-hw, -6, width, 62), Rect2(6, 147, 2161, 320))
	elif style == "wood_shelf":
		var base := maxf(-position.y, 74.0)
		_draw_frame(DIKME_AHSAP, KUSAK_AHSAP, hw - 13.0, 27.0, base, 12.0)
		draw_texture_rect_region(WOOD, Rect2(-hw, -6, width, 45), Rect2(220, 255, 615, 175))
		draw_dark_edge(self, -hw, hw, -6.0)
	elif style in ["scaffold", "industrial", "underground"]:
		var base := maxf(-position.y, 74.0)
		_draw_frame(DIKME_CELIK, KUSAK_CELIK, hw - 9.0, 32.0, base, 10.0)
		if style in ["industrial", "underground"]:
			var surface := INDUSTRIAL if style == "industrial" else UNDERGROUND
			draw_texture_rect(surface,
				Rect2(-hw, -6, width, 38), true)
		else:
			draw_texture_rect_region(SCAFFOLD, Rect2(-hw, -6, width, 80), Rect2(26, 148, 1931, 535))
			draw_dark_edge(self, -hw, hw, -6.0)
	elif style == "roof":
		# Çatı iki taş direğe oturur (revak): altından yürünerek geçilir.
		if _support_depth > 0.0:
			for px in [-hw + 8.0, hw - 36.0]:
				tile_down(self, PILLAR, Rect2(px, 24.0, 28.0, _support_depth - 24.0))
		draw_texture_rect(ROOF, Rect2(-hw, -6, width, 44), false)
	else:
		draw_texture_rect(LEDGE, Rect2(-hw, -6, width, 62), false)


## İki direk (±`ox`) `y0`'dan zemine (`base`) iner; aralarında her ~64 px'te bir
## yatay kuşak. Eski çapraz çizgi yerine eksene hizalı piksel doku.
func _draw_frame(post: Texture2D, beam: Texture2D, ox: float, y0: float, base: float, post_w: float) -> void:
	var y := y0 + 24.0
	while y < base - 16.0:
		tile_across(self, beam, Rect2(-ox, y, ox * 2.0, 8.0))
		y += 64.0
	for x in [-ox, ox]:
		tile_down(self, post, Rect2(x - post_w * 0.5, y0, post_w, base - y0))


## Dokuyu genişliğe ölçekleyip aşağı doğru döşer; son parça kırpılır (esnetilmez).
static func tile_down(ci: CanvasItem, tex: Texture2D, r: Rect2) -> void:
	var tile_h := r.size.x * tex.get_height() / tex.get_width()
	var y := r.position.y
	while y < r.end.y - 0.5:
		var h := minf(tile_h, r.end.y - y)
		ci.draw_texture_rect_region(tex, Rect2(r.position.x, y, r.size.x, h),
			Rect2(0, 0, tex.get_width(), tex.get_height() * h / tile_h))
		y += h


## Dokuyu yüksekliğe ölçekleyip yana doğru döşer; son parça kırpılır.
static func tile_across(ci: CanvasItem, tex: Texture2D, r: Rect2, tint := Color.WHITE) -> void:
	var tile_w := r.size.y * tex.get_width() / tex.get_height()
	var x := r.position.x
	while x < r.end.x - 0.5:
		var w := minf(tile_w, r.end.x - x)
		ci.draw_texture_rect_region(tex, Rect2(x, r.position.y, w, r.size.y),
			Rect2(0, 0, tex.get_width() * w / tile_w, tex.get_height()), tint)
		x += w


## Gece sahnesinde ince platformun basılacak kenarı: level.gd'deki kenar ışığı +
## altındaki koyu dudak kuralının aynısı (bölümün edge_light rengiyle boyanan doku).
static func draw_dark_edge(ci: CanvasItem, x0: float, x1: float, y: float) -> void:
	var lvl := Level.dark_scene_of(ci)
	if lvl == null:
		return
	tile_across(ci, KENAR_ISIK, Rect2(x0, y - 2.0, x1 - x0, 8.0), lvl.get("edge_light"))

## BreakableProp — kırılabilir dekor kabı (vazo / saksı / kasa / tüp / varil / sandık).
##
## Yolu KAPATMAZ, içinden geçilir; vurunca kırılır ve coin saçar.
## Her türün dayanıklılığı farklıdır (saksı 1 darbe, sandık 5) — oyuncu hangi kabın
## kaç vuruş istediğini görerek öğrenir, ödül de dayanıklılıkla ölçeklenir.
## Vuruş, Redmount'un Hitbox'ı (veya mermi) Hurtbox'a değince `apply_hit` ile gelir.
class_name BreakableProp
extends Node2D

const COIN := preload("res://scenes/pickups/Coin.tscn")
const HEALTH := preload("res://scenes/pickups/HealthPickup.tscn")
const AMMO_PATH := "res://scenes/pickups/AmmoPickup.tscn"
const STONES_PATH := "res://scenes/pickups/TasPickup.tscn"
## Tür → ganimet tablosu: oyuncu neyi kırmaya değer olduğunu öğrensin (Dan the Man).
## Kasa yiyecek, varil cephane, sandık silah verir; saksı/vazo/tüp yalnız coin.
## Bölüm tasarımcısı drops_health / reward verdiyse tablo devreye girmez.
const LOOT := {
	"kasa": {"chance": 0.3, "scenes": ["res://scenes/pickups/HealthPickup.tscn"]},
	"varil": {"chance": 0.35, "scenes": ["res://scenes/pickups/AmmoPickup.tscn"]},
	"sandik": {"chance": 0.5, "scenes": ["res://scenes/pickups/BatPickup.tscn", "res://scenes/pickups/KnifePickup.tscn",
		"res://scenes/pickups/AnahtarPickup.tscn", "res://scenes/pickups/SemsiyePickup.tscn"]},
}
const VASE_SMALL := preload("res://assets/environment/mahalle/vase_small.png")
const VASE_BIG := preload("res://assets/environment/mahalle/vase_big.png")
const VASE_IZNIK := preload("res://assets/environment/mahalle/vase_iznik_v2.png")
const CRATE := preload("res://assets/environment/mahalle/crate_wood_v2.png")
const CHEST := preload("res://assets/environment/mahalle/chest_ottoman_v2.png")
const POTS := preload("res://assets/environment/kit/pots.png")
## Varsayılan sanat: setteki piksel çizimler (tüp / varil prosedürel kalır).
const DEFAULT_ART := {"vazo": VASE_SMALL, "saksi": POTS, "kasa": CRATE, "sandik": CHEST,
	"varil": preload("res://assets/environment/pixel/varil.png"),
	"tup": preload("res://assets/environment/pixel/tup.png"),
	"patlayici": preload("res://assets/environment/pixel/patlayici.png")}
const BOOM := preload("res://assets/environment/pixel/patlama.png")
## Patlama yarıçapı (px) ve hasarı: düşmana tam, oyuncuya hafif.
const BLAST_RADIUS := 180.0
const BLAST_DAMAGE := 45
const BLAST_PLAYER_DAMAGE := 18
## Kenar boşluklu büyük kaynaklarda yalnız nesnenin kendisi çizilir.
const ART_REGION := {
	"kasa": Rect2(227, 193, 893, 781),
}

## Tür tablosu: dayanıklılık, coin, ölçü, gövde/vurgu rengi, malzeme sesi.
const KINDS := {
	"saksi": {
		"hits": 1, "coins": 2, "size": Vector2(30, 52),
		"body": Color("a8563a"), "trim": Color("d98f5e"), "mat": "toprak",
	},
	"vazo": {
		"hits": 1, "coins": 3, "size": Vector2(30, 46),
		"body": Color("b5643c"), "trim": Color("f0c08a"), "mat": "toprak",
	},
	"kasa": {
		"hits": 2, "coins": 5, "size": Vector2(56, 50),
		"body": Color("8a6236"), "trim": Color("c39a5c"), "mat": "tahta",
	},
	"tup": {
		"hits": 2, "coins": 5, "size": Vector2(34, 54),
		"body": Color("d2662f"), "trim": Color("f2e8cf"), "mat": "metal",
	},
	"varil": {
		"hits": 3, "coins": 7, "size": Vector2(44, 60),
		"body": Color("45545a"), "trim": Color("a47651"), "mat": "metal",
	},
	"patlayici": {
		"hits": 1, "coins": 0, "size": Vector2(44, 60),
		"body": Color("b0302a"), "trim": Color("f2c14e"), "mat": "metal",
	},
	"sandik": {
		"hits": 4, "coins": 15, "size": Vector2(76, 58),
		"body": Color("6f4b2a"), "trim": Color("c8a349"), "mat": "tahta",
	},
}

@export_enum("saksi", "vazo", "kasa", "tup", "varil", "sandik", "patlayici") var kind: String = "vazo"
## 0 = türün varsayılanı. Aynı türden bir kabı özellikle daha sağlam yapmak için.
@export var hits_override: int = 0
## -1 = türün varsayılanı.
@export var coins_override: int = -1
## Kırılınca can da düşürür (nadir, gizli cepler için).
@export var drops_health: bool = false
## Kırılınca çıkan özel ödül (silah / zırh sahnesi). Boş olabilir.
@export var reward: PackedScene
@export var art: Texture2D

var _hp: int = 0
var _max_hp: int = 1
var _data: Dictionary
var _broken: bool = false
var _shake: float = 0.0
var _seed: float = 0.0

## Ölçüler Redmount'un (112 px) yarısı civarında: kap bir engel değil, kırılacak süstür.
func _size() -> Vector2:
	if kind == "vazo":
		match _max_hp:
			1: return Vector2(30, 46)
			2: return Vector2(36, 54)
			_: return Vector2(42, 62)
	return _data["size"]


func _ready() -> void:
	_data = KINDS.get(kind, KINDS["vazo"])
	if art == null:
		art = DEFAULT_ART.get(kind)
	_max_hp = hits_override if hits_override > 0 else int(_data["hits"])
	_hp = _max_hp
	_seed = randf() * 10.0
	if kind == "patlayici":
		add_to_group(&"explosive")
	z_index = 2
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var hurtbox := Area2D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.collision_layer = 64  # enemy_hurtbox — oyuncunun hitbox'ı bunu tarar
	hurtbox.collision_mask = 8    # player_hitbox
	hurtbox.monitoring = false
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	var size := _size()
	shape.size = size
	col.shape = shape
	col.position = Vector2(0, -size.y * 0.5)
	hurtbox.add_child(col)
	add_child(hurtbox)


func _process(delta: float) -> void:
	if _shake > 0.0:
		_shake = maxf(_shake - delta * 42.0, 0.0)
		queue_redraw()


## Redmount'un saldırısı / mermisi değince çağrılır (saldıran taraf çağırır).
func apply_hit(_damage: int, dir: Vector2, _knockback: float) -> void:
	if _broken:
		return
	_hp -= 1
	_shake = 7.0
	var size := _size()
	Fx.spark(global_position + Vector2(0, -size.y * 0.5), dir, 6, _data["trim"], 0.8)
	Combat.shake(2.5)
	match _data["mat"]:
		"metal":
			Sfx.play(&"heavy_hit", 1.15)
		"tahta":
			Sfx.play(&"hit", 0.85)
		_:
			Sfx.play(&"hit", 1.25)
	queue_redraw()
	if _hp <= 0:
		_break(dir)


func _break(dir: Vector2) -> void:
	_broken = true
	var size := _size()
	var center := global_position + Vector2(0, -size.y * 0.5)

	Combat.shake(5.0)
	Sfx.play(&"weapon_break", 1.0 if _data["mat"] == "tahta" else 1.2)
	Fx.dust(global_position, dir.x, 7, _data["body"])
	Fx.ring(center, Color(_data["trim"], 0.8), 6.0, size.x * 1.2, 0.26, 3.0)
	if _data["mat"] == "metal":
		Fx.spark(center, Vector2.ZERO, 12, Color("ffd27a"), 1.2)

	for i in 7:
		var shard := _Shard.new(_data["body"] if i % 2 else _data["trim"])
		get_parent().add_child(shard)
		shard.global_position = center
		shard.launch(dir.x)

	if kind == "patlayici":
		_explode(center)
	var count: int = coins_override if coins_override >= 0 else int(_data["coins"])
	for i in count:
		_pop_coin.call_deferred(center, i, count)
	if drops_health:
		_drop.call_deferred(HEALTH, center + Vector2(0, -30))
	if reward != null:
		_drop.call_deferred(reward, center + Vector2(0, -46))
	elif not drops_health:
		var loot := adapt_loot(roll_loot(kind, randf(), randi()), get_tree().get_first_node_in_group(&"player"))
		if loot != null:
			_drop.call_deferred(loot, center + Vector2(0, -46))

	queue_free()


## LOOT tablosundan zar: roll < chance ise türün sahnelerinden biri, yoksa null.
static func roll_loot(prop_kind: String, roll: float, pick: int) -> PackedScene:
	var entry: Dictionary = LOOT.get(prop_kind, {})
	if entry.is_empty() or roll >= float(entry["chance"]):
		return null
	var scenes: Array = entry["scenes"]
	return load(scenes[pick % scenes.size()]) as PackedScene


## Ganimeti oyuncunun eline göre uyarlar: elinde menzilli silah yokken varilden
## çıkan cephane kutusu işe yaramaz, onun yerine kaldırım taşı yığını düşer —
## silahsız oyuncu da varili kırmaya değer bulur ve menzilli seçenek kazanır.
static func adapt_loot(scene: PackedScene, player: Node) -> PackedScene:
	if scene == null or scene.resource_path != AMMO_PATH:
		return scene
	if player != null and player.has_method(&"has_gun") and not player.has_gun():
		return load(STONES_PATH) as PackedScene
	return scene


## Dan the Man tarzı patlayıcı varil: çevredeki düşmanları savurur, oyuncuyu
## hafif yaralar, yakındaki diğer patlayıcıları kısa gecikmeyle zincirler.
func _explode(center: Vector2) -> void:
	Combat.shake(12.0)
	Sfx.play(&"heavy_hit", 0.55, 4.0)
	var boom := _Boom.new()
	get_parent().add_child(boom)
	boom.global_position = center + Vector2(0, -10)
	Fx.ring(center, Color(1.0, 0.7, 0.3, 0.9), 10.0, BLAST_RADIUS, 0.3, 5.0)
	Fx.spark(center, Vector2.ZERO, 18, Color("ffb347"), 1.6)
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		if not is_instance_valid(e) or not e.has_method(&"apply_hit"):
			continue
		var d: Vector2 = e.global_position + Vector2(0, -50) - center
		if d.length() < BLAST_RADIUS:
			e.apply_hit(BLAST_DAMAGE, Vector2(signf(d.x) if d.x != 0.0 else 1.0, -0.6).normalized(), 620.0)
	var pl := get_tree().get_first_node_in_group(&"player") as Node2D
	if pl != null and pl.has_method(&"apply_hit"):
		var dp: Vector2 = pl.global_position + Vector2(0, -50) - center
		if dp.length() < BLAST_RADIUS * 0.7:
			pl.apply_hit(BLAST_PLAYER_DAMAGE, Vector2(signf(dp.x) if dp.x != 0.0 else 1.0, -0.5).normalized(), 420.0)
	for p in get_tree().get_nodes_in_group(&"explosive"):
		if p != self and is_instance_valid(p) and not p._broken 				and (p.global_position - global_position).length() < BLAST_RADIUS + 40.0:
			get_tree().create_timer(0.18, false, false, true).timeout.connect(p.apply_hit.bind(1, Vector2.RIGHT, 0.0))


## Coin kaptan fırlar: kısa bir yay çizip yere düşer, sonra mıknatıs devreye girer.
func _pop_coin(from: Vector2, index: int, total: int) -> void:
	var coin := COIN.instantiate()
	get_parent().add_child(coin)
	coin.global_position = from
	var spread := float(index) / maxf(float(total - 1), 1.0) - 0.5
	var land := Vector2(from.x + spread * 150.0, global_position.y - 26.0)
	var peak := Vector2((from.x + land.x) * 0.5, from.y - randf_range(80.0, 140.0))
	var magnet: float = coin.magnet_radius
	coin.magnet_radius = 0.0
	var t := coin.create_tween()
	t.tween_property(coin, ^"global_position", peak, 0.16).set_ease(Tween.EASE_OUT)
	t.tween_property(coin, ^"global_position", land, 0.2).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void:
		if is_instance_valid(coin):
			coin.magnet_radius = magnet)


func _drop(scene: PackedScene, at: Vector2) -> void:
	var node := scene.instantiate()
	get_parent().add_child(node)
	node.global_position = at


func _draw() -> void:
	# Düğüm _ready içinde kendini siliyor; o kareye denk gelen çizim boş veriyle çalışmasın.
	if _data.is_empty():
		return
	var size := _size()
	var body: Color = _data["body"]
	var trim: Color = _data["trim"]
	# Hasar aldıkça koyulaşır; son darbede belirgin biçimde yıpranmış görünür.
	var wear := 1.0 - float(_hp) / float(_max_hp)
	body = body.darkened(wear * 0.22)
	var off := Vector2(sin(_shake * 5.0) * _shake * 0.5, 0)
	draw_set_transform(off, 0.0, Vector2.ONE)

	# Temas gölgesi — kap zemine oturmuş görünsün.
	draw_colored_polygon(_ellipse(Vector2(0, -3), size.x * 0.52, 8.0),
		Color(0.04, 0.04, 0.08, 0.35))

	if art != null:
		var dst := Rect2(Vector2(-size.x * 0.5, -size.y), size)
		var tint := Color.WHITE.darkened(wear * 0.22)
		if ART_REGION.has(kind):
			draw_texture_rect_region(art, dst, ART_REGION[kind], tint)
		else:
			draw_texture_rect(art, dst, false, tint)
		_draw_cracks(size, wear)
		return

	match kind:
		"saksi":
			_draw_saksi(size, body, trim)
		"vazo":
			_draw_vazo(size, body, trim)
		"kasa":
			_draw_kasa(size, body, trim)
		"tup":
			_draw_tup(size, body, trim)
		"varil":
			_draw_varil(size, body, trim)
		"sandik":
			_draw_sandik(size, body, trim)

	_draw_cracks(size, wear)


## Kalan dayanıklılık çatlak olarak okunur: 1 darbelik kap çatlaksız, sağlam kap
## kırılmadan önce ilerleyen çatlaklarla oyuncuya "bir vuruş daha" der.
func _draw_cracks(size: Vector2, wear: float) -> void:
	if wear <= 0.0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = int(_seed * 1000.0)
	var lines := int(wear * 5.0) + 1
	for i in lines:
		var x := rng.randf_range(-size.x * 0.32, size.x * 0.32)
		var y := rng.randf_range(-size.y * 0.78, -size.y * 0.2)
		var pts := PackedVector2Array([
			Vector2(x, y),
			Vector2(x + rng.randf_range(-9, 9), y + 13),
			Vector2(x + rng.randf_range(-11, 11), y + 27),
		])
		# Piksel çatlak: 3 px'lik kareler (çizgi değil), ızgaraya oturur.
		for k in 2:
			var a := pts[k]
			var b := pts[k + 1]
			for t in 6:
				var q := a.lerp(b, float(t) / 5.0)
				draw_rect(Rect2(roundf(q.x / 3.0) * 3.0, roundf(q.y / 3.0) * 3.0, 3.0, 3.0), Color(0.06, 0.05, 0.09, 0.8))


func _draw_vazo(size: Vector2, body: Color, trim: Color) -> void:
	var texture: Texture2D = VASE_IZNIK if _max_hp >= 3 else (VASE_BIG if _max_hp == 2 else VASE_SMALL)
	var source := Rect2(97, 86, 879, 1333) if _max_hp >= 3 else (Rect2(0, 0, VASE_BIG.get_width(), VASE_BIG.get_height()) if _max_hp == 2 else Rect2(0, 0, 52, 79))
	draw_texture_rect_region(texture, Rect2(-size.x * 0.5, -size.y, size.x, size.y), source)


func _draw_saksi(size: Vector2, body: Color, trim: Color) -> void:
	var h := size.y
	var w := size.x
	draw_colored_polygon(PackedVector2Array([
		Vector2(-w * 0.38, -h * 0.72), Vector2(w * 0.38, -h * 0.72),
		Vector2(w * 0.28, 0), Vector2(-w * 0.28, 0),
	]), body)
	draw_rect(Rect2(-w * 0.44, -h * 0.82, w * 0.88, 13), trim)
	# Sardunya: gövdeden taşan birkaç yaprak + kırmızı çiçek.
	var leaf := Color(0.29, 0.52, 0.28)
	for i in 5:
		var a := -PI * 0.5 + (float(i) - 2.0) * 0.42
		var tip := Vector2(cos(a), sin(a)) * (h * 0.42)
		draw_line(Vector2(0, -h * 0.78), Vector2(0, -h * 0.78) + tip, leaf, 5.0)
		draw_circle(Vector2(0, -h * 0.78) + tip, 7.0, leaf.lightened(0.15))
	draw_circle(Vector2(0, -h * 1.18), 8.0, Color(0.82, 0.29, 0.31))


func _draw_kasa(size: Vector2, body: Color, trim: Color) -> void:
	draw_texture_rect_region(CRATE, Rect2(-size.x * 0.5, -size.y, size.x, size.y), Rect2(226, 192, 895, 783))


func _draw_tup(size: Vector2, body: Color, trim: Color) -> void:
	var h := size.y
	var w := size.x
	var edge := Color("312c2c")
	draw_rect(Rect2(-w * 0.46, -h * 0.87, w * 0.92, h * 0.84), edge)
	draw_rect(Rect2(-w * 0.4, -h * 0.83, w * 0.8, h * 0.76), body)
	draw_rect(Rect2(-w * 0.4, -h * 0.83, 6, h * 0.76), body.lightened(0.22))
	draw_rect(Rect2(w * 0.24, -h * 0.83, 8, h * 0.76), body.darkened(0.28))
	draw_rect(Rect2(-w * 0.34, -h * 0.94, w * 0.68, 8), edge)
	draw_rect(Rect2(-w * 0.25, -h, w * 0.5, 6), Color("91867a"))
	draw_rect(Rect2(-w * 0.11, -h * 1.05, w * 0.22, 5), edge)
	draw_rect(Rect2(-w * 0.4, -h * 0.58, w * 0.8, 17), edge)
	draw_rect(Rect2(-w * 0.34, -h * 0.54, w * 0.68, 9), trim)
	draw_rect(Rect2(-w * 0.15, -h * 0.51, w * 0.3, 4), body.darkened(0.5))
	draw_rect(Rect2(-w * 0.35, -h * 0.08, w * 0.7, 5), edge)


func _draw_varil(size: Vector2, body: Color, trim: Color) -> void:
	var h := size.y
	var w := size.x
	var edge := Color("252b30")
	draw_rect(Rect2(-w * 0.5, -h * 0.91, w, h * 0.88), edge)
	draw_rect(Rect2(-w * 0.44, -h * 0.88, w * 0.88, h * 0.81), body)
	draw_rect(Rect2(-w * 0.37, -h * 0.84, 7, h * 0.7), body.lightened(0.2))
	draw_rect(Rect2(w * 0.28, -h * 0.84, 7, h * 0.7), body.darkened(0.3))
	draw_colored_polygon(_ellipse(Vector2(0, -h * 0.91), w * 0.47, 9), edge)
	draw_colored_polygon(_ellipse(Vector2(0, -h * 0.92), w * 0.39, 5), body.lightened(0.1))
	for ry in [-h * 0.78, -h * 0.43, -h * 0.12]:
		draw_rect(Rect2(-w * 0.48, ry, w * 0.96, 7), edge)
		draw_rect(Rect2(-w * 0.43, ry + 2, w * 0.86, 2), trim)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(_seed * 733.0)
	for i in 13:
		var x := rng.randi_range(-int(w * 0.35), int(w * 0.3))
		var y := rng.randi_range(-int(h * 0.72), -int(h * 0.2))
		draw_rect(Rect2(x, y, rng.randi_range(3, 8), rng.randi_range(3, 10)), trim.darkened(0.18))


func _draw_sandik(size: Vector2, body: Color, trim: Color) -> void:
	draw_texture_rect_region(CHEST, Rect2(-size.x * 0.5, -size.y, size.x, size.y), Rect2(121, 210, 1197, 704))


func _ellipse(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * float(i) / 20.0
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


## Kırılma parçası — kısa ömürlü, yerçekimli döner kıymık.
class _Shard extends Node2D:
	var _color: Color
	var _vel: Vector2
	var _spin: float
	var _life: float = 0.0

	func _init(color: Color) -> void:
		_color = color

	func launch(dir_x: float) -> void:
		var away := signf(dir_x) if absf(dir_x) > 0.01 else (1.0 if randf() > 0.5 else -1.0)
		_vel = Vector2(away * randf_range(60.0, 260.0), randf_range(-330.0, -120.0))
		_spin = randf_range(-12.0, 12.0)
		z_index = 3

	func _process(delta: float) -> void:
		_life += delta
		_vel.y += 1500.0 * delta
		position += _vel * delta
		rotation += _spin * delta
		modulate.a = clampf(1.0 - (_life - 0.35) / 0.35, 0.0, 1.0)
		queue_redraw()
		if _life > 0.7:
			queue_free()

	func _draw() -> void:
		draw_colored_polygon(PackedVector2Array([
			Vector2(-6, -5), Vector2(7, -7), Vector2(5, 6), Vector2(-5, 4),
		]), _color)


## Piksel art patlama: 6 kare (40x40 sanat, 4x), sonra kendini siler.
class _Boom extends Node2D:
	var _t := 0.0

	func _ready() -> void:
		z_index = 8
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _process(delta: float) -> void:
		_t += delta
		if _t > 0.48:
			queue_free()
		queue_redraw()

	func _draw() -> void:
		var f := mini(int(_t / 0.08), 5)
		var s := 40.0 * 4.0
		draw_texture_rect_region(BOOM, Rect2(-s * 0.5, -s * 0.5, s, s), Rect2(f * 40, 0, 40, 40))

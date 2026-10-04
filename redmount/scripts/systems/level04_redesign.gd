## Bölüm 4 uzun rota: dağ kalesi, zırhlı birlikler ve mini-boss yaklaşımı.
extends "res://scripts/systems/level02_redesign.gd"

const FORTRESS_ATLAS := preload("res://assets/backgrounds/level04_fortress_atlas.png")
const FORTRESS_STONE := preload("res://assets/environment/fortress_stone.png")
const AGILE := preload("res://scenes/enemies/AgileAssassin.tscn")
const BRUISER := preload("res://scenes/enemies/ArmoredBruiser.tscn")
const BOSS := preload("res://scenes/enemies/MiniBoss.tscn")


func _ready() -> void:
	for old_name in [^"Cover1", ^"MiniBossArena", ^"RightWall"]:
		var old := get_parent().get_node_or_null(old_name)
		if old != null:
			old.queue_free()
	add_child(_FortressBackdrop.new())
	_restyle_opening()
	for old_name in [^"MoverC1", ^"MoverC2", ^"Fall1", ^"Fall2", ^"Fall3"]:
		var upper := get_parent().get_node_or_null(old_name) as Node2D
		if upper != null:
			upper.position.y -= 170.0
	_ground(1980, 520, METAL, -160)
	_ground(3420, 600, METAL, -160)
	_ground(4820, 1000, BRICK, -160)
	_build_fortress_route()
	var level := get_parent() as Level
	level.camera_limit_right = 51200
	level.par_time = 480.0
	var goal := level.get_node_or_null(^"LevelGoal")
	if goal != null:
		goal.position = Vector2(50600, 0)


func _build_fortress_route() -> void:
	# 5.000–14.000 — dış sur: geniş zeminlerde zırhlı düşman tanıtımı.
	_ground(6500, 2800, BRICK)
	_enemy(BRUISER, 6100, 0); _enemy(RIFLE, 7000, 0); _enemy(AGILE, 7900, 0)
	_platform(9000, -15, 420, 110, BRICK); _platform(9460, -80, 380, 110, BRICK)
	_platform(9880, -15, 420, 110, BRICK)
	_ground(9200, 2600, METAL)
	_cloud(9220, -315, 170); _cloud(9480, -390, 170); _cloud(9740, -315, 170)
	_pickup(ARMOR, 9480, -440)
	_ground(11700, 2700, METAL)
	_enemy(RIFLE, 11100, 0); _enemy(BRUISER, 12100, 0)
	_shop(12800, 0, "DIŞ SUR BÜFESİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(13400)
	_ground(13775, 1450, BRICK)
	_arena(13700, 12900, 14500, _wave(BRUISER, RIFLE), _wave(AGILE, BRUISER, RIFLE), HEALTH)

	# 14.000–23.000 — mazgal hattı: alçak/yüksek ateş koridoru.
	_ground(15800, 2600, ASPHALT)
	_enemy(RIFLE, 15200, 0); _enemy(RIFLE, 16100, 0); _enemy(AGILE, 16900, 0)
	_platform(18000, -15, 400, 90, METAL); _platform(18440, -80, 360, 90, METAL)
	_platform(18840, -145, 360, 90, METAL); _platform(19240, -80, 360, 90, METAL)
	_platform(19660, -15, 400, 90, METAL)
	_ground(18600, 3000, METAL)
	_coin_arc(17950, 6, 330, -260)
	_ground(21500, 2800, BRICK)
	_enemy(BRUISER, 20800, 0); _enemy(AGILE, 21600, 0); _enemy(RIFLE, 22400, 0)
	_pickup(HEALTH, 22800, -45); _checkpoint(23100)

	# 23.000–32.000 — uçurum geçidi: ana rota güvenli, üst rota ödüllü.
	_platform(23900, -15, 420, 100, BRICK); _platform(24360, -85, 380, 100, BRICK)
	_platform(24780, -15, 420, 100, BRICK)
	_ground(24100, 2400, BRICK)
	_ground(26400, 2200, METAL)
	_enemy(AGILE, 25900, 0); _enemy(BRUISER, 26700, 0)
	_cloud(27500, -290, 170); _cloud(27760, -365, 170); _cloud(28020, -290, 170)
	_pickup(AMMO, 27760, -415)
	_ground(27900, 800, METAL)
	_ground(29800, 3000, ASPHALT)
	_enemy(RIFLE, 29000, 0); _enemy(BRUISER, 29900, 0); _enemy(AGILE, 30700, 0)
	_shop(31300, 0, "UÇURUM KARAKOLU", PackedStringArray(["can", "cephane", "tabanca"]))
	_checkpoint(31800)
	_ground(31700, 800, ASPHALT)

	# 32.000–41.000 — iç kale: iki dalgalı ağır birlik arenası.
	_ground(33500, 2800, BRICK)
	_enemy(RIFLE, 32800, 0); _enemy(AGILE, 33700, 0); _enemy(BRUISER, 34600, 0)
	_checkpoint(35200)
	_arena(35800, 35000, 36600, _wave(BRUISER, AGILE, RIFLE), _wave(BRUISER, BRUISER, RIFLE), ARMOR)
	_ground(36750, 3700, METAL)
	_platform(37400, -15, 420, 110, METAL); _platform(37860, -80, 380, 110, METAL)
	_platform(38280, -15, 420, 110, METAL)
	_ground(39900, 2600, ASPHALT)
	_enemy(AGILE, 39400, 0); _enemy(RIFLE, 40200, 0)
	_pickup(HEALTH, 41000, -45); _checkpoint(41400)
	_ground(41450, 500, ASPHALT)

	# 41.000–50.600 — komutan avlusu: hazırlık, muhafız dalgası ve mini-boss.
	_ground(43000, 2600, BRICK)
	_enemy(BRUISER, 42400, 0); _enemy(RIFLE, 43300, 0); _enemy(AGILE, 44100, 0)
	_shop(44700, 0, "KOMUTAN DEPOSU", PackedStringArray(["can", "cephane", "zirh"]))
	_pickup(HEALTH, 45100, -45); _pickup(AMMO, 45260, -45)
	_checkpoint(45600)
	_ground(44950, 1300, BRICK)
	_ground(48000, 4800, METAL)
	_arena(48000, 46200, 49800, _wave(BRUISER, RIFLE, AGILE), [BOSS], HEALTH)
	_dialogue(50100, "REDMOUNT", "Kale kapısı açıldı. Karahanlı artık çok yakın.")
	_ground(50600, 600, BRICK)
	for marker in [5600, 15500, 23600, 32600, 41500, 46300]:
		_coin_line(marker, 4, 180, -55)
	for marker in [9180, 18380, 24360, 37860]:
		_coin_arc(marker, 4, 180, -180)


func _restyle_opening() -> void:
	for body in get_parent().get_children():
		if not body is StaticBody2D:
			continue
		var body_name := str(body.name)
		if not body_name.begins_with("Ground"):
			continue
		var vis := body.get_node_or_null(^"Vis") as Polygon2D
		var col := body.get_node_or_null(^"Col") as CollisionShape2D
		if vis == null or col == null or not col.shape is RectangleShape2D:
			continue
		vis.visible = false
		var size := (col.shape as RectangleShape2D).size
		body.add_child(_FortressSurface.new(size.x, size.y))


func _platform(x: float, y: float, width: float, height: float, _color: Color) -> void:
	_serial += 1
	var body := StaticBody2D.new()
	body.name = "FortressGround%d" % _serial
	body.position = Vector2(x, y)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	col.shape = shape
	body.add_child(col)
	body.add_child(_FortressSurface.new(width, height))
	add_child(body)


func _shop(x: float, y: float, title: String, items: PackedStringArray) -> void:
	var node: LevelShop = SHOP.new()
	node.position = Vector2(x, y)
	node.title = title
	node.items = items
	node.style = "fortress"
	node.accent = Color("b88757")
	add_child(node)


class _FortressSurface extends Node2D:
	var _width: float
	var _height: float

	func _init(width: float, height: float) -> void:
		_width = width
		_height = height

	func _draw() -> void:
		var left := -_width * 0.5
		var top := -_height * 0.5
		draw_texture_rect(FORTRESS_STONE, Rect2(left, top, _width, _height), true)
		draw_rect(Rect2(left, top, _width, 6), Color("6f7188"))


class _FortressBackdrop extends Node2D:
	var _camera: Camera2D

	func _ready() -> void:
		z_index = -80
		z_as_relative = false

	func _process(_delta: float) -> void:
		if _camera == null or not is_instance_valid(_camera):
			_camera = get_viewport().get_camera_2d()
			if _camera == null:
				return
		global_position = _camera.get_screen_center_position()
		queue_redraw()

	func _draw() -> void:
		var x := global_position.x
		var cell := 0 if x < 13000.0 else 1 if x < 26500.0 else 2 if x < 43000.0 else 3
		draw_texture_rect_region(FORTRESS_ATLAS, Rect2(-960, -540, 1920, 900),
			Rect2((cell % 2) * 836 + 2, (cell / 2) * 470 + 2, 832, 365))

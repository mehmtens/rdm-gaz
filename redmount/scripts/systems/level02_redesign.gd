## Bölüm 2 görseli ve ödül katmanı: kontrol bölgesi dekoru, kırılabilir kaplar,
## parkur büfeleri ve zorunlu olmayan yüksek bonus rotası.
extends Node2D

const BACKGROUND := preload("res://assets/backgrounds/level02_armed_checkpoint.png")
const LOCATION_ATLAS := preload("res://assets/backgrounds/level02_locations_atlas.png")
const PROP := preload("res://scripts/systems/breakable_prop.gd")
const SHOP := preload("res://scripts/systems/level_shop.gd")
const ONEWAY := preload("res://scenes/systems/OneWayPlatform.tscn")
const COIN := preload("res://scenes/pickups/Coin.tscn")
const ARMOR := preload("res://scenes/pickups/ArmorPickup.tscn")
const HEALTH := preload("res://scenes/pickups/HealthPickup.tscn")
const AMMO := preload("res://scenes/pickups/AmmoPickup.tscn")
const PISTOL := preload("res://scenes/pickups/PistolPickup.tscn")
const RIFLE_PICKUP := preload("res://scenes/pickups/RiflePickup.tscn")
const STREET := preload("res://scenes/enemies/StreetThug.tscn")
const KNIFE := preload("res://scenes/enemies/KnifeAgent.tscn")
const RIFLE := preload("res://scenes/enemies/RifleGuard.tscn")
const CHECKPOINT := preload("res://scenes/systems/Checkpoint.tscn")
const ARENA := preload("res://scenes/systems/BattleArena.tscn")
const DIALOGUE := preload("res://scenes/systems/DialogueTrigger.tscn")

const ASPHALT := Color("343b49")
const METAL := Color("46515c")
const BRICK := Color("594149")

var _serial := 0


func _ready() -> void:
	add_child(_BackdropArt.new())
	_restyle_opening()
	_prop("vazo", 120, 0)
	_prop("kasa", 720, 0)
	_prop("sandik", 1540, -320, ARMOR)
	_cloud(1120, -190, 150)
	_cloud(1330, -255, 160)
	_cloud(1540, -320, 170)
	for i in 3:
		_pickup(COIN, 1120 + i * 210, -382)
	_shop(2240, 0, "KONTROL BÜFESİ", PackedStringArray(["can", "cephane", "bicak"]))
	_prop("varil", 3260, -70)
	_prop("tup", 3970, -70)
	_prop("kasa", 4870, -70)
	_shop(4930, -70, "GEÇİŞ NOKTASI", PackedStringArray(["can", "cephane", "zirh"]))
	_build_long_route()


func _build_long_route() -> void:
	# 05.800–10.600 — Otobüs terminali: siperler ve ilk tüfek baskısı.
	_ground(6500, 1400, ASPHALT)
	_prop("kasa", 6020); _prop("varil", 6250)
	_enemy(RIFLE, 6650, 0); _enemy(STREET, 7000, 0)
	_ground(7800, 1300, ASPHALT, 90)
	_platform(7400, -15, 360, 90, METAL)
	_platform(7800, -75, 340, 90, METAL)
	_platform(8200, -15, 360, 90, METAL)
	_cloud(7550, -290, 160); _cloud(7800, -365, 170); _cloud(8050, -290, 160)
	_pickup(AMMO, 7800, -415)
	_ground(9500, 2200, ASPHALT)
	_enemy(RIFLE, 9000, 0); _enemy(KNIFE, 9500, 0)
	_pickup(HEALTH, 9850, -45)
	_checkpoint(10150)
	_arena(9900, 9200, 10500, _wave(STREET, RIFLE), _wave(KNIFE, STREET, RIFLE), AMMO)

	# 10.600–16.000 — Polis bariyerleri: alçak/yüksek siper değişimi.
	_ground(11200, 1200, BRICK)
	_prop("tup", 10850); _prop("kasa", 11400)
	_ground(12700, 1900, BRICK, 90)
	_platform(12000, -15, 360, 70, METAL)
	_platform(12400, -75, 340, 70, METAL)
	_platform(12800, -15, 360, 70, METAL)
	_platform(13200, -85, 340, 70, METAL)
	_platform(13560, -15, 380, 70, METAL)
	_coin_arc(11950, 5, 400, -185)
	_enemy(RIFLE, 12800, -50)
	_ground(14800, 2400, ASPHALT)
	_enemy(STREET, 14100, 0); _enemy(KNIFE, 14700, 0); _enemy(RIFLE, 15300, 0)
	_shop(15600, 0, "NÖBET BÜFESİ", PackedStringArray(["can", "cephane", "tabanca"]))
	_checkpoint(15800)

	# 16.000–21.400 — Gümrük deposu çatıları: üstte silah, altta yakın dövüş.
	_ground(16900, 1800, BRICK)
	_prop("varil", 16400); _prop("kasa", 17100)
	_enemy(KNIFE, 16800, 0); _enemy(STREET, 17400, 0)
	_ground(18400, 1300, BRICK, 90)
	_platform(18000, -15, 360, 110, BRICK)
	_platform(18400, -75, 340, 110, BRICK)
	_platform(18800, -15, 360, 110, BRICK)
	_cloud(18150, -305, 160); _cloud(18400, -380, 170); _cloud(18650, -305, 160)
	_pickup(RIFLE_PICKUP, 18400, -430)
	_ground(20200, 2400, ASPHALT)
	_enemy(RIFLE, 19500, 0); _enemy(KNIFE, 20100, 0)
	_prop("sandik", 20600, 0, ARMOR)
	_shop(20900, 0, "DEPO KANTİNİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(21200)

	# 21.400–26.500 — Tel örgü servis yolu: sabit bakım platformları.
	_ground(21800, 800, METAL)
	_ground(23300, 2600, METAL, 150)
	_street_steps(22220, [35, 70, 105, 70, 35], METAL)
	_coin_arc(22350, 6, 335, -210)
	_ground(25300, 2400, ASPHALT)
	_enemy(RIFLE, 24600, 0); _enemy(KNIFE, 25200, 0); _enemy(STREET, 25800, 0)
	_prop("tup", 26100); _prop("varil", 26300)
	_checkpoint(26400)

	# 26.500–31.800 — Ray kontrol noktası: geniş ateş hattı ve kilitli pusu.
	_ground(27600, 3600, ASPHALT)
	_pickup(HEALTH, 26950, -45)
	_enemy(RIFLE, 27300, 0); _enemy(RIFLE, 28100, 0)
	_checkpoint(28200)
	_arena(28600, 27800, 29400, _wave(RIFLE, STREET, KNIFE), _wave(RIFLE, KNIFE, RIFLE), ARMOR)
	_ground(30050, 1400, ASPHALT, 90)
	_platform(29600, -15, 400, 90, METAL)
	_platform(30000, -75, 360, 90, METAL)
	_platform(30400, -15, 400, 90, METAL)
	_ground(31800, 2200, BRICK)
	_prop("kasa", 31300); _prop("sandik", 32100, 0, PISTOL)
	_shop(32500, 0, "RAY BÜFESİ", PackedStringArray(["can", "cephane", "tabanca"]))
	_checkpoint(32700)

	# 31.800–37.200 — Trafo bakım hattı: ana yol düz, bulut hattı gizli.
	_ground(32900, 2200, METAL)
	_enemy(KNIFE, 33300, 0); _enemy(RIFLE, 33800, 0)
	_ground(35100, 2600, METAL, 150)
	_street_steps(34020, [35, 70, 105, 70, 35], METAL)
	_cloud(34700, -290, 160); _cloud(34950, -365, 170); _cloud(35200, -290, 160)
	_coin_line(34650, 4, 190, -425)
	_pickup(AMMO, 34950, -415)
	_ground(37200, 2400, ASPHALT)
	_enemy(RIFLE, 36500, 0); _enemy(STREET, 37100, 0); _enemy(KNIFE, 37700, 0)
	_prop("varil", 38100)
	_checkpoint(38200)

	# 37.200–42.500 — Komuta avlusu: bölümün en yoğun ateşli silah arenası.
	_ground(39000, 3600, BRICK)
	_pickup(HEALTH, 38600, -45); _pickup(AMMO, 38750, -45)
	_checkpoint(39000)
	_arena(39700, 38900, 40500, _wave(RIFLE, KNIFE, STREET), _wave(RIFLE, RIFLE, KNIFE), RIFLE_PICKUP)
	_prop("sandik", 40600, 0, HEALTH)
	_ground(41600, 1600, ASPHALT)
	_shop(42000, 0, "KOMUTA TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(42300)

	# 42.500–49.000 — Şehir kapısı: iki katlı son yaklaşım ve final pusu.
	_ground(43600, 2400, BRICK, 150)
	_street_steps(42420, [35, 70, 105, 70, 35], BRICK)
	_cloud(43250, -310, 160); _cloud(43500, -385, 170); _cloud(43750, -310, 160)
	_pickup(ARMOR, 43500, -435)
	_ground(45500, 2200, ASPHALT)
	_enemy(RIFLE, 44800, 0); _enemy(KNIFE, 45400, 0); _enemy(RIFLE, 46000, 0)
	_prop("kasa", 46300); _prop("varil", 46500)
	_ground(47800, 2400, BRICK)
	_pickup(HEALTH, 47150, -45)
	_checkpoint(47300)
	_arena(48100, 47400, 48800, _wave(STREET, RIFLE, KNIFE), _wave(RIFLE, KNIFE, RIFLE), HEALTH)
	_dialogue(48840, "REDMOUNT", "Kontrol hattı düştü. Sevkiyat raylardan sanayi kuşağına gidiyor.")


func _prop(kind: String, x: float, y: float = 0.0, reward: PackedScene = null) -> void:
	var node: BreakableProp = PROP.new()
	node.kind = kind
	node.reward = reward
	node.position = Vector2(x, y)
	add_child(node)


func _cloud(x: float, y: float, width: float) -> void:
	var node := ONEWAY.instantiate()
	node.position = Vector2(x, y)
	node.set("width", width)
	node.set("style", "cloud")
	add_child(node)


func _pickup(scene: PackedScene, x: float, y: float) -> void:
	var node := scene.instantiate()
	node.position = Vector2(x, y)
	add_child(node)


func _shop(x: float, y: float, title: String, items: PackedStringArray) -> void:
	var node: LevelShop = SHOP.new()
	node.position = Vector2(x, y)
	node.title = title
	node.items = items
	node.accent = Color("e7a449")
	add_child(node)


func _ground(x: float, width: float, color: Color, surface := 0.0) -> void:
	_platform(x, surface + 200.0, width, 400.0, color)


func _street_steps(start_x: float, depths: Array[int], color: Color) -> void:
	for i in depths.size():
		_ground(start_x + i * 400.0 + 180.0, 360.0, color, float(depths[i]))


func _restyle_opening() -> void:
	for body in get_parent().get_children():
		if not body is StaticBody2D:
			continue
		var body_name := str(body.name)
		if not body_name.begins_with("Ground") and not body_name.begins_with("Roof"):
			continue
		var col := body.get_node_or_null(^"Col") as CollisionShape2D
		var vis := body.get_node_or_null(^"Vis") as Polygon2D
		if col == null or not col.shape is RectangleShape2D or vis == null:
			continue
		vis.visible = false
		var size := (col.shape as RectangleShape2D).size
		body.add_child(_Surface.new(size.x, size.y, BRICK if body_name.begins_with("Roof") else ASPHALT))


func _platform(x: float, y: float, width: float, height: float, color: Color) -> void:
	_serial += 1
	var body := StaticBody2D.new()
	body.name = "ExtensionGround%d" % _serial
	body.position = Vector2(x, y)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	col.shape = shape
	body.add_child(col)
	body.add_child(_Surface.new(width, height, color))
	add_child(body)


func _enemy(scene: PackedScene, x: float, y: float) -> void:
	var node := scene.instantiate()
	node.position = Vector2(x, y)
	add_child(node)


func _checkpoint(x: float) -> void:
	var node := CHECKPOINT.instantiate()
	node.position = Vector2(x, 0)
	add_child(node)


func _dialogue(x: float, speaker: String, line: String) -> void:
	var node := DIALOGUE.instantiate()
	node.position = Vector2(x, -70)
	node.set("speakers", PackedStringArray([speaker]))
	node.set("texts", PackedStringArray([line]))
	add_child(node)


func _wave(a: PackedScene, b: PackedScene, c: PackedScene = null) -> Array[PackedScene]:
	var result: Array[PackedScene] = [a, b]
	if c != null:
		result.append(c)
	return result


func _arena(x: float, left: float, right: float, first: Array[PackedScene],
		second: Array[PackedScene], reward: PackedScene = null) -> void:
	var node: BattleArena = ARENA.instantiate()
	node.position = Vector2(x, 0)
	node.gate_left_x = left
	node.gate_right_x = right
	node.floor_y = 0
	node.wave1 = first
	node.wave2 = second
	node.reward = reward
	add_child(node)


func _coin_line(start_x: float, count: int, spacing: float, y: float) -> void:
	for i in count:
		_pickup(COIN, start_x + i * spacing, y)


func _coin_arc(start_x: float, count: int, spacing: float, top_y: float) -> void:
	for i in count:
		var t := float(i) / maxf(float(count - 1), 1.0)
		_pickup(COIN, start_x + i * spacing, top_y + absf(t - 0.5) * 110.0)


class _Surface extends Node2D:
	const PAVING := preload("res://assets/environment/mahalle/ground_long.png")
	const STONE := preload("res://assets/environment/mahalle/stone_fill.png")
	const ROOF := preload("res://assets/environment/mahalle/roof_a.png")
	const SCAFFOLD := preload("res://assets/environment/mahalle/scaffold_deck_v2.png")
	var _width: float
	var _height: float
	var _color: Color

	func _init(width: float, height: float, color: Color) -> void:
		_width = width
		_height = height
		_color = color

	func _draw() -> void:
		var left := -_width * 0.5
		var top := -_height * 0.5
		if _height >= 150:
			draw_texture_rect(STONE, Rect2(left, top + 32, _width, _height - 32), true, Color("797689"))
			draw_texture_rect(PAVING, Rect2(left, top, _width, 90), true, Color("c7bbc4"))
		elif _color == METAL:
			var floor_depth := maxf(-get_parent().position.y, 75.0)
			for support_x in [left + 10.0, -left - 10.0]:
				draw_line(Vector2(support_x, top + 26), Vector2(support_x, floor_depth), Color("343b40"), 7)
			draw_texture_rect_region(SCAFFOLD, Rect2(left, top, _width, 70), Rect2(26, 148, 1931, 535))
		else:
			draw_texture_rect(ROOF, Rect2(left, top, _width, _height + 18), false)


class _BackdropArt extends Node2D:
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
		var cuts := [5800.0, 10600.0, 21400.0, 37200.0, 42500.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_scene(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_scene(scene: int, alpha: float) -> void:
		var tint := Color(1, 1, 1, alpha)
		if scene == 0 or scene == 4:
			draw_texture_rect(BACKGROUND, Rect2(-960, -540, 1920, 1080), false, tint)
			return
		var cell := Vector2i.ZERO
		match scene:
			1: cell = Vector2i(0, 0)
			2: cell = Vector2i(1, 0)
			3: cell = Vector2i(0, 1)
			5: cell = Vector2i(1, 1)
		draw_texture_rect_region(LOCATION_ATLAS, Rect2(-960, -540, 1920, 800),
			Rect2(cell.x * 992 + 2, cell.y * 396 + 2, 988, 392), tint)

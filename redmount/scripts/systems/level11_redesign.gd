## Bölüm 10 — Kuzey Surları: servis yolu açık, burç ve hareketli köprüler ödüllü.
extends "res://scripts/systems/story_blockout.gd"

const ATLAS := preload("res://assets/backgrounds/level11_north_walls_atlas_v2.png")
const STONE := preload("res://assets/environment/fortress_stone.png")
const PLATFORM_STONE := preload("res://assets/environment/fortress_platform.png")
const HINT := preload("res://scenes/systems/HintTrigger.tscn")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_Backdrop.new())
	_intro("REDMOUNT", "Kuzey surunun servis yolu açık. Burçlardan kalenin kör noktasını görebilirim.")

	# Dış nöbet yolu: tek seçkinle dövüş; köprü önce güvenli zeminin üstünde.
	_ground(2000, 4000)
	_ground(6000, 4000)
	_coin_line(500, 6, 190, -55)
	_enemy(ELITE, 1700, 0)
	_hint(2600, "HAREKETLİ KÖPRÜLER ÜST ROTA.\nAlt servis yolundan da ilerleyebilirsin.")
	_oneway(3000, -85, 230)
	_moving(3320, -135, Vector2(230, -45), 195)
	_moving(3820, -190, Vector2(-210, 35), 195, 0.5)
	_oneway(4280, -85, 230)
	for i in 5:
		_bonus_coin(3210 + i * 210, -245, 5)
	_pickup(ARMOR, 3780, -270)
	_enemy(ASSASSIN, 5150, 0)
	_enemy(RIFLE, 6200, 0)
	_prop("sandik", 6750, 0, HEALTH)
	_shop(7250, "KUZEY NÖBETÇİSİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(7800, 0)

	# Seyir burcu: alttaki yol 70 alçalır, üst iskele yüksek değerli coine çıkar.
	_ground(10000, 4000, 70)
	_ground(14000, 4000)
	_coin_line(8300, 5, 560, 15)
	_oneway(8500, -20, 220)
	_oneway(8800, -110, 220)
	_moving(9130, -175, Vector2(230, 0), 190)
	_moving(9610, -230, Vector2(-230, 0), 190, 0.5)
	_oneway(10100, -90, 220)
	for i in 5:
		_bonus_coin(8750 + i * 290, -265, 5)
	_pickup(AMMO, 9610, -290)
	_enemy(ASSASSIN, 9400, 70)
	_enemy(RIFLE, 10500, 70)
	_enemy(ELITE, 12000, 0)
	_pickup(HEALTH, 12900, -45)
	_checkpoint(13500, 0)
	_arena(14300, 0, 13500, 15100, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, ELITE), AMMO)
	_coin_line(15300, 5, 170, -55)

	# Kemerli su yolu: çift köprü ters fazda; başarısız atlayış servis yoluna indirir.
	_ground(18000, 4000)
	_ground(22000, 4000, 80)
	_oneway(17000, -80, 225)
	_moving(17400, -145, Vector2(250, -45), 190)
	_moving(18150, -205, Vector2(-240, 40), 190, 0.5)
	_oneway(18800, -115, 225)
	for i in 5:
		_bonus_coin(17270 + i * 390, -270, 5)
	_pickup(PISTOL, 18150, -285)
	_enemy(ASSASSIN, 17300, 0)
	_enemy(RIFLE, 18350, 0)
	_coin_line(19100, 5, 500, -55)
	_enemy(ELITE, 21100, 80)
	_enemy(RIFLE, 22500, 80)
	_pickup(HEALTH, 23000, 20)
	_checkpoint(23600, 80)

	# Fener bataryası: üç kotlu gönüllü tırmanış, sonra geniş avlu savunması.
	_ground(26000, 4000)
	_ground(30000, 4000, 70)
	_ground(34000, 4000)
	_shop(24600, "KEMER ERZAK ODASI", PackedStringArray(["can", "cephane", "tabanca"]))
	_oneway(25600, -85, 220)
	_oneway(25900, -170, 220)
	_oneway(26200, -255, 220)
	_oneway(26500, -170, 220)
	_oneway(26800, -85, 220)
	for i in 5:
		_bonus_coin(25600 + i * 300, -315 if i == 2 else -235, 5)
	_pickup(ARMOR, 26200, -315)
	_enemy(ASSASSIN, 26800, 0)
	_enemy(RIFLE, 27900, 0)
	_coin_line(28300, 5, 500, 15)
	_moving(29600, -135, Vector2(200, -70), 190)
	_enemy(ELITE, 30400, 70)
	_enemy(ASSASSIN, 31300, 70)
	_pickup(HEALTH, 32400, -45)
	_checkpoint(33300, 0)
	_arena(34200, 0, 33400, 35000, _wave(RIFLE, ELITE),
		_wave(ASSASSIN, ELITE, RIFLE), HEALTH)
	_coin_line(35400, 5, 400, -55)

	# Kuzey gedik: hareketli köprü öğrenmesi tüfek baskısıyla yinelenir.
	_ground(38000, 4000)
	_ground(42000, 4000, 60)
	_ground(46000, 4000)
	_enemy(ASSASSIN, 37200, 0)
	_enemy(RIFLE, 38300, 0)
	_shop(39200, "FENER MUHAFIZ DEPOSU", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(39700, 0)
	_oneway(40500, -85, 220)
	_moving(40850, -155, Vector2(260, -55), 190)
	_moving(41650, -220, Vector2(-250, 45), 190, 0.5)
	_oneway(42400, -115, 220)
	for i in 5:
		_bonus_coin(40750 + i * 340, -290, 5)
	_pickup(RIFLE_PICKUP, 41650, -305)
	_enemy(ELITE, 41500, 60)
	_enemy(RIFLE, 42800, 60)
	_coin_line(43300, 5, 480, 5)
	_pickup(HEALTH, 44900, -45)
	_checkpoint(45600, 0)

	# İç kapı: tek karar veren son arena; sessiz koridora yürüyerek çıkılır.
	_ground(49000, 2000)
	_enemy(ASSASSIN, 46300, 0)
	_enemy(ELITE, 46650, 0)
	_arena(47400, 0, 46600, 48200, _wave(ELITE, RIFLE),
		_wave(ELITE, ASSASSIN, RIFLE), HEALTH)
	_dialogue(48800, "REDMOUNT", "Kör noktayı buldum. Gazelle'in sesi şimdi duvarın ötesinden geliyor.")
	_goal(49400, 0)


func _bonus_coin(x: float, y: float, value: int) -> void:
	var coin := COIN.instantiate()
	coin.position = Vector2(x, y)
	coin.value = value
	add_child(coin)


func _hint(x: float, message: String) -> void:
	var hint: HintTrigger = HINT.instantiate()
	hint.position = Vector2(x, 0)
	hint.text = message
	add_child(hint)


func _shop(x: float, title: String, items: PackedStringArray) -> void:
	super._shop(x, title, items)
	(get_child(get_child_count() - 1) as LevelShop).style = "fortress"


func _platform(x: float, y: float, width: float, height: float) -> void:
	super._platform(x, y, width, height)
	var body := get_child(get_child_count() - 1) as StaticBody2D
	body.get_node(^"Vis").visible = false
	body.add_child(_StoneFace.new(width, height))


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "fortress")


func _moving(x: float, y: float, travel: Vector2, width: float, phase := 0.0) -> void:
	super._moving(x, y, travel, width, phase)
	get_child(get_child_count() - 1).set("style", "fortress")


class _StoneFace extends Node2D:
	var width: float
	var height: float

	func _init(w: float, h: float) -> void:
		width = w
		height = h

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

	func _draw() -> void:
		var left := -width * 0.5
		var top := -height * 0.5
		draw_texture_rect(STONE if height > 150.0 else PLATFORM_STONE,
			Rect2(left, top, width, height), true)
		draw_rect(Rect2(left, top, width, 6), Color("6f7188" if height > 150.0 else "a89eaa"))


class _Backdrop extends Node2D:
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
		var cuts := [12000.0, 26000.0, 38500.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_cell(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_cell(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_cell(scene: int, alpha: float) -> void:
		var half := ATLAS.get_size() * 0.5
		var cell := Vector2(scene % 2, scene / 2) * half
		draw_texture_rect_region(ATLAS, Rect2(-960, -540, 1920, 900),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y * 0.82)),
			Color(1, 1, 1, alpha))

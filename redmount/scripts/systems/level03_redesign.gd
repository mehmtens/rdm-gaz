## Bölüm 3 uzun rota: ağır sanayi, menzilli baskı ve çevik düşman katmanı.
## Level02'nin sahne kurucularını tekrar kullanır; yalnız içerik dizilimi farklıdır.
extends "res://scripts/systems/level02_redesign.gd"

const HEAVY_BG := preload("res://assets/backgrounds/level03_heavy_industry.png")
const INDUSTRY_ATLAS := preload("res://assets/backgrounds/level03_industry_atlas.png")
const FURNACE_BG := preload("res://assets/backgrounds/level03_high_furnace.png")
const AGILE := preload("res://scenes/enemies/AgileAssassin.tscn")
const BRUISER := preload("res://scenes/enemies/ArmoredBruiser.tscn")
const HINT := preload("res://scenes/systems/HintTrigger.tscn")


func _ready() -> void:
	add_child(_HeavyBackdrop.new())
	_restyle_opening()
	_build_heavy_route()
	var level := get_parent() as Level
	level.camera_limit_right = 49800
	level.par_time = 450.0
	var goal := level.get_node_or_null(^"LevelGoal")
	if goal != null:
		goal.position = Vector2(49200, 0)


func _build_heavy_route() -> void:
	# 5.200–13.000 — dökümhane: siperli tüfek hattı, üst rota cephane.
	_ground(6500, 2600, METAL)
	_checkpoint(5350)
	_lesson(5450, "YERE ÇAKMA: HAVADA AŞAĞI + SALDIRI\nZırhlıyı sars; K ağır yumruk da işe yarar.")
	_enemy(BRUISER, 5800, 0)
	_enemy(RIFLE, 6550, 0); _enemy(KNIFE, 7050, 0); _enemy(RIFLE, 7600, 0)
	_coin_line(5550, 5, 150, -55)
	_ground(8600, 1600, METAL, 150)
	_street_steps(7820, [35, 70, 70, 35], METAL)
	_cloud(8500, -300, 170); _cloud(8760, -380, 170); _cloud(9020, -300, 170)
	_pickup(AMMO, 8760, -430)
	_coin_line(9450, 4, 220, -55)
	_ground(10600, 2500, ASPHALT)
	_ground(12575, 1450, ASPHALT)
	_enemy(AGILE, 10100, 0); _enemy(RIFLE, 11000, 0)
	_shop(11900, 0, "DÖKÜMHANE BÜFESİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(12400)
	_arena(12600, 11800, 13400, _wave(RIFLE, AGILE), _wave(KNIFE, RIFLE, AGILE), AMMO)

	# 13.000–22.000 — pres hattı: düz ana yol, isteğe bağlı yüksek ödül hattı.
	_ground(14800, 3000, BRICK)
	_enemy(BRUISER, 14300, 0); _enemy(RIFLE, 15100, 0); _enemy(AGILE, 15900, 0)
	_ground(17900, 2800, METAL, 175)
	_street_steps(16320, [35, 70, 105, 140, 105, 70, 35], METAL)
	for i in 7:
		_pickup(COIN, 16500 + i * 400, [ -10, 25, 60, 95, 60, 25, -10 ][i])
	_coin_line(13700, 5, 240, -55)
	_ground(20400, 2600, ASPHALT)
	_enemy(RIFLE, 19800, 0); _enemy(BRUISER, 20700, 0)
	_pickup(HEALTH, 21400, -45); _checkpoint(21800)

	# 22.000–31.000 — vinç galerisi: platform ritmi, güvenli inişlerde yakın dövüş.
	_ground(22800, 2300, METAL, 150)
	_street_steps(21720, [35, 70, 105, 105, 70, 35], METAL)
	for i in 6:
		_pickup(COIN, 21900 + i * 400, [ -10, 25, 60, 60, 25, -10 ][i])
	_ground(24900, 1900, BRICK)
	_ground(26175, 650, ASPHALT, 70)
	_enemy(AGILE, 24400, 0); _enemy(KNIFE, 25100, 0)
	_cloud(25800, -280, 170); _cloud(26060, -355, 170); _cloud(26320, -280, 170)
	_pickup(ARMOR, 26060, -405)
	_ground(28000, 3000, ASPHALT)
	_coin_line(26800, 5, 330, -55)
	_ground(30450, 1900, ASPHALT)
	_enemy(RIFLE, 27300, 0); _enemy(AGILE, 28100, 0); _enemy(BRUISER, 28900, 0)
	_shop(29600, 0, "VİNÇ KANTİNİ", PackedStringArray(["can", "cephane", "tabanca"]))
	_checkpoint(30200)
	_arena(30600, 29800, 31400, _wave(AGILE, RIFLE), _wave(BRUISER, RIFLE, AGILE), ARMOR)

	# 31.000–40.000 — yüksek fırın çevresi: artan karma düşman baskısı.
	_ground(32600, 2400, METAL)
	_coin_line(31700, 5, 310, -55)
	_enemy(RIFLE, 32100, 0); _enemy(KNIFE, 32800, 0)
	_ground(34600, 1700, BRICK, 150)
	_street_steps(33820, [35, 70, 70, 35], BRICK)
	for i in 4:
		_pickup(COIN, 34000 + i * 400, [ -10, 25, 25, -10 ][i])
	_ground(36900, 3300, ASPHALT)
	_ground(39025, 950, ASPHALT)
	_enemy(AGILE, 36000, 0); _enemy(RIFLE, 36900, 0); _enemy(BRUISER, 37800, 0)
	_prop("sandik", 38400, 0, HEALTH)
	_checkpoint(39100)

	# 40.000–49.200 — güvenlik çekirdeği: son hazırlık ve iki dalgalı arena.
	_ground(40800, 2600, BRICK)
	_coin_line(40100, 4, 280, -55)
	_pickup(HEALTH, 39850, -45); _pickup(AMMO, 40020, -45)
	_enemy(RIFLE, 40500, 0); _enemy(AGILE, 41400, 0)
	_ground(43300, 2400, METAL, 150)
	_street_steps(42120, [35, 70, 105, 70, 35], METAL)
	_ground(45900, 3600, ASPHALT)
	_ground(48750, 2100, BRICK)
	_shop(44600, 0, "GÜVENLİK TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))
	_coin_line(44600, 5, 200, -55)
	_checkpoint(45700)
	_arena(46600, 45400, 47800, _wave(RIFLE, AGILE, KNIFE), _wave(BRUISER, RIFLE, AGILE), HEALTH)
	_dialogue(48400, "REDMOUNT", "Sanayi hattı çöktü. Sırada dağ kalesi var.")


func _lesson(x: float, message: String) -> void:
	var node: HintTrigger = HINT.instantiate()
	node.position = Vector2(x, 0)
	node.text = message if Save.owns("ground_slam") else "ZIRHLI DÜŞMAN: K AĞIR YUMRUK\nYere çakma vuruşu ana menü mağazasında açılır."
	add_child(node)


class _HeavyBackdrop extends Node2D:
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
		var cuts := [5200.0, 13000.0, 22000.0, 31000.0, 40000.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_scene(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_scene(scene: int, alpha: float) -> void:
		var tint := Color(1, 1, 1, alpha)
		if scene == 0:
			draw_texture_rect(HEAVY_BG, Rect2(-960, -540, 1920, 1080), false, tint)
			return
		if scene == 4:
			draw_texture_rect(FURNACE_BG, Rect2(-960, -540, 1920, 1080), false, tint)
			return
		var cells := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 1)]
		var cell: Vector2i = cells[scene - 1]
		draw_texture_rect_region(INDUSTRY_ATLAS, Rect2(-960, -540, 1920, 800),
			Rect2(cell.x * 887 + 2, cell.y * 443 + 2, 883, 439), tint)

## Kitap 2 / Bölüm 6 — Kapalıçarşı Arka Hanı.
extends "res://scripts/systems/book02_level01.gd"

const BAZAAR := preload("res://assets/backgrounds/book02_bazaar_streets_atlas.png")
const HAN := preload("res://assets/backgrounds/book02_bazaar_han_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_BazaarBackdrop.new())
	_intro("GAZELLE", "Posta fişindeki han numarası burada. Sevkiyatın dağıtım defterini bulmalıyız.")
	for i in 29:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [8, 17, 24]:
			x -= 50.0
			width = 3900.0
		elif i in [9, 18, 25]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [4, 5, 19, 20, 21] else 0.0)

	# Çarşı kapısı: az düşmanla okunur giriş, üst saçak isteğe bağlı.
	_coin_line(500, 6, 220, -55)
	_enemy(STREET, 2300, 0)
	_enemy(KNIFE, 5100, 0)
	_oneway(6600, -85, 220)
	_oneway(6900, -170, 220)
	_oneway(7200, -85, 220)
	for i in 4:
		_bonus_coin(6600 + i * 220, -225, 5)
	_pickup(ARMOR, 6900, -225)
	_checkpoint(9300, 0)
	_enemy(RIFLE, 11700, 0)
	_dialogue(13500, "REDMOUNT", "Kapı tutulmuş. Defter gerçekten bu hanın içindeyse bizi bekliyorlar.")

	# Kalpakçılar geçidi: 60 px alçak rota, kumaş saçakları bonus yol.
	_coin_line(15100, 6, 300, -55)
	_enemy(STREET, 17400, 60)
	_enemy(ASSASSIN, 19100, 60)
	_oneway(20200, -25, 220)
	_oneway(20500, -110, 220)
	_oneway(20800, -195, 220)
	for i in 4:
		_bonus_coin(20200 + i * 220, -250, 5)
	_pickup(AMMO, 20800, -255)
	_checkpoint(22600, 60)
	_arena(26000, 0, 25200, 26800, _wave(STREET, KNIFE),
		_wave(ASSASSIN, RIFLE), HEALTH)
	_coin_line(27800, 5, 300, -55)

	# Bedesten: taş aralık yalnız 200 px; raflarda daha değerli iz var.
	_enemy(KNIFE, 31600, 0)
	_oneway(33200, -85, 220)
	_oneway(33500, -170, 220)
	_oneway(33800, -255, 220)
	_oneway(34100, -170, 220)
	for i in 5:
		_bonus_coin(33200 + i * 260, -310, 5)
	_pickup(PISTOL, 33800, -315)
	_checkpoint(35000, 0)
	_oneway(36000, -45, 240)
	_enemy(ELITE, 39400, 0)
	_pickup(HEALTH, 42500, -45)

	# Bakırcılar: kısa siper ve açık avluda ikinci arena.
	_shop(44400, "BAKIRCILAR ERZAK TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))
	_enemy(RIFLE, 45800, 0)
	_oneway(47600, -85, 220)
	_moving(48100, -145, Vector2(180, -30), 190)
	_oneway(48700, -205, 220)
	for i in 5:
		_bonus_coin(47600 + i * 275, -265, 5)
	_pickup(RIFLE_PICKUP, 48700, -265)
	_enemy(BRUISER, 50600, 0)
	_checkpoint(52100, 0)
	_arena(54400, 0, 53600, 55200, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(57500, "GAZELLE", "Çuvallarda mal yok; içleri sahte mühür ve rota fişleriyle dolu.")

	# Han avlusu: üst revak bonus, geniş alt taş yolu serbest.
	_checkpoint(60800, 0)
	_enemy(ASSASSIN, 63000, 0)
	_oneway(64800, -85, 220)
	_oneway(65100, -170, 220)
	_oneway(65400, -85, 220)
	for i in 4:
		_bonus_coin(64800 + i * 220, -225, 5)
	_pickup(ARMOR, 65100, -225)
	_enemy(STREET, 67700, 0)
	_checkpoint(69500, 0)
	_oneway(72000, -45, 240)
	_coin_line(71300, 5, 330, -125)

	# Han ambarı: alt servis zemini 60 px iner; üst taşıma rafı seçimdir.
	_enemy(ELITE, 78100, 60)
	_oneway(81600, -25, 220)
	_oneway(81900, -110, 220)
	_oneway(82200, -195, 220)
	for i in 4:
		_bonus_coin(81600 + i * 220, -250, 5)
	_pickup(HEALTH, 83300, 5)
	_checkpoint(84000, 60)
	_arena(86000, 60, 85200, 86800, _wave(ELITE, STREET),
		_wave(RIFLE, KNIFE), AMMO)
	_checkpoint(87900, 60)

	# Gizli defter odası: son 200 px servis aralığı ve kısa tekli devriye.
	_enemy(ASSASSIN, 90600, 0)
	_oneway(92800, -85, 220)
	_oneway(93100, -170, 220)
	_oneway(93400, -85, 220)
	for i in 4:
		_bonus_coin(92800 + i * 220, -225, 5)
	_enemy(RIFLE, 96700, 0)
	_checkpoint(98300, 0)
	_oneway(100000, -45, 240)
	_coin_line(99300, 5, 330, -125)
	_enemy(ELITE, 103000, 0)
	_pickup(HEALTH, 104400, -45)
	_dialogue(106000, "REDMOUNT", "Defter burada. Önce çatıdaki çıkışı güvene alalım.")

	# Üç dalgalı han savunması: hızlı, menzilli, sonra zırhlı.
	_checkpoint(107400, 0)
	var finale: BattleArena = ARENA.instantiate()
	finale.position = Vector2(110000, 0)
	finale.gate_left_x = 109200
	finale.gate_right_x = 110800
	finale.wave1 = _wave(KNIFE, ASSASSIN)
	finale.wave2 = _wave(ELITE, RIFLE)
	finale.wave3 = _wave(BRUISER, ELITE)
	finale.reward = HEALTH
	add_child(finale)
	_dialogue(112700, "GAZELLE", "Defterin son işareti Çemberlitaş'taki eski hamamın külhanı. Dağıtım oradan yönetiliyor.")
	_goal(114800, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	if x >= 30000 and x < 44000 or x >= 58000 and x < 104000:
		get_child(get_child_count() - 1).set("style", "wood_shelf")
	elif x >= 44000 and x < 58000:
		get_child(get_child_count() - 1).set("style", "awning")
	elif x >= 104000:
		get_child(get_child_count() - 1).set("style", "roof")


class _BazaarBackdrop extends Node2D:
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
		var cuts := [14000.0, 30000.0, 44000.0, 58000.0,
			73000.0, 88000.0, 103000.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_scene(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_scene(scene: int, alpha: float) -> void:
		var atlas: Texture2D = BAZAAR if scene < 4 else HAN
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -540, 1920, 900),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y * 0.84)),
			Color(1, 1, 1, alpha))

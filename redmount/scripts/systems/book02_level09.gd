## Kitap 2 / Bölüm 9 — Yenikapı Gece Vardiyası.
extends "res://scripts/systems/book02_level01.gd"

const QUAY := preload("res://assets/backgrounds/book02_yenikapi_quay_atlas.png")
const DISPATCH := preload("res://assets/backgrounds/book02_yenikapi_dispatch_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_YenikapiBackdrop.new())
	_intro("GAZELLE", "Samatya fişinde Yenikapı gece vardiyası yazıyor. Teslim alanı gemi kalkmadan bulmalıyız.")
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

	# Gece sokağı: tekli devriyeler, üst balkon kısa ödül yolu.
	_coin_line(500, 6, 220, -55)
	_enemy(STREET, 2200, 0)
	_enemy(KNIFE, 5300, 0)
	_oneway(6800, -85, 220)
	_oneway(7100, -170, 220)
	_oneway(7400, -85, 220)
	for i in 4:
		_bonus_coin(6800 + i * 220, -225, 5)
	_pickup(ARMOR, 7100, -225)
	_checkpoint(9300, 0)
	_enemy(ASSASSIN, 11800, 0)
	_dialogue(13500, "REDMOUNT", "Fenerler hâlâ yanıyor. Gece vardiyası bitmeden iskeleye varalım.")

	# Mezat alanı: 60 px alçak servis yolu; tezgâh çatısı isteğe bağlı.
	_coin_line(15100, 6, 300, -55)
	_enemy(KNIFE, 17200, 60)
	_enemy(RIFLE, 19200, 60)
	_oneway(20200, -25, 220)
	_oneway(20500, -110, 220)
	_oneway(20800, -195, 220)
	for i in 4:
		_bonus_coin(20200 + i * 220, -250, 5)
	_pickup(AMMO, 20800, -255)
	_checkpoint(22600, 60)
	_arena(26000, 0, 25200, 26800, _wave(KNIFE, ASSASSIN),
		_wave(BRUISER, STREET), HEALTH)
	_coin_line(28000, 5, 300, -55)

	# Kayıkhane: tek kısa su açıklığı, üst tekne kirişinde tabanca.
	_enemy(STREET, 31500, 0)
	_oneway(33400, -85, 220)
	_oneway(33700, -170, 220)
	_oneway(34000, -255, 220)
	for i in 5:
		_bonus_coin(33400 + i * 240, -310, 5)
	_pickup(PISTOL, 34000, -315)
	_checkpoint(35000, 0)
	_oneway(36000, -45, 240)
	_enemy(ELITE, 39300, 0)
	_pickup(HEALTH, 42300, -45)

	# Dış rıhtım: vinç hattı ödül yolu, alt geniş yol arena alanı.
	_shop(44300, "RIHTIM ERZAKÇISI", PackedStringArray(["can", "cephane", "zirh"]))
	_enemy(RIFLE, 45700, 0)
	_oneway(47500, -85, 220)
	_moving(48000, -145, Vector2(180, -30), 190)
	_oneway(48600, -205, 220)
	for i in 5:
		_bonus_coin(47500 + i * 275, -265, 5)
	_pickup(RIFLE_PICKUP, 48600, -265)
	_enemy(ASSASSIN, 50500, 0)
	_checkpoint(52100, 0)
	_arena(54600, 0, 53800, 55400, _wave(RIFLE, KNIFE),
		_wave(ELITE, STREET), HEALTH)
	_dialogue(57500, "GAZELLE", "Yükleme saati değişmiş. Kuru havuzdaki sevk bürosu yeni çizelgeyi tutuyor.")

	# Kuru havuz: üst iskele isteğe bağlı, alttaki iş yolu açık.
	_checkpoint(60800, 0)
	_enemy(BRUISER, 63100, 0)
	_oneway(64800, -85, 220)
	_oneway(65100, -170, 220)
	_oneway(65400, -85, 220)
	for i in 4:
		_bonus_coin(64800 + i * 220, -225, 5)
	_pickup(ARMOR, 65100, -225)
	_enemy(RIFLE, 68100, 0)
	_checkpoint(69500, 0)
	_oneway(72000, -45, 240)
	_coin_line(71300, 5, 330, -125)

	# Sevk bürosu: alçak servis zemini ve ahşap raf bonusu.
	_enemy(ASSASSIN, 78000, 60)
	_oneway(81600, -25, 220)
	_oneway(81900, -110, 220)
	_oneway(82200, -195, 220)
	for i in 4:
		_bonus_coin(81600 + i * 220, -250, 5)
	_pickup(HEALTH, 83300, 5)
	_checkpoint(84000, 60)
	_arena(86000, 60, 85200, 86800, _wave(ELITE, KNIFE),
		_wave(RIFLE, BRUISER), AMMO)
	_checkpoint(87900, 60)

	# Tartıhane: kayıt sandığına giden son açıklık.
	_enemy(STREET, 90600, 0)
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
	_dialogue(106000, "REDMOUNT", "Gemi fişi yemmiş. Kayıt, yükün şehir içinde kaldığını gösteriyor.")

	# Son iskele: teslim görevlisinin üç kademeli savunması.
	_checkpoint(107400, 0)
	var finale: BattleArena = ARENA.instantiate()
	finale.position = Vector2(110000, 0)
	finale.gate_left_x = 109200
	finale.gate_right_x = 110800
	finale.wave1 = _wave(ASSASSIN, KNIFE)
	finale.wave2 = _wave(ELITE, RIFLE)
	finale.wave3 = _wave(BRUISER, ELITE)
	finale.reward = HEALTH
	add_child(finale)
	_dialogue(112700, "GAZELLE", "Gerçek teslim yeri Aksaray'daki eski pompa istasyonu. Şafaktan önce gitmeliyiz.")
	_goal(114800, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	var platform := get_child(get_child_count() - 1)
	if x >= 30000 and x < 44000 or x >= 73000 and x < 104000:
		platform.set("style", "wood_shelf")
	elif x >= 44000 and x < 73000:
		platform.set("style", "industrial")
	elif x >= 104000:
		platform.set("style", "metal")


func _ground(x: float, width: float, surface_y := 0.0) -> void:
	_platform(x, surface_y + 200.0, width, 400.0)


class _YenikapiBackdrop extends Node2D:
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
		var atlas: Texture2D = QUAY if scene < 4 else DISPATCH
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

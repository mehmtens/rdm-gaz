## Kitap 2 / Bölüm 4 — Süleymaniye Arşivi.
extends "res://scripts/systems/book02_level01.gd"

const STREETS := preload("res://assets/backgrounds/book02_suleymaniye_streets_atlas.png")
const ARCHIVE := preload("res://assets/backgrounds/book02_suleymaniye_archive_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_SuleymaniyeBackdrop.new())
	_intro("GAZELLE", "Zeyrek vanasının kaydı Süleymaniye'deki bir ciltçi deposuna çıkıyor. Defter orada olmalı.")
	for i in 30:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [7, 16, 23]:
			x -= 50.0
			width = 3900.0
		elif i in [8, 17, 24]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [4, 5, 19, 20, 21] else 0.0)

	# Yokuş: tekli devriye ve seçmeli çatı çizgisiyle yönü oku.
	_coin_line(500, 6, 220, -55)
	_enemy(STREET, 2200, 0)
	_enemy(KNIFE, 4900, 0)
	_oneway(6500, -85, 220)
	_oneway(6800, -170, 220)
	_oneway(7100, -85, 220)
	for i in 4:
		_bonus_coin(6500 + i * 220, -225, 5)
	_pickup(ARMOR, 6800, -225)
	_checkpoint(9100, 0)
	_enemy(RIFLE, 11500, 0)
	_dialogue(13700, "REDMOUNT", "Suyolunun kaydı kâğıda çevrilmiş. Ciltçilerin sokağını izleyelim.")

	# Ciltçiler sokağı: yol 60 px alçalır; saçak ödülü zorunlu değildir.
	_coin_line(15000, 6, 300, -55)
	_enemy(STREET, 17300, 60)
	_enemy(ASSASSIN, 19200, 60)
	_oneway(20200, -25, 220)
	_oneway(20500, -110, 220)
	_oneway(20800, -195, 220)
	for i in 4:
		_bonus_coin(20200 + i * 220, -250, 5)
	_pickup(AMMO, 20800, -255)
	_checkpoint(22700, 60)
	_arena(26800, 0, 26000, 27600, _wave(STREET, KNIFE),
		_wave(ASSASSIN, RIFLE), HEALTH)
	_shop(29300, "CİLTÇİLER ERZAK TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))

	# Dış avlu: 200 px drenaj kesintisi sabit iskeleyle aşılır.
	_coin_line(30600, 5, 290, -55)
	_oneway(32000, -45, 240)
	_enemy(KNIFE, 34800, 0)
	_checkpoint(36500, 0)
	_oneway(38400, -85, 220)
	_oneway(38700, -170, 220)
	_oneway(39000, -255, 220)
	_oneway(39300, -170, 220)
	for i in 5:
		_bonus_coin(38400 + i * 260, -310, 5)
	_pickup(PISTOL, 39000, -315)
	_enemy(ELITE, 42100, 0)
	_pickup(HEALTH, 44000, -45)

	# Kâğıt imalathanesi: açık siperli tüfekliye yaklaş; üst asma yol riskli.
	_enemy(RIFLE, 47200, 0)
	_oneway(48800, -85, 220)
	_moving(49300, -145, Vector2(180, -30), 190)
	_oneway(49900, -205, 220)
	for i in 5:
		_bonus_coin(48800 + i * 275, -265, 5)
	_pickup(RIFLE_PICKUP, 49900, -265)
	_enemy(BRUISER, 51900, 0)
	_checkpoint(53200, 0)
	_arena(55400, 0, 54600, 56200, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(58300, "GAZELLE", "Bu kâğıtlar su yolundaki sevkiyatları yardım malzemesi gibi göstermiş.")

	# Cilt atölyesi: ahşap raflar üst bonus yol, ana zemin kesintisiz.
	_checkpoint(61300, 0)
	_enemy(ASSASSIN, 63200, 0)
	_oneway(65000, -85, 220)
	_oneway(65300, -170, 220)
	_oneway(65600, -85, 220)
	for i in 4:
		_bonus_coin(65000 + i * 220, -225, 5)
	_pickup(ARMOR, 65300, -225)
	_oneway(68000, -45, 240)
	_coin_line(67300, 5, 330, -125)
	_enemy(STREET, 70400, 0)
	_checkpoint(73500, 0)

	# Belge odası: kısa alçak servis yolu, sonra geniş ve kontrollü arena.
	_coin_line(76000, 5, 310, -55)
	_enemy(KNIFE, 78500, 60)
	_enemy(ELITE, 80500, 60)
	_oneway(82000, -25, 220)
	_oneway(82300, -110, 220)
	_oneway(82600, -195, 220)
	for i in 4:
		_bonus_coin(82000 + i * 220, -250, 5)
	_pickup(HEALTH, 83800, 5)
	_checkpoint(84600, 60)
	_arena(86400, 60, 85600, 87200, _wave(ELITE, STREET),
		_wave(RIFLE, KNIFE), AMMO)
	_checkpoint(87900, 60)

	# Mahzen: dar servis aralığı, üst raf ödülü; çatışma kuru zemin üstünde.
	_enemy(ASSASSIN, 90800, 0)
	_oneway(92700, -85, 220)
	_oneway(93000, -170, 220)
	_oneway(93300, -85, 220)
	for i in 4:
		_bonus_coin(92700 + i * 220, -225, 5)
	_oneway(96000, -45, 240)
	_coin_line(95300, 5, 330, -125)
	_enemy(RIFLE, 98900, 0)
	_checkpoint(101000, 0)
	_enemy(ELITE, 103000, 0)
	_pickup(HEALTH, 104300, -45)

	# Arka teras: defteri koruyan iki farklı dalga, sonra Beyazıt izi.
	_coin_line(106000, 5, 300, -55)
	_checkpoint(108000, 0)
	_arena(111400, 0, 110600, 112200, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, BRUISER), HEALTH)
	_dialogue(115000, "GAZELLE", "Asıl liste burada: sonraki teslimat Beyazıt'ın eski posta hattına yapılacak.")
	_goal(117700, 0)


class _SuleymaniyeBackdrop extends Node2D:
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
		var cuts := [14000.0, 30000.0, 46000.0, 60000.0,
			76000.0, 90000.0, 104000.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_scene(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_scene(scene: int, alpha: float) -> void:
		var atlas: Texture2D = STREETS if scene < 4 else ARCHIVE
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -540, 1920, 900),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y * 0.84)),
			Color(1, 1, 1, alpha))

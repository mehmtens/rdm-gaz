## Kitap 2 / Bölüm 3 — Zeyrek Su Hattı.
extends "res://scripts/systems/book02_level02.gd"

const SURFACE := preload("res://assets/backgrounds/book02_zeyrek_surface_atlas.png")
const CISTERN := preload("res://assets/backgrounds/book02_zeyrek_cistern_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_ZeyrekBackdrop.new())
	_intro("GAZELLE", "Kalıbın arkasındaki adres Zeyrek su hattı. Sevkiyat yerin altına inmiş.")
	for i in 29:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [6, 14, 22]:
			x -= 50.0
			width = 3900.0
		elif i in [7, 15, 23]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [4, 5, 18, 19, 20] else 0.0)

	# Mahalle girişinde tekli devriye; balkon güzergâhı yalnız ödül verir.
	_coin_line(500, 6, 210, -55)
	_enemy(STREET, 2100, 0)
	_enemy(KNIFE, 4600, 0)
	_oneway(6400, -85, 220)
	_oneway(6700, -170, 220)
	_oneway(7000, -85, 220)
	for i in 4:
		_bonus_coin(6400 + i * 220, -225, 5)
	_pickup(ARMOR, 6700, -225)
	_checkpoint(8700, 0)
	_enemy(ASSASSIN, 10800, 0)
	_shop(12600, "ZEYREK ERZAK TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))
	_dialogue(13600, "REDMOUNT", "İz, çeşmenin altındaki eski kanala gidiyor.")

	# Çeşme meydanı: kısa alçak kot, ardından düz ve geniş dövüş avlusu.
	_coin_line(14700, 6, 300, -55)
	_enemy(STREET, 17400, 60)
	_enemy(KNIFE, 19300, 60)
	_oneway(20100, -25, 220)
	_oneway(20400, -110, 220)
	_oneway(20700, -195, 220)
	for i in 4:
		_bonus_coin(20100 + i * 220, -250, 5)
	_pickup(AMMO, 20700, -255)
	_checkpoint(22400, 60)
	_arena(25400, 0, 24600, 26200, _wave(STREET, KNIFE),
		_wave(ASSASSIN, STREET), HEALTH)
	_coin_line(26800, 5, 280, -55)

	# Açık su kemeri: 200 px kesinti sabit iskeleyle geçilir; üst yol değerli.
	_oneway(28000, -45, 240)
	_enemy(KNIFE, 30800, 0)
	_oneway(32800, -85, 220)
	_oneway(33100, -170, 220)
	_oneway(33400, -255, 220)
	_oneway(33700, -170, 220)
	for i in 5:
		_bonus_coin(32800 + i * 260, -310, 5)
	_pickup(PISTOL, 33400, -315)
	_checkpoint(35900, 0)
	_enemy(RIFLE, 38900, 0)
	_pickup(HEALTH, 41400, -45)

	# Bakım galerisi: tüfekliye karşı yaklaşma; hareketli üst köprü isteğe bağlı.
	_enemy(RIFLE, 45200, 0)
	_oneway(46600, -85, 220)
	_moving(47100, -145, Vector2(180, -30), 190)
	_oneway(47700, -205, 220)
	for i in 5:
		_bonus_coin(46600 + i * 275, -265, 5)
	_pickup(RIFLE_PICKUP, 47700, -265)
	_enemy(BRUISER, 49300, 0)
	_checkpoint(50700, 0)
	_arena(53300, 0, 52500, 54100, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(55300, "GAZELLE", "Su kapaklarının hepsinde aynı sahte mühür var. Geçit bilerek açılmış.")

	# Sarnıç: dar su kanalı üstünde sabit iskele, düşman güvenli zeminde.
	_checkpoint(57800, 0)
	_oneway(60000, -45, 240)
	_coin_line(59300, 5, 330, -125)
	_enemy(STREET, 62700, 0)
	_enemy(ASSASSIN, 64800, 0)
	_oneway(66200, -85, 220)
	_oneway(66500, -170, 220)
	_oneway(66800, -85, 220)
	for i in 4:
		_bonus_coin(66200 + i * 220, -225, 5)
	_pickup(ARMOR, 66500, -225)
	_checkpoint(69400, 0)

	# Su çarkı: alçak servis yolu ana rota; yüksek dişli hattı bonus rota.
	_coin_line(71500, 5, 310, -55)
	_enemy(KNIFE, 73600, 60)
	_enemy(ELITE, 75200, 60)
	_oneway(76500, -25, 220)
	_oneway(76800, -110, 220)
	_oneway(77100, -195, 220)
	for i in 4:
		_bonus_coin(76500 + i * 220, -250, 5)
	_pickup(HEALTH, 78000, 5)
	_checkpoint(78600, 60)
	_arena(80900, 60, 80100, 81700, _wave(ELITE, STREET),
		_wave(RIFLE, KNIFE), AMMO)
	_checkpoint(83300, 60)

	# Gizli kemer: üçüncü kısa kesinti, sonra tekli devriye ve üst taş raf.
	_enemy(ASSASSIN, 85800, 0)
	_oneway(88300, -85, 220)
	_oneway(88600, -170, 220)
	_oneway(88900, -85, 220)
	for i in 4:
		_bonus_coin(88300 + i * 220, -225, 5)
	_oneway(92000, -45, 240)
	_coin_line(91300, 5, 330, -125)
	_enemy(RIFLE, 94900, 0)
	_checkpoint(97000, 0)
	_enemy(ELITE, 99000, 0)
	_pickup(HEALTH, 100300, -45)

	# Teras: ele geçirilen vana kayıtları bir sonraki güzergâhı gösterir.
	_coin_line(102000, 5, 300, -55)
	_checkpoint(104000, 0)
	_arena(107000, 0, 106200, 107800, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, BRUISER), HEALTH)
	_dialogue(111000, "GAZELLE", "Su hattı kaçak sevkiyata dönüştürülmüş. Vanadaki kayıt bizi Süleymaniye'ye götürüyor.")
	_goal(113700, 0)


class _ZeyrekBackdrop extends Node2D:
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
		var cuts := [14000.0, 28000.0, 44000.0, 58000.0,
			72000.0, 87000.0, 101000.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_scene(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_scene(scene: int, alpha: float) -> void:
		var atlas: Texture2D = SURFACE if scene < 4 else CISTERN
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -540, 1920, 900),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y * 0.84)),
			Color(1, 1, 1, alpha))

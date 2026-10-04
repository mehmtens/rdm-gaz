## Kitap 3 / Bölüm 1 — Cağaloğlu'nda İlk Baskın.
extends "res://scripts/systems/book02_level01.gd"

const STREETS := preload("res://assets/backgrounds/book03_cagaloglu_streets_atlas.png")
const PRESS := preload("res://assets/backgrounds/book03_cagaloglu_press_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_PrintBackdrop.new())
	_intro("GAZELLE", "Su hattı güvende. Kumanda anahtarındaki mühür Cağaloğlu'ndaki bir matbaaya ait.")
	for i in 28:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [8, 16, 24]:
			x -= 50.0
			width = 3900.0
		elif i in [9, 17, 25]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [4, 5, 12, 13, 20, 21] else 0.0)

	# Uyanan sokak: oyuncu önce tekli devriyeyi, sonra yakın-menzilli ikilisini okur.
	_coin_line(500, 6, 220, -55)
	_enemy(STREET, 2200, 0)
	_enemy(KNIFE, 5000, 0)
	_reward_path(6600, ARMOR)
	_checkpoint(9400, 0)
	_enemy(RIFLE, 11600, 0)
	_dialogue(13700, "REDMOUNT", "Mühür matbaanın. Buradaki kâğıtların su emrini kimin bastığını söylemesi gerek.")

	# Kitapçı yokuşu: 60 px alt sokak, üst tentede kısa coin kestirmesi.
	_coin_line(15000, 6, 340, -55)
	_enemy(KNIFE, 17400, 60)
	_oneway(19000, -25, 220)
	_oneway(19300, -110, 220)
	_oneway(19600, -195, 220)
	for i in 4:
		_bonus_coin(19000 + i * 220, -250, 5)
	_pickup(AMMO, 19600, -255)
	_enemy(ASSASSIN, 21100, 60)
	_checkpoint(23000, 0)
	_arena(26000, 0, 25200, 26800, _wave(STREET, KNIFE),
		_wave(RIFLE, ASSASSIN), HEALTH)
	_coin_line(27800, 5, 300, -55)

	# Matbaa avlusu: taş köprü ana rota; kurutma rafı isteğe bağlı.
	_enemy(RIFLE, 30600, 0)
	_reward_path(32800, PISTOL)
	_checkpoint(34500, 0)
	_oneway(36000, -45, 240)
	_coin_line(35250, 5, 350, -125)
	_enemy(ELITE, 39400, 0)
	_shop(41700, "MATBAA ERZAK TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(42700, 0)
	_enemy(KNIFE, 45100, 0)
	_reward_path(47300, ARMOR)
	_checkpoint(50500, 0)
	_arena(53100, 0, 52300, 53900, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(56600, "GAZELLE", "Baskı kalıpları sökülmüş. Bir nüsha çatıdaki kurutma odasına taşınmış.")

	# Kurutma çatıları: alttan yürüyerek geçilir, yukarıda daha değerli ödül var.
	_enemy(ASSASSIN, 59200, 0)
	_oneway(61700, -85, 220)
	_moving(62200, -145, Vector2(180, -30), 190)
	_oneway(62800, -205, 220)
	for i in 5:
		_bonus_coin(61700 + i * 275, -265, 5)
	_pickup(RIFLE_PICKUP, 62800, -265)
	_checkpoint(65000, 0)
	_oneway(68000, -45, 240)
	_coin_line(67250, 5, 350, -125)
	_enemy(RIFLE, 70400, 0)
	_checkpoint(72800, 0)
	_arena(75300, 0, 74500, 76100, _wave(ASSASSIN, KNIFE),
		_wave(ELITE, RIFLE), HEALTH)
	_shop(78400, "CİLTÇİ REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))

	# Dağıtım deposu: seçkin nöbetçi ve sandık arasından yan rotayı seç.
	_enemy(ELITE, 81100, 0)
	_prop("sandik", 82200, 0, AMMO)
	_reward_path(83700, ARMOR)
	_enemy(KNIFE, 86000, 60)
	_checkpoint(88300, 0)
	_enemy(BRUISER, 90600, 0)
	_checkpoint(93800, 0)
	_checkpoint(98400, 0)
	_oneway(100000, -45, 240)
	_coin_line(99300, 5, 350, -125)
	_checkpoint(101100, 0)
	_arena(103000, 0, 102200, 103800, _wave(RIFLE, KNIFE),
		_wave(ELITE, ASSASSIN), HEALTH)

	# Arşiv kapısı: mühür ile matbaa kaydı bağlanır; sonraki bölümün izi açılır.
	_coin_line(104100, 5, 300, -55)
	_enemy(ELITE, 105100, 0)
	_pickup(HEALTH, 106700, -45)
	_dialogue(108300, "GAZELLE", "Kalıpta başka bir emir var: su değil, şehirdeki bütün haberleri susturacaklar.")
	_dialogue(109800, "REDMOUNT", "Dağıtım defteri burada. İlk sevkiyat Sirkeci'ye çıkmış; iz sürüyor.")
	_goal(110900, 0)


func _reward_path(x: float, pickup: PackedScene) -> void:
	_oneway(x, -85, 220)
	_oneway(x + 300, -170, 220)
	_oneway(x + 600, -85, 220)
	for i in 4:
		_bonus_coin(x + i * 220, -225, 5)
	_pickup(pickup, x + 300, -225)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	var platform := get_child(get_child_count() - 1)
	platform.set("style", "awning" if x < 32000 else "wood_shelf" if x < 58000 else "scaffold" if x < 80000 else "corridor")


func _ground(x: float, width: float, surface_y := 0.0) -> void:
	_platform(x, surface_y + 200.0, width, 400.0)


class _PrintBackdrop extends Node2D:
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
		var cuts := [14000.0, 28000.0, 42000.0, 56000.0,
			70000.0, 84000.0, 98000.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_scene(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_scene(scene: int, alpha: float) -> void:
		var atlas: Texture2D = STREETS if scene < 4 else PRESS
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

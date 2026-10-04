## Kitap 2 / Bölüm 2 — Sahte Mühür.
extends "res://scripts/systems/book02_level01.gd"

const STREETS := preload("res://assets/backgrounds/book02_cibali_streets_atlas.png")
const PRESS := preload("res://assets/backgrounds/book02_cibali_press_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_CibaliBackdrop.new())
	_intro("GAZELLE", "Gümrük kaydındaki mühür sahte. Kâğıt Cibali'den gelmiş; baskı kalıbını bulmalıyız.")
	for i in 28:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [6, 14]:
			x -= 50.0
			width = 3900.0
		elif i in [7, 15]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [4, 5, 18, 19, 20] else 0.0)

	# Gümrük avlusu: tek devriye ve ilk üst ödül yolu.
	_coin_line(500, 6, 210, -55)
	_enemy(STREET, 2300, 0)
	_enemy(KNIFE, 4700, 0)
	_oneway(6500, -85, 220)
	_oneway(6800, -170, 220)
	_oneway(7100, -85, 220)
	for i in 4:
		_bonus_coin(6500 + i * 220, -225, 5)
	_pickup(ARMOR, 6800, -225)
	_checkpoint(9000, 0)
	_enemy(RIFLE, 11500, 0)
	_dialogue(12500, "REDMOUNT", "Aynı mühür üç farklı sevkiyatta. Biri burada izini saklıyor.")

	# Unkapanı sokakları: zemin kısa süre alçalır, balkon yolu zorunlu değil.
	_coin_line(14200, 6, 320, -55)
	_enemy(STREET, 16800, 60)
	_enemy(KNIFE, 18500, 60)
	_oneway(19500, -25, 220)
	_oneway(19800, -110, 220)
	_oneway(20100, -195, 220)
	for i in 4:
		_bonus_coin(19500 + i * 220, -250, 5)
	_pickup(AMMO, 20100, -255)
	_checkpoint(22200, 0)
	_arena(24400, 0, 23600, 25200, _wave(STREET, KNIFE),
		_wave(ASSASSIN, STREET), HEALTH)
	_coin_line(26000, 5, 310, -55)

	# Kemerli geçit: 200 px taş derz boşluğu sabit iskeleyle okunur.
	_oneway(28000, -45, 240)
	_enemy(KNIFE, 31000, 0)
	_oneway(33200, -85, 220)
	_oneway(33500, -170, 220)
	_oneway(33800, -85, 220)
	for i in 4:
		_bonus_coin(33200 + i * 220, -225, 5)
	_pickup(PISTOL, 33500, -225)
	_checkpoint(35200, 0)
	_enemy(RIFLE, 36800, 0)
	_shop(38500, "UNKAPANI FIRIN TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))

	# Cibali halat atölyesi: vinç yolu ödüllü; zırhlı düşman zeminde kalır.
	_coin_line(41000, 5, 300, -55)
	_enemy(BRUISER, 43800, 0)
	_oneway(45300, -85, 220)
	_moving(45800, -145, Vector2(180, -30), 190)
	_oneway(46400, -205, 220)
	for i in 5:
		_bonus_coin(45300 + i * 275, -265, 5)
	_pickup(RIFLE_PICKUP, 46400, -265)
	_enemy(ASSASSIN, 48300, 0)
	_checkpoint(49100, 0)
	_arena(51500, 0, 50700, 52300, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(53500, "GAZELLE", "Faturaların hepsi aynı kalıptan çıkmış. Baskı atölyesi yakın olmalı.")

	# Cibali fabrika yolu: ikinci 200 px açıklık ve siperli tek çatışma.
	_enemy(RIFLE, 56200, 0)
	_checkpoint(57800, 0)
	_oneway(60000, -45, 240)
	_coin_line(59300, 5, 330, -125)
	_enemy(STREET, 62600, 0)
	_enemy(ASSASSIN, 64600, 0)
	_oneway(66300, -85, 220)
	_oneway(66600, -170, 220)
	_oneway(66900, -85, 220)
	for i in 4:
		_bonus_coin(66300 + i * 220, -225, 5)
	_pickup(ARMOR, 66600, -225)
	_checkpoint(69200, 0)

	# Fener basamakları: alçak zeminde kontrollü dövüş, çatıda kısa kestirme.
	_coin_line(71400, 5, 320, -55)
	_enemy(KNIFE, 73300, 60)
	_enemy(ELITE, 75000, 60)
	_oneway(76100, -25, 220)
	_oneway(76400, -110, 220)
	_oneway(76700, -195, 220)
	for i in 4:
		_bonus_coin(76100 + i * 220, -250, 5)
	_pickup(HEALTH, 77700, 5)
	_checkpoint(78400, 60)
	_arena(80300, 60, 79500, 81100, _wave(ELITE, STREET),
		_wave(RIFLE, KNIFE), AMMO)
	_checkpoint(83300, 60)

	# Sahte mühür baskıhanesi: ipucu üst rotada, ana çıkış açık.
	_enemy(ASSASSIN, 85900, 0)
	_oneway(88300, -85, 220)
	_oneway(88600, -170, 220)
	_oneway(88900, -255, 220)
	_oneway(89200, -170, 220)
	for i in 5:
		_bonus_coin(88300 + i * 260, -310, 5)
	_pickup(ARMOR, 88900, -315)
	_enemy(RIFLE, 92200, 0)
	_dialogue(94600, "REDMOUNT", "Kalıp burada. Gümrükteki mühürler bu preste çoğaltılmış.")
	_checkpoint(96000, 0)
	_enemy(ELITE, 98100, 0)
	_pickup(HEALTH, 99700, -45)

	# Arşiv avlusu: yakın ve menzilli savunmayı geniş alanda çöz.
	_coin_line(101000, 5, 300, -55)
	_checkpoint(103000, 0)
	_arena(105500, 0, 104700, 106300, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, BRUISER), HEALTH)
	_dialogue(108200, "GAZELLE", "Kalıbın arkasında ikinci adres var: Zeyrek su yolları. Sıradaki iz orada.")
	_goal(110700, 0)


class _CibaliBackdrop extends Node2D:
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
		var cuts := [14000.0, 28000.0, 40000.0, 55000.0,
			70000.0, 86000.0, 101000.0]
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
		draw_texture_rect_region(atlas, Rect2(-960, -540, 1920, 900),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y * 0.84)),
			Color(1, 1, 1, alpha))

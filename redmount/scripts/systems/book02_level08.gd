## Kitap 2 / Bölüm 8 — Samatya Taş Depoları.
extends "res://scripts/systems/book02_level01.gd"

const COAST := preload("res://assets/backgrounds/book02_samatya_coast_atlas.png")
const DEPOT := preload("res://assets/backgrounds/book02_samatya_depot_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_SamatyaBackdrop.new())
	_intro("GAZELLE", "Külhan kayıtlarındaki bütün taş sevkiyatları Samatya'da buluşuyor. Depodaki asıl yükü bulalım.")
	for i in 29:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [8, 16, 24]:
			x -= 50.0
			width = 3900.0
		elif i in [9, 17, 25]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [5, 6, 18, 19, 20, 21] else 0.0)

	# Sahile inen sokak: az düşman, balkon üstünde güvenli ödül.
	_coin_line(500, 6, 220, -55)
	_enemy(KNIFE, 2100, 0)
	_enemy(STREET, 5100, 0)
	_encounter("tente_duvar", 6220, ARMOR)
	_checkpoint(9200, 0)
	_enemy(RIFLE, 11500, 0)
	_dialogue(13400, "REDMOUNT", "Depo kıyıda. Balıkçı tezgâhlarının arkasından deniz kapısına çıkacağız.")

	# Balık pazarı: 60 px alçalan ana yol ve üst tezgâh saçakları.
	_coin_line(14900, 6, 300, -55)
	_enemy(STREET, 17400, 0)
	_enemy(ASSASSIN, 20300, 0)
	_encounter("cati", 21740, AMMO)
	_enemy(KNIFE, 24000, 60)
	_checkpoint(25000, 60)
	_arena(27000, 60, 26200, 27800, _wave(STREET, ASSASSIN),
		_wave(BRUISER, KNIFE), HEALTH)
	_coin_line(28800, 5, 300, -55)

	# Deniz kapısı: 200 px açıklık sabit taş platformla geçilir.
	_enemy(RIFLE, 31600, 0)
	_encounter("balkon", 33150, PISTOL)
	_checkpoint(35000, 0)
	_oneway(36000, -45, 240)
	_coin_line(35300, 5, 330, -125)
	_enemy(ELITE, 39300, 0)
	_pickup(HEALTH, 42600, -45)

	# Taş depo girişi: vinç rafı bonus, dükkân ve açık savunma alanı.
	_shop(44100, "SAMATYA ERZAK TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))
	_enemy(KNIFE, 45900, 0)
	_encounter("engel", 47690, RIFLE_PICKUP)
	_enemy(RIFLE, 50200, 0)
	_checkpoint(52000, 0)
	_arena(55100, 0, 54300, 55900, _wave(RIFLE, KNIFE),
		_wave(ELITE, STREET), HEALTH)
	_dialogue(57400, "GAZELLE", "Taş blokların ağırlığı kayıtlarla uyuşmuyor. İçleri oyulmuş olabilir.")

	# Tasnif salonu: alt yol serbest, üst vinç kirişinde coin ve zırh.
	_checkpoint(60600, 0)
	_enemy(BRUISER, 62600, 0)
	_encounter("kasa", 64250, ARMOR)
	_checkpoint(66200, 0)
	_oneway(68000, -45, 240)
	_enemy(ASSASSIN, 69800, 0)
	_coin_line(71300, 5, 330, -55)

	# Tuzlu servis geçidi: 60 px alt zemin, üst raf ve karma arena.
	_enemy(ELITE, 75500, 60)
	_encounter("iskele", 79790)
	_pickup(HEALTH, 81500, 5)
	_checkpoint(82000, 60)
	_arena(83800, 60, 83000, 84600, _wave(KNIFE, RIFLE),
		_wave(BRUISER, ASSASSIN), AMMO)
	_checkpoint(87900, 60)

	# Gizli kayıt odası: içi oyulmuş taşın içinden sevkiyat fişi çıkar.
	_enemy(STREET, 90300, 0)
	_encounter("engel", 92640)
	_enemy(RIFLE, 96600, 0)
	_checkpoint(98000, 0)
	_oneway(100000, -45, 240)
	_coin_line(99300, 5, 330, -125)
	_enemy(ELITE, 102700, 0)
	_pickup(HEALTH, 104300, -45)
	_dialogue(105800, "REDMOUNT", "Taşların içi boş. Sevkiyat kayıtlarını blokların içinde taşımışlar.")

	# Yükleme avlusu: kaydı aldıktan sonra üç dalgalı çıkış savunması.
	_checkpoint(107300, 0)
	var finale: BattleArena = ARENA.instantiate()
	finale.position = Vector2(110000, 0)
	finale.gate_left_x = 109200
	finale.gate_right_x = 110800
	finale.wave1 = _wave(ASSASSIN, KNIFE)
	finale.wave2 = _wave(RIFLE, ELITE)
	finale.wave3 = _wave(BRUISER, ELITE)
	finale.reward = HEALTH
	add_child(finale)
	_dialogue(112700, "GAZELLE", "Son fişte Yenikapı gece vardiyası yazıyor. Yükü kim alıyorsa orada yakalayacağız.")
	_goal(114800, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	var platform := get_child(get_child_count() - 1)
	if x >= 30000 and x < 44000 or x >= 66000 and x < 74000:
		platform.set("style", "metal")
	elif x >= 44000 and x < 66000 or x >= 74000 and x < 104000:
		platform.set("style", "wood_shelf")
	elif x >= 104000:
		platform.set("style", "metal")


func _ground(x: float, width: float, surface_y := 0.0) -> void:
	_platform(x, surface_y + 200.0, width, 400.0)


class _SamatyaBackdrop extends Node2D:
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
		var atlas: Texture2D = COAST if scene < 4 else DEPOT
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

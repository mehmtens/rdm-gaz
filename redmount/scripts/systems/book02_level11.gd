## Kitap 2 / Bölüm 11 — Saraçhane Ana Vana.
extends "res://scripts/systems/book02_level01.gd"

const STREETS := preload("res://assets/backgrounds/book02_sarachane_streets_atlas.png")
const VALVES := preload("res://assets/backgrounds/book02_sarachane_valves_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_SarachaneBackdrop.new())
	_intro("GAZELLE", "Aksaray çizelgesindeki kapatma emri burada uygulanacak. Ana vanaya onlardan önce ulaşmalıyız.")
	for i in 29:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [8, 16, 24]:
			x -= 50.0
			width = 3900.0
		elif i in [9, 17, 25]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [4, 5, 19, 20, 21] else 0.0)

	# Saraçhane sokağı: yakın ve hızlı tekli nöbetçiler, üst balkon ödülü.
	_coin_line(500, 6, 220, -55)
	_enemy(KNIFE, 2200, 0)
	_enemy(STREET, 5100, 0)
	_encounter("sekme", 6240, ARMOR)
	_checkpoint(9300, 0)
	_enemy(RIFLE, 11600, 0)
	_dialogue(13500, "REDMOUNT", "Su idaresi sessiz görünüyor, ama bütün çıkışları tutmuşlar.")

	# Dış avlu: sığ alt servis yolu ve kademeli ilk savunma.
	_coin_line(15100, 6, 300, -55)
	_enemy(STREET, 17200, 60)
	_enemy(ASSASSIN, 19100, 60)
	_encounter("tente_duvar", 20120, AMMO)
	_checkpoint(22600, 60)
	_arena(26000, 0, 25200, 26800, _wave(ASSASSIN, KNIFE),
		_wave(BRUISER, STREET), HEALTH)
	_coin_line(27900, 5, 300, -55)

	# Su terazisi: sabit 200 px su kanalı ve üst taş rafı.
	_enemy(RIFLE, 31600, 0)
	_encounter("engel", 33240, PISTOL)
	_checkpoint(35000, 0)
	_oneway(36000, -45, 240)
	_enemy(ELITE, 39400, 0)
	_pickup(HEALTH, 42400, -45)

	# Basınç galerisi: alt taş yol, üst gösterge rafı ve ikinci arena.
	_shop(44400, "SARAÇHANE ERZAKÇISI", PackedStringArray(["can", "cephane", "zirh"]))
	_enemy(RIFLE, 45900, 0)
	_encounter("kasa", 47700, RIFLE_PICKUP)
	_enemy(KNIFE, 50500, 0)
	_checkpoint(52100, 0)
	_arena(54600, 0, 53800, 55400, _wave(RIFLE, ASSASSIN),
		_wave(ELITE, STREET), HEALTH)
	_dialogue(57500, "GAZELLE", "Aksaray'daki yeni parçalar buraya bağlanmış. Şebekeyi tek komutla kesecekler.")

	# Ana vana salonu: zemin ana rota; üst bakım rafı ekipman verir.
	_checkpoint(60800, 0)
	_enemy(BRUISER, 63000, 0)
	_encounter("iskele", 64590, ARMOR)
	_enemy(STREET, 67700, 0)
	_checkpoint(66500, 0)
	_oneway(68000, -45, 240)
	_coin_line(67300, 5, 330, -125)

	# Bakım geçidi: alt servis kotunda seçkin ve tüfekli savunma.
	_enemy(ELITE, 78000, 60)
	_encounter("engel", 81640)
	_pickup(HEALTH, 83300, 5)
	_checkpoint(84000, 60)
	_arena(86000, 60, 85200, 86800, _wave(ELITE, KNIFE),
		_wave(RIFLE, BRUISER), AMMO)
	_checkpoint(87900, 60)

	# Kontrol masası: yerel vana durdurulur, uzaktan komutun kaynağı bulunur.
	_enemy(ASSASSIN, 90500, 0)
	_encounter("cati", 92240)
	_enemy(RIFLE, 96700, 0)
	_checkpoint(98300, 0)
	_oneway(100000, -45, 240)
	_coin_line(99300, 5, 330, -125)
	_enemy(ELITE, 103000, 0)
	_pickup(HEALTH, 104400, -45)
	_dialogue(106000, "REDMOUNT", "Bu vanayı durdurduk, fakat üst hat hâlâ açık. Komut Bozdoğan Kemeri'nden geliyor.")

	# Taşma avlusu: kontrolü almak için üç dalgalı son savunma.
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
	_dialogue(112700, "GAZELLE", "Son kumanda Bozdoğan Kemeri'nin servis kulesinde. Oraya yetişirsek kesintiyi önleriz.")
	_goal(114800, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	var platform := get_child(get_child_count() - 1)
	if x >= 30000 and x < 44000 or x >= 103000:
		platform.set("style", "metal")
	elif x >= 44000 and x < 58000 or x >= 73000 and x < 88000:
		platform.set("style", "corridor")
	elif x >= 58000 and x < 73000:
		platform.set("style", "industrial")
	elif x >= 88000 and x < 103000:
		platform.set("style", "wood_shelf")


func _ground(x: float, width: float, surface_y := 0.0) -> void:
	_platform(x, surface_y + 200.0, width, 400.0)


class _SarachaneBackdrop extends Node2D:
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
		var atlas: Texture2D = STREETS if scene < 4 else VALVES
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

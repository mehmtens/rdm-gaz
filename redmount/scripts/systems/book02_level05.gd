## Kitap 2 / Bölüm 5 — Beyazıt Posta Hattı.
extends "res://scripts/systems/book02_level01.gd"

const STREETS := preload("res://assets/backgrounds/book02_beyazit_streets_atlas.png")
const POST := preload("res://assets/backgrounds/book02_beyazit_post_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_BeyazitBackdrop.new())
	_intro("GAZELLE", "Süleymaniye listesindeki teslimat Beyazıt postasına gidiyor. Çuvalların çıkışını bulalım.")
	for i in 29:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [7, 17, 24]:
			x -= 50.0
			width = 3900.0
		elif i in [8, 18, 25]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [4, 5, 19, 20, 21] else 0.0)

	# Süleymaniye inişi: tekli devriye, çatı izi isteğe bağlı.
	_coin_line(500, 6, 220, -55)
	_enemy(STREET, 2300, 0)
	_enemy(KNIFE, 5000, 0)
	_encounter("cati", 6040, ARMOR)
	_checkpoint(9200, 0)
	_enemy(RIFLE, 11600, 0)
	_dialogue(13500, "REDMOUNT", "Dış kapıda üç mühür var. Hangisi gerçek çuvala ait?")

	# Beyazıt meydanı: 60 px alçak döşeme, geniş ilk avlu karşılaşması.
	_coin_line(15000, 6, 300, -55)
	_enemy(STREET, 17200, 60)
	_enemy(ASSASSIN, 19000, 60)
	_encounter("balkon", 20050, AMMO)
	_checkpoint(22500, 60)
	_arena(25800, 0, 25000, 26600, _wave(STREET, KNIFE),
		_wave(ASSASSIN, RIFLE), HEALTH)
	_shop(28500, "SAHAFLAR ERZAK TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))

	# Sahaflar: 200 px tezgâh aralığı sabit platformla okunur.
	_coin_line(30500, 5, 300, -55)
	_oneway(32000, -45, 240)
	_enemy(KNIFE, 34800, 0)
	_checkpoint(36500, 0)
	_encounter("sekme", 38090, PISTOL)
	_enemy(ELITE, 41900, 0)
	_pickup(HEALTH, 44000, -45)

	# Posta dış cephesi: tüfekliyi düz zeminde ayır, taşıma saçağı ödüllü.
	_enemy(RIFLE, 46700, 0)
	_encounter("engel", 48490, RIFLE_PICKUP)
	_enemy(BRUISER, 51300, 0)
	_checkpoint(53000, 0)
	_arena(55200, 0, 54400, 56000, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(57800, "GAZELLE", "İki çuval boş. Üçüncüsü tasnif salonundan telgrafa taşınmış.")

	# Tasnif salonu: ahşap üst galeri riski, alt güzergâh açık.
	_checkpoint(61000, 0)
	_enemy(ASSASSIN, 63100, 0)
	_encounter("kasa", 64450, ARMOR)
	_enemy(STREET, 67300, 0)
	_checkpoint(69900, 0)

	# Telgraf odası: tekli devriye ve 200 px servis masası aralığı.
	_coin_line(70800, 5, 310, -55)
	_oneway(72000, -45, 240)
	_enemy(KNIFE, 74400, 0)
	_dialogue(75800, "REDMOUNT", "Bantta 'çarşının arka kapısı' yazıyor. Önce çıkış kaydını almalıyız.")
	_enemy(ELITE, 78300, 60)
	_encounter("iskele", 81590)
	_pickup(HEALTH, 83400, 5)
	_checkpoint(84100, 60)
	_arena(86100, 60, 85300, 86900, _wave(ELITE, STREET),
		_wave(RIFLE, KNIFE), AMMO)
	_checkpoint(88100, 60)

	# Paket geçidi: el arabası hattı boyunca kısa çatışma ve son servis aralığı.
	_enemy(ASSASSIN, 91100, 0)
	_encounter("tente_duvar", 92820)
	_enemy(RIFLE, 96400, 0)
	_checkpoint(98200, 0)
	_oneway(100000, -45, 240)
	_coin_line(99300, 5, 330, -125)
	_enemy(ELITE, 103000, 0)
	_pickup(HEALTH, 104300, -45)

	# Çıkış kulesi: son muhafız dalgalarını ayırıp yeni adresi oku.
	_coin_line(105500, 5, 300, -55)
	_checkpoint(107500, 0)
	_arena(110000, 0, 109200, 110800, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, BRUISER), HEALTH)
	_dialogue(112500, "GAZELLE", "Çıkış fişi Kapalıçarşı'nın arka hanına ait. Sevkiyat oradan dağıtılıyor.")
	_goal(114800, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	if x >= 60000 and x < 90000:
		get_child(get_child_count() - 1).set("style", "wood_shelf")
	elif x >= 30000 and x < 45000:
		get_child(get_child_count() - 1).set("style", "awning")


class _BeyazitBackdrop extends Node2D:
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
		var cuts := [14000.0, 30000.0, 45000.0, 60000.0,
			72000.0, 90000.0, 104000.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_scene(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_scene(scene: int, alpha: float) -> void:
		var atlas: Texture2D = STREETS if scene < 4 else POST
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -540, 1920, 900),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y * 0.84)),
			Color(1, 1, 1, alpha))

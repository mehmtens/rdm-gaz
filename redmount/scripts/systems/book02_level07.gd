## Kitap 2 / Bölüm 7 — Çemberlitaş Külhanı.
extends "res://scripts/systems/book02_level01.gd"

const APPROACH := preload("res://assets/backgrounds/book02_hamam_approach_atlas.png")
const INNER := preload("res://assets/backgrounds/book02_hamam_inner_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_HamamBackdrop.new())
	_intro("GAZELLE", "Defter Çemberlitaş'taki eski hamamı gösteriyor. Dağıtım emri külhandan çıkmış.")
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

	# Arka sokak: koşu ve ilk devriye, balkon üstünde isteğe bağlı erzak.
	_coin_line(500, 6, 220, -55)
	_enemy(STREET, 2300, 0)
	_enemy(KNIFE, 5100, 0)
	_encounter("sekme", 6240, ARMOR)
	_checkpoint(9300, 0)
	_enemy(RIFLE, 11700, 0)
	_dialogue(13500, "REDMOUNT", "Meydandaki devriyeler kapıya bakıyor. Servis yolundan gireceğiz.")

	# Meydan: 60 px alçalan servis yolu ana rota; dükkân saçağı ödül rotası.
	_coin_line(15100, 6, 300, -55)
	_enemy(STREET, 17400, 60)
	_enemy(ASSASSIN, 19100, 60)
	_encounter("tente_duvar", 20120, AMMO)
	_checkpoint(22600, 60)
	_arena(26000, 0, 25200, 26800, _wave(STREET, KNIFE),
		_wave(ASSASSIN, RIFLE), HEALTH)
	_coin_line(27800, 5, 300, -55)

	# Hamam girişi: açık ana yol ve 200 px'lik kısa taş kanal geçişi.
	_enemy(KNIFE, 31600, 0)
	_encounter("cati", 32790, PISTOL)
	_checkpoint(35000, 0)
	_oneway(36000, -45, 240)
	_enemy(ELITE, 39400, 0)
	_pickup(HEALTH, 42500, -45)

	# Soyunmalık: üst ahşap galeri isteğe bağlı, alt mermer yol okunur.
	_shop(44400, "HAMAM ERZAKÇISI", PackedStringArray(["can", "cephane", "zirh"]))
	_enemy(RIFLE, 45800, 0)
	_encounter("iskele", 47740, RIFLE_PICKUP)
	_enemy(BRUISER, 50600, 0)
	_checkpoint(52100, 0)
	_arena(54400, 0, 53600, 55200, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(57500, "GAZELLE", "Sıcak su boruları yeni. Hamam kapanmış ama külhan hâlâ çalışıyor.")

	# Ilıklık: alt rota kesintisiz, çini duvar rafları coin ve zırh verir.
	_checkpoint(60800, 0)
	_enemy(ASSASSIN, 63000, 0)
	_encounter("engel", 64840, ARMOR)
	_enemy(STREET, 67700, 0)
	_checkpoint(69500, 0)
	_oneway(72000, -45, 240)
	_coin_line(71300, 5, 330, -125)

	# Su kanalı: 60 px alt servis yolu ve üst boru rafı.
	_enemy(ELITE, 78100, 60)
	_encounter("kasa", 81450)
	_pickup(HEALTH, 83300, 5)
	_checkpoint(84000, 60)
	_arena(86000, 60, 85200, 86800, _wave(ELITE, STREET),
		_wave(RIFLE, KNIFE), AMMO)
	_checkpoint(87900, 60)

	# Külhan: yakıt rafı ödül rotası; savunma öncesi can ve kontrol noktası.
	_enemy(ASSASSIN, 90600, 0)
	_encounter("iskele", 92690)
	_enemy(RIFLE, 96700, 0)
	_checkpoint(98300, 0)
	_oneway(100000, -45, 240)
	_coin_line(99300, 5, 330, -125)
	_enemy(ELITE, 103000, 0)
	_pickup(HEALTH, 104400, -45)
	_dialogue(106000, "REDMOUNT", "Ocakta yakıt değil, mühürlü sevkiyat kayıtları saklıyorlar.")

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
	_dialogue(112700, "GAZELLE", "Kayıtların sonraki teslim noktası Samatya taş depoları. İz hâlâ sıcak.")
	_goal(114800, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	var platform := get_child(get_child_count() - 1)
	if x >= 44000 and x < 104000:
		platform.set("style", "wood_shelf" if x < 58000 or x >= 88000 else "metal")
	elif x >= 104000:
		platform.set("style", "metal")


func _ground(x: float, width: float, surface_y := 0.0) -> void:
	_platform(x, surface_y + 200.0, width, 400.0)


class _HamamBackdrop extends Node2D:
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
		var atlas: Texture2D = APPROACH if scene < 4 else INNER
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

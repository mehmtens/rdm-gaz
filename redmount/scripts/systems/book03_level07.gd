## Kitap 3 / Bölüm 7 — Çengelköy Sahil Konağı.
extends "res://scripts/systems/book03_level01.gd"

const CENGELKOY_SHORE := preload("res://assets/backgrounds/book03_cengelkoy_shore_atlas.png")
const CENGELKOY_MANSION := preload("res://assets/backgrounds/book03_cengelkoy_mansion_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_CengelkoyBackdrop.new())
	_intro("GAZELLE", "Beylerbeyi arşivindeki sahte mühür Çengelköy sahil konağından çıkmış. Kalıp ve emir defteri hâlâ içeride olabilir.")
	for i in 28:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [7, 15, 23]:
			x -= 50.0
			width = 3900.0
		elif i in [8, 16, 24]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [2, 3, 10, 11, 18, 19] else 0.0)

	# Çınaraltı iskelesi: yakından başlayıp tüfekli nöbetçiye açılır.
	_coin_line(500, 6, 230, -55)
	_enemy(STREET, 2400, 0)
	_enemy(KNIFE, 5300, 0)
	_reward_path(7100, ARMOR)
	_checkpoint(9600, 0)
	_enemy(RIFLE, 12000, 60)
	_dialogue(13800, "REDMOUNT", "Mühür konağın içinde. Önce bahçe kapısına giden sokağı temizleyelim.")

	# Ahşap evler: balkon coinleri isteğe bağlı, alttan sokak açık.
	_coin_line(14900, 6, 350, -55)
	_enemy(KNIFE, 17100, 0)
	_oneway(18400, -25, 220)
	_oneway(18700, -110, 220)
	_oneway(19000, -195, 220)
	for i in 4:
		_bonus_coin(18400 + i * 220, -250, 5)
	_pickup(AMMO, 19000, -255)
	_enemy(ASSASSIN, 21200, 0)
	_checkpoint(23100, 0)
	_arena(25500, 0, 24700, 26300, _wave(STREET, KNIFE),
		_wave(RIFLE, ASSASSIN), HEALTH)
	_coin_line(27300, 5, 300, -55)

	# Bahçe duvarı: sabit taş geçit; yüksek pergolada tabanca.
	_enemy(RIFLE, 29200, 0)
	_checkpoint(30800, 0)
	_oneway(32000, -45, 240)
	_coin_line(31300, 5, 350, -125)
	_checkpoint(33300, 0)
	_reward_path(35000, PISTOL)
	_enemy(ELITE, 39300, 0)
	_shop(41600, "ÇENGELKÖY SAHİL ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(43000, 0)

	# Konağın dış avlusu: ağır nöbetçi altında, bahçe rafı ödüllü.
	_enemy(KNIFE, 45100, 60)
	_reward_path(47100, ARMOR)
	_enemy(BRUISER, 49300, 60)
	_prop("sandik", 50900, 60, AMMO)
	_checkpoint(52500, 0)
	_enemy(ASSASSIN, 54600, 0)
	_checkpoint(55200, 0)
	_arena(57000, 0, 56200, 57800, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(60900, "GAZELLE", "Vitray kapıdan mühür odasına geçiliyor. Koruma defteri içeri taşımış.")

	# Vitray giriş: ana yol sabit köprüyle devam eder; ahşap rafta tüfek.
	_enemy(ELITE, 62300, 0)
	_checkpoint(62900, 0)
	_oneway(64000, -45, 240)
	_coin_line(63300, 5, 350, -125)
	_checkpoint(65300, 0)
	_oneway(66500, -85, 220)
	_moving(67000, -145, Vector2(180, -30), 190)
	_oneway(67600, -205, 220)
	for i in 5:
		_bonus_coin(66500 + i * 270, -265, 5)
	_pickup(RIFLE_PICKUP, 67600, -265)
	_enemy(RIFLE, 70400, 0)
	_checkpoint(72200, 0)

	# Çinili salon: kısa dinlenme sonrası menzilli-yakın ikili sınavı.
	_enemy(KNIFE, 74400, 0)
	_coin_line(75600, 5, 300, -55)
	_enemy(RIFLE, 78100, 60)
	_reward_path(80000, ARMOR)
	_enemy(BRUISER, 82000, 60)
	_checkpoint(84400, 0)
	_arena(86500, 0, 85700, 87300, _wave(ASSASSIN, RIFLE),
		_wave(ELITE, KNIFE), HEALTH)
	_shop(90300, "KONAK BAKIM ODASI", PackedStringArray(["can", "cephane", "zirh"]))

	# Mühür odası: üst dolap yolu zırha, ana koridor üçüncü geçide çıkar.
	_enemy(ELITE, 92400, 0)
	_reward_path(94100, ARMOR)
	_checkpoint(94700, 0)
	_oneway(96000, -45, 240)
	_coin_line(95300, 5, 350, -125)
	_checkpoint(97300, 0)
	_enemy(BRUISER, 99100, 0)
	_pickup(HEALTH, 100500, -45)

	# Kış bahçesi: son savunmayı aş, kalıbın çizelgesini oku.
	_checkpoint(101100, 0)
	_arena(103000, 0, 102200, 103800, _wave(RIFLE, KNIFE),
		_wave(ELITE, BRUISER), HEALTH)
	_enemy(ASSASSIN, 106100, 0)
	_dialogue(108300, "GAZELLE", "Mühür burada basılmış. Çizelgede Kuleli kıyı nöbetleri boşaltılmış; bir sevkiyat geçecek.")
	_dialogue(109600, "REDMOUNT", "Sevkiyat başlamadan Kuleli gözetleme hattına yetişmeliyiz.")
	_goal(110900, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "awning" if x < 32000 else "wood_shelf" if x < 64000 else "corridor" if x < 90000 else "scaffold")


class _CengelkoyBackdrop extends Node2D:
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
		var atlas: Texture2D = CENGELKOY_SHORE if scene < 4 else CENGELKOY_MANSION
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

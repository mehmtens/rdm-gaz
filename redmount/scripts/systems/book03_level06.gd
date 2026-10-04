## Kitap 3 / Bölüm 6 — Beylerbeyi İskele Arşivi.
extends "res://scripts/systems/book03_level01.gd"

const BEYLERBEYI_SHORE := preload("res://assets/backgrounds/book03_beylerbeyi_shore_atlas.png")
const BEYLERBEYI_ARCHIVE := preload("res://assets/backgrounds/book03_beylerbeyi_archive_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_BeylerbeyiBackdrop.new())
	_intro("GAZELLE", "Kuzguncuk defterindeki asıl emir Beylerbeyi iskele arşivine taşınmış. Kayıt mühürlenmeden içeri girmeliyiz.")
	for i in 28:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [8, 16, 24]:
			x -= 50.0
			width = 3900.0
		elif i in [9, 17, 25]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [3, 4, 11, 12, 19, 20] else 0.0)

	# İskele: tekli nöbetler, üst yolun zırh ödülü.
	_coin_line(500, 6, 230, -55)
	_enemy(STREET, 2600, 0)
	_enemy(KNIFE, 5700, 0)
	_reward_path(7600, ARMOR)
	_checkpoint(9800, 0)
	_enemy(RIFLE, 12100, 0)
	_dialogue(13800, "REDMOUNT", "İskele boş görünüyor. Evrakı koruyanlar sahil evlerinin arkasına çekilmiş.")

	# Sahil evleri: sığ alt sokak, balkonlarda cephane.
	_coin_line(15100, 6, 350, -55)
	_enemy(KNIFE, 17000, 60)
	_oneway(18400, -25, 220)
	_oneway(18700, -110, 220)
	_oneway(19000, -195, 220)
	for i in 4:
		_bonus_coin(18400 + i * 220, -250, 5)
	_pickup(AMMO, 19000, -255)
	_enemy(ASSASSIN, 21100, 0)
	_checkpoint(23100, 0)
	_arena(26000, 0, 25200, 26800, _wave(STREET, KNIFE),
		_wave(RIFLE, ASSASSIN), HEALTH)
	_coin_line(28000, 5, 300, -55)

	# Bahçe duvarı: ana yürüyüş yolu; taş revakta silahlı yan rota.
	_enemy(RIFLE, 30800, 0)
	_reward_path(32500, PISTOL)
	_checkpoint(34700, 0)
	_oneway(36000, -45, 240)
	_coin_line(35300, 5, 350, -125)
	_checkpoint(37300, 0)
	_enemy(ELITE, 39500, 0)
	_shop(41900, "BEYLERBEYİ SAHİL ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(43200, 0)

	# Kemerli avlu: uzun düz geçişi iki ayrı düşman kararıyla böl.
	_enemy(KNIFE, 45300, 60)
	_reward_path(47300, ARMOR)
	_enemy(BRUISER, 49500, 60)
	_prop("sandik", 51100, 60, AMMO)
	_checkpoint(52600, 0)
	_enemy(ASSASSIN, 54800, 0)
	_checkpoint(55900, 0)
	_arena(58000, 0, 57200, 58800, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(60900, "GAZELLE", "Arşiv kapısındaki muhafızlar kâğıtları içeride yakmaya hazırlanıyor.")

	# Arşiv girişi: sabit taş köprü, bakım rafında isteğe bağlı tüfek.
	_enemy(ELITE, 62300, 0)
	_checkpoint(66900, 0)
	_oneway(68000, -45, 240)
	_coin_line(67300, 5, 350, -125)
	_checkpoint(69300, 0)
	_oneway(70400, -85, 220)
	_moving(70900, -145, Vector2(180, -30), 190)
	_oneway(71500, -205, 220)
	for i in 5:
		_bonus_coin(70400 + i * 270, -265, 5)
	_pickup(RIFLE_PICKUP, 71500, -265)
	_enemy(RIFLE, 73700, 0)
	_checkpoint(75400, 0)

	# Kayıt salonu: rafların altında ilerle, üst yolda zırh topla.
	_enemy(KNIFE, 77600, 0)
	_coin_line(78900, 5, 300, -55)
	_enemy(RIFLE, 81400, 60)
	_reward_path(83300, ARMOR)
	_checkpoint(84600, 0)
	_arena(87000, 0, 86200, 87800, _wave(ASSASSIN, RIFLE),
		_wave(ELITE, KNIFE), HEALTH)
	_shop(90400, "ARŞİV BAKIM MASASI", PackedStringArray(["can", "cephane", "zirh"]))

	# Mühürlü kasa: çıkış koridorundaki ağır nöbet ve son belge izi.
	_enemy(ELITE, 92500, 0)
	_reward_path(94400, ARMOR)
	_enemy(BRUISER, 96900, 0)
	_checkpoint(98700, 0)
	_oneway(100000, -45, 240)
	_coin_line(99300, 5, 350, -125)
	_checkpoint(101200, 0)
	_pickup(HEALTH, 101700, -45)

	# Arka oda: asıl nüshayı tutan son savunma ve sonraki bölümün izi.
	_arena(104000, 0, 103200, 104800, _wave(RIFLE, KNIFE),
		_wave(ELITE, BRUISER), HEALTH)
	_enemy(ASSASSIN, 106700, 0)
	_dialogue(108300, "GAZELLE", "Asıl emrin üstü çizilmiş. Değişikliği yapan mühür Çengelköy'deki sahil konağına ait.")
	_dialogue(109600, "REDMOUNT", "Emri kim bozduysa konağa dönecek. Çengelköy'e gidiyoruz.")
	_goal(110900, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "awning" if x < 30000 else "wood_shelf" if x < 68000 else "scaffold" if x < 90000 else "corridor")


class _BeylerbeyiBackdrop extends Node2D:
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
		var atlas: Texture2D = BEYLERBEYI_SHORE if scene < 4 else BEYLERBEYI_ARCHIVE
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

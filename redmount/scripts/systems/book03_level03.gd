## Kitap 3 / Bölüm 3 — Galata Telgrafı.
extends "res://scripts/systems/book03_level01.gd"

const GALATA_STREETS := preload("res://assets/backgrounds/book03_galata_streets_atlas.png")
const TELEGRAPH := preload("res://assets/backgrounds/book03_galata_telegraph_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_GalataBackdrop.new())
	_intro("GAZELLE", "Sirkeci kaydı açık: emirler Galata telgrafından çıkmış. Önce hat defterini bulacağız.")
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

	# Karaköy kıyısı: karşı kıyıdan çıkarken tekli devriyelerle alanı oku.
	_coin_line(500, 6, 220, -55)
	_enemy(STREET, 2400, 0)
	_enemy(KNIFE, 5400, 0)
	_encounter("sekme", 6640, ARMOR)
	_checkpoint(9700, 0)
	_enemy(RIFLE, 12000, 0)
	_dialogue(13700, "REDMOUNT", "Kıyıdaki direkler telgraf binasına gidiyor. Kabloyu değil, emri veren kişiyi arıyoruz.")

	# Galata alt sokağı: 60 px yokuş hissi; üst dükkân tentesi ödüllü.
	_coin_line(15100, 6, 350, -55)
	_enemy(KNIFE, 17600, 60)
	_encounter("tente_duvar", 18820, AMMO)
	_enemy(ASSASSIN, 21500, 60)
	_checkpoint(23300, 0)
	_arena(26000, 0, 25200, 26800, _wave(STREET, KNIFE),
		_wave(ASSASSIN, RIFLE), HEALTH)
	_coin_line(28100, 5, 300, -55)

	# Telgraf cephesi: kablo hendeği sabit köprü, üst bakım rafı silah verir.
	_enemy(RIFLE, 30900, 0)
	_encounter("cati", 32340, PISTOL)
	_checkpoint(34700, 0)
	_oneway(36000, -45, 240)
	_coin_line(35300, 5, 350, -125)
	_enemy(ELITE, 39500, 0)
	_shop(42000, "KARAKÖY ERZAKÇISI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(43100, 0)

	# Kablo bakım avlusu: ağır nöbetçiyi dar raf altından geniş avluya çek.
	_enemy(KNIFE, 45600, 0)
	_encounter("balkon", 47550, ARMOR)
	_enemy(BRUISER, 50600, 60)
	_checkpoint(53000, 60)
	_prop("sandik", 54500, 60, AMMO)
	_enemy(ASSASSIN, 55500, 0)
	_checkpoint(56900, 0)
	_arena(59000, 0, 58200, 59800, _wave(RIFLE, KNIFE),
		_wave(BRUISER, ASSASSIN), HEALTH)
	_dialogue(61500, "GAZELLE", "Kâğıt şeritler içeride tutuluyor. Çıkış kanalının numarasını oradan çözeriz.")

	# Röle salonu: ana zemin açık; kablo servis rafında yüksek ödül.
	_enemy(ELITE, 63800, 0)
	_encounter("kasa", 65100, RIFLE_PICKUP)
	_checkpoint(67000, 0)
	_oneway(68000, -45, 240)
	_coin_line(67300, 5, 350, -125)
	_enemy(RIFLE, 70700, 0)
	_checkpoint(72900, 0)

	# Pil galerisi: tüfekliyi ayırıp seçkini yaklaşırken karşıla.
	_enemy(KNIFE, 74700, 0)
	_checkpoint(76100, 0)
	_arena(78400, 0, 77600, 79200, _wave(ASSASSIN, RIFLE),
		_wave(ELITE, STREET), HEALTH)
	_shop(81200, "TELGRAF REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))

	# Hat arşivi: alt servis kotu ve isteğe bağlı üst kâğıt rafı.
	_enemy(BRUISER, 82700, 60)
	_encounter("iskele", 84490, ARMOR)
	_enemy(RIFLE, 87100, 60)
	_checkpoint(89000, 0)
	_coin_line(90700, 6, 300, -55)
	_enemy(ASSASSIN, 93300, 0)
	_checkpoint(97000, 0)

	# Sinyal terası: son kablo hendeği ve çıkış hattını tutan muhafızlar.
	_oneway(100000, -45, 240)
	_coin_line(99300, 5, 350, -125)
	_checkpoint(101100, 0)
	_arena(103000, 0, 102200, 103800, _wave(RIFLE, KNIFE),
		_wave(ELITE, BRUISER), HEALTH)
	_pickup(HEALTH, 106200, -45)
	_enemy(ASSASSIN, 107000, 0)
	_dialogue(108300, "GAZELLE", "Ana şerit burada. Aynı emir Üsküdar'daki yedek röleye de gönderilmiş.")
	_dialogue(109600, "REDMOUNT", "Galata hattını kestik. Yedek yayına başlamadan Üsküdar'a geçmeliyiz.")
	_goal(110900, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "awning" if x < 28000 else "metal" if x < 70000 else "corridor" if x < 98000 else "fortress")


class _GalataBackdrop extends Node2D:
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
		var atlas: Texture2D = GALATA_STREETS if scene < 4 else TELEGRAPH
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

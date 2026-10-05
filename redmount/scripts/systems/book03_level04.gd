## Kitap 3 / Bölüm 4 — Üsküdar Yedek Hattı.
extends "res://scripts/systems/book03_level01.gd"

const USKUDAR_SHORE := preload("res://assets/backgrounds/book03_uskudar_shore_atlas.png")
const USKUDAR_RELAY := preload("res://assets/backgrounds/book03_uskudar_relay_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_UskudarBackdrop.new())
	_intro("GAZELLE", "Galata sustu ama aynı emir Üsküdar'daki yedek röleye ulaştı. Yayın başlamadan şeridi almalıyız.")
	for i in 28:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [7, 15, 23]:
			x -= 50.0
			width = 3900.0
		elif i in [8, 16, 24]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [3, 4, 11, 12, 19, 20] else 0.0)

	# Vapur iskelesi: tekli muhafızlar ve yük rafından isteğe bağlı zırh.
	_coin_line(500, 6, 230, -55)
	_enemy(STREET, 2500, 0)
	_enemy(KNIFE, 5500, 0)
	_encounter("tente_duvar", 7020, ARMOR)
	_checkpoint(9700, 0)
	_enemy(RIFLE, 11900, 0)
	_dialogue(13600, "REDMOUNT", "Kablo iskeleden meydana dönüyor. Röleyi durdurmadan kimseye haber güvenemeyiz.")

	# Mihrimah meydanı: sığ alt yol, üst revakta cephane; geniş ilk savaş.
	_coin_line(15000, 6, 360, -55)
	_enemy(KNIFE, 17000, 60)
	_encounter("cati", 17740, AMMO)
	_enemy(ASSASSIN, 20800, 0)
	_checkpoint(23200, 0)
	_arena(26000, 0, 25200, 26800, _wave(STREET, KNIFE),
		_wave(RIFLE, ASSASSIN), HEALTH)
	_coin_line(27700, 5, 300, -55)

	# Ahşap evler: 32 bin geçişi sabit, balkon izi tabancaya götürür.
	_enemy(RIFLE, 29200, 0)
	_checkpoint(30900, 0)
	_oneway(32000, -45, 240)
	_coin_line(31300, 5, 350, -125)
	_checkpoint(33300, 0)
	_encounter("balkon", 35050, PISTOL)
	_enemy(ELITE, 39200, 0)
	_shop(41900, "ÜSKÜDAR İSKELE ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(43100, 0)

	# Sahil pazarı: alt servis yolu, ağır nöbetçinin ardında kayıt sandığı.
	_enemy(KNIFE, 45100, 60)
	_encounter("sekme", 46440, ARMOR)
	_enemy(BRUISER, 49400, 60)
	_prop("sandik", 51000, 60, AMMO)
	_checkpoint(52700, 0)
	_enemy(ASSASSIN, 54700, 0)
	_checkpoint(55900, 0)
	_arena(58000, 0, 57200, 58800, _wave(RIFLE, KNIFE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(60900, "GAZELLE", "Yedek rölenin bakım avlusu açık. Şerit henüz makineye takılmamış.")

	# Röle avlusu: 64 bin sabit köprü, üst bakım rafında tüfek.
	_enemy(ELITE, 62300, 0)
	_checkpoint(62900, 0)
	_oneway(64000, -45, 240)
	_coin_line(63300, 5, 350, -125)
	_checkpoint(65300, 0)
	_encounter("iskele", 66140, RIFLE_PICKUP)
	_enemy(RIFLE, 69700, 0)
	_checkpoint(72200, 0)

	# Kablo kontrol salonu: menzilliyle seçkini sırayla ayır.
	_enemy(KNIFE, 74200, 0)
	_coin_line(75600, 5, 300, -55)
	_enemy(RIFLE, 78100, 60)
	_encounter("engel", 80140, ARMOR)
	_enemy(BRUISER, 81800, 60)
	_checkpoint(84900, 0)
	_arena(87500, 0, 86700, 88300, _wave(ASSASSIN, RIFLE),
		_wave(ELITE, KNIFE), HEALTH)
	_shop(91000, "RÖLE BAKIM REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))

	# Pil galerisi: üçüncü kısa geçişten önce hazırlık; üst raf isteğe bağlı.
	_enemy(ELITE, 92800, 0)
	_checkpoint(94700, 0)
	_oneway(96000, -45, 240)
	_coin_line(95300, 5, 350, -125)
	_checkpoint(97300, 0)
	_enemy(ASSASSIN, 99100, 0)
	_pickup(HEALTH, 100700, -45)

	# Yedek sinyal terası: şeridi tutan son savunmayı aş, Üsküdar çıkışını aç.
	_checkpoint(101100, 0)
	_arena(103000, 0, 102200, 103800, _wave(RIFLE, KNIFE),
		_wave(ELITE, BRUISER), HEALTH)
	_enemy(ASSASSIN, 106000, 0)
	_dialogue(108300, "GAZELLE", "Yedek şerit durdu. Alıcı listesinde Kuzguncuk'taki eski bir kıyı deposu var.")
	_dialogue(109600, "REDMOUNT", "Emri kim dağıtıyorsa oraya iz bırakmış. Şimdi Kuzguncuk'a gidiyoruz.")
	_goal(110900, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "wood_shelf" if x < 42000 else "awning" if x < 56000 else "metal" if x < 84000 else "corridor")


class _UskudarBackdrop extends Node2D:
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
		var atlas: Texture2D = USKUDAR_SHORE if scene < 4 else USKUDAR_RELAY
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

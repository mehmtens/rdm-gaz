## Kitap 3 / Bölüm 8 — Kuleli Gözetleme Hattı.
extends "res://scripts/systems/book03_level01.gd"

const KULELI_SHORE := preload("res://assets/backgrounds/book03_kuleli_shore_atlas.png")
const KULELI_SIGNAL := preload("res://assets/backgrounds/book03_kuleli_signal_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_KuleliBackdrop.new())
	_intro("GAZELLE", "Çengelköy çizelgesi Kuleli kıyı nöbetlerinin boşaltıldığını gösteriyor. Sinyal hattını kapatıp geçen tekneyi bulmalıyız.")
	for i in 28:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [6, 14, 22]:
			x -= 50.0
			width = 3900.0
		elif i in [7, 15, 23]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [3, 4, 11, 12, 19, 20] else 0.0)

	# Kıyı inişi: tekli muhafızlar; üst nöbet rafı ilk zırhı verir.
	_coin_line(500, 6, 230, -55)
	_enemy(STREET, 2500, 0)
	_enemy(KNIFE, 5500, 0)
	_encounter("tente_duvar", 7220, ARMOR)
	_checkpoint(9700, 0)
	_enemy(RIFLE, 12000, 0)
	_dialogue(13700, "REDMOUNT", "Boş nöbet noktaları sahte. Kıyıdaki kapıda yine silahlı koruma var.")

	# Kışla servis yolu: sığ alt yol; üst kemerlerde cephane.
	_coin_line(15000, 6, 350, -55)
	_enemy(KNIFE, 17100, 60)
	_encounter("cati", 17740, AMMO)
	_enemy(ASSASSIN, 21000, 0)
	_checkpoint(22900, 0)
	_arena(25000, 0, 24200, 25800, _wave(KNIFE, STREET),
		_wave(RIFLE, ASSASSIN), HEALTH)
	_checkpoint(26800, 0)

	# Deniz duvarı: 28 bin geçişi sabit, taş raflarda tabanca ödülü.
	_oneway(28000, -45, 240)
	_coin_line(27300, 5, 350, -125)
	_checkpoint(29300, 0)
	_enemy(RIFLE, 31200, 0)
	_encounter("balkon", 33850, PISTOL)
	_enemy(ELITE, 39400, 0)
	_shop(41600, "KULELİ SAHİL ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(42900, 0)

	# Sinyal avlusu: önce ağır nöbetçi, sonra açık alanda iki dalga.
	_enemy(KNIFE, 45100, 60)
	_encounter("sekme", 46540, ARMOR)
	_enemy(BRUISER, 49300, 60)
	_prop("sandik", 50900, 60, AMMO)
	_checkpoint(52200, 0)
	_enemy(ASSASSIN, 54200, 0)
	_checkpoint(55000, 0)
	_arena(56500, 0, 55700, 57300, _wave(RIFLE, KNIFE),
		_wave(ELITE, STREET), HEALTH)
	_dialogue(58200, "GAZELLE", "Sinyal fenerleri içeride. Teknenin yönünü kayıt odasında bulacağız.")

	# Sinyal iskelesi: sabit yük köprüsü; üst bakım hattında tüfek.
	_checkpoint(58900, 0)
	_oneway(60000, -45, 240)
	_coin_line(59300, 5, 350, -125)
	_checkpoint(61300, 0)
	_enemy(ELITE, 63800, 0)
	_encounter("engel", 65690, RIFLE_PICKUP)
	_enemy(RIFLE, 69300, 0)
	_checkpoint(71900, 0)

	# Gözetleme galerisi: teleskopların altında güvenli ana koridor.
	_enemy(KNIFE, 74100, 0)
	_coin_line(75300, 5, 300, -55)
	_enemy(RIFLE, 78000, 60)
	_encounter("kasa", 79650, ARMOR)
	_enemy(BRUISER, 81900, 60)
	_checkpoint(83700, 0)
	_arena(85500, 0, 84700, 86300, _wave(ASSASSIN, RIFLE),
		_wave(BRUISER, KNIFE), HEALTH)
	_shop(89300, "GÖZETLEME REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))

	# Telgraf odası: raflardan zırh, üçüncü sabit geçitten kayıt masasına.
	_enemy(ELITE, 91600, 0)
	_checkpoint(90900, 0)
	_oneway(92000, -45, 240)
	_coin_line(91300, 5, 350, -125)
	_checkpoint(93300, 0)
	_encounter("iskele", 94890, ARMOR)
	_enemy(ASSASSIN, 98500, 0)
	_pickup(HEALTH, 100500, -45)

	# Arka rıhtım: son savunmayı aş, gizli teknenin rotasını oku.
	_checkpoint(101100, 0)
	_arena(103000, 0, 102200, 103800, _wave(ELITE, RIFLE),
		_wave(BRUISER, ASSASSIN), HEALTH)
	_enemy(KNIFE, 106100, 0)
	_dialogue(108300, "GAZELLE", "Sinyal kesildi. Kayıt, teknenin sahte emir cihazlarını Vaniköy'deki eski yalı iskelesine indirdiğini söylüyor.")
	_dialogue(109600, "REDMOUNT", "Yük karaya çıktıysa iz hâlâ taze. Vaniköy'e gidiyoruz.")
	_goal(110900, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "scaffold" if x < 42000 else "metal" if x < 84000 else "corridor")


class _KuleliBackdrop extends Node2D:
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
		var atlas: Texture2D = KULELI_SHORE if scene < 4 else KULELI_SIGNAL
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

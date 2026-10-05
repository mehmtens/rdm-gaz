## Kitap 3 / Bölüm 10 — Kandilli Verici Sırtı.
extends "res://scripts/systems/book03_level01.gd"

const KANDILLI_RIDGE := preload("res://assets/backgrounds/book03_kandilli_ridge_atlas.png")
const KANDILLI_TRANSMITTER := preload("res://assets/backgrounds/book03_kandilli_transmitter_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_KandilliBackdrop.new())
	_intro("GAZELLE", "Vaniköy planı ana vericiyi Kandilli sırtında gösteriyor. Sahte emir yayına girmeden bobin hattını durdurmalıyız.")
	for i in 28:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [7, 15, 23]:
			x -= 50.0
			width = 3900.0
		elif i in [8, 16, 24]:
			x += 50.0
			width = 3900.0
		_ground(x, width, -60.0 if i in [3, 4, 19, 20] else 60.0 if i in [11, 12] else 0.0)

	# Sırt yolu: tekli devriyeler, ilk yüksek bahçe rafında zırh.
	_coin_line(500, 6, 230, -55)
	_enemy(STREET, 2500, 0)
	_enemy(KNIFE, 5500, 0)
	_encounter("balkon", 7150, ARMOR)
	_checkpoint(9700, 0)
	_enemy(RIFLE, 12000, -60)
	_dialogue(13800, "REDMOUNT", "Kablolar evlerin üstünden sırta çıkıyor. Yolu izlersek vericiyi buluruz.")

	# Kandilli bahçeleri: kısa yükseliş, pergola coinleri yan rota.
	_coin_line(15000, 6, 350, -115)
	_enemy(KNIFE, 17100, -60)
	_encounter("sekme", 18040, AMMO)
	_enemy(ASSASSIN, 21200, 0)
	_checkpoint(23100, 0)
	_arena(26000, 0, 25200, 26800, _wave(STREET, KNIFE),
		_wave(RIFLE, ASSASSIN), HEALTH)
	_coin_line(27900, 5, 300, -55)

	# Taş istinat yolu: sabit ana geçit; üst revakta tabanca.
	_enemy(RIFLE, 29300, 0)
	_checkpoint(30900, 0)
	_oneway(32000, -45, 240)
	_coin_line(31300, 5, 350, -125)
	_checkpoint(33300, 0)
	_encounter("tente_duvar", 34920, PISTOL)
	_enemy(ELITE, 39400, 0)
	_shop(41700, "KANDİLLİ YOL ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(43100, 0)

	# İstinat altında alçalan yol: ağır nöbetçi, ardından açık avlu.
	_enemy(KNIFE, 45100, 60)
	_encounter("cati", 46440, ARMOR)
	_enemy(BRUISER, 49400, 60)
	_prop("sandik", 51000, 60, AMMO)
	_checkpoint(52700, 0)
	_enemy(ASSASSIN, 54700, 0)
	_checkpoint(55800, 0)
	_arena(58000, 0, 57200, 58800, _wave(RIFLE, KNIFE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(60900, "GAZELLE", "Verici avlusu ileride. Ana kablo galeriden bobin odasına gidiyor.")

	# Verici avlusu: sabit taş geçiş, bakım iskelelerinde tüfek.
	_enemy(ELITE, 62300, 0)
	_checkpoint(62900, 0)
	_oneway(64000, -45, 240)
	_coin_line(63300, 5, 350, -125)
	_checkpoint(65300, 0)
	_encounter("iskele", 66640, RIFLE_PICKUP)
	_enemy(RIFLE, 70300, 0)
	_checkpoint(72100, 0)

	# Kablo galerisi: yükselen ana teras, seçmeli üst raf.
	_enemy(KNIFE, 74300, 0)
	_coin_line(75600, 5, 300, -55)
	_enemy(RIFLE, 78100, -60)
	_encounter("engel", 80040, ARMOR)
	_enemy(BRUISER, 82000, -60)
	_checkpoint(84400, 0)
	_arena(86500, 0, 85700, 87300, _wave(ASSASSIN, RIFLE),
		_wave(ELITE, KNIFE), HEALTH)
	_shop(90200, "VERİCİ BAKIM REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))

	# Bobin odası: kalın kablolar arasında son erzak ve üçüncü geçiş.
	_enemy(ELITE, 92400, 0)
	_encounter("balkon", 93550, ARMOR)
	_checkpoint(94700, 0)
	_oneway(96000, -45, 240)
	_coin_line(95300, 5, 350, -125)
	_checkpoint(97300, 0)
	_enemy(BRUISER, 99300, 0)
	_pickup(HEALTH, 100500, -45)

	# Sinyal terası: ana bobini savunanları yen, yayını kes.
	_checkpoint(101100, 0)
	_arena(103000, 0, 102200, 103800, _wave(RIFLE, KNIFE),
		_wave(ELITE, BRUISER), HEALTH)
	_enemy(ASSASSIN, 106100, 0)
	_dialogue(108300, "GAZELLE", "Ana bobin sustu. Ama uzaktan devreye sokulan son bir kumanda Anadoluhisarı'ndaki kale içinden geliyor.")
	_dialogue(109600, "REDMOUNT", "Yayını burada kestik. Son kumandayı da kalede bulacağız.")
	_goal(110900, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "wood_shelf" if x < 42000 else "scaffold" if x < 84000 else "metal")


class _KandilliBackdrop extends Node2D:
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
		var atlas: Texture2D = KANDILLI_RIDGE if scene < 4 else KANDILLI_TRANSMITTER
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

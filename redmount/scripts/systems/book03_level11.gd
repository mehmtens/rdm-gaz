## Kitap 3 / Bölüm 11 — Anadoluhisarı Kale İçi.
extends "res://scripts/systems/book03_level01.gd"

const HISAR_OUTER := preload("res://assets/backgrounds/book03_anadoluhisari_outer_atlas.png")
const HISAR_INNER := preload("res://assets/backgrounds/book03_anadoluhisari_inner_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_HisarBackdrop.new())
	_intro("GAZELLE", "Kandilli vericisi sustu. Onu yeniden açabilecek son kumanda Anadoluhisarı kale içinde; anahtarı almalıyız.")
	for i in 28:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [5, 13, 21]:
			x -= 50.0
			width = 3900.0
		elif i in [6, 14, 22]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [2, 3, 18, 19] else -60.0 if i in [10, 11] else 0.0)

	# Göksu köprüsü: önce tekli devriye; dere tarafındaki üst taş ödüllü.
	_coin_line(500, 6, 230, -55)
	_enemy(STREET, 2400, 0)
	_enemy(KNIFE, 5500, 0)
	_encounter("sekme", 6840, ARMOR)
	_checkpoint(9700, 60)
	_enemy(RIFLE, 12000, 60)
	_coin_line(14900, 4, 320, 5)
	_dialogue(16400, "REDMOUNT", "Kale kapısına bu sokaktan giriliyor. Kumandayı almadan yayın durmayacak.")

	# Ahşap hisar sokağı: çatı izi cephane, dere boşluğu sabit köprü.
	_enemy(KNIFE, 17700, 0)
	_encounter("tente_duvar", 18820, AMMO)
	_enemy(ASSASSIN, 21400, 0)
	_checkpoint(22900, 0)
	_oneway(24000, -45, 240)
	_coin_line(23300, 5, 350, -125)
	_checkpoint(25300, 0)
	_arena(27000, 0, 26200, 27800, _wave(STREET, KNIFE),
		_wave(RIFLE, ASSASSIN), HEALTH)

	# Dış kale kapısı: sur raflarında tabanca, zeminde seçkin muhafız.
	_enemy(RIFLE, 30500, 0)
	_encounter("cati", 32740, PISTOL)
	_enemy(ELITE, 38200, 0)
	_shop(39400, "HİSAR KAPISI ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(39900, 0)

	# Dere erzak avlusu: ana yol 60 piksel yükselir; düşmanlar sırayla gelir.
	_enemy(KNIFE, 44900, -60)
	_encounter("engel", 46840, ARMOR)
	_enemy(BRUISER, 49400, 0)
	_prop("sandik", 51000, 0, AMMO)
	_checkpoint(52600, 0)
	_enemy(ASSASSIN, 54300, 0)
	_checkpoint(54800, 0)
	_oneway(56000, -45, 240)
	_coin_line(55300, 5, 350, -125)
	_checkpoint(57300, 0)
	_arena(59000, 0, 58200, 59800, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(60900, "GAZELLE", "Kumanda odası surun içinde. Galeriyi aşarsak anahtar masasına varacağız.")

	# Kale geçidi: sabit ana koridor, yüksek ahşap bakım yolunda tüfek.
	_enemy(ELITE, 62700, 0)
	_encounter("kasa", 65600, RIFLE_PICKUP)
	_enemy(RIFLE, 69700, 0)
	_checkpoint(71900, 0)

	# İç avlu galerisi: sığ dere hattı, yüksek sur rafında zırh.
	_enemy(KNIFE, 74200, 60)
	_coin_line(75400, 5, 300, 5)
	_enemy(RIFLE, 78000, 60)
	_encounter("iskele", 79890, ARMOR)
	_enemy(BRUISER, 82100, 0)
	_checkpoint(83700, 0)
	_arena(85000, 0, 84200, 85800, _wave(ASSASSIN, RIFLE),
		_wave(ELITE, KNIFE), HEALTH)
	_checkpoint(86900, 0)
	_oneway(88000, -45, 240)
	_coin_line(87300, 5, 350, -125)
	_checkpoint(89300, 0)
	_shop(90600, "KUMANDA REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))

	# Mekanik kumanda odası: son belgeyi tutan nöbetçi ve yüksek kasa yolu.
	_enemy(ELITE, 92900, 0)
	_encounter("balkon", 94750, ARMOR)
	_enemy(BRUISER, 97900, 0)
	_checkpoint(100700, 0)
	_pickup(HEALTH, 101200, -45)

	# Göksu'ya bakan arka sur: anahtarı al, son yayın yerini öğren.
	_arena(103000, 0, 102200, 103800, _wave(RIFLE, KNIFE),
		_wave(ELITE, BRUISER), HEALTH)
	_enemy(ASSASSIN, 106100, 0)
	_dialogue(108300, "GAZELLE", "Kumanda kesildi. Ama emir kasetleri Göksu ağzındaki yayın mavnasına çıkarılmış. Son yayın oradan yapılacak.")
	_dialogue(109600, "REDMOUNT", "Artık tek kaynak kaldı. Mavnaya ulaşacağız.")
	_goal(110900, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "wood_shelf" if x < 56000 else "scaffold" if x < 88000 else "corridor")


class _HisarBackdrop extends Node2D:
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
		var atlas: Texture2D = HISAR_OUTER if scene < 4 else HISAR_INNER
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

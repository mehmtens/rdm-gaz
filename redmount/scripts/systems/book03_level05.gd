## Kitap 3 / Bölüm 5 — Kuzguncuk Kıyı Deposu.
extends "res://scripts/systems/book03_level01.gd"

const KUZGUNCUK_STREETS := preload("res://assets/backgrounds/book03_kuzguncuk_streets_atlas.png")
const KUZGUNCUK_DEPOT := preload("res://assets/backgrounds/book03_kuzguncuk_depot_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_KuzguncukBackdrop.new())
	_intro("GAZELLE", "Üsküdar'daki alıcı listesi Kuzguncuk kıyı deposunu gösteriyor. Sahte emirlerin dağıtım defteri orada.")
	for i in 28:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [6, 14, 22]:
			x -= 50.0
			width = 3900.0
		elif i in [7, 15, 23]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [2, 3, 10, 11, 18, 19] else 0.0)

	# Renkli evler: dar sokakta tekli devriye, balkonlarda isteğe bağlı zırh.
	_coin_line(500, 6, 230, -55)
	_enemy(STREET, 2400, 0)
	_enemy(KNIFE, 5300, 0)
	_reward_path(7200, ARMOR)
	_checkpoint(9600, 0)
	_enemy(RIFLE, 12100, 60)
	_dialogue(13900, "REDMOUNT", "Mahalle sessiz. Sevkiyatın kıyıya inen izini bulalım.")

	# Bostan yolu: alçak ana geçiş, seraların üstünde cephane izi.
	_coin_line(15000, 6, 340, -55)
	_enemy(KNIFE, 16900, 0)
	_oneway(18100, -25, 220)
	_oneway(18400, -110, 220)
	_oneway(18700, -195, 220)
	for i in 4:
		_bonus_coin(18100 + i * 220, -250, 5)
	_pickup(AMMO, 18700, -255)
	_enemy(ASSASSIN, 21000, 0)
	_checkpoint(23100, 0)
	_arena(25200, 0, 24400, 26000, _wave(STREET, KNIFE),
		_wave(RIFLE, ASSASSIN), HEALTH)

	# Mahalle çeşmesi: taş köprü zorunlu rotayı taşır; çatı yolu silah verir.
	_checkpoint(26800, 0)
	_oneway(28000, -45, 240)
	_coin_line(27300, 5, 350, -125)
	_checkpoint(29300, 0)
	_enemy(RIFLE, 31000, 0)
	_reward_path(34000, PISTOL)
	_enemy(ELITE, 38600, 0)
	_shop(41200, "KUZGUNCUK MAHALLE ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(42700, 0)

	# Kıyı yolu: yük arabaları arasında ağır nöbetçi ve kısa yan ödül.
	_enemy(KNIFE, 44800, 60)
	_reward_path(46700, ARMOR)
	_enemy(BRUISER, 49300, 0)
	_prop("sandik", 50800, 0, AMMO)
	_checkpoint(52100, 0)
	_enemy(ASSASSIN, 54200, 0)
	_checkpoint(55300, 0)
	_arena(56800, 0, 56000, 57600, _wave(KNIFE, RIFLE),
		_wave(BRUISER, STREET), HEALTH)
	_dialogue(58200, "GAZELLE", "Depo defterleri içeride. Kayıt odasına giden rıhtım kapısı korunuyor.")

	# Ahşap rıhtım: sabit yük köprüsü ve yukarıda tüfekli yan rota.
	_checkpoint(58900, 0)
	_oneway(60000, -45, 240)
	_coin_line(59300, 5, 350, -125)
	_checkpoint(61300, 0)
	_enemy(ELITE, 63800, 0)
	_oneway(65400, -85, 220)
	_moving(65900, -145, Vector2(180, -30), 190)
	_oneway(66500, -205, 220)
	for i in 5:
		_bonus_coin(65400 + i * 270, -265, 5)
	_pickup(RIFLE_PICKUP, 66500, -265)
	_enemy(RIFLE, 69400, 0)
	_checkpoint(72000, 0)

	# Kapalı yükleme hattı: düşmanlar aralıklı gelir, üst raf güvenli yan yol.
	_enemy(KNIFE, 74200, 0)
	_coin_line(75200, 5, 300, -55)
	_enemy(RIFLE, 77700, 60)
	_reward_path(79700, ARMOR)
	_enemy(BRUISER, 81800, 0)
	_checkpoint(83500, 0)
	_arena(85000, 0, 84200, 85800, _wave(ASSASSIN, RIFLE),
		_wave(ELITE, KNIFE), HEALTH)
	_shop(89100, "DEPO İLK YARDIMI", PackedStringArray(["can", "cephane", "zirh"]))

	# Sevk ofisi: kısa üçüncü köprü, baskı kalıbı rafına isteğe bağlı çıkış.
	_checkpoint(90800, 0)
	_oneway(92000, -45, 240)
	_coin_line(91300, 5, 350, -125)
	_checkpoint(93300, 0)
	_enemy(ELITE, 95400, 0)
	_reward_path(97400, ARMOR)
	_enemy(ASSASSIN, 99400, 0)
	_pickup(HEALTH, 100500, -45)

	# Kıyı arka kapısı: defteri tutan son koruma ve yeni sevkiyat izi.
	_checkpoint(101100, 0)
	_arena(103000, 0, 102200, 103800, _wave(RIFLE, KNIFE),
		_wave(ELITE, BRUISER), HEALTH)
	_enemy(ASSASSIN, 106000, 0)
	_dialogue(108300, "GAZELLE", "Defterde sahte emirleri alan herkes yazılı. Asıl nüsha Beylerbeyi iskele arşivine taşınmış.")
	_dialogue(109600, "REDMOUNT", "Dağıtım zincirini gördük. Şimdi emrin kaynağını Beylerbeyi'nde bulacağız.")
	_goal(110900, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "awning" if x < 40000 else "wood_shelf" if x < 60000 else "scaffold" if x < 90000 else "corridor")


class _KuzguncukBackdrop extends Node2D:
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
		var atlas: Texture2D = KUZGUNCUK_STREETS if scene < 4 else KUZGUNCUK_DEPOT
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

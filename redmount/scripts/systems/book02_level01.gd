## Kitap 2 / Bölüm 1 — Haliç'te Şafak.
extends "res://scripts/systems/story_blockout.gd"

const OPENING := preload("res://assets/backgrounds/book02_halij_opening_atlas.png")
const FINALE := preload("res://assets/backgrounds/book02_halij_final_atlas.png")
const REGISTRY := preload("res://assets/backgrounds/book02_halij_registry_atlas.png")
const PAVING := preload("res://assets/environment/mahalle/ground_long.png")
const STONE := preload("res://assets/environment/mahalle/stone_fill.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_HaliçBackdrop.new())
	_intro("GAZELLE", "Karahanlı gitti, ama defterindeki sevkiyatlar sürüyor. İlk adres Haliç kıyısında.")
	for i in 28:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [8, 16, 24]:
			x -= 50.0
			width = 3900.0
		elif i in [9, 17, 25]:
			x += 50.0
			width = 3900.0
		_ground(x, width, 60.0 if i in [4, 5, 12, 13] else 0.0)

	# Kale çıkışı: eski hareketleri birer güvenli hedefle hatırlat.
	_coin_line(500, 6, 200, -55)
	_enemy(STREET, 1800, 0)
	_oneway(3800, -85, 220)
	_oneway(4100, -170, 220)
	_oneway(4400, -85, 220)
	for i in 3:
		_bonus_coin(3800 + i * 300, -220, 5)
	_enemy(KNIFE, 5600, 0)
	_pickup(PISTOL, 7200, -45)
	_checkpoint(9000, 0)
	_dialogue(10600, "REDMOUNT", "Kale geride kaldı. Şimdi defterdeki iskele numarasını bulalım.")

	# Balat yokuşu: ana sokak 60 px alçalır; balkon izi isteğe bağlı.
	_coin_line(12600, 6, 390, -55)
	_enemy(STREET, 13800, 0)
	_enemy(KNIFE, 15400, 0)
	_oneway(17200, -30, 220)
	_oneway(17500, -115, 220)
	_oneway(17800, -200, 220)
	_oneway(18100, -115, 220)
	for i in 4:
		_bonus_coin(17300 + i * 260, -255, 5)
	_pickup(ARMOR, 17800, -260)
	_enemy(ASSASSIN, 20300, 60)
	_pickup(HEALTH, 21500, 5)
	_checkpoint(23000, 0)
	_arena(25800, 0, 25000, 26600, _wave(STREET, KNIFE),
		_wave(KNIFE, ASSASSIN), AMMO)
	_coin_line(27200, 5, 250, -55)

	# Kayıkçı iskelesi: 200 px su boşluğu, sabit taş-iskele köprüsü.
	_enemy(KNIFE, 30200, 0)
	_oneway(33000, -85, 220)
	_oneway(33300, -170, 220)
	_oneway(33600, -255, 220)
	_oneway(33900, -170, 220)
	for i in 4:
		_bonus_coin(33100 + i * 260, -310, 5)
	_pickup(ARMOR, 33600, -315)
	_checkpoint(34500, 0)
	_oneway(36000, -45, 240)
	_coin_line(35300, 5, 350, -125)
	_enemy(RIFLE, 39300, 0)
	_shop(41800, "KAYIKÇI ERZAK TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(42600, 0)

	# Kapan depoları: tüfekliyi siperden ayır, geniş avluda iki kısa dalga.
	_enemy(RIFLE, 44700, 0)
	_prop("kasa", 45600)
	_enemy(KNIFE, 46600, 0)
	_oneway(47500, -85, 220)
	_oneway(47800, -170, 220)
	_oneway(48100, -85, 220)
	for i in 4:
		_bonus_coin(47500 + i * 220, -220, 5)
	_pickup(AMMO, 47800, -225)
	_enemy(BRUISER, 49600, 60)
	_enemy(ASSASSIN, 51000, 60)
	_checkpoint(52500, 60)
	_arena(55000, 60, 54200, 55800, _wave(RIFLE, KNIFE),
		_wave(BRUISER, STREET), HEALTH)
	_coin_line(56600, 5, 350, -55)

	# Açık Haliç yolu: üst vinç ödüllü; ikinci su geçişi düşmansız.
	_enemy(ASSASSIN, 59800, 0)
	_enemy(RIFLE, 61700, 0)
	_oneway(63200, -85, 220)
	_moving(63700, -145, Vector2(180, -30), 190)
	_oneway(64300, -205, 220)
	for i in 5:
		_bonus_coin(63200 + i * 275, -265, 5)
	_pickup(RIFLE_PICKUP, 64300, -265)
	_checkpoint(65200, 0)
	_oneway(68000, -45, 240)
	_coin_line(67400, 5, 300, -125)
	_enemy(KNIFE, 70600, 0)
	_checkpoint(72300, 0)

	# Eski han: Gazelle'in bulduğu adres, sonraki hikâyenin kapısı.
	_enemy(ELITE, 74400, 0)
	_prop("vazo", 75500)
	_pickup(HEALTH, 76200, -45)
	_checkpoint(76800, 0)
	_arena(78800, 0, 78000, 79600, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, KNIFE), HEALTH)
	_dialogue(81200, "GAZELLE", "Depoda adres yok. Mühür kayıkçıların eski gümrük kaydına ait.")
	_checkpoint(83400, 0)

	# Tekne onarım kızağı: ana rota düz, üst güvertede isteğe bağlı mühimmat.
	_enemy(STREET, 85500, 0)
	_enemy(KNIFE, 87300, 0)
	_oneway(88600, -85, 220)
	_oneway(88900, -170, 220)
	_oneway(89200, -85, 220)
	for i in 4:
		_bonus_coin(88600 + i * 220, -225, 5)
	_pickup(AMMO, 88900, -225)
	_enemy(RIFLE, 91100, 0)
	_checkpoint(92800, 0)

	# Arasta: 200 px açıklığı sabit iskele kapatır; çıkışta karışık devriye.
	_coin_line(93800, 5, 280, -55)
	_enemy(KNIFE, 96200, 0)
	_enemy(ASSASSIN, 97800, 0)
	_pickup(HEALTH, 99300, -45)
	_oneway(100000, -45, 240)
	_checkpoint(101000, 0)
	_arena(103300, 0, 102500, 104100, _wave(RIFLE, STREET),
		_wave(ASSASSIN, KNIFE), HEALTH)
	_coin_line(105200, 5, 280, -55)

	# Gümrük kayıt kapısı: kalenin değil, yeni sevkiyat ağının ilk somut izi.
	_enemy(ELITE, 108000, 0)
	_dialogue(109000, "GAZELLE", "Kayıt bulundu. Sevkiyatlar Haliç'ten içeri gidiyor; iz burada bitmiyor.")
	_goal(110700, 0)


func _bonus_coin(x: float, y: float, value: int) -> void:
	var coin := COIN.instantiate()
	coin.position = Vector2(x, y)
	coin.value = value
	add_child(coin)


func _platform(x: float, y: float, width: float, height: float) -> void:
	_serial += 1
	var body := StaticBody2D.new()
	body.name = "HaliçGround%d" % _serial
	body.position = Vector2(x, y)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	col.shape = shape
	body.add_child(col)
	body.add_child(_QuayFace.new(width, height))
	add_child(body)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "awning" if x < 28000 else "scaffold")


class _QuayFace extends Node2D:
	var width: float
	var height: float

	func _init(w: float, h: float) -> void:
		width = w
		height = h

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

	func _draw() -> void:
		var left := -width * 0.5
		var top := -height * 0.5
		draw_texture_rect(STONE, Rect2(left, top, width, height), true, Color("b5b2b6"))
		draw_texture_rect(PAVING, Rect2(left, top, width, 50), true, Color("e3d6c6"))


class _HaliçBackdrop extends Node2D:
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
		var cuts := [11000.0, 28000.0, 43000.0, 51000.0,
			58000.0, 72000.0, 79000.0, 84000.0,
			93000.0, 101000.0, 108000.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_scene(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_scene(scene: int, alpha: float) -> void:
		var atlas: Texture2D = OPENING if scene < 4 else (FINALE if scene < 8 else REGISTRY)
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -540, 1920, 900),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y * 0.84)),
			Color(1, 1, 1, alpha))

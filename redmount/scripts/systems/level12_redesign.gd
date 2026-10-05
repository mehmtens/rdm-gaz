## Bölüm 11 — Sessiz Koridor: Gazelle'in izini takip eden dört iç mekân.
extends "res://scripts/systems/level11_redesign.gd"

const INTERIOR_ATLAS := preload("res://assets/backgrounds/level12_silent_corridor_atlas.png")
const INTERIOR_STONE := preload("res://assets/environment/corridor_ground.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_InteriorBackdrop.new())
	_intro("REDMOUNT", "Surlar geride kaldı. Gazelle'in sesini duydum; odasına açılan yolu bulacağım.")

	# Nöbet girişi: sessizlik, tek seçkin, sonra isteğe bağlı galeri.
	_ground(2000, 4000)
	_ground(6000, 4000)
	_coin_line(550, 6, 190, -55)
	_pickup(PISTOL, 950, -45)
	_pickup(AMMO, 1150, -45)
	_enemy(ELITE, 2750, 0)
	_oneway(4600, -85, 225)
	_oneway(4900, -170, 225)
	_oneway(5200, -255, 225)
	_oneway(5500, -170, 225)
	_oneway(5800, -85, 225)
	for i in 5:
		_bonus_coin(4600 + i * 300, -310 if i == 2 else -225, 5)
	_pickup(ARMOR, 5200, -315)
	_enemy(ASSASSIN, 5400, 0)
	_enemy(RIFLE, 6450, 0)
	_prop("vazo", 6760)
	_shop(7250, "NÖBET ERZAK ODASI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(7800, 0)

	# Arşiv galerisi: alt arşiv yolunda kısa alçalma, üst raflarda silah ödülü.
	_ground(10000, 4000, 60)
	_ground(14000, 4000)
	_coin_line(8300, 5, 560, 5)
	_oneway(8500, -25, 220)
	_oneway(8800, -110, 220)
	_oneway(9100, -195, 220)
	_oneway(9400, -110, 220)
	for i in 4:
		_bonus_coin(8700 + i * 240, -250, 5)
	_pickup(RIFLE_PICKUP, 9100, -255)
	_enemy(ASSASSIN, 9100, 60)
	_enemy(RIFLE, 10200, 60)
	_hint(10900, "GAZELLE: Arşivin ötesindeyim.\nİki kapı daha var.")
	_enemy(ELITE, 12000, 0)
	_pickup(HEALTH, 12900, -45)
	_checkpoint(13500, 0)
	_arena(14300, 0, 13500, 15100, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, ELITE), ARMOR)
	_coin_line(15300, 5, 170, -55)

	# Kayıt odaları: alt ana koridor açık, hareketli arşiv asansörü bonus verir.
	_ground(18000, 4000)
	_ground(22000, 4000, 80)
	_enemy(ASSASSIN, 16900, 0)
	_enemy(ELITE, 17800, 0)
	_oneway(17500, -85, 220)
	_moving(17900, -130, Vector2(0, -140), 190)
	_oneway(18300, -245, 220)
	_oneway(18700, -160, 220)
	for i in 5:
		_bonus_coin(17500 + i * 300, -300 if i == 2 else -235, 5)
	_pickup(AMMO, 18300, -300)
	_enemy(RIFLE, 19000, 0)
	_coin_line(19500, 5, 480, -55)
	_enemy(ELITE, 21100, 80)
	_enemy(RIFLE, 22400, 80)
	_pickup(HEALTH, 23100, 25)
	_checkpoint(23600, 80)

	# Servis şaftı: düşey katlar önce ödül yolu, sonra geniş savunma avlusu.
	_ground(26000, 4000)
	_ground(30000, 4000, 70)
	_ground(34000, 4000)
	_shop(24600, "ŞAFT BAKIM ODASI", PackedStringArray(["can", "cephane", "tabanca"]))
	_hint(25300, "GAZELLE: Alt servisten yürü.\nAsansör galerisi yalnız kestirme.")
	_oneway(26500, -85, 220)
	_moving(26800, -130, Vector2(0, -145), 190)
	_oneway(27200, -245, 220)
	_oneway(27500, -160, 220)
	for i in 5:
		_bonus_coin(26500 + i * 260, -305, 5)
	_pickup(ARMOR, 27200, -305)
	_enemy(ASSASSIN, 27400, 0)
	_enemy(RIFLE, 28600, 70)
	_coin_line(29100, 5, 500, 15)
	_enemy(ELITE, 30400, 70)
	_enemy(ASSASSIN, 31400, 70)
	_pickup(HEALTH, 32400, -45)
	_checkpoint(33300, 0)
	_arena(34200, 0, 33400, 35000, _wave(RIFLE, ELITE),
		_wave(ASSASSIN, ELITE, RIFLE), HEALTH)
	_coin_line(35400, 5, 400, -55)

	# İç revir: kısa nefes, ardından sessiz pusu ve son kapı işareti.
	_ground(38000, 4000)
	_ground(42000, 4000, 60)
	_ground(46000, 4000)
	_prop("sandik", 37100, 0, AMMO)
	_shop(39000, "İÇ REVİR", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(39600, 0)
	_hint(40000, "GAZELLE: Son kapının kilidi eski.\nNöbet değişimini bekliyorum.")
	_oneway(40600, -90, 220)
	_oneway(40900, -175, 220)
	_oneway(41200, -260, 220)
	_oneway(41500, -175, 220)
	for i in 5:
		_bonus_coin(40600 + i * 230, -310, 5)
	_pickup(PISTOL, 41200, -320)
	_enemy(ASSASSIN, 40800, 60)
	_enemy(ELITE, 41700, 60)
	_enemy(RIFLE, 43000, 60)
	_coin_line(43500, 5, 450, -55)
	_pickup(HEALTH, 44800, -45)
	_checkpoint(45500, 0)

	# Gazelle'in kapısı: cezası uzun olmayan son muhafız sınavı.
	_ground(49000, 2000)
	_enemy(ELITE, 46300, 0)
	_arena(47400, 0, 46600, 48200, _wave(ELITE, ASSASSIN),
		_wave(ELITE, RIFLE, ASSASSIN), HEALTH)
	_dialogue(48750, "GAZELLE", "Redmount! Sesin kapının öte yanında. Karahanlı geliyor.")
	_goal(49400, 0)


func _shop(x: float, title: String, items: PackedStringArray) -> void:
	super._shop(x, title, items)
	if title == "İÇ REVİR":
		(get_child(get_child_count() - 1) as LevelShop).style = "underground"


func _platform(x: float, y: float, width: float, height: float) -> void:
	_serial += 1
	var body := StaticBody2D.new()
	body.name = "CorridorGround%d" % _serial
	body.position = Vector2(x, y)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	col.shape = shape
	body.add_child(col)
	body.add_child(_CorridorFace.new(width, height))
	add_child(body)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "corridor")


func _moving(x: float, y: float, travel: Vector2, width: float, phase := 0.0) -> void:
	super._moving(x, y, travel, width, phase)
	get_child(get_child_count() - 1).set("style", "corridor")


class _CorridorFace extends Node2D:
	var width: float
	var height: float

	func _init(w: float, h: float) -> void:
		width = w
		height = h

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

	func _draw() -> void:
		draw_texture_rect(INTERIOR_STONE,
			Rect2(-width * 0.5, -height * 0.5, width, height), true)


class _InteriorBackdrop extends Node2D:
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
		var cuts := [12000.0, 25000.0, 38500.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_cell(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_cell(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_cell(scene: int, alpha: float) -> void:
		var half := INTERIOR_ATLAS.get_size() * 0.5
		var cell := Vector2(scene % 2, scene / 2) * half
		draw_texture_rect_region(INTERIOR_ATLAS, Rect2(-960, -540, 1920, 900),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y * 0.72)),
			Color(1, 1, 1, alpha))

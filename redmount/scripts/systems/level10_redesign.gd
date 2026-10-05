## Bölüm 8 — Yeraltı Sevkiyatı. Hareketli yük arabaları ödüllü üst rota;
## aşağıdaki ray servis yolu her zaman geçilebilir.
extends "res://scripts/systems/story_blockout.gd"

const ATLAS := preload("res://assets/backgrounds/level08_underground_atlas.png")
const GROUND := preload("res://assets/environment/underground_ground.png")
const HINT := preload("res://scenes/systems/HintTrigger.tscn")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_Backdrop.new())
	_intro("GAZELLE", "Rayların altındayım. Üç güvenlik kapısı var; seslerini takip et.")

	# 0–8 bin: yükleme holü; ileri-geri araba önce güvenli zeminin üstünde.
	_ground(2000, 4000)
	_ground(6000, 4000)
	_enemy(ASSASSIN, 1300, 0)
	_coin_line(520, 6, 200, -55)
	_oneway(2600, -75, 220)
	_moving(2920, -90, Vector2(240, 0), 190)
	_oneway(3510, -75, 220)
	for i in 5:
		_bonus_coin(2780 + i * 140, -170, 5)
	_pickup(ARMOR, 3190, -200)
	_enemy(RIFLE, 5200, 0)
	_enemy(KNIFE, 6200, 0)
	_prop("sandik", 6830, 0, HEALTH)
	_shop(7300, "YÜKLEME REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(7800, 0)

	# 8–16 bin: sarnıç pompası; zemin 70 aşağıda, dikey araba kısa yol açar.
	_ground(10000, 4000, 70)
	_ground(14000, 4000)
	_oneway(8560, -10, 220)
	_moving(8940, -30, Vector2(0, -125), 190)
	_moving(9370, -155, Vector2(220, 0), 190, 0.5)
	_oneway(9870, -80, 220)
	for i in 4:
		_bonus_coin(8960 + i * 180, -205, 5)
	_pickup(AMMO, 9470, -245)
	_coin_line(8350, 5, 530, 20)
	_enemy(KNIFE, 9150, 70)
	_enemy(RIFLE, 10150, 70)
	_enemy(ASSASSIN, 11250, 70)
	_pickup(HEALTH, 12400, -45)
	_checkpoint(13500, 0)
	_arena(14300, 0, 13500, 15100, _wave(KNIFE, RIFLE), _wave(ASSASSIN, BRUISER), AMMO)
	_coin_line(15300, 5, 170, -55)

	# 16–24 bin: pompa kuyusu; aşağı yol 80 kotunda, üstte ters yönlü arabalar.
	_ground(18000, 4000, 80)
	_ground(22000, 4000)
	_enemy(KNIFE, 17000, 80)
	_enemy(RIFLE, 18100, 80)
	_oneway(17450, -10, 210)
	_moving(17780, -95, Vector2(250, 0), 190)
	_moving(18780, -150, Vector2(-240, 0), 190, 0.5)
	_oneway(19150, -80, 210)
	for i in 5:
		_bonus_coin(17750 + i * 290, -215, 5)
	_pickup(PISTOL, 18780, -245)
	_enemy(BRUISER, 20300, 0)
	_coin_line(20800, 5, 500, -55)
	_shop(22400, "POMPA BAKIM ODASI", PackedStringArray(["can", "cephane", "tabanca"]))
	_checkpoint(23800, 0)

	# 24–38 bin: ray makası; platformlar karşı yönde hareket eder, alt hat sürer.
	_ground(26000, 4000)
	_ground(30000, 4000, 70)
	_ground(34000, 4000)
	_ground(38000, 4000)
	_oneway(24900, -80, 220)
	_moving(25250, -110, Vector2(260, 0), 190)
	_moving(26150, -175, Vector2(-230, 0), 190, 0.5)
	_oneway(26950, -80, 220)
	for i in 5:
		_bonus_coin(25100 + i * 430, -230, 5)
	_pickup(ARMOR, 26150, -265)
	_enemy(ASSASSIN, 25700, 0)
	_enemy(RIFLE, 27200, 0)
	_coin_line(28300, 5, 520, 20)
	_moving(29600, -85, Vector2(210, -70), 185)
	_oneway(30400, -15, 220)
	_enemy(BRUISER, 30200, 70)
	_enemy(KNIFE, 31200, 70)
	_pickup(HEALTH, 32400, -45)
	_checkpoint(33300, 0)
	_arena(34200, 0, 33400, 35000, _wave(RIFLE, ASSASSIN), _wave(BRUISER, RIFLE), HEALTH)
	_enemy(KNIFE, 36600, 0)
	_coin_line(35800, 5, 380, -55)

	# 38–49 bin: Gazelle'in üç kapı sayımı, son hazırlık ve sevkiyat baskını.
	_ground(42000, 4000, 70)
	_ground(46000, 4000)
	_ground(49000, 2000)
	_radio(38800, "GAZELLE: ÜÇ KAPI.\nİlki ray makasının gerisinde kaldı.")
	_enemy(RIFLE, 39300, 0)
	_enemy(ASSASSIN, 40300, 70)
	_oneway(40800, -10, 220)
	_moving(41100, -65, Vector2(230, -75), 190)
	_oneway(41680, -90, 220)
	for i in 4:
		_bonus_coin(40900 + i * 260, -200, 5)
	_pickup(AMMO, 41400, -245)
	_radio(43000, "GAZELLE: İKİ KAPI.\nSon vagondaki muhafızları duyuyorum.")
	_enemy(BRUISER, 43400, 70)
	_enemy(RIFLE, 44500, 0)
	_pickup(HEALTH, 45000, -45)
	_checkpoint(45600, 0)
	_arena(46600, 0, 45400, 47800,
		_wave(RIFLE, ASSASSIN), _wave(BRUISER, RIFLE, ASSASSIN), HEALTH)
	_radio(48300, "GAZELLE: SON KAPI.\nBuradan sonra dağ yolu başlıyor.")
	_goal(49200, 0)


func _bonus_coin(x: float, y: float, value: int) -> void:
	var coin := COIN.instantiate()
	coin.position = Vector2(x, y)
	coin.value = value
	add_child(coin)


func _shop(x: float, title: String, items: PackedStringArray) -> void:
	super._shop(x, title, items)
	(get_child(get_child_count() - 1) as LevelShop).style = "underground"


func _radio(x: float, message: String) -> void:
	var hint: HintTrigger = HINT.instantiate()
	hint.position = Vector2(x, 0)
	hint.text = message
	add_child(hint)


func _platform(x: float, y: float, width: float, height: float) -> void:
	super._platform(x, y, width, height)
	var body := get_child(get_child_count() - 1) as StaticBody2D
	body.get_node(^"Vis").visible = false
	body.add_child(_TunnelFace.new(width, height))


func _oneway(x: float, y: float, width: float) -> void:
	var node := ONEWAY.instantiate()
	node.position = Vector2(x, y)
	node.set("width", width)
	node.set("style", "underground")
	add_child(node)


func _moving(x: float, y: float, travel: Vector2, width: float, phase := 0.0) -> void:
	var node := MOVING.instantiate()
	node.position = Vector2(x, y)
	node.set("travel", travel)
	node.set("width", width)
	node.set("phase_offset", phase)
	node.set("style", "rail")
	add_child(node)


class _TunnelFace extends Node2D:
	var width: float
	var height: float

	func _init(w: float, h: float) -> void:
		width = w
		height = h

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

	func _draw() -> void:
		draw_texture_rect(GROUND, Rect2(-width * 0.5, -height * 0.5, width, height), true)


class _Backdrop extends Node2D:
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
		var cuts := [12000.0, 24000.0, 38000.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_cell(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_cell(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_cell(scene: int, alpha: float) -> void:
		var half := ATLAS.get_size() * 0.5
		var cell := Vector2(scene % 2, scene / 2) * half
		draw_texture_rect_region(ATLAS, Rect2(-960, -540, 1920, 1080),
			Rect2(cell + Vector2(2, 2), half - Vector2(4, 4)), Color(1, 1, 1, alpha))

## Bölüm 7 — Haddehane. Ana servis yolu geçilebilir; yüksek iskeleler ödüllüdür.
extends "res://scripts/systems/story_blockout.gd"

const ATLAS := preload("res://assets/backgrounds/level07_haddehane_atlas.png")
const GROUND := preload("res://assets/environment/haddehane_ground.png")
const HINT := preload("res://scenes/systems/HintTrigger.tscn")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_Backdrop.new())
	_intro("KARAHANLI", "Dökümhaneyi geçtin. Bu haddehanede her kapıyı ben açarım, Redmount.")

	# 0–8 bin: tek zırhlı ile sakin tekrar, ardından mesafeli tüfekli.
	_ground(2000, 4000)
	_ground(6000, 4000)
	_hint(1050, "ZIRHLI: YERE ÇAKMA ZIRHI SARSAR\nK ağır vuruş ve temiz yumruklar da işe yarar.")
	_enemy(BRUISER, 1650, 0)
	_coin_line(520, 6, 190, -55)
	_oneway(3750, -85, 220)
	_oneway(4020, -170, 220)
	_oneway(4290, -255, 220)
	_oneway(4560, -170, 220)
	_oneway(4830, -85, 220)
	for i in 5:
		_bonus_coin(3750 + i * 270, -300 if i == 2 else -215, 5)
	_pickup(ARMOR, 4290, -305)
	_enemy(KNIFE, 5050, 0)
	_enemy(RIFLE, 5900, 0)
	_prop("sandik", 6800, 0, HEALTH)
	_shop(7250, "HADDEHANE İŞÇİ LOKALİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(7800, 0)

	# 8–16 bin: su verme kanalı; alt servis yolu iner, üst iskele kestirmedir.
	_ground(10000, 4000, 70)
	_ground(14000, 4000)
	_oneway(8500, -10, 220)
	_oneway(8780, -95, 220)
	_oneway(9060, -180, 220)
	_oneway(9340, -95, 220)
	for i in 4:
		_bonus_coin(8780 + i * 190, -245, 5)
	_pickup(AMMO, 9060, -230)
	_coin_line(8350, 5, 510, 20)
	_enemy(KNIFE, 9250, 70)
	_enemy(RIFLE, 10100, 70)
	_enemy(ASSASSIN, 11250, 70)
	_pickup(HEALTH, 12300, -45)
	_enemy(RIFLE, 13100, 0)
	_checkpoint(13600, 0)
	_arena(14300, 0, 13500, 15100, _wave(KNIFE, RIFLE), _wave(BRUISER, ASSASSIN), AMMO)
	_coin_line(15300, 5, 170, -55)

	# 16–28 bin: servis şaftında üç katlı bonus tırmanış; alt rota açık.
	_ground(18000, 4000)
	_ground(22000, 4000, 80)
	_ground(26000, 4000)
	_enemy(ASSASSIN, 17200, 0)
	_enemy(BRUISER, 18350, 0)
	_oneway(19800, -70, 220)
	_oneway(20080, -155, 220)
	_oneway(20360, -240, 220)
	_oneway(20640, -155, 220)
	_oneway(20920, -70, 220)
	for i in 5:
		_bonus_coin(19800 + i * 280, -295 if i == 2 else -205, 5)
	_pickup(PISTOL, 20360, -290)
	_enemy(KNIFE, 21700, 80)
	_enemy(RIFLE, 22600, 80)
	_coin_line(21200, 5, 540, 25)
	_shop(23800, "ŞAFT BAKIM ODASI", PackedStringArray(["can", "cephane", "tabanca"]))
	_checkpoint(24100, 0)
	_enemy(BRUISER, 25000, 0)
	_enemy(RIFLE, 26200, 0)
	_pickup(HEALTH, 27300, -45)

	# 28–38 bin: cüruf köprüsü, savunma ve hareket birlikte sınanır.
	_ground(30000, 4000)
	_ground(34000, 4000, 90)
	_ground(38000, 4000)
	_oneway(29300, -90, 220)
	_oneway(29580, -175, 220)
	_oneway(29860, -90, 220)
	for i in 4:
		_bonus_coin(29300 + i * 185, -225, 5)
	_enemy(ASSASSIN, 30400, 0)
	_enemy(RIFLE, 31350, 0)
	_coin_line(32200, 5, 480, 35)
	_enemy(BRUISER, 33900, 90)
	_enemy(KNIFE, 34750, 90)
	_shop(35500, "CÜRUF KANTİNİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(36100, 0)
	_arena(36900, 0, 36100, 37700, _wave(ASSASSIN, RIFLE), _wave(BRUISER, RIFLE), ARMOR)

	# 38–49 bin: vericiye yaklaşım, son hazırlık ve zırhlı final sınavı.
	_ground(42000, 4000)
	_ground(46000, 4000)
	_ground(49000, 2000)
	_enemy(RIFLE, 39000, 0)
	_enemy(KNIFE, 39900, 0)
	_oneway(41000, -85, 220)
	_oneway(41280, -170, 220)
	_oneway(41560, -255, 220)
	_oneway(41840, -170, 220)
	for i in 5:
		_bonus_coin(41000 + i * 210, -305 if i == 2 else -215, 5)
	_pickup(ARMOR, 41560, -305)
	_enemy(BRUISER, 43000, 0)
	_enemy(RIFLE, 44200, 0)
	_pickup(HEALTH, 45000, -45)
	_checkpoint(45600, 0)
	_arena(46600, 0, 45400, 47800,
		_wave(BRUISER, RIFLE), _wave(ASSASSIN, BRUISER, RIFLE), HEALTH)
	_dialogue(48400, "KARAHANLI", "Vericiyi susturdun. Gazelle çoktan yeraltı sevkiyatında.")
	_goal(49200, 0)


func _bonus_coin(x: float, y: float, value: int) -> void:
	var coin := COIN.instantiate()
	coin.position = Vector2(x, y)
	coin.value = value
	add_child(coin)


func _shop(x: float, title: String, items: PackedStringArray) -> void:
	super._shop(x, title, items)
	(get_child(get_child_count() - 1) as LevelShop).style = "workshop"


func _platform(x: float, y: float, width: float, height: float) -> void:
	super._platform(x, y, width, height)
	var body := get_child(get_child_count() - 1) as StaticBody2D
	body.get_node(^"Vis").visible = false
	body.add_child(_SteelFace.new(width, height))


func _oneway(x: float, y: float, width: float) -> void:
	var node := ONEWAY.instantiate()
	node.position = Vector2(x, y)
	node.set("width", width)
	node.set("style", "industrial")
	add_child(node)


func _hint(x: float, message: String) -> void:
	var hint: HintTrigger = HINT.instantiate()
	hint.position = Vector2(x, 0)
	hint.text = message if Save.owns("ground_slam") else "ZIRHLI: K AĞIR VURUŞ\nArt arda dört temiz darbe zırhı sarsar."
	add_child(hint)


class _SteelFace extends Node2D:
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

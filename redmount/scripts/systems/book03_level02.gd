## Kitap 3 / Bölüm 2 — Sirkeci Sevkiyatı.
extends "res://scripts/systems/book03_level01.gd"

const STATION := preload("res://assets/backgrounds/book03_sirkeci_station_atlas.png")
const DISPATCH := preload("res://assets/backgrounds/book03_sirkeci_dispatch_atlas.png")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_SirkeciBackdrop.new())
	_intro("GAZELLE", "Cağaloğlu defterindeki ilk sevkiyat Sirkeci'ye indi. Sandıklar dağılmadan yük kaydını bulmalıyız.")
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

	# Gar sokağı: muhafızın menzili ve yakın dövüşçünün hızı ayrı ayrı okunur.
	_coin_line(500, 6, 220, -55)
	_enemy(STREET, 2300, 0)
	_enemy(RIFLE, 5200, 0)
	_reward_path(6700, ARMOR)
	_checkpoint(9500, 0)
	_enemy(KNIFE, 11900, 0)
	_dialogue(13600, "REDMOUNT", "Garın önünde yalnız yolcu yok. Kâğıt sandıklarının başına nöbet koymuşlar.")

	# İstasyon cephesi: 60 px servis kotu, tentede coin; ilk arena geniş avluda.
	_coin_line(15100, 6, 360, -55)
	_enemy(ASSASSIN, 17400, 60)
	_oneway(19100, -25, 220)
	_oneway(19400, -110, 220)
	_oneway(19700, -195, 220)
	for i in 4:
		_bonus_coin(19100 + i * 220, -250, 5)
	_pickup(AMMO, 19700, -255)
	_enemy(STREET, 21500, 60)
	_checkpoint(23500, 0)
	_arena(26300, 0, 25500, 27100, _wave(KNIFE, STREET),
		_wave(RIFLE, ASSASSIN), HEALTH)
	_coin_line(28300, 5, 300, -55)

	# Yolcu peronu: ana geçiş sabit; valiz rafı tabanca verir.
	_enemy(RIFLE, 31000, 0)
	_reward_path(32900, PISTOL)
	_checkpoint(34600, 0)
	_oneway(36000, -45, 240)
	_coin_line(35300, 5, 350, -125)
	_enemy(ELITE, 39700, 0)
	_shop(42100, "PERON ERZAKÇISI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(43200, 0)

	# Bilet holü: ikinci baskın iki açıdan gelir; yan raf zırh verir.
	_enemy(KNIFE, 45500, 0)
	_reward_path(47200, ARMOR)
	_enemy(BRUISER, 50600, 60)
	_checkpoint(52900, 60)
	_enemy(ASSASSIN, 55000, 0)
	_checkpoint(56800, 0)
	_arena(58800, 0, 58000, 59600, _wave(ASSASSIN, RIFLE),
		_wave(BRUISER, KNIFE), HEALTH)
	_dialogue(61500, "GAZELLE", "Yolcu treni yem. Mühürlü sandıklar arka yük peronuna geçirilmiş.")

	# Yük peronu: üstte hareketli bagaj rafı; alttan açık taş geçit.
	_enemy(ELITE, 63500, 0)
	_oneway(65000, -85, 220)
	_moving(65500, -145, Vector2(180, -30), 190)
	_oneway(66100, -205, 220)
	for i in 5:
		_bonus_coin(65000 + i * 270, -265, 5)
	_pickup(RIFLE_PICKUP, 66100, -265)
	_checkpoint(67100, 0)
	_oneway(68000, -45, 240)
	_coin_line(67300, 5, 350, -125)
	_enemy(RIFLE, 70700, 0)
	_checkpoint(72900, 0)

	# Posta ayıklama: tüfekliyi önceden konumlanıp ayır; üçüncü arena.
	_enemy(KNIFE, 74500, 0)
	_prop("sandik", 75600, 0, AMMO)
	_checkpoint(76100, 0)
	_arena(78300, 0, 77500, 79100, _wave(RIFLE, STREET),
		_wave(ELITE, ASSASSIN), HEALTH)
	_shop(81200, "POSTA REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))

	# Ray-iskele aktarması: 60 px alçalan ana yol, üst bagaj yolu isteğe bağlı.
	_enemy(BRUISER, 82500, 60)
	_reward_path(84400, ARMOR)
	_enemy(RIFLE, 87000, 60)
	_checkpoint(89000, 0)
	_coin_line(90300, 6, 300, -55)
	_enemy(ASSASSIN, 93200, 0)
	_checkpoint(97000, 0)

	# Sevk odası: son açıklık sabit, kayıt sandığına ulaşmak için final baskını.
	_oneway(100000, -45, 240)
	_coin_line(99300, 5, 350, -125)
	_checkpoint(101100, 0)
	_arena(103100, 0, 102300, 103900, _wave(KNIFE, RIFLE),
		_wave(ELITE, BRUISER), HEALTH)
	_enemy(ASSASSIN, 105800, 0)
	_pickup(HEALTH, 107000, -45)
	_dialogue(108200, "GAZELLE", "Kâğıtlar trene yüklenmemiş. Emirler Galata'daki telgraf hattından dağıtılıyor.")
	_dialogue(109500, "REDMOUNT", "O zaman sandıkları değil, emri yollayan hattı bulacağız. Galata'ya geçelim.")
	_goal(110900, 0)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	get_child(get_child_count() - 1).set("style", "awning" if x < 28000 else "metal" if x < 70000 else "wood_shelf" if x < 98000 else "corridor")


class _SirkeciBackdrop extends Node2D:
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
		var atlas: Texture2D = STATION if scene < 4 else DISPATCH
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

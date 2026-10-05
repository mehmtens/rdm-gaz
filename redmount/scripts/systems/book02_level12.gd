## Kitap 2 / Bölüm 12 — Bozdoğan Kemeri, su hattı finali.
extends "res://scripts/systems/book02_level01.gd"

const APPROACH := preload("res://assets/backgrounds/book02_final_approach_atlas.png")
const AQUEDUCT := preload("res://assets/backgrounds/book02_final_aqueduct_atlas.png")
const TOWER := preload("res://assets/backgrounds/book02_final_tower_atlas.png")
const CHIEF := preload("res://scenes/enemies/WaterworksChief.tscn")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_FinalBackdrop.new())
	_intro("GAZELLE", "Saraçhane'deki vana durdu. Son kumanda Bozdoğan Kemeri'nin servis kulesinde.")
	for i in 72:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [8, 20, 32, 44, 56, 68]:
			x -= 50.0
			width = 3900.0
		elif i in [9, 21, 33, 45, 57, 69]:
			x += 50.0
			width = 3900.0
		var low := i in [3, 4, 15, 16, 27, 28, 39, 40, 51, 52, 63, 64]
		_ground(x, width, 60.0 if low else 0.0)
	_approach()
	_lower_works()
	_upper_works()
	_command_tower()


func _approach() -> void:
	# 0–24 bin: sokak devriyeleri, güvenli üst rota, alçak avlu sınavı.
	_coin_line(500, 6, 230, -55)
	_enemy(STREET, 2300, 0)
	_enemy(KNIFE, 5400, 0)
	_reward_path(6900, ARMOR)
	_checkpoint(9700, 0)
	_enemy(RIFLE, 12000, 60)
	_dialogue(14300, "REDMOUNT", "Kemere yaklaştık. Alt geçidi tutmuşlar; geniş avluda ayırarak dövüşelim.")
	_checkpoint(16200, 60)
	_arena(18000, 60, 17200, 18800, _wave(STREET, KNIFE),
		_wave(ASSASSIN, RIFLE), HEALTH)
	_checkpoint(21100, 0)

	# 24–48 bin: kemer altı, kısa su açıklığı ve iki yönlü pusu.
	_coin_line(24800, 6, 430, -55)
	_enemy(ASSASSIN, 27500, 0)
	_reward_path(30000, AMMO)
	_checkpoint(34500, 0)
	_oneway(36000, -45, 240)
	_coin_line(35300, 5, 330, -125)
	_enemy(RIFLE, 38300, 0)
	_shop(39200, "KEMER ALTI ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(39800, 0)
	_arena(41600, 0, 40800, 42400, _wave(KNIFE, RIFLE),
		_wave(ELITE, STREET), HEALTH)
	_dialogue(46200, "GAZELLE", "Eski su kapısına giden bakım yolu, meydanın arkasındaki avludan açılıyor.")

	# 48–72 bin: su kapısı avlusu; üst raf ekipman, alt rota açık.
	_coin_line(48900, 6, 450, -55)
	_enemy(BRUISER, 51200, 0)
	_encounter("kasa", 54100, RIFLE_PICKUP)
	_enemy(ASSASSIN, 57100, 0)
	_checkpoint(60300, 60)
	_shop(59200, "SU KAPISI REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(63000, 60)
	_arena(65000, 60, 64200, 65800, _wave(BRUISER, ASSASSIN),
		_wave(ELITE, RIFLE), HEALTH)
	_pickup(HEALTH, 68600, -45)

	# 72–96 bin: gizli bakım avlusu, ikinci köprü ve karışık savunma.
	_enemy(RIFLE, 74900, 0)
	_reward_path(77900, ARMOR)
	_enemy(ELITE, 80900, 0)
	_checkpoint(82700, 0)
	_oneway(84000, -45, 240)
	_coin_line(83300, 5, 330, -125)
	_checkpoint(87000, 0)
	_arena(89000, 0, 88200, 89800, _wave(ASSASSIN, RIFLE),
		_wave(ELITE, BRUISER), HEALTH)
	_dialogue(94000, "REDMOUNT", "Alt galerinin kapısı açık. Yukarıdaki kuleye buradan çıkacağız.")


func _lower_works() -> void:
	# 96–120 bin: su kanalı; kısa iniş, zırhlı nöbet, raf bonusu.
	_coin_line(97000, 6, 450, -55)
	_enemy(KNIFE, 99400, 0)
	_reward_path(101000, ARMOR)
	_enemy(RIFLE, 105000, 0)
	_checkpoint(110900, 60)
	_arena(113000, 60, 112200, 113800, _wave(ELITE, KNIFE),
		_wave(RIFLE, BRUISER), HEALTH)
	_shop(117300, "ALT GALERİ ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))

	# 120–144 bin: ölçüm salonu, sabit su açıklığı ve gösterge nöbeti.
	_enemy(ASSASSIN, 123000, 0)
	_coin_line(124500, 6, 430, -55)
	_encounter("iskele", 127290, AMMO)
	_enemy(ELITE, 129000, 0)
	_checkpoint(130500, 0)
	_oneway(132000, -45, 240)
	_coin_line(131300, 5, 330, -125)
	_checkpoint(135100, 0)
	_arena(137000, 0, 136200, 137800, _wave(ELITE, RIFLE),
		_wave(BRUISER, ASSASSIN), HEALTH)
	_dialogue(141000, "GAZELLE", "Manometreler yükseliyor. Kesinti emri henüz verilmemiş ama çok az zamanımız var.")

	# 144–168 bin: denetim merdivenleri; alt taş yol ve yüksek raf.
	_enemy(BRUISER, 147000, 0)
	_reward_path(150000, ARMOR)
	_enemy(RIFLE, 153600, 0)
	_checkpoint(158700, 60)
	_arena(161000, 60, 160200, 161800, _wave(ASSASSIN, ELITE),
		_wave(RIFLE, BRUISER), HEALTH)
	_shop(165800, "DENETİM REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))

	# 168–192 bin: kemer üst yolu; açıklık sabit, üst revak ödüllü.
	_coin_line(169500, 6, 450, -55)
	_enemy(ASSASSIN, 172000, 0)
	_reward_path(174500, RIFLE_PICKUP)
	_enemy(RIFLE, 177200, 0)
	_checkpoint(178500, 0)
	_oneway(180000, -45, 240)
	_coin_line(179300, 5, 330, -125)
	_checkpoint(183100, 0)
	_arena(185000, 0, 184200, 185800, _wave(ELITE, RIFLE),
		_wave(BRUISER, ASSASSIN), HEALTH)
	_dialogue(189500, "REDMOUNT", "Kule göründü. Komut masasını bulmadan hiçbir vanayı çevirmeyelim.")


func _upper_works() -> void:
	# 192–216 bin: üst dağıtım haznesi, alt servis yolu açık.
	_enemy(ELITE, 194000, 0)
	_coin_line(195000, 6, 450, -55)
	_reward_path(198000, ARMOR)
	_enemy(KNIFE, 202000, 0)
	_checkpoint(206700, 60)
	_arena(209000, 60, 208200, 209800, _wave(BRUISER, ASSASSIN),
		_wave(ELITE, RIFLE), HEALTH)
	_shop(213800, "HAZNE BAKIM ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))

	# 216–240 bin: komuta arşivi, son 200 px açıklık.
	_enemy(RIFLE, 218500, 0)
	_coin_line(219700, 5, 420, -55)
	_reward_path(222000, AMMO)
	_enemy(ASSASSIN, 225000, 0)
	_checkpoint(226500, 0)
	_oneway(228000, -45, 240)
	_coin_line(227300, 5, 330, -125)
	_checkpoint(231000, 0)
	_arena(233000, 0, 232200, 233800, _wave(ASSASSIN, RIFLE),
		_wave(ELITE, BRUISER), HEALTH)
	_dialogue(237500, "GAZELLE", "Arşivdeki imza yok edilmiş. Yalnız son komut anahtarının kulede olduğu yazıyor.")

	# 240–264 bin: servis kulesi içi; son alçak kot ve ağır savunma.
	_enemy(BRUISER, 242000, 0)
	_reward_path(245500, ARMOR)
	_enemy(RIFLE, 250000, 0)
	_checkpoint(254800, 60)
	_arena(257000, 60, 256200, 257800, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, BRUISER), HEALTH)
	_shop(261500, "KULE REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))


func _command_tower() -> void:
	# 264–288 bin: kule üst terası, son açıklık, boss öncesi toparlanma.
	_enemy(ASSASSIN, 266200, 0)
	_coin_line(267500, 6, 430, -55)
	_encounter("tente_duvar", 270320, ARMOR)
	_enemy(ELITE, 272000, 0)
	_checkpoint(274500, 0)
	_oneway(276000, -45, 240)
	_coin_line(275300, 5, 330, -125)
	_pickup(HEALTH, 278100, -45)
	_pickup(AMMO, 278500, -45)
	_shop(279200, "SON KULE ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(280300, 0)
	_dialogue(281000, "REDMOUNT", "Son anahtar bu terasta. Muhafızı geçip şebeke komutunu durduracağız.")
	var finale: BattleArena = ARENA.instantiate()
	finale.position = Vector2(283000, 0)
	finale.gate_left_x = 282200
	finale.gate_right_x = 283800
	finale.wave1 = _wave(ASSASSIN, KNIFE)
	finale.wave2 = _wave(ELITE, RIFLE)
	finale.wave3 = _wave(CHIEF)
	finale.reward = HEALTH
	add_child(finale)
	_dialogue(285300, "GAZELLE", "Anahtar bizde. Basınç normale dönüyor; İstanbul'un suyu kesilmeyecek.")
	_goal(286800, 0)


func _reward_path(x: float, pickup: PackedScene) -> void:
	# Eski üç basamaklı havada platform yerine mekâna uygun parkur sahnesi.
	_encounter(_next_kind(x), x - 40.0, pickup)


func _oneway(x: float, y: float, width: float) -> void:
	super._oneway(x, y, width)
	var platform := get_child(get_child_count() - 1)
	if x >= 96000 and x < 144000 or x >= 192000 and x < 240000:
		platform.set("style", "corridor")
	elif x >= 144000 and x < 192000 or x >= 240000:
		platform.set("style", "fortress")
	elif x >= 48000 and x < 96000:
		platform.set("style", "wood_shelf")
	elif x >= 24000:
		platform.set("style", "metal")


func _ground(x: float, width: float, surface_y := 0.0) -> void:
	_platform(x, surface_y + 200.0, width, 400.0)


class _FinalBackdrop extends Node2D:
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
		var cuts := [24000.0, 48000.0, 72000.0, 96000.0,
			120000.0, 144000.0, 168000.0, 192000.0,
			216000.0, 240000.0, 264000.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_scene(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_scene(scene: int, alpha: float) -> void:
		var atlas: Texture2D = APPROACH if scene < 4 else AQUEDUCT if scene < 8 else TOWER
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -600, 1920, 1200),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y - 4)),
			Color(1, 1, 1, alpha))

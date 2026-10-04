## Bölüm 12 — Karahanlı'nın iç kalesi ve Gazelle'in kurtarılması.
extends "res://scripts/systems/level12_redesign.gd"

const APPROACH := preload("res://assets/backgrounds/level13_final_approach_atlas.png")
const MIDDLE := preload("res://assets/backgrounds/level13_middle_atlas.png")
const LAST := preload("res://assets/backgrounds/level13_last_atlas.png")
const KARAHANLI := preload("res://scenes/enemies/Karahanli.tscn")
const GAZELLE := preload("res://scenes/characters/Gazelle.tscn")


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_FinalBackdrop.new())
	_intro("REDMOUNT", "Son kapı. Gazelle'i alıp buradan birlikte çıkacağız.")

	# İç nöbet: tek hedef, güvenli tırmanış, sonra iki düşmanlı karar.
	for i in 13:
		var surface := 65.0 if i == 3 or i == 6 or i == 10 else 0.0
		_ground(2000 + i * 4000, 4000, surface)
	_coin_line(480, 6, 210, -55)
	_pickup(PISTOL, 1050, -45)
	_pickup(AMMO, 1250, -45)
	_enemy(ELITE, 2200, 0)
	_oneway(3600, -85, 225)
	_oneway(3900, -170, 225)
	_oneway(4200, -255, 225)
	_oneway(4500, -170, 225)
	for i in 4:
		_bonus_coin(3700 + i * 260, -315, 5)
	_pickup(ARMOR, 4200, -315)
	_enemy(ASSASSIN, 5350, 0)
	_enemy(RIFLE, 6300, 0)
	_prop("vazo", 6760)
	_shop(7200, "İÇ NÖBET ERZAKI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(7800, 0)

	# Cephanelik: alçalan ana geçit; asma raflar riskli silah rotası.
	_coin_line(8400, 5, 560, 10)
	_oneway(8500, -30, 220)
	_oneway(8800, -115, 220)
	_moving(9150, -180, Vector2(0, -100), 190)
	_oneway(9500, -115, 220)
	for i in 5:
		_bonus_coin(8500 + i * 260, -255, 5)
	_pickup(RIFLE_PICKUP, 9150, -300)
	_enemy(ASSASSIN, 9400, 0)
	_enemy(RIFLE, 10500, 65)
	_enemy(ELITE, 11900, 0)
	_pickup(HEALTH, 13000, -45)
	_checkpoint(13500, 0)
	_arena(14300, 65, 13500, 15100, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, ELITE), AMMO)
	_coin_line(15300, 5, 175, -55)

	# Komuta arşivi: üst kayıt galerisi ödül verir; aşağıda açık dövüş alanı.
	_enemy(ASSASSIN, 17000, 0)
	_oneway(17500, -85, 220)
	_moving(17900, -145, Vector2(0, -115), 190)
	_oneway(18300, -250, 220)
	_oneway(18700, -165, 220)
	for i in 5:
		_bonus_coin(17500 + i * 290, -310, 5)
	_pickup(ARMOR, 18300, -310)
	_enemy(RIFLE, 19000, 0)
	_coin_line(19700, 5, 490, -55)
	_enemy(ELITE, 21200, 0)
	_enemy(ASSASSIN, 22600, 65)
	_pickup(HEALTH, 23200, 20)
	_checkpoint(23600, 65)
	_shop(24500, "ARŞİV REVİRİ", PackedStringArray(["can", "cephane", "tabanca"]))
	_hint(25300, "ÜST GALERİDE ERZAK VAR.\nALT GEÇİT AÇIK.")
	_oneway(26500, -85, 220)
	_oneway(26800, -170, 220)
	_oneway(27100, -255, 220)
	_oneway(27400, -170, 220)
	for i in 5:
		_bonus_coin(26500 + i * 235, -315, 5)
	_pickup(AMMO, 27100, -315)
	_enemy(RIFLE, 28600, 0)
	_enemy(ELITE, 30300, 0)
	_coin_line(30800, 5, 480, -55)
	_enemy(ASSASSIN, 31800, 0)
	_pickup(HEALTH, 32600, -45)
	_checkpoint(33400, 0)
	_arena(34200, 0, 33400, 35000, _wave(ELITE, RIFLE),
		_wave(ASSASSIN, ELITE, RIFLE), HEALTH)

	# Tören geçidi: son malzeme seçimi, sessiz yaklaşma, kapı muhafızları.
	_coin_line(35400, 5, 410, -55)
	_enemy(ASSASSIN, 37300, 0)
	_enemy(RIFLE, 38300, 0)
	_shop(39100, "TÖREN GEÇİDİ REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(39700, 0)
	_oneway(40500, -85, 220)
	_oneway(40800, -170, 220)
	_oneway(41100, -255, 220)
	_oneway(41400, -170, 220)
	for i in 5:
		_bonus_coin(40500 + i * 240, -310, 5)
	_pickup(ARMOR, 41100, -315)
	_enemy(ELITE, 41800, 65)
	_enemy(RIFLE, 42900, 65)
	_coin_line(43500, 5, 450, -55)
	_pickup(HEALTH, 44900, -45)
	_checkpoint(45600, 0)
	_arena(47400, 0, 46600, 48200, _wave(ELITE, ASSASSIN),
		_wave(ELITE, RIFLE, ASSASSIN), HEALTH)
	for i in range(13, 60):
		var surface := 75.0 if i in [16, 17, 26, 27, 38, 39, 48, 49, 55] else 0.0
		var width := 3800.0 if i in [18, 19, 31, 32, 46, 47] else 4000.0
		_ground(2000 + i * 4000, width, surface)
	_cistern_and_roofs()
	_barracks_and_cells()
	_palace_approach()

	# Boss: tuzaksız geniş taş zemin. Gazelle, Karahanlı'nın arkasında.
	_checkpoint(237100, 0)
	_pickup(HEALTH, 237400, -45)
	_dialogue(237750, "KARAHANLI", "Gazelle burada. Onu istiyorsan önce beni geçeceksin.")
	_enemy(KARAHANLI, 238500, 0)
	var gazelle := GAZELLE.instantiate()
	gazelle.position = Vector2(239500, 0)
	add_child(gazelle)
	_platform(239850, -220, 80, 440)


func _cistern_and_roofs() -> void:
	# 48–80 bin: sarnıçta alt yürüyüş yolu, yükselen bakım iskelesi ve kısa su hendeği.
	_dialogue(50900, "GAZELLE", "Beni daha içeride tutuyorlar. Sarnıçtaki su kapısı saray yoluna çıkıyor.")
	_enemy(BRUISER, 52800, 0)
	_coin_line(54000, 6, 460, -55)
	_oneway(56000, -85, 220)
	_oneway(56300, -170, 220)
	_moving(56700, -220, Vector2(0, -90), 190)
	_oneway(57100, -170, 220)
	for i in 5:
		_bonus_coin(56000 + i * 270, -300, 5)
	_pickup(ARMOR, 56700, -330)
	_enemy(ASSASSIN, 57800, 0)
	_enemy(RIFLE, 59500, 0)
	_checkpoint(61700, 0)
	_shop(62400, "SARNIÇ BAKIM ODASI", PackedStringArray(["can", "cephane", "zirh"]))
	_enemy(BRUISER, 64400, 75)
	_enemy(ASSASSIN, 65500, 75)
	_coin_line(66700, 5, 520, -55)
	_checkpoint(69000, 0)
	_arena(70300, 75, 69500, 71100, _wave(BRUISER, ASSASSIN),
		_wave(ELITE, RIFLE), HEALTH)
	_hint(73500, "SU HENDEĞİ: SIÇRA VEYA KÖPRÜYÜ KULLAN.")
	_checkpoint(74700, 0)
	_moving(76000, -55, Vector2(0, -70), 210)
	_coin_line(75200, 5, 350, -125)
	_enemy(RIFLE, 78900, 0)
	_pickup(HEALTH, 80500, -45)

	# 80–112 bin: kapak mekanizması, sonra açık seyir terasında yön değiştirme.
	_enemy(ELITE, 82500, 0)
	_oneway(84500, -85, 220)
	_oneway(84900, -170, 220)
	_moving(85400, -225, Vector2(190, 0), 190)
	_oneway(85900, -170, 220)
	for i in 5:
		_bonus_coin(84500 + i * 350, -290, 5)
	_pickup(AMMO, 85400, -305)
	_enemy(ASSASSIN, 86700, 0)
	_enemy(RIFLE, 88300, 0)
	_shop(90200, "SU KAPISI ERZAĞI", PackedStringArray(["can", "cephane", "tabanca"]))
	_checkpoint(90900, 0)
	_arena(92900, 0, 92100, 93700, _wave(ELITE, RIFLE),
		_wave(BRUISER, ASSASSIN), ARMOR)
	_coin_line(94700, 6, 440, -55)
	_enemy(ASSASSIN, 97200, 0)
	_enemy(ELITE, 99100, 0)
	_checkpoint(101000, 0)
	_oneway(102600, -85, 220)
	_oneway(102900, -170, 220)
	_oneway(103200, -255, 220)
	_oneway(103500, -170, 220)
	for i in 5:
		_bonus_coin(102600 + i * 240, -315, 5)
	_pickup(RIFLE_PICKUP, 103200, -315)
	_enemy(RIFLE, 105100, 0)
	_pickup(HEALTH, 107000, -45)
	_checkpoint(109000, 0)
	_arena(110300, 75, 109500, 111100, _wave(ASSASSIN, ELITE),
		_wave(RIFLE, BRUISER, ASSASSIN), HEALTH)


func _barracks_and_cells() -> void:
	# 112–144 bin: rüzgârlı seyir yolu; alt taş geçit, üst nöbet galerisi.
	_dialogue(113000, "REDMOUNT", "Şehrin ışıkları görünüyor. Gazelle hâlâ şu duvarların içinde.")
	_coin_line(114000, 6, 460, -55)
	_enemy(ASSASSIN, 116000, 0)
	_oneway(118000, -85, 220)
	_moving(118400, -140, Vector2(0, -120), 190)
	_oneway(118800, -255, 220)
	_oneway(119200, -170, 220)
	for i in 5:
		_bonus_coin(118000 + i * 300, -315, 5)
	_pickup(ARMOR, 118800, -315)
	_enemy(RIFLE, 120500, 0)
	_enemy(ELITE, 122000, 0)
	_checkpoint(125000, 0)
	_shop(125700, "SEYİR NÖBETİ", PackedStringArray(["can", "cephane", "zirh"]))
	_hint(127000, "KISA ÇATLAK: ÜST ASMA KÖPRÜ GÜVENLİ.")
	_moving(128000, -55, Vector2(0, -85), 210)
	_coin_line(127300, 5, 350, -125)
	_enemy(ASSASSIN, 130100, 0)
	_enemy(BRUISER, 132000, 0)
	_pickup(HEALTH, 134000, -45)
	_checkpoint(135000, 0)
	_arena(137000, 0, 136200, 137800, _wave(ELITE, ASSASSIN),
		_wave(ELITE, RIFLE, BRUISER), HEALTH)
	_coin_line(139000, 5, 460, -55)
	_enemy(RIFLE, 142000, 0)

	# 144–176 bin: kışla avlusu; bir düşmanı ayır, sonra çift yönlü pusu.
	_enemy(ELITE, 145000, 0)
	_oneway(147000, -85, 220)
	_oneway(147300, -170, 220)
	_oneway(147600, -255, 220)
	_oneway(147900, -170, 220)
	for i in 5:
		_bonus_coin(147000 + i * 240, -315, 5)
	_pickup(AMMO, 147600, -315)
	_enemy(ASSASSIN, 149000, 0)
	_enemy(RIFLE, 151000, 0)
	_checkpoint(153000, 0)
	_shop(154000, "KIŞLA REVİRİ", PackedStringArray(["can", "cephane", "zirh"]))
	_arena(156000, 75, 155200, 156800, _wave(BRUISER, ASSASSIN),
		_wave(ELITE, RIFLE, ASSASSIN), ARMOR)
	_coin_line(158000, 6, 440, -55)
	_enemy(ELITE, 160800, 0)
	_enemy(ASSASSIN, 163000, 0)
	_oneway(165000, -90, 220)
	_moving(165400, -145, Vector2(210, 0), 190)
	_oneway(166000, -200, 220)
	for i in 5:
		_bonus_coin(165000 + i * 285, -270, 5)
	_pickup(HEALTH, 166000, -260)
	_enemy(RIFLE, 168200, 0)
	_checkpoint(169500, 0)
	_arena(171000, 0, 170200, 171800, _wave(ELITE, RIFLE),
		_wave(BRUISER, ELITE, ASSASSIN), HEALTH)
	_coin_line(173000, 5, 450, -55)
	_enemy(ASSASSIN, 175000, 0)


func _palace_approach() -> void:
	# 176–208 bin: tutukevi kapıları ve saray mutfağı; Gazelle'in izi belirginleşir.
	_dialogue(177000, "GAZELLE", "Redmount! Sesini duyuyorum. Zincir kapısının ardındayım.")
	_enemy(BRUISER, 179000, 0)
	_coin_line(181000, 5, 470, -55)
	_oneway(183000, -85, 220)
	_oneway(183300, -170, 220)
	_moving(183700, -225, Vector2(0, -100), 190)
	_oneway(184100, -170, 220)
	for i in 5:
		_bonus_coin(183000 + i * 275, -305, 5)
	_pickup(ARMOR, 183700, -320)
	_enemy(ASSASSIN, 185000, 0)
	_checkpoint(185500, 0)
	_moving(188000, -55, Vector2(0, -80), 210)
	_coin_line(187300, 5, 350, -125)
	_enemy(RIFLE, 190000, 0)
	_shop(192000, "TUTUKEVİ DEPOSU", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(192700, 0)
	_arena(195000, 75, 194200, 195800, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, BRUISER, ELITE), HEALTH)
	_coin_line(197000, 6, 430, -55)
	_enemy(ASSASSIN, 200000, 0)
	_enemy(ELITE, 202000, 0)
	_pickup(HEALTH, 204000, -45)
	_checkpoint(205500, 0)

	# 208–240 bin: zincir kapısı, kısa son parkur, sessizlik ve boss öncesi mühimmat.
	_enemy(RIFLE, 209000, 0)
	_oneway(211000, -85, 220)
	_oneway(211300, -170, 220)
	_oneway(211600, -255, 220)
	_oneway(211900, -170, 220)
	for i in 5:
		_bonus_coin(211000 + i * 240, -315, 5)
	_pickup(RIFLE_PICKUP, 211600, -315)
	_enemy(BRUISER, 213500, 0)
	_enemy(ASSASSIN, 215000, 0)
	_shop(217000, "SARAY MUTFAĞI KİLERİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(217700, 0)
	_arena(218700, 0, 217900, 219500, _wave(ELITE, RIFLE),
		_wave(ELITE, BRUISER, ASSASSIN), HEALTH)
	_coin_line(222000, 5, 450, -55)
	_enemy(ASSASSIN, 224500, 0)
	_enemy(RIFLE, 226000, 0)
	_checkpoint(227000, 0)
	_shop(228000, "ZİNCİR KAPISI ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_arena(231000, 0, 230200, 231800, _wave(ELITE, ASSASSIN),
		_wave(RIFLE, BRUISER, ELITE), ARMOR)
	_coin_line(233000, 5, 460, -55)
	_pickup(AMMO, 235000, -45)
	_pickup(HEALTH, 236000, -45)


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
		var cuts := [12000.0, 26000.0, 38500.0, 52000.0,
			80000.0, 112000.0, 144000.0, 176000.0,
			192000.0, 208000.0, 228000.0, 236000.0]
		var scene := 0
		for cut in cuts:
			if x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < cuts.size() and x > cuts[scene] - 400.0:
			_draw_scene(scene + 1, clampf((x - cuts[scene] + 400.0) / 400.0, 0.0, 1.0))

	func _draw_scene(scene: int, alpha: float) -> void:
		if scene == 12:
			# Karahanlı düellosu da aynı Osmanlı taht salonunda geçer.
			scene = 11
		var atlas: Texture2D = APPROACH if scene < 4 else MIDDLE if scene < 8 else LAST
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		draw_texture_rect_region(atlas, Rect2(-960, -540, 1920, 900),
			Rect2(cell + Vector2(2, 2), Vector2(half.x - 4, half.y * 0.89)),
			Color(1, 1, 1, alpha))

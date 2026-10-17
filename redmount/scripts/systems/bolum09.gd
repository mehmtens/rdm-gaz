## Bölüm 9 — Zırhlı Üs (Kitap 1 / "Gazelle'in İzi").
##
## Dağ geçidini Karahanlı'nın zırhlı üssü kapatıyor. Redmount tünelden çıkınca
## Gazelle'i taşıyan aracın köprüden üsse girdiğini görür, çöken ip köprüyü ve nehir
## yatağını geçer, cephanelikte güçlendiricileri bulur (zırhlılar tek yumrukla
## düşmüyor), zırhlı avluyu temizler, surların tepesinde Gazelle'in üçüncü kapıdan
## içeri götürüldüğünü görür ve Binbaşı Kaya'yı yenerek geçidi açar.
extends DtmLevel

const MINIBOSS := preload("res://scenes/enemies/MiniBoss.tscn")
const POWERUP := preload("res://scenes/pickups/PowerupPickup.tscn")
const PU_DAMAGE := preload("res://resources/powerups/damage_x2.tres")
const PU_SHIELD := preload("res://resources/powerups/shield.tres")
const PU_SPEED := preload("res://resources/powerups/speed.tres")


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/level04_fortress_atlas.png")
	sky_cells = [[1, -100000.0], [2, 4500.0], [0, 8000.0]]
	sky_tint = Color(0.86, 0.84, 0.92)
	sky_shade = Color(0.04, 0.04, 0.08)
	back_row_on = false
	_night(Color(0.76, 0.76, 0.9))

	# --- 1. Tünel çıkışı: köprüde Gazelle'i taşıyan araç ---------------------------
	_terrain(-400, 1800, 0)
	_han_gate(-60, "TÜNEL")
	_story(-1.0, _sahne_gecit, 220.0)
	_powerup(560, -60, PU_DAMAGE)
	_enemy(BRUISER, 900, 0)
	_enemy(STREET, 1120, 0)
	_prop("varil", 1280)
	_prop("kasa", 1340)
	_lantern(400)
	_lantern(1500)

	# --- 2. Nehir yatağı: çöken ip köprü ----------------------------------------
	_checkpoint(1620, 0)
	_canal(1800, 2800, 160)
	_terrain(2700, 2800, 80)
	for k in 6:
		var cx := 1880.0 + k * 165.0
		_collapse(cx, -10.0, 145)
		_pickup(COIN, cx, -65.0)
	_moving(2150, -150, Vector2(380, 0), 140, 0.0)
	_pickup(HEALTH, 2340, -210)
	_terrain(2800, 4700, 0)
	_scaffold(2900, -110, 120)
	_scaffold(2900, -220, 120)
	_tower(3010, -310)
	_enemy(RIFLE, 3010, -310)

	# --- 3. Cephanelik: güçlendirici kasaları --------------------------------------
	_checkpoint(3260, 0)
	_story(3340, _sahne_cephanelik)
	# Cephanelik binası: içeri girince cephe açılır; güçlendirici kasaları içeride.
	_interior(3420, 4560, -345, [], 0)
	_sandbags(3460, 110)
	_crates(3700, 2, 1)
	_powerup(3745, -150, PU_SHIELD)
	_powerup(3835, -150, PU_SPEED)
	_enemy(BRUISER, 4050, 0)
	_enemy(RIFLE, 4250, 0)
	_sandbags(4150, 70)
	_prop("sandik", 4400, 0, AMMO)
	_prop("varil", 4500)

	# --- 4. Zırhlı avlu: kilitli arena; üs kantini --------------------------------
	_checkpoint(4620, 0)
	_terrain(4700, 9700, 0)
	_scaffold(5350, -170, 240)
	_powerup(5350, -220, PU_DAMAGE)
	_prop("varil", 5000)
	_prop("kasa", 5650)
	_lantern(4850)
	_lantern(5850)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(5350, 0)
	arena.gate_left_x = 4820
	arena.gate_right_x = 5900
	arena.floor_y = 0
	arena.wave1 = _wave(BRUISER, STREET, KNIFE)
	arena.wave2 = _wave(BRUISER, RIFLE, ELITE)
	arena.wave3 = _wave(BRUISER, BRUISER)
	arena.reward = HEALTH
	add_child(arena)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6100, 0)
	shop.title = "ÜS KANTİNİ"
	shop.items = PackedStringArray(["can", "zirh", "cephane"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Üs duvarları: kule tırmanışı; Gazelle surların tepesinde --------------
	_checkpoint(6320, 0)
	_crates(6450, 1, 1)
	_terrain(6540, 6900, -180)
	_enemy(KNIFE, 6750, -180)
	_scaffold(6960, -270, 130)
	_tower(7120, -360, 140)
	_enemy(RIFLE, 7120, -360)
	_coin_line(6580, 5, 70, -230)
	_pickup(ARMOR, 6960, -315)
	_story(7140, _sahne_surlar)
	_scaffold(7280, -250, 130)
	_scaffold(7410, -140, 130)
	_enemy(BRUISER, 7700, 0)
	_prop("vazo", 7850)

	# --- 6. Binbaşı Kaya; geçit açılır --------------------------------------------
	_checkpoint(8000, 0)
	_story(8060, _sahne_binbasi)
	_prop("varil", 8350)
	_prop("kasa", 8900)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(8650, 0)
	final.gate_left_x = 8180
	final.gate_right_x = 9120
	final.floor_y = 0
	final.wave1 = _wave(BRUISER, RIFLE)
	final.wave2 = _wave(MINIBOSS)
	final.wave3 = _wave(ELITE, BRUISER)
	final.reward = HEALTH
	add_child(final)
	_story(9200, _sahne_gecit_acildi)
	_han_gate(9450, "KUZEY GEÇİDİ")
	_goal(9450, 0)


func _powerup(x: float, y: float, res: PowerupConfig) -> void:
	var p := POWERUP.instantiate()
	p.set("powerup", res)
	p.position = Vector2(x, y)
	add_child(p)


# --- Hikâye sahneleri ----------------------------------------------------------

## Tünel çıkışı: karşı köprüden Gazelle'i taşıyan araç üsse girer.
func _sahne_gecit(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(60, 0))
	await cs.pan(Vector2(400, -200), 0.01)
	await cs.move("rm", 220, 0.9, "walk")
	await cs.say("rm", "REDMOUNT", "Dağ geçidi. Rüzgâr bıçak gibi. Karşıda... bir üs.")
	cs.actor("bus", "bus", Vector2(700, 0), 1)
	await cs.pan(Vector2(1100, -220), 0.8)
	cs.move("bus", 2400, 3.2, "", false)
	await cs.wait(0.6)
	await cs.say("bus", "GAZELLE", "Üçüncü kapı! Redmount, ÜÇÜNCÜ KAPI!", 1.8)
	await cs.say("bus", "ZIRHLI ŞOFÖR", "Bağırma! Bu dağda seni rüzgârdan başka duyan yok.", 1.8)
	await cs.pan(Vector2(400, -200), 0.7)
	await cs.say("rm", "REDMOUNT", "Rüzgâr duydu, ben de duydum. Üçüncü kapı bu üssün içinde.")
	await cs.say("rm", "REDMOUNT", "Zırhlılar tek yumrukla düşmez. Şu kasadaki çift güç işime yarar.")


## Cephanelik: güçlendirici kasaları ve Binbaşı'nın anonsu.
func _sahne_cephanelik(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("ann", "voice", Vector2(p.x + 450, -330))
	await cs.pan(Vector2(p.x + 350, -220), 0.5)
	await cs.say("ann", "BİNBAŞI KAYA (hoparlör)", "Cephaneliğe girildi! Zırhlı takım, kasaları korumaya!")
	await cs.say("rm", "REDMOUNT", "Kasalarda kalkan ve hız iğneleri... Karahanlı adamlarını iyi donatmış.")
	await cs.say("rm", "REDMOUNT", "Bugün donatım benden yana.")


## Surların tepesi: Gazelle üçüncü kapıdan içeri götürülür.
func _sahne_surlar(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", Vector2(p.x + 640, -360), -1)
	cs.actor("b1", "bruiser", Vector2(p.x + 720, -360), -1)
	cs.pose("gz", "bound_idle")
	await cs.pan(Vector2(p.x + 360, -380), 0.7)
	await cs.say("gz", "GAZELLE", "Redmount! Buradayım! Üçüncü kapı bu, arkasında kalenin surları!")
	await cs.say("rm", "REDMOUNT", "Gördüm seni! Kıpırdama, geliyorum!")
	await cs.say("b1", "ZIRHLI MUHAFIZ", "Kapıyı aç. Kız artık kalenin malı.")
	cs.face("gz", 1)
	cs.face("b1", 1)
	cs.move("b1", p.x + 900, 0.8, "walk", false)
	await cs.struggle("gz", p.x + 860, 2)
	cs.fade_out("b1", 0.4)
	await cs.fade_out("gz", 0.5)
	await cs.say("rm", "REDMOUNT", "Üçüncü kapı kapandı. Ama kale bir duvardan ibaret değil.")


## Binbaşı Kaya: geçidin bekçisi.
func _sahne_binbasi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("bk", "elite", Vector2(8600, 0), -1)
	cs.actor("b1", "bruiser", Vector2(8740, 0), -1)
	await cs.pan(Vector2(8380, -200), 0.7)
	await cs.say("bk", "BİNBAŞI KAYA", "Tüneli geçtin, köprüyü geçtin, cephaneliğimi soydun. Takdir ederim.")
	await cs.say("bk", "BİNBAŞI KAYA", "Ama bu geçit yirmi yıldır kapalı. Benim zırhım da öyle.")
	await cs.say("rm", "REDMOUNT", "Yirmi yıl yeter. Aç şu kapıyı.")
	cs.move("b1", 9100, 0.6, "walk", false)
	await cs.move("bk", 9050, 0.6, "walk")
	cs.remove("bk")
	cs.remove("b1")


## Geçit açıldı: karşıda kalenin kuzey surları.
func _sahne_gecit_acildi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	await cs.pan(Vector2(9380, -240), 0.6)
	await cs.say("rm", "REDMOUNT", "Geçit açıldı. Kalenin kuzey surları tam karşımda.")
	await cs.say("rm", "REDMOUNT", "Ana kapıyı tutmuşlardır. Kör noktadan tırmanacağım.")

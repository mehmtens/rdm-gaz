## Bölüm 33 — Vaniköy Gece Sevkiyatı (Kitap 3 / "İstanbul'un Sesi", 9. bölüm).
##
## Nüzhet'in teknesi Vaniköy iskelesine yanaşmış; yük boşaltılmış. Vaniköy
## iskelesi -> yalı sırası (balkonlar) -> kayık tezgâhı (arena) -> kasa yığınları
## (sandık basamakları, seçkin) -> vinç rıhtımı (palet) -> yükleme hattı (erzak,
## çöken iskele) -> kasa ambarı (boş kasalar, arena) -> kablo kapısı (son arena).
## Kasalar boş: verici parçaları kablolarla Kandilli sırtına taşınmış.
extends DtmLevel

const SHORE := preload("res://assets/backgrounds/book03_vanikoy_shore_atlas.png")
const CARGO := preload("res://assets/backgrounds/book03_vanikoy_cargo_atlas.png")


func _build() -> void:
	sky_atlas = SHORE
	sky_cells = [[0, -100000.0], [1, 1500.0], [2, 3000.0], [3, 4300.0],
		[0, 5600.0, CARGO], [1, 7000.0, CARGO], [2, 8300.0, CARGO], [3, 9500.0, CARGO]]
	sky_tint = Color(0.86, 0.86, 0.96)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_row_skip = [[5500.0, 9400.0]]
	_night(Color(0.74, 0.76, 0.94))

	# --- 1. Vaniköy iskelesi -------------------------------------------------
	_terrain(-400, 10300, 0)
	_story(-1.0, _sahne_iskele, 240.0)
	_lantern(300)
	_lantern(1100)
	_enemy(KNIFE, 850, 0)
	_enemy(STREET, 1050, 0)

	# --- 2. Yalı sırası: balkonlar -------------------------------------------
	_checkpoint(1300, 0)
	_balcony(1500, -70, 110)
	_balcony(1660, -170, 110)
	_balcony(1820, -270, 110)
	_pickup(ARMOR, 1820, -315)
	_coin_line(1460, 5, 70, -330)

	# --- 3. Kayık tezgâhı: arena ----------------------------------------------
	_checkpoint(2100, 0)
	var kayik: BattleArena = ARENA.instantiate()
	kayik.position = Vector2(2750, 0)
	kayik.gate_left_x = 2350
	kayik.gate_right_x = 3150
	kayik.floor_y = 0
	kayik.wave1 = _wave(STREET, KNIFE, ASSASSIN)
	kayik.wave2 = _wave(RIFLE, BRUISER)
	kayik.reward = AMMO
	add_child(kayik)

	# --- 4. Kasa yığınları: basamaklar, seçkin ------------------------------
	_checkpoint(3300, 0)
	_crates(3450, 1, 1)
	_crates(3540, 1, 2)
	_crates(3630, 2, 3)
	_crates(3810, 1, 2)
	_crates(3900, 1, 1)
	_enemy(ELITE, 4150, 0)
	_pickup(PISTOL, 3720, -315)
	_coin_line(3480, 6, 80, -330)

	# --- 5. Vinç rıhtımı: palet --------------------------------------------
	_checkpoint(4400, 0)
	_canal(4550, 4750, 110)
	_scaffold(4650, -20, 220)
	_crates(4850, 1, 1)
	_scaffold(5010, -150, 120)
	_moving(5200, -240, Vector2(300, 0), 140, 0.0)
	_scaffold(5620, -240, 120)
	_pickup(RIFLE_PICKUP, 5620, -285)
	_enemy(BRUISER, 5400, 0)

	# --- 6. Yükleme hattı: erzak, çöken iskele -------------------------------
	_checkpoint(5850, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6050, 0)
	shop.title = "YÜKLEME KİLERİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)
	_crates(6300, 1, 1)
	_crates(6390, 1, 2)
	for k in 3:
		_collapse(6550.0 + k * 140.0, -180.0, 130)
		_pickup(COIN, 6550.0 + k * 140.0, -235.0)
	_crates(6900, 1, 1)

	# --- 7. Kasa ambarı: boş kasalar, arena ----------------------------------
	_checkpoint(7150, 0)
	_story(7230, _sahne_bos)
	var amb: BattleArena = ARENA.instantiate()
	amb.position = Vector2(7850, 0)
	amb.gate_left_x = 7450
	amb.gate_right_x = 8250
	amb.floor_y = 0
	amb.wave1 = _wave(ELITE, KNIFE, RIFLE)
	amb.wave2 = _wave(ELITE, BRUISER)
	amb.reward = HEALTH
	add_child(amb)

	# --- 8. Kablo kapısı: son arena -----------------------------------------
	_checkpoint(8400, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9000, 0)
	final.gate_left_x = 8600
	final.gate_right_x = 9400
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN, RIFLE)
	final.wave2 = _wave(ELITE, RIFLE)
	final.wave3 = _wave(BRUISER, BRUISER)
	final.reward = HEALTH
	add_child(final)
	_story(9500, _sahne_kablo)
	_han_gate(9800, "KANDİLLİ")
	_goal(9800, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Vaniköy iskelesi: tekne boş.
func _sahne_iskele(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Tekne iskelede ama içi boş. Nüzhet yok, yük yok.")
	await cs.say("rm", "REDMOUNT", "Kasaların izi rıhtım boyunca yükleme hattına gidiyor. Gece vardiyası sürüyor.")


## Kasa ambarı: boş kasalar.
func _sahne_bos(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Kasalar boş... Talaş ve kablo artıkları. Verici parçaları çıkarılmış.")
	await cs.say("rm", "REDMOUNT", "Kablolar duvardan çıkıp yokuşa tırmanıyor.")


## Kablo kapısı: Kandilli.
func _sahne_kablo(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(9650, -220), 0.6)
	await cs.say("gz", "GAZELLE", "Kablolar evlerin üstünden Kandilli sırtına çıkıyor. Orada bir verici kurmuşlar.")
	await cs.say("gz", "GAZELLE", "Verici çalışırsa şehrin bütün yayınları bastırılır. Sadece Nüzhet'in sesi kalır.")
	await cs.say("rm", "REDMOUNT", "O zaman sırta. Çatı çatı.")

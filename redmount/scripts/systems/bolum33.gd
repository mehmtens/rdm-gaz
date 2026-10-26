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
	back_row_skip = [[1450.0, 2150.0], [7300.0, 9400.0]]
	chimney_rack = true  # verici odası / kasa ambarı resmi: taş kule yabancı
	_night(Color(0.74, 0.76, 0.94))

	# --- 1. Vaniköy iskelesi -----------------------------------------------------
	_terrain(-400, 4550, 0)
	_story(-1.0, _sahne_iskele, 240.0)
	_lantern(300)
	_lantern(1100)
	_enemy(KNIFE, 850, 0)
	_enemy(STREET, 1050, 0)
	_prop("varil", 1200)

	# --- 2. Yalı: iki katlı ahşap yalı, katlardan geçiş --------------------------
	_checkpoint(1300, 0)
	_interior(1450, 2150, -230, [-115.0], 1)
	_enemy(SHIELD, 1750, 0)
	_enemy(STREET, 1950, -115)
	_pickup(ARMOR, 2080, -160)
	_coin_line(1500, 5, 50, -160)
	_coin_line(1550, 6, 90, -280)

	# --- 3. Kayık tezgâhı: arena (ortada kayık kızağı) ---------------------------
	_checkpoint(2250, 0)
	_scaffold(2750, -110, 220)
	_coin_line(2680, 4, 45, -160)
	_fight(2350, 3150, _wave(STREET, KNIFE, ASSASSIN), _wave(RIFLE, BRUISER), [], AMMO)

	# --- 4. Kasa dağı: basamak basamak, tepede seçkin; aralarda cep -----------------
	_checkpoint(3300, 0)
	_crates(3450, 1, 1)
	_crates(3540, 1, 2)
	_crates(3630, 2, 3)
	_crates(3810, 1, 2)
	_crates(3990, 1, 2)
	_crates(4080, 1, 1)
	_prop("sandik", 3945, 0, HEALTH)
	_enemy(ELITE, 3720, -270)
	_pickup(PISTOL, 3990, -225)
	_coin_line(3480, 6, 80, -330)
	_enemy(KNIFE, 4300, 0)

	# --- 5. Vinç rıhtımı: geniş havuz, iki palet ve kazık --------------------------
	_checkpoint(4400, 0)
	_canal(4550, 5250, 110)
	_scaffold(4640, -20, 140)
	_moving(4830, -150, Vector2(150, 0), 130, 0.0)
	_scaffold(5100, -20, 140)
	_moving(5200, -260, Vector2(0, 110), 120, 0.5)
	_coins_arc(4700, 8, 60, -320)
	_terrain(5250, 6350, 0)
	_scaffold(5500, -150, 120)
	_scaffold(5650, -260, 120)
	_pickup(RIFLE_PICKUP, 5650, -305)
	_enemy(BRUISER, 5850, 0)

	# --- 6. Yükleme hattı: erzak, çivili ambar ağzı üstünde çürük tahtalar ------------
	_checkpoint(6000, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6150, 0)
	shop.title = "YÜKLEME KİLERİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)
	_spike_pit(6350, 6510)
	for k in 2:
		_collapse(6400.0 + k * 100.0, -80.0, 90)
		_pickup(COIN, 6400.0 + k * 100.0, -130.0)
	_terrain(6510, 10300, 0)
	_crates(6700, 1, 1)
	_crates(6790, 1, 2)
	_scaffold(6950, -230, 140)
	_coin_line(6900, 3, 50, -280)

	# --- 7. Kasa ambarı: boş kasalar; galerili ambarda arena ---------------------
	_checkpoint(7200, 0)
	_story(7250, _sahne_bos)
	_pickup(HEALTH, 7320, -45)
	_interior(7350, 8250, -345, [], 0)
	_scaffold(7520, -115, 180)
	_scaffold(8080, -115, 180)
	_scaffold(7800, -230, 220)
	_coin_line(7730, 4, 45, -280)
	_fight(7400, 8200, _wave(ELITE, KNIFE, BOMBER), _wave(ELITE, BRUISER))

	# --- 8. Kablo kapısı: kablo direklerinin dibinde nöbetçiler ----------------------
	_checkpoint(8400, 0)
	_antenna(8700, 0, 4.0)
	_antenna(9300, 0, 4.0)
	_sandbags(8650, 100)
	_enemy(BOMBER, 8950, 0)
	_enemy(KNIFE, 9100, 0)
	_enemy(ASSASSIN, 9250, 0)
	_story(9500, _sahne_kablo)
	_han_gate(9800, "KANDİLLİ")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2450, "gazelle", "GAZELLE", "Vaniköy. Tekne boş, kasalar boş.")
	_radio(5390, "redmount", "REDMOUNT", "Kablolar yokuşa tırmanıyor. Verici yukarıda.")
	_radio(8330, "gazelle", "GAZELLE", "Kandilli sırtı. Verici çalışırsa şehirde tek ses kalır.")
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

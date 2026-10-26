## Bölüm 35 — Anadoluhisarı Kale İçi (Kitap 3 / "İstanbul'un Sesi", 11. bölüm).
##
## Yayının kumandası Anadoluhisarı'nın surları içinde. Göksu kıyısı (taş köprü) ->
## dış sur yolu (kuleler) -> sur kapısı (arena) -> kale avlusu (burç tırmanışı,
## erzak) -> kışla koridoru (arena) -> kumanda odası (anahtar; Nüzhet'in kaydı) ->
## iç surlar (son arena). Kumanda anahtarı alınır; son yayın istasyonu Göksu'da
## demirli mavna. Nüzhet oraya geçmiş; Yayın Şefi mavnayı koruyor.
extends DtmLevel

const OUTER := preload("res://assets/backgrounds/book03_anadoluhisari_outer_atlas.png")
const INNER := preload("res://assets/backgrounds/book03_anadoluhisari_inner_atlas.png")
const MINIBOSS := preload("res://scenes/enemies/MiniBoss.tscn")


func _build() -> void:
	sky_atlas = OUTER
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3100.0], [0, 4400.0, INNER],
		[1, 5800.0, INNER], [3, 7000.0, INNER], [2, 8300.0], [3, 9600.0]]
	sky_tint = Color(0.86, 0.86, 0.96)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_row_skip = [[2300.0, 10300.0]]
	_night(Color(0.74, 0.76, 0.94))

	# --- 1. Göksu kıyısı: taş köprü ---------------------------------------------
	_terrain(-400, 1600, 0)
	_story(-1.0, _sahne_kiyi, 240.0)
	_lantern(300)
	_enemy(KNIFE, 900, 0)
	_enemy(STREET, 1100, 0)
	_canal(1600, 1800, 110)
	_scaffold(1700, -20, 220)

	# --- 2. Dış sur: kuleden gözcü, basamak taşlarla sur sırtına -----------------
	_terrain(1800, 3700, 0)
	_checkpoint(1950, 0)
	_tower(2250, -260, 110)
	_enemy(RIFLE, 2250, -260)
	_scaffold(2040, -95, 100)
	_scaffold(2140, -185, 100)
	_rampart(2400, 2490, -90, true, false)
	_rampart(2490, 2580, -180, true, false)
	_rampart(2580, 3300, -270)
	_enemy(KNIFE, 2850, -270)
	_enemy(RIFLE, 3200, -270)
	_coin_line(2620, 8, 80, -320)
	_pickup(ARMOR, 3240, -315)
	for fx in [2700.0, 3150.0]:
		_fg("sarmasik", fx, -640.0)

	# --- 3. Hendek: çivili çukur, üstünde iki çürük köprü tahtası -----------------
	_lantern(3500)
	_spike_pit(3700, 3860)
	for k in 2:
		_collapse(3745.0 + k * 100.0, -60.0, 90)
	_coin_line(3730, 3, 60, -120)
	_terrain(3860, 10300, 0)

	# --- 4. Sur kapısı: arena -----------------------------------------------------
	_checkpoint(4000, 0)
	_scaffold(4500, -110, 200)
	_coin_line(4430, 4, 45, -160)
	_fight(4100, 4900, _wave(ELITE, KNIFE, ASSASSIN), _wave(RIFLE, BRUISER), [], AMMO)

	# --- 5. Kale avlusu: burç bacası (duvar-zıplama), erzak -------------------------
	_checkpoint(5050, 0)
	_chimney(5350, -560, 140, 150, RIFLE_PICKUP)
	_enemy(ELITE, 5650, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5950, 0)
	shop.title = "HİSAR KİLERİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 6. Kışla: galerili koğuşta arena (seçkinler, sonra Yüzbaşı) -----------------
	_checkpoint(6200, 0)
	_interior(6300, 7200, -345, [], 0)
	_scaffold(6470, -115, 180)
	_scaffold(7030, -115, 180)
	_scaffold(6750, -230, 220)
	_coin_line(6680, 4, 45, -280)
	_fight(6350, 7150, _wave(ELITE, ELITE), _wave(MINIBOSS, SHIELD), [], HEALTH)

	# --- 7. Kumanda odası: pres hattı, anahtar --------------------------------------
	_checkpoint(7350, 0)
	_press(7600, 0.0, 3.0)
	_press(7950, 1.5, 3.0)
	_coin_line(7570, 5, 90, -60)
	_story(8150, _sahne_kumanda)
	_pickup(HEALTH, 8250, -45)

	# --- 8. İç sur sırtı: son yürüyüş, nöbetçiler -----------------------------------
	_checkpoint(8400, 0)
	_rampart(8550, 8640, -90, true, false)
	_rampart(8640, 8730, -180, true, false)
	_rampart(8730, 9360, -270)
	_enemy(RIFLE, 9000, -270)
	_enemy(ELITE, 9250, -270)
	_coin_line(8770, 7, 80, -320)
	_enemy(SHIELD, 9500, 0)
	_story(9650, _sahne_mavna)
	_han_gate(9950, "GÖKSU")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2487, "gazelle", "GAZELLE", "Altı yüz yıllık surlar bir radyo kumandasını koruyor.")
	_radio(5472, "redmount", "REDMOUNT", "Kumanda anahtarı burada. Bu kez kale bizim tarafımızda.")
	_radio(8457, "telsiz", "NÜZHET HANIM (kayıt)", "Mavnada kendi jeneratörüm var. Durduramazsınız.")
	_goal(9950, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Göksu kıyısı: hisar.
func _sahne_kiyi(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Anadoluhisarı. Altı yüz yıllık surlar, bir radyo kumandasını koruyor.")
	await cs.say("rm", "REDMOUNT", "Surlar hiç bu kadar küçük bir şeyi korumamıştı.")
	await cs.say("gz", "GAZELLE", "Küçük değil. Bir şehrin sesini.")


## Kumanda odası: anahtar ve Nüzhet'in kaydı.
func _sahne_kumanda(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("nz", "voice", Vector2(p.x + 250, -200))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("rm", "REDMOUNT", "Kumanda anahtarı. Bununla ana yayının üç bağlantısı açılıp kapanıyor.")
	await cs.say("nz", "NÜZHET HANIM (masadaki kayıt)", "Anahtarı aldıysanız tebrikler. Ama mavnada kendi jeneratörüm var. Sabah yayını oradan yapılacak.")
	await cs.say("nz", "NÜZHET HANIM", "Yayın Şefi'm mavnayı koruyor. O, benim sesimin eli. Durduramazsınız.")
	cs.pose("gz", "rescue_react")
	await cs.say("gz", "GAZELLE", "Durdurmayacağız. Ele geçireceğiz. Kendi kayıtlarımızı, onun mikrofonundan okuyacağım.")


## İç surlar: mavna.
func _sahne_mavna(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(9850, -220), 0.6)
	await cs.say("gz", "GAZELLE", "Surların ötesinde, Göksu'da demirli mavna. Antenleri ışıklı.")
	await cs.say("rm", "REDMOUNT", "Üç bağlantı, bir jeneratör, bir Yayın Şefi. Son yürüyüş.")
	await cs.say("gz", "GAZELLE", "Balat'tan beri hep son yürüyüş diyorsun.")
	await cs.say("rm", "REDMOUNT", "Bu sefer gerçekten. Sonra simit.")

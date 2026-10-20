## Bölüm 34 — Kandilli Verici Sırtı (Kitap 3 / "İstanbul'un Sesi", 10. bölüm).
##
## Kablolar evlerin üstünden Kandilli sırtındaki vericiye tırmanıyor. Yokuş başı
## -> çatı çatı kablo yolu (evler, çöken tahta) -> bahçe merdiveni (arena) ->
## sırt yolu (kuleler, projektörler) -> verici avlusu (erzak) -> jeneratör odası
## (pistonlar, arena) -> verici direği (kırılır) -> sırt terası (son arena).
## Verici susar; kumanda Anadoluhisarı surlarının içinde. Nüzhet radyodan konuşur.
extends DtmLevel

const RIDGE := preload("res://assets/backgrounds/book03_kandilli_ridge_atlas.png")
const TRANSMITTER := preload("res://assets/backgrounds/book03_kandilli_transmitter_atlas.png")


func _build() -> void:
	sky_atlas = RIDGE
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3200.0], [3, 4600.0],
		[0, 5900.0, TRANSMITTER], [2, 7100.0, TRANSMITTER], [1, 8300.0, TRANSMITTER], [3, 9400.0, TRANSMITTER]]
	sky_tint = Color(0.86, 0.86, 0.96)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_row_skip = [[7350.0, 8050.0]]
	_night(Color(0.74, 0.76, 0.94))

	# --- 1. Yokuş: basamaklı Kandilli sokağı, sahanlıkta kavga ------------------
	_terrain(-400, 650, 0)
	_story(-1.0, _sahne_yokus, 240.0)
	_lantern(300)
	for k in 5:
		_terrain(650.0 + k * 100.0, 750.0 + k * 100.0, -40.0 * (k + 1))
	_terrain(1150, 1360, -200)
	_lantern(1250, -370)
	_enemy(STREET, 1250, -200)
	_coins_arc(700, 6, 80, -300)
	for vx in [420.0, 900.0]:
		_fg("sarmasik", vx, -620.0)

	# --- 2. Çatı çatı kablo yolu: evler, çürük tahta, balkonlar ---------------------
	var h1 := _house(1360, -280, 0)
	_terrain(1360, 10300, 0)
	_collapse(h1 + 70, -280, 130)
	_balcony(h1 + 150, -130, 80)
	_balcony(h1 + 150, -215, 80)
	var h2 := _house(h1 + 200, -300, 1)
	_balcony(h2 + 45, -130, 90)
	_balcony(h2 + 115, -225, 90)
	var h3 := _house(h2 + 160, -320, 2)
	_coin_line(1410, 4, 60, -330)
	_coin_line(h2 - 160, 3, 50, -350)
	_coin_line(h3 - 200, 4, 50, -370)
	_enemy(KNIFE, h2 - 100, -300)
	_enemy(RIFLE, h3 - 60, -320)
	_pickup(ARMOR, h3 - 140, -365)
	_prop("vazo", h1 - 120, -280)

	# --- 3. Bahçe sekileri: kilitsiz kavga, sarmaşıklar ------------------------
	var bx := h3 + 150.0
	_checkpoint(bx, 0)
	_stones(bx + 250, 2, 1)
	_stones(bx + 600, 3, 1)
	_scaffold(bx + 735, -200, 160)
	_coin_line(bx + 680, 3, 50, -250)
	_enemy(SHIELD, bx + 450, 0)
	_enemy(ASSASSIN, bx + 560, 0)
	_enemy(STREET, bx + 950, 0)
	for vx in [bx + 300.0, bx + 800.0]:
		_fg("sarmasik", vx, -620.0)

	# --- 4. Sırt yolu: kuleler, projektörler, antenler ------------------------------
	var sx := bx + 1150.0
	_checkpoint(sx, 0)
	_antenna(sx + 350, 0, 3.0)
	_sandbags(sx + 250, 110)
	_scaffold(sx + 500, -110, 120)
	_scaffold(sx + 500, -220, 120)
	_tower(sx + 620, -320)
	_enemy(RIFLE, sx + 620, -320)
	_pickup(PISTOL, sx + 500, -265)
	_scaffold(sx + 760, -200, 120)
	_scaffold(sx + 860, -100, 120)
	_enemy(BRUISER, sx + 1100, 0)

	# --- 5. Verici avlusu: erzak, Nüzhet radyoda -----------------------------------
	_checkpoint(5900, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6100, 0)
	shop.title = "SIRT KANTİNİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)
	_story(6350, _sahne_radyo)

	# --- 6. Pres hattı, sonra iki katlı jeneratör binası ------------------------
	_checkpoint(6550, 0)
	_press(6750, 0.0, 2.6)
	_press(6980, 0.6, 2.6)
	_press(7210, 1.2, 2.6)
	_coin_line(6720, 6, 92, -60)
	_interior(7400, 8000, -230, [-115.0], 0)
	_enemy(KNIFE, 7600, 0)
	_enemy(ELITE, 7850, -115)
	_pickup(HEALTH, 7950, -160)
	_coin_line(7450, 5, 60, -160)
	_coin_line(7450, 6, 90, -280)

	# --- 7. Verici direği: kır --------------------------------------------
	_checkpoint(8100, 0)
	_enemy(BOMBER, 8300, 0)
	var mast := _Art.new(_Art.A_TOWER, Vector2(90, 380))
	mast.position = Vector2(8700, -190)
	mast.z_index = -6
	add_child(mast)
	_antenna(8780, -380, 2.0)
	var verici := BREAKABLE_WALL.instantiate()
	verici.set("hits_to_break", 7)
	verici.position = Vector2(8640, 0)
	add_child(verici)
	var sign := _Sign.new()
	sign.text = "KANDİLLİ VERİCİSİ"
	sign.position = Vector2(8640, -300)
	add_child(sign)

	# --- 8. Sırt terası: son arena ------------------------------------------
	_checkpoint(8900, 0)
	_fight(9000, 9600, _wave(KNIFE, ASSASSIN, BOMBER), _wave(ELITE, ELITE))
	_story(9700, _sahne_hisar)
	_han_gate(9950, "ANADOLUHİSARI")
	# Çevresel tehlikeler.
	_live_wire(6300, 6460, 0.4)
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2487, "telsiz", "NÜZHET HANIM (radyo)", "İstanbul, yarın sabah gerçekleri size ben okuyacağım.")
	_radio(5472, "gazelle", "GAZELLE", "Annemi bana karşı kullanıyor... Devam edelim.")
	_radio(8457, "redmount", "REDMOUNT", "Verici sustu. Kumanda Anadoluhisarı'nda.")
	_goal(9950, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Yokuş başı.
func _sahne_yokus(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Kablolar çatıların üstünden gidiyor. Biz de öyle gideceğiz.")
	await cs.say("rm", "REDMOUNT", "Balat'taki gibi. Tenteden çatıya. Bu kez yanımdasın.")
	await cs.say("gz", "GAZELLE", "Bu kez minibüse binen yok.")


## Verici avlusu: Nüzhet radyoda.
func _sahne_radyo(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("nz", "voice", Vector2(p.x + 300, -260))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("nz", "NÜZHET HANIM (radyo, test yayını)", "İstanbul, iyi akşamlar. Yarın sabah size gerçekleri ben okuyacağım. Yalnız ben.")
	await cs.say("nz", "NÜZHET HANIM", "Gazeteci Gazelle'i görenler... ona annesini sorsun.")
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Annemi bana karşı kullanıyor...")
	await cs.say("rm", "REDMOUNT", "Çünkü korkuyor. Annenin dosyası artık bizde. Vericiyi susturalım.")


## Sırt terası: kumanda Anadoluhisarı'nda.
func _sahne_hisar(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(9850, -220), 0.6)
	await cs.say("gz", "GAZELLE", "Verici sustu! Ama ana kablo aşağıya, Anadoluhisarı surlarına iniyor.")
	await cs.say("rm", "REDMOUNT", "Kumanda orada. Onu almadan susturma planı durmaz.")
	await cs.say("gz", "GAZELLE", "Bir kale daha. Kalelerle aram iyi değil, biliyorsun.")
	await cs.say("rm", "REDMOUNT", "Biliyorum. Bu sefer içeriden değil, dışarıdan giriyorsun. Benimle.")

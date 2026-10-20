## Bölüm 27 — Galata Telgrafı (Kitap 3 / "İstanbul'un Sesi", 3. bölüm).
##
## Asıl emirler Galata telgrafından yayılıyor. Karaköy kıyısı -> köprübaşı (arena)
## -> yokuş sokak (balkon/çatı) -> telgraf binası cephesi (tüfekliler, kablo
## direkleri) -> mors salonu (erzak) -> kablo koridoru (arena) -> arşiv odası ->
## çatı direkleri (son arena). Hat kesilir; Kâtip'in son telgrafı yedek röleyi ele
## verir: Üsküdar. Komiser Rıfat makbuzu kontrol eder, Gazelle'e bir gün süre verir.
extends DtmLevel

const STREETS := preload("res://assets/backgrounds/book03_galata_streets_atlas.png")
const TELEGRAPH := preload("res://assets/backgrounds/book03_galata_telegraph_atlas.png")


func _build() -> void:
	sky_atlas = STREETS
	sky_cells = [[0, -100000.0], [2, 1700.0], [1, 3200.0], [3, 4700.0],
		[0, 6000.0, TELEGRAPH], [1, 7300.0, TELEGRAPH], [2, 8600.0, TELEGRAPH], [3, 9700.0, TELEGRAPH]]
	sky_tint = Color(0.96, 0.94, 0.9)
	sky_shade = Color(0.08, 0.06, 0.05)
	back_row_skip = [[5900.0, 9600.0]]

	# --- 1. Karaköy kıyısı: balıkçı tezgâhları, balkonla zırha -----------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_kiyi, 240.0)
	_lantern(150)
	_stall(620)
	_fg("kolon", 420.0, 40.0, 380.0)
	_enemy(KNIFE, 900, 0)
	_enemy(STREET, 1080, 0)
	_prop("saksi", 1150)
	_balcony(1300, -70, 110)
	_balcony(1460, -170, 110)
	_balcony(1300, -270, 110)
	_pickup(ARMOR, 1300, -315)
	_coin_line(1420, 3, 45, -220)

	# --- 2. Köprübaşı: alçak meydanda arena (orta iskele) -----------------------
	_checkpoint(1650, 0)
	_terrain(1700, 1850, 30)
	_terrain(1850, 3100, 60)
	_scaffold(2450, -50, 200)
	_coin_line(2380, 4, 45, -100)
	_fight(2000, 2900, _wave(STREET, KNIFE, ASSASSIN), _wave(RIFLE, BRUISER), [], AMMO, 60.0)
	_terrain(3100, 3250, 30)

	# --- 3. Kamondo merdivenleri: basamak basamak yokuş, sahanlıkta kavga ------
	_checkpoint(3300, 0)
	_terrain(3250, 3380, 0)
	for k in 4:
		_terrain(3380.0 + k * 110.0, 3490.0 + k * 110.0, -45.0 * (k + 1))
		if k % 2 == 1:
			_prop("saksi", 3420.0 + k * 110.0, -45.0 * (k + 1))
	_terrain(3820, 4150, -180)
	_lantern(3700, -330)
	_enemy(KNIFE, 3950, -180)
	_enemy(STREET, 4080, -180)
	_coins_arc(3400, 6, 70, -260)

	# --- 4. Çatı yolu: sahanlıktan evlerin damına, aşağı sokağa iniş ------------
	var h1 := _house(4150, -270, 0)
	_balcony(h1 + 45, -150, 90)
	_balcony(h1 + 115, -230, 90)
	var h2 := _house(h1 + 160, -310, 1)
	_enemy(RIFLE, h2 - 80, -310)
	_pickup(PISTOL, h1 - 60, -315)
	_coin_line(h2 - 230, 4, 50, -360)
	_prop("vazo", h1 - 140, -270)

	# --- 5. Telgraf binası: üç kat, içeriden yukarı; damda antenler ---------------
	_checkpoint(5250, 0)
	_interior(5350, 6100, -345, [-115.0, -230.0], 0)
	_enemy(SHIELD, 5600, 0)
	_enemy(BOMBER, 5900, 0)
	_enemy(ELITE, 5750, -115)
	_enemy(STREET, 5500, -230)
	_coin_line(5450, 6, 60, -160)
	_pickup(HEALTH, 6050, -275)
	_coin_line(5700, 4, 50, -275)
	_antenna(5500, -345, 3.0)
	_antenna(5950, -345, 3.0)
	_coin_line(5600, 5, 60, -395)
	_story(6200, _sahne_mors)

	# --- 6. Mors kantini ----------------------------------------------------------
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6550, 0)
	shop.title = "MORS KANTİNİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 7. Kablo koridoru: arena ---------------------------------------------
	_checkpoint(6850, 0)
	_fg("zincir", 7300.0, -560.0, 220.0)
	_fg("zincir", 7650.0, -560.0, 160.0)
	_fight(7050, 7850, _wave(ELITE, KNIFE), _wave(ELITE, RIFLE, SHIELD))

	# --- 8. Arşiv: iki katlı raf odası, sonra çökmüş döşeme (çivili bodrum) -----
	_checkpoint(7950, 0)
	_interior(8050, 8500, -230, [-115.0], 1)
	_enemy(ELITE, 8300, 0)
	_pickup(RIFLE_PICKUP, 8420, -160)
	_coin_line(8100, 4, 50, -160)
	_terrain(4150, 8600, 0)
	_spike_pit(8600, 8760)
	for k in 2:
		_collapse(8650.0 + k * 100.0, -90.0, 90)
	_coin_line(8630, 3, 70, -140)
	_terrain(8760, 10300, 0)

	# --- 9. Çatı direkleri: son arena; hattı kes ----------------------------------
	_checkpoint(8950, 0)
	_antenna(9250, 0, 4.0)
	_antenna(9650, 0, 4.0)
	_fight(9100, 9700, _wave(KNIFE, ASSASSIN, BOMBER), _wave(ELITE, BRUISER))
	var hat := BREAKABLE_WALL.instantiate()
	hat.set("hits_to_break", 5)
	hat.position = Vector2(9850, 0)
	add_child(hat)
	var sign := _Sign.new()
	sign.text = "TELGRAF HATTI"
	sign.position = Vector2(9850, -260)
	add_child(sign)
	_story(9950, _sahne_hat)
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2537, "gazelle", "GAZELLE", "Kamondo merdivenleri. Babamla burada fotoğraf çekmiştik.")
	_radio(5582, "redmount", "REDMOUNT", "Telgraf binası üç kat. İçeriden, kat kat çıkacağız.")
	_radio(8627, "telsiz", "SON TELGRAF", "...ANA HAT DÜŞTÜ STOP ÜSKÜDAR YEDEK RÖLE DEVREDE STOP")
	_goal(10150, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Karaköy kıyısı: Galata kulesi, telgraf.
func _sahne_kiyi(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Galata telgrafı. Babam derdi ki: 'Bir haber önce telgrafa düşer, sonra şehre.'")
	await cs.say("rm", "REDMOUNT", "Bugün düşmeyecek. Hattı keseceğiz.")


## Mors salonu: Kâtip'in emirleri banda düşüyor.
func _sahne_mors(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("tg", "voice", Vector2(p.x + 200, -140))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("tg", "MORS (tık-tık)", "...BÜTÜN GAZETELERE STOP GAZETECİ KAÇAK STOP RADYO SABAH OKUSUN STOP K...", 2.6)
	await cs.say("gz", "GAZELLE", "Her gazeteye, her radyoya aynı yalan. Bir şehir aynı sesi duyunca ona inanır.")
	await cs.say("rm", "REDMOUNT", "Bir şehir aynı sessizliği duyunca da şüphelenir. Kesiyoruz.")


## Çatı direkleri: hat kesildi; Üsküdar rölesi.
func _sahne_hat(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("tg", "voice", Vector2(p.x + 200, -260))
	await cs.pan(Vector2(p.x + 100, -220), 0.5)
	await cs.say("tg", "SON TELGRAF", "...ANA HAT DÜŞTÜ STOP ÜSKÜDAR YEDEK RÖLE DEVREDE STOP", 2.2)
	await cs.say("gz", "GAZELLE", "Galata sustu ama yayın Üsküdar'daki yedek röleye geçti!")
	await cs.say("rm", "REDMOUNT", "Karşı yakaya. Röleyi şerit takılmadan durduralım.")

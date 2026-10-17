## Bölüm 30 — Beylerbeyi İskele Arşivi (Kitap 3 / "İstanbul'un Sesi", 6. bölüm).
##
## Evrak Beylerbeyi iskele arşivinde yakılmayı bekliyor. Gece sahili -> yalı
## sokağı (balkonlar) -> iskele (kanal, arena) -> merdivenli bahçe (alev mangalları)
## -> arşiv binası (raflar, erzak) -> evrak salonu (arena; mangallar) -> kasa odası
## (kırılır) -> arka iskele (son arena). Arşivin kasasında: Kâtip'in mühürünün
## Çengelköy sahil konağındaki "mühür odasında" saklandığı. Leyla dosyası kurtarılır.
extends DtmLevel

const SHORE := preload("res://assets/backgrounds/book03_beylerbeyi_shore_atlas.png")
const ARCHIVE := preload("res://assets/backgrounds/book03_beylerbeyi_archive_atlas.png")


func _build() -> void:
	sky_atlas = SHORE
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3300.0], [3, 4600.0],
		[0, 4950.0, ARCHIVE], [1, 6300.0, ARCHIVE], [2, 7550.0, ARCHIVE], [3, 8750.0, ARCHIVE]]
	sky_tint = Color(0.86, 0.86, 0.96)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_row_skip = [[4900.0, 8700.0]]
	_night(Color(0.76, 0.78, 0.94))

	# --- 1. Gece sahili --------------------------------------------------------
	_terrain(-400, 2700, 0)
	_story(-1.0, _sahne_sahil, 240.0)
	for x in [300, 1100]:
		_lantern(float(x))
	_enemy(STREET, 800, 0)
	_enemy(KNIFE, 1000, 0)

	# --- 2. Yalı sokağı: balkonlar, sarmaşıklı duvarlar -------------------------
	_checkpoint(1450, 0)
	_balcony(1750, -70, 110)
	_balcony(1910, -170, 110)
	_balcony(2070, -270, 110)
	_pickup(ARMOR, 2070, -315)
	_coin_line(1710, 5, 70, -330)
	for vx in [1650.0, 2150.0]:
		_fg("sarmasik", vx, -600.0)
	_enemy(ASSASSIN, 2400, 0)
	_prop("vazo", 2550)

	# --- 3. İskele: kazıklar arası su, sallanan palet --------------------------------
	_checkpoint(2650, 0)
	_canal(2700, 3500, 110)
	_scaffold(2800, -20, 140)
	_moving(3050, -60, Vector2(200, 0), 140, 0.0)
	_scaffold(3400, -20, 140)
	_coins_arc(2850, 7, 80, -200)
	_terrain(3500, 4250, 0)
	_enemy(KNIFE, 3700, 0)
	_enemy(RIFLE, 3900, 0)

	# --- 4. Merdivenli bahçe: mangallı sekiler -------------------------------
	_checkpoint(3600, 0)
	for k in 3:
		_terrain(4250.0 + k * 220.0, 4470.0 + k * 220.0, -45.0 * (k + 1))
		_flame(4360.0 + k * 220.0, k * 0.4, -45.0 * (k + 1))
	_terrain(4910, 5050, -135)
	_terrain(5050, 10300, 0)
	_scaffold(4580, -280, 300)
	_pickup(PISTOL, 4580, -325)
	_coin_line(4300, 8, 75, -200)
	_lantern(4150)

	# --- 5. Yanan arşiv: üç kat, katlarda alev; en üstte Leyla dosyası -------------
	_checkpoint(5150, 0)
	_interior(5250, 6250, -345, [-115.0, -230.0], 0)
	_flame(5550, 0.0)
	_flame(5950, 0.6)
	_flame(5700, 0.3, -115)
	_flame(5450, 0.9, -230)
	_enemy(ELITE, 5800, 0)
	_enemy(KNIFE, 5400, -115)
	_enemy(RIFLE, 6050, -230)
	_pickup(RIFLE_PICKUP, 6180, -160)
	_coin_line(5300, 5, 50, -160)
	_coin_line(5700, 6, 60, -275)
	_prop("sandik", 6150, -230, HEALTH)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6450, 0)
	shop.title = "İSKELE ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 6. Evrak salonu: galerili salonda arena -----------------------------
	_checkpoint(6650, 0)
	_story(6720, _sahne_ates)
	_interior(6850, 7650, -345, [], 0)
	_scaffold(7020, -115, 180)
	_scaffold(7480, -115, 180)
	_scaffold(7250, -230, 200)
	_coin_line(7190, 3, 50, -280)
	_fight(6900, 7600, _wave(ELITE, KNIFE), _wave(ELITE, RIFLE, ASSASSIN))

	# --- 7. Kasa odası: alevli koridor, kasayı kır ----------------------------
	_checkpoint(7750, 0)
	_flame(7900, 0.3)
	_flame(8050, 0.8)
	var kasa := BREAKABLE_WALL.instantiate()
	kasa.set("hits_to_break", 6)
	kasa.position = Vector2(8250, 0)
	add_child(kasa)
	var sign := _Sign.new()
	sign.text = "ARŞİV KASASI"
	sign.position = Vector2(8250, -260)
	add_child(sign)
	_story(8350, _sahne_kasa)
	_enemy(BRUISER, 8550, 0)

	# --- 8. Arka iskele: son arena ------------------------------------------
	_checkpoint(8750, 0)
	_lantern(8850)
	_fight(8950, 9650, _wave(KNIFE, ASSASSIN, RIFLE), _wave(ELITE, BRUISER))
	_han_gate(10050, "ÇENGELKÖY")
	_goal(10050, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Gece sahili: iskeleden duman.
func _sahne_sahil(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "İskelenin arkasından duman yükseliyor. Yakmaya başlamışlar!")
	await cs.say("rm", "REDMOUNT", "Koşuyoruz. Annenin dosyası o yığının içindeyse, dumana karışmadan alacağız.")


## Evrak salonu: yakılan kâğıtlar.
func _sahne_ates(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("e1", "elite", Vector2(p.x + 500, 0), -1)
	await cs.pan(Vector2(p.x + 250, -200), 0.5)
	await cs.say("e1", "ARŞİV BEKÇİSİ", "Kâtip Hanım şafağa kadar tek kâğıt kalmasın dedi. Onlar da kâğıt sayılır!")
	await cs.say("gz", "GAZELLE", "'Kâtip HANIM'... Duydun mu Redmount?")
	await cs.say("rm", "REDMOUNT", "Duydum. Önce bunlar.")
	await cs.move("e1", p.x + 1000, 0.5, "walk")
	cs.remove("e1")


## Kasa odası: Leyla dosyası ve mühür odası.
func _sahne_kasa(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 100, -200), 0.5)
	cs.pose("gz", "rescue_react")
	await cs.say("gz", "GAZELLE", "Annemin dosyası! Yanmamış... Son yazısının taslağı: 'Su idaresindeki mühürler.'")
	await cs.say("gz", "GAZELLE", "Yirmi yıl önce aynı işi yazmış. Ve aynı kişi onu susturmuş.")
	await cs.say("rm", "REDMOUNT", "Kasada başka ne var?")
	await cs.say("gz", "GAZELLE", "Bir not: 'Mühür, Çengelköy sahil konağında, mühür odasında. Konak N. hanımın.'")
	await cs.say("rm", "REDMOUNT", "N. Nüzhet. Çengelköy'e.")

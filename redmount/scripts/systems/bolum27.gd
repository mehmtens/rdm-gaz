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

	# --- 1. Karaköy kıyısı: devriye -------------------------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_kiyi, 240.0)
	_enemy(KNIFE, 900, 0)
	_prop("saksi", 1150)
	_balcony(1300, -70, 110)
	_balcony(1460, -170, 110)
	_pickup(ARMOR, 1460, -215)

	# --- 2. Köprübaşı: arena -------------------------------------------------
	_checkpoint(1650, 0)
	_terrain(1700, 1850, 30)
	_terrain(1850, 3100, 60)
	var kop: BattleArena = ARENA.instantiate()
	kop.position = Vector2(2450, 60)
	kop.gate_left_x = 2000
	kop.gate_right_x = 2900
	kop.floor_y = 60
	kop.wave1 = _wave(STREET, KNIFE, ASSASSIN)
	kop.wave2 = _wave(RIFLE, BRUISER)
	kop.reward = AMMO
	add_child(kop)
	_terrain(3100, 3250, 30)

	# --- 3. Yokuş sokak: tente -> çatılar -------------------------------------
	_terrain(3250, 10300, 0)
	_checkpoint(3300, 0)
	var aw := AwningBounce.new()
	aw.width = 180
	aw.height = 60
	aw.position = Vector2(3500, 0)
	add_child(aw)
	_balcony(3552, -125, 70)
	var h1 := _house(3590, -220, 0)
	_balcony(h1 + 45, -110, 90)
	_balcony(h1 + 115, -195, 90)
	var h2 := _house(h1 + 160, -270, 1)
	_coin_line(3640, 4, 60, -270)
	_coin_line(h2 - 160, 3, 50, -320)
	_enemy(KNIFE, h2 - 120, -270)
	_pickup(PISTOL, h2 - 40, -315)

	# --- 4. Telgraf binası cephesi: tüfekliler, kablo direkleri -------------------
	_checkpoint(4650, 0)
	_crates(4800, 1, 1)
	_crates(4890, 1, 2)
	_terrain(4980, 5250, -180)
	_enemy(RIFLE, 5200, -180)
	_enemy(RIFLE, 5500, 0)
	_scaffold(5580, -130, 120)
	_scaffold(5580, -240, 120)
	_tower(5700, -280, 110, false)

	# --- 5. Mors salonu: erzak --------------------------------------------------
	_checkpoint(5950, 0)
	_story(6050, _sahne_mors)
	_enemy(ASSASSIN, 6400, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6700, 0)
	shop.title = "MORS KANTİNİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 6. Kablo koridoru: arena ---------------------------------------------
	_checkpoint(6900, 0)
	var kab: BattleArena = ARENA.instantiate()
	kab.position = Vector2(7450, 0)
	kab.gate_left_x = 7100
	kab.gate_right_x = 7800
	kab.floor_y = 0
	kab.wave1 = _wave(ELITE, KNIFE)
	kab.wave2 = _wave(ELITE, RIFLE, STREET)
	kab.reward = HEALTH
	add_child(kab)

	# --- 7. Arşiv odası: raflar --------------------------------------------------
	_checkpoint(7950, 0)
	_crates(8100, 1, 1)
	_scaffold(8260, -150, 130)
	_scaffold(8410, -260, 130)
	_pickup(RIFLE_PICKUP, 8410, -305)
	_enemy(ELITE, 8700, 0)

	# --- 8. Çatı direkleri: son arena; hattı kes ----------------------------------
	_checkpoint(8950, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9400, 0)
	final.gate_left_x = 9100
	final.gate_right_x = 9700
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN, RIFLE)
	final.wave2 = _wave(ELITE, BRUISER)
	final.reward = HEALTH
	add_child(final)
	var hat := BREAKABLE_WALL.instantiate()
	hat.set("hits_to_break", 5)
	hat.position = Vector2(9850, 0)
	add_child(hat)
	var sign := _Sign.new()
	sign.text = "TELGRAF HATTI"
	sign.position = Vector2(9850, -260)
	add_child(sign)
	_story(9950, _sahne_hat)
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

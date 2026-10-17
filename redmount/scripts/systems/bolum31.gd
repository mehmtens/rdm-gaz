## Bölüm 31 — Çengelköy Sahil Konağı (Kitap 3 / "İstanbul'un Sesi", 7. bölüm).
##
## Bütün emirlerin altındaki mühür Çengelköy'deki sahil konağında. Sahil yolu ->
## çınar altı (arena) -> konak bahçesi (tente, duvar) -> konak kapısı -> sofa
## (erzak) -> kütüphane (raflar, arena) -> mühür odası (Kâtip açığa çıkar:
## Nüzhet Hanım) -> deniz köşkü (son arena, Nüzhet kayıkla kaçar). Masadaki deniz
## haritası: kıyı fenerleri bir teknenin yolunu çiziyor, ilk fener Kuleli'de.
extends DtmLevel

const SHORE := preload("res://assets/backgrounds/book03_cengelkoy_shore_atlas.png")
const MANSION := preload("res://assets/backgrounds/book03_cengelkoy_mansion_atlas.png")


func _build() -> void:
	sky_atlas = SHORE
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3200.0], [3, 4500.0],
		[0, 5700.0, MANSION], [1, 7000.0, MANSION], [2, 8200.0, MANSION], [3, 9500.0, MANSION]]
	sky_tint = Color(0.86, 0.86, 0.96)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_row_skip = [[3900.0, 7700.0]]
	_night(Color(0.76, 0.78, 0.94))

	# --- 1. Sahil yolu ---------------------------------------------------------
	_terrain(-400, 10300, 0)
	_story(-1.0, _sahne_sahil, 240.0)
	for x in [300, 1100]:
		_lantern(float(x))
	_enemy(KNIFE, 900, 0)
	_prop("saksi", 1150)

	# --- 2. Çınar altı: dallarda coin, altta devriye (kilitsiz) --------------------
	_checkpoint(1400, 0)
	for vx in [1650.0, 2050.0, 2450.0]:
		_fg("sarmasik", vx, -600.0)
	_balcony(1750, -100, 110)
	_balcony(1900, -200, 110)
	_balcony(2080, -290, 120)
	_balcony(2260, -200, 110)
	_coin_line(1860, 7, 55, -340)
	_pickup(ARMOR, 2080, -335)
	_enemy(STREET, 1900, 0)
	_enemy(KNIFE, 2150, 0)
	_enemy(ASSASSIN, 2400, 0)

	# --- 3. Konak bahçesi: tente -> taş duvar sırtı; bahçe köşkü (gizli) -------------
	_checkpoint(2650, 0)
	var aw := AwningBounce.new()
	aw.width = 180
	aw.height = 60
	aw.position = Vector2(2850, 0)
	add_child(aw)
	_balcony(2902, -125, 70)
	_stones(2940, 5, 2)
	_enemy(RIFLE, 3300, -180)
	_coin_line(2980, 5, 80, -240)
	_secret_han(3600)
	_lantern(3450)

	# --- 4. Selamlık: üç katlı konak cephesi, kat kat devriye -------------------
	_checkpoint(4000, 0)
	_interior(4100, 4950, -345, [-115.0, -230.0], 1)
	_enemy(ELITE, 4450, 0)
	_enemy(KNIFE, 4700, -115)
	_enemy(STREET, 4300, -230)
	_pickup(PISTOL, 4880, -160)
	_coin_line(4200, 5, 60, -160)
	_prop("vazo", 4850, -230, HEALTH)
	_coin_line(4500, 5, 60, -275)
	_story(5030, _sahne_sofa)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5350, 0)
	shop.title = "KONAK KİLERİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Kütüphane: raf galerilerinde arena --------------------------------
	_checkpoint(5600, 0)
	_interior(5700, 6650, -345, [], 1)
	for k in 4:
		_scaffold(5850.0 + k * 220.0, -115.0 - (k % 2) * 115.0, 160)
		_pickup(COIN, 5850.0 + k * 220.0, -165.0 - (k % 2) * 115.0)
	_pickup(RIFLE_PICKUP, 6070, -275)
	_fight(5750, 6600, _wave(ELITE, KNIFE), _wave(ELITE, RIFLE, ASSASSIN))

	# --- 6. Mühür odası: iki kat; Kâtip açığa çıkar -----------------------------
	_checkpoint(6800, 0)
	_interior(6900, 7650, -230, [-115.0], 1)
	_story(7250, _sahne_muhur_odasi)
	_pickup(HEALTH, 7550, -160)
	_coin_line(6950, 6, 50, -160)
	_chimney(7980, -480, 140, 150, AMMO)
	_enemy(KNIFE, 8150, 0)

	# --- 7. Deniz köşkü: son arena -------------------------------------------
	_checkpoint(8250, 0)
	_lantern(8350)
	_scaffold(8900, -120, 220)
	_fight(8450, 9350, _wave(KNIFE, ASSASSIN, RIFLE), _wave(ELITE, KNIFE), _wave(BRUISER, RIFLE))
	_story(9450, _sahne_harita)
	_han_gate(9750, "KULELİ")
	_goal(9750, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Sahil yolu.
func _sahne_sahil(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Nüzhet Hanım'ın yalısı... Gazetenin yılbaşı balosu hep burada olurdu.")
	await cs.say("gz", "GAZELLE", "Bana 'sen bu gazetenin geleceğisin' demişti. Annemin dosyasını kapatan kişi.")
	await cs.say("rm", "REDMOUNT", "Bu gece ona kendi geleceğini anlatacağız.")


## Sofa: aile fotoğrafları.
func _sahne_sofa(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Duvarda fotoğraflar... Nüzhet Hanım, Kemal Bey, Karahanlı! Hepsi aynı karede.")
	await cs.say("rm", "REDMOUNT", "Zincirin bütün halkaları, bir yılbaşı balosunda.")


## Mühür odası: Kâtip açığa çıkar.
func _sahne_muhur_odasi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("nz", "voice", Vector2(p.x + 360, -140))
	await cs.pan(Vector2(p.x + 220, -200), 0.6)
	await cs.say("nz", "NÜZHET HANIM (gölgede)", "Gazelle. Annenin gözleri, annenin inadı. Ve annenin hatası.")
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Kâtip... sizsiniz. Beyaz eldivenler, mürekkep, K imzası...")
	await cs.say("nz", "NÜZHET HANIM", "'Kâtip' bana gazetenin ilk yılında taktıkları addı. Her haberi ben yazardım, sonra herkesin kaderini.")
	await cs.say("nz", "NÜZHET HANIM", "Su, kâğıt, haber... Bir şehri yönetmek için silah gerekmez. Defter yeter.")
	await cs.say("rm", "REDMOUNT", "Defteriniz bizde. Mührünüz de birazdan.")
	await cs.say("nz", "NÜZHET HANIM", "Mühür bir nesne değil, Redmount. Bir ses. Ve o ses şafakta bütün şehirde yankılanacak.")
	await cs.say("gz", "GAZELLE", "Mühür odası boş... Kaçtı! Deniz köşküne!")


## Deniz köşkü: harita, Kuleli.
func _sahne_harita(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(9600, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Kayıkla kaçtı. Masada bir deniz haritası: kıyı fenerleri bir teknenin yolunu çiziyor.")
	await cs.say("rm", "REDMOUNT", "İlk fener Kuleli'de. Feneri takip et, tekneyi bul.")
	await cs.say("gz", "GAZELLE", "Annem için. Ve bu şehirde susturulan herkes için.")

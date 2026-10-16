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
	back_row_skip = [[5600.0, 9400.0]]
	_night(Color(0.76, 0.78, 0.94))

	# --- 1. Sahil yolu -----------------------------------------------------
	_terrain(-400, 10300, 0)
	_story(-1.0, _sahne_sahil, 240.0)
	for x in [300, 1100]:
		_lantern(float(x))
	_enemy(KNIFE, 900, 0)
	_prop("saksi", 1150)

	# --- 2. Çınar altı: arena ---------------------------------------------
	_checkpoint(1400, 0)
	var cinar: BattleArena = ARENA.instantiate()
	cinar.position = Vector2(2100, 0)
	cinar.gate_left_x = 1700
	cinar.gate_right_x = 2500
	cinar.floor_y = 0
	cinar.wave1 = _wave(STREET, KNIFE, ASSASSIN)
	cinar.wave2 = _wave(RIFLE, BRUISER)
	cinar.reward = AMMO
	add_child(cinar)

	# --- 3. Konak bahçesi: tente, duvar üstü --------------------------------
	_checkpoint(2650, 0)
	var aw := AwningBounce.new()
	aw.width = 180
	aw.height = 60
	aw.position = Vector2(2850, 0)
	add_child(aw)
	_balcony(2902, -125, 70)
	_terrain(2940, 3400, -200)
	_enemy(RIFLE, 3300, -200)
	_coin_line(2980, 5, 80, -250)
	_pickup(ARMOR, 3350, -245)
	_lantern(3600)

	# --- 4. Konak kapısı: devriyeler -------------------------------------------
	_checkpoint(3800, 0)
	_enemy(ELITE, 4100, 0)
	_enemy(KNIFE, 4300, 0)
	_prop("vazo", 4500)
	_pickup(PISTOL, 4650, -45)

	# --- 5. Sofa: erzak ----------------------------------------------------
	_checkpoint(4900, 0)
	_story(5000, _sahne_sofa)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5400, 0)
	shop.title = "KONAK KİLERİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 6. Kütüphane: raflar, arena ---------------------------------------
	_checkpoint(5700, 0)
	_crates(5850, 1, 1)
	for k in 4:
		_scaffold(6010.0 + k * 160.0, -150.0 - (k % 2) * 100.0, 140)
		_pickup(COIN, 6010.0 + k * 160.0, -200.0 - (k % 2) * 100.0)
	_pickup(RIFLE_PICKUP, 6490, -295)
	var kut: BattleArena = ARENA.instantiate()
	kut.position = Vector2(7050, 0)
	kut.gate_left_x = 6750
	kut.gate_right_x = 7350
	kut.floor_y = 0
	kut.wave1 = _wave(ELITE, KNIFE)
	kut.wave2 = _wave(ELITE, RIFLE, ASSASSIN)
	kut.reward = HEALTH
	add_child(kut)

	# --- 7. Mühür odası: Kâtip ---------------------------------------------
	_checkpoint(7500, 0)
	_story(7700, _sahne_muhur_odasi)
	_pickup(HEALTH, 8000, -45)

	# --- 8. Deniz köşkü: son arena ------------------------------------------
	_checkpoint(8250, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(8900, 0)
	final.gate_left_x = 8450
	final.gate_right_x = 9350
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN, RIFLE)
	final.wave2 = _wave(ELITE, ELITE)
	final.wave3 = _wave(BRUISER, RIFLE)
	final.reward = HEALTH
	add_child(final)
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

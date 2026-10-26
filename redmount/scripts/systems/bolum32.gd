## Bölüm 32 — Kuleli Gözetleme Hattı (Kitap 3 / "İstanbul'un Sesi", 8. bölüm).
##
## Kıyı fenerleri Nüzhet'in teknesinin yolunu çiziyor; boş görünen nöbet noktaları
## sahte. Kuleli kıyısı -> okul cephesi (arena) -> taş rıhtım (çürük iskele) ->
## fener kulesi (tırmanış, projektör) -> sinyal kulübesi (erzak) -> gözetleme
## koridoru (arena) -> sinyal kayıt odası (fener defteri) -> sahil kapısı (son
## arena). Kayıtta teknenin Vaniköy iskelesine yanaştığı yazıyor.
extends DtmLevel

const SHORE := preload("res://assets/backgrounds/book03_kuleli_shore_atlas.png")
const SIGNAL := preload("res://assets/backgrounds/book03_kuleli_signal_atlas.png")


func _build() -> void:
	sky_atlas = SHORE
	sky_cells = [[0, -100000.0], [1, 1500.0], [2, 3000.0], [0, 4200.0, SIGNAL],
		[3, 5600.0], [1, 6900.0, SIGNAL], [2, 7550.0, SIGNAL], [3, 8900.0, SIGNAL]]
	sky_tint = Color(0.86, 0.86, 0.96)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_row_skip = [[1450.0, 2450.0], [6800.0, 9400.0]]
	_night(Color(0.74, 0.76, 0.94))

	# --- 1. Kuleli kıyısı ------------------------------------------------------
	_terrain(-400, 2700, 0)
	_story(-1.0, _sahne_kiyi, 240.0)
	_lantern(300)
	_lantern(1100)
	_enemy(KNIFE, 900, 0)
	_prop("varil", 1200)

	# --- 2. Okul binası: üç kat koridor, nöbetçiler kat kat ---------------------
	_checkpoint(1350, 0)
	_interior(1500, 2400, -345, [-115.0, -230.0], 0)
	_enemy(SHIELD, 1750, 0)
	_enemy(KNIFE, 2050, 0)
	_enemy(RIFLE, 2250, -115)
	_enemy(ASSASSIN, 1700, -230)
	_coin_line(1600, 6, 60, -160)
	_pickup(ARMOR, 2330, -275)
	_coin_line(1700, 8, 70, -395)

	# --- 3. Taş rıhtım: çürük kayık iskelesi, sandık merdiveni ---------------------
	# Kanalın üstüne serili sağlam plank yerine 450 px su üstünde çürük iskele: basılan
	# tahta yarım saniyede çöker, durmadan koşmak gerekir; düşen ıslanır, dipten çıkar.
	_checkpoint(2550, 0)
	_canal(2700, 3150, 110)
	for cx in [2775.0, 2925.0, 3075.0]:
		_collapse(cx, -20.0, 145)
	_coin_line(2760, 5, 70, -70)
	_terrain(3150, 10300, 0)
	_crates(3250, 1, 1)
	_scaffold(3410, -150, 130)
	_scaffold(3560, -260, 130)
	_coin_line(3380, 4, 60, -310)
	_enemy(STREET, 3700, 0)

	# --- 4. Fener kulesi: dış iskele merdiveni + içi tırmanılan fener bacası --------
	_checkpoint(3850, 0)
	_scaffold(4000, -110, 120)
	_scaffold(4000, -220, 120)
	_scaffold(4000, -330, 120)
	_tower(4140, -420, 130)
	_enemy(RIFLE, 4140, -420)
	_scaffold(4320, -330, 120)
	_scaffold(4460, -220, 120)
	_pickup(PISTOL, 4140, -470)
	_coin_line(4000, 3, 160, -380)
	_scaffold(4600, -110, 120)
	_chimney(4900, -600, 140, 150, HEALTH)
	_lantern(4900, -640)
	_story(5100, _sahne_fener)

	# --- 5. Sinyal kulübesi: erzak --------------------------------------------
	_checkpoint(5200, 0)
	_enemy(ASSASSIN, 5380, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5600, 0)
	shop.title = "FENERCİ KİLERİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 6. Gözetleme hattı: projektörlü kuleler, siperler (kilitsiz) --------------
	_checkpoint(5850, 0)
	_sandbags(6000, 100)
	_tower(6300, -300)
	_enemy(RIFLE, 6300, -300)
	_scaffold(6170, -110, 110)
	_scaffold(6170, -215, 110)
	_flame(6500, 0.0)
	_sandbags(6650, 100, 90)
	_enemy(KNIFE, 6850, 0)
	_tower(7050, -220)
	_enemy(RIFLE, 7050, -220)
	_scaffold(6820, -90, 110)
	_scaffold(6930, -180, 110)
	_coin_line(6150, 5, 220, -350)
	_enemy(ELITE, 7300, 0)

	# --- 7. Sinyal kayıt odası: iki kat; fener defteri ------------------------
	_checkpoint(7500, 0)
	_interior(7600, 8300, -230, [-115.0], 1)
	_enemy(KNIFE, 7850, -115)
	_pickup(RIFLE_PICKUP, 8230, -160)
	_coin_line(7650, 5, 50, -160)
	_story(8000, _sahne_kayit)

	# --- 8. Sahil kapısı: son arena --------------------------------------
	_checkpoint(8550, 0)
	_scaffold(9150, -110, 220)
	_fight(8750, 9550, _wave(KNIFE, ASSASSIN, BOMBER), _wave(BRUISER, ELITE))
	_han_gate(9900, "VANİKÖY")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2475, "gazelle", "GAZELLE", "Kuleli fenerleri bir teknenin rotasını çiziyor.")
	_radio(5445, "redmount", "REDMOUNT", "Fener kulesinin içi tırmanılır. Tepeden rota görünür.")
	_radio(8415, "gazelle", "GAZELLE", "Fener defteri: tekne Vaniköy iskelesine yanaşmış.")
	_goal(9900, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Kuleli kıyısı: fenerler.
func _sahne_kiyi(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Fenerler yanıp sönüyor. Haritadaki sırayla aynı: bir kısa, iki uzun.")
	await cs.say("rm", "REDMOUNT", "Teknesine yol gösteriyorlar. Nöbet noktaları boş görünüyor... fazla boş.")


## Fener kulesi tepesi: işaret kodu.
func _sahne_fener(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 100, -220), 0.5)
	await cs.say("gz", "GAZELLE", "Fener kodu değişti: 'Tekne yanaştı. Yük boşalt.' Kuzeye işaret ediyor.")
	await cs.say("rm", "REDMOUNT", "Sinyal kayıt odası yolun sonunda. Hangi iskele, orada yazar.")


## Sinyal kayıt odası: Vaniköy.
func _sahne_kayit(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Fener defteri: 'N. teknesi Vaniköy iskelesine. Kasalar kapalı yükleme hattına.'")
	await cs.say("rm", "REDMOUNT", "Kasaları takip edersek Nüzhet'in sesini taşıdığı yeri buluruz.")
	await cs.say("gz", "GAZELLE", "Verici parçaları... Sirkeci'den beri onları topluyor. Bir yayın istasyonu kuruyor.")

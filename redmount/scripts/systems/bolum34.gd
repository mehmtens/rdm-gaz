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
	back_row_skip = [[7000.0, 8800.0]]
	_night(Color(0.74, 0.76, 0.94))

	# --- 1. Yokuş başı -------------------------------------------------------
	_terrain(-400, 10300, 0)
	_story(-1.0, _sahne_yokus, 240.0)
	_lantern(300)
	_enemy(STREET, 850, 0)

	# --- 2. Çatı çatı kablo yolu ----------------------------------------------
	_checkpoint(1050, 0)
	var aw := AwningBounce.new()
	aw.width = 180
	aw.height = 60
	aw.position = Vector2(1250, 0)
	add_child(aw)
	_balcony(1302, -125, 70)
	var h1 := _house(1340, -220, 0)
	_collapse(h1 + 70, -220, 130)
	_balcony(h1 + 150, -110, 80)
	_balcony(h1 + 150, -195, 80)
	var h2 := _house(h1 + 200, -260, 1)
	_balcony(h2 + 45, -110, 90)
	_balcony(h2 + 115, -205, 90)
	var h3 := _house(h2 + 160, -290, 2)
	_coin_line(1390, 4, 60, -270)
	_coin_line(h2 - 160, 3, 50, -310)
	_coin_line(h3 - 200, 4, 50, -340)
	_enemy(KNIFE, h2 - 100, -260)
	_enemy(RIFLE, h3 - 60, -290)
	_pickup(ARMOR, h3 - 140, -335)

	# --- 3. Bahçe merdiveni: arena ---------------------------------------------
	_checkpoint(h3 + 150, 0)
	var bah: BattleArena = ARENA.instantiate()
	bah.position = Vector2(h3 + 700, 0)
	bah.gate_left_x = h3 + 300
	bah.gate_right_x = h3 + 1100
	bah.floor_y = 0
	bah.wave1 = _wave(KNIFE, ASSASSIN, STREET)
	bah.wave2 = _wave(RIFLE, ELITE)
	bah.reward = AMMO
	add_child(bah)

	# --- 4. Sırt yolu: kuleler, projektörler -------------------------------------
	var sx := h3 + 1300.0
	_checkpoint(sx, 0)
	_sandbags(sx + 250, 110)
	_scaffold(sx + 500, -110, 120)
	_scaffold(sx + 500, -220, 120)
	_tower(sx + 620, -320)
	_enemy(RIFLE, sx + 620, -320)
	_pickup(PISTOL, sx + 500, -265)
	_sandbags(sx + 900, 100)
	_enemy(BRUISER, sx + 1150, 0)

	# --- 5. Verici avlusu: erzak --------------------------------------------
	_checkpoint(5800, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6050, 0)
	shop.title = "SIRT KANTİNİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)
	_story(6350, _sahne_radyo)

	# --- 6. Jeneratör odası: pistonlar, arena --------------------------------
	_checkpoint(6650, 0)
	_press(6850, 0.0, 2.6)
	_press(7100, 0.5, 2.6)
	_coin_line(6820, 5, 70, -60)
	var jen: BattleArena = ARENA.instantiate()
	jen.position = Vector2(7750, 0)
	jen.gate_left_x = 7350
	jen.gate_right_x = 8150
	jen.floor_y = 0
	jen.wave1 = _wave(ELITE, KNIFE, RIFLE)
	jen.wave2 = _wave(BRUISER, ELITE)
	jen.reward = HEALTH
	add_child(jen)

	# --- 7. Verici direği: kır --------------------------------------------
	_checkpoint(8300, 0)
	var mast := _Art.new(_Art.A_TOWER, Vector2(90, 380))
	mast.position = Vector2(8700, -190)
	mast.z_index = -6
	add_child(mast)
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
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9300, 0)
	final.gate_left_x = 9000
	final.gate_right_x = 9600
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN, RIFLE)
	final.wave2 = _wave(ELITE, ELITE)
	final.reward = HEALTH
	add_child(final)
	_story(9700, _sahne_hisar)
	_han_gate(9950, "ANADOLUHİSARI")
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

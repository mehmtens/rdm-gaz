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
	back_row_skip = [[3000.0, 10300.0]]
	_night(Color(0.74, 0.76, 0.94))

	# --- 1. Göksu kıyısı: köprü --------------------------------------------
	_terrain(-400, 1600, 0)
	_story(-1.0, _sahne_kiyi, 240.0)
	_lantern(300)
	_enemy(KNIFE, 900, 0)
	_canal(1600, 1800, 110)
	_scaffold(1700, -20, 220)
	_terrain(1800, 10300, 0)

	# --- 2. Dış sur yolu: kuleler, projektör ---------------------------------
	_checkpoint(1950, 0)
	_sandbags(2150, 110)
	_scaffold(2420, -110, 120)
	_scaffold(2420, -220, 120)
	_tower(2540, -320)
	_enemy(RIFLE, 2540, -320)
	_pickup(ARMOR, 2420, -265)
	_enemy(ELITE, 2900, 0)

	# --- 3. Sur kapısı: arena ------------------------------------------------
	_checkpoint(3150, 0)
	var kapi: BattleArena = ARENA.instantiate()
	kapi.position = Vector2(3750, 0)
	kapi.gate_left_x = 3350
	kapi.gate_right_x = 4150
	kapi.floor_y = 0
	kapi.wave1 = _wave(ELITE, KNIFE, ASSASSIN)
	kapi.wave2 = _wave(RIFLE, BRUISER)
	kapi.reward = AMMO
	add_child(kapi)

	# --- 4. Kale avlusu: burç tırmanışı, erzak --------------------------------
	_checkpoint(4300, 0)
	_crates(4450, 1, 1)
	_crates(4540, 1, 2)
	_terrain(4630, 5000, -180)
	_scaffold(5080, -270, 140)
	_scaffold(5230, -360, 140)
	_pickup(RIFLE_PICKUP, 5230, -405)
	_enemy(RIFLE, 4950, -180)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5550, 0)
	shop.title = "HİSAR KİLERİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Kışla koridoru: arena ---------------------------------------------
	_checkpoint(5800, 0)
	var kisla: BattleArena = ARENA.instantiate()
	kisla.position = Vector2(6450, 0)
	kisla.gate_left_x = 6050
	kisla.gate_right_x = 6850
	kisla.floor_y = 0
	kisla.wave1 = _wave(ELITE, ELITE)
	kisla.wave2 = _wave(MINIBOSS)
	kisla.reward = HEALTH
	add_child(kisla)

	# --- 6. Kumanda odası: anahtar ---------------------------------------
	_checkpoint(7000, 0)
	_press(7250, 0.0, 2.6)
	_press(7500, 0.5, 2.6)
	_coin_line(7220, 5, 70, -60)
	_story(7800, _sahne_kumanda)
	_pickup(HEALTH, 8000, -45)

	# --- 7. İç surlar: son arena -----------------------------------------------
	_checkpoint(8250, 0)
	_sandbags(8450, 100)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9150, 0)
	final.gate_left_x = 8750
	final.gate_right_x = 9550
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN, RIFLE)
	final.wave2 = _wave(ELITE, RIFLE)
	final.wave3 = _wave(BRUISER, ELITE)
	final.reward = HEALTH
	add_child(final)
	_story(9650, _sahne_mavna)
	_han_gate(9950, "GÖKSU")
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

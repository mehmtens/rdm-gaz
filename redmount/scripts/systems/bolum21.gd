## Bölüm 21 — Yenikapı Gece Vardiyası (Kitap 2 / "Haliç'in İzi", 9. bölüm).
##
## Kemal Bey'in kaçtığı Yenikapı'da gece teslimi. Gece sokağı -> balık mezadı
## (arena) -> kayıkhane (tekne kirişi) -> dış rıhtım (tüfekli, vinç, arena, erzak)
## -> kuru havuz (iskele) -> sevk bürosu (arena; evrak gemiye değil şehre) ->
## tartıhane -> gece iskelesi (yük sandıkları, tüfekli nöbet). Finalde Kemal Bey yakalanır: Kâtip'in
## yüzünü görmemiştir ama emirlerin Aksaray eski pompa istasyonundan geldiğini söyler.
extends DtmLevel

const QUAY := preload("res://assets/backgrounds/book02_yenikapi_quay_atlas.png")
const DISPATCH := preload("res://assets/backgrounds/book02_yenikapi_dispatch_atlas.png")


func _build() -> void:
	sky_atlas = QUAY
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3300.0], [3, 4600.0],
		[0, 6100.0, DISPATCH], [1, 7400.0, DISPATCH], [2, 8700.0, DISPATCH], [3, 9800.0, DISPATCH]]
	sky_tint = Color(0.86, 0.86, 0.94)
	sky_shade = Color(0.03, 0.04, 0.08)
	back_row_skip = [[3300.0, 4500.0], [6000.0, 9700.0]]
	_night(Color(0.76, 0.8, 0.94))

	# --- 1. Gece sokağı: devriye, kısa balkon rotası ------------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_sokak, 240.0)
	_balcony(560, -70, 110)
	_balcony(720, -170, 110)
	_pickup(ARMOR, 720, -215)
	_enemy(KNIFE, 1050, 0)
	for x in [300, 1400]:
		_lantern(float(x))

	# --- 2. Balık mezadı: alçak servis yolu, iki dalga ----------------------------
	_checkpoint(1550, 0)
	_terrain(1700, 1850, 30)
	_terrain(1850, 3200, 60)
	_stall(2000)
	_stall(2950)
	var mezat: BattleArena = ARENA.instantiate()
	mezat.position = Vector2(2500, 60)
	mezat.gate_left_x = 2050
	mezat.gate_right_x = 2950
	mezat.floor_y = 60
	mezat.wave1 = _wave(STREET, KNIFE, STREET)
	mezat.wave2 = _wave(ASSASSIN, RIFLE)
	mezat.reward = HEALTH
	add_child(mezat)
	_terrain(3200, 3350, 30)

	# --- 3. Kayıkhane: kısa su açıklığı, tekne kirişi -----------------------------
	_terrain(3350, 3800, 0)
	_checkpoint(3400, 0)
	_canal(3800, 4000, 110)
	_scaffold(3900, -20, 220)
	_terrain(4000, 10300, 0)
	_crates(4150, 1, 1)
	_scaffold(4310, -150, 130)
	_scaffold(4460, -260, 130)
	_pickup(PISTOL, 4460, -305)
	_enemy(SHIELD, 4600, 0)

	# --- 4. Dış rıhtım: tüfekli, vinç yolu, arena, erzak --------------------------
	_checkpoint(4750, 0)
	_crates(4880, 1, 1)
	_crates(4970, 1, 2)
	_terrain(5060, 5300, -180)
	_enemy(RIFLE, 5240, -180)
	_moving(5450, -250, Vector2(260, 0), 140, 0.0)
	_pickup(RIFLE_PICKUP, 5720, -305)
	_enemy(KNIFE, 5500, 0)
	_enemy(BRUISER, 5750, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6000, 0)
	shop.title = "RIHTIM ERZAKÇISI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Kuru havuz: alt iş yolu, üst iskele --------------------------------
	_checkpoint(6200, 0)
	# Kuru havuz: tekne çekilmiş derin havuz; altta işçiler + sandık, üstte iskele.
	_basin(6450, 7150, 200)
	_prop("sandik", 7000, 200, HEALTH)
	_coin_line(6620, 6, 70, 150)
	_enemy(KNIFE, 6650, 200)
	_crates(6350, 1, 1)
	for k in 4:
		_scaffold(6520.0 + k * 170.0, -220.0 - (k % 2) * 50.0, 150)
		_pickup(COIN, 6520.0 + k * 170.0, -270.0 - (k % 2) * 50.0)
	_scaffold(6440, -120, 90)
	_pickup(ARMOR, 7030, -315)
	_enemy(ASSASSIN, 6850, 200)
	_prop("varil", 7230)

	# --- 6. Sevk bürosu: seçkin + menzilli arena; gerçek rota -----------------------
	_checkpoint(7350, 0)
	_story(7420, _sahne_buro)
	_interior(7560, 8340, -345, [], 0)
	_pickup(HEALTH, 7480, -45)
	_scaffold(7720, -115, 160)
	_scaffold(8180, -115, 160)
	var buro: BattleArena = ARENA.instantiate()
	buro.position = Vector2(7950, 0)
	buro.gate_left_x = 7600
	buro.gate_right_x = 8300
	buro.floor_y = 0
	buro.wave1 = _wave(ELITE, BOMBER)
	buro.wave2 = _wave(ELITE, SHIELD, RIFLE)
	buro.reward = AMMO
	add_child(buro)

	# --- 7. Tartıhane: son açıklık, kayıt izi ----------------------------------
	_checkpoint(8450, 0)
	_canal(8600, 8800, 110)
	_scaffold(8700, -20, 220)
	_interior(8900, 9260, -230, [-115.0], 1)
	_stones(8950, 1, 1)
	_pickup(HEALTH, 9220, -160)
	_coin_line(8950, 5, 60, -160)
	_enemy(ELITE, 9100, 0)

	# --- 8. Gece iskelesi: sandık üstleri, tüfekli nöbet; Kemal Bey yakalanır -------
	_checkpoint(9300, 0)
	_scaffold(9560, -115, 140)
	_scaffold(9840, -115, 140)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9700, 0)
	final.gate_left_x = 9400
	final.gate_right_x = 10000
	final.floor_y = 0
	## İskele hamalları, sonra teslimi koruyan tüfekli bir kalkanlının arkasında; iki
	## yük sandığı iskelesi üstten ateş hattını aşmaya yarar. Son: seçkin + bombacı.
	final.wave1 = _wave(STREET, STREET, KNIFE)
	final.wave2 = _wave(SHIELD, RIFLE)
	final.wave3 = _wave(ELITE, BOMBER)
	final.reward = HEALTH
	add_child(final)
	_story(10050, _sahne_kemal)
	_han_gate(10150, "AKSARAY")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2537, "gazelle", "GAZELLE", "Yenikapı'da gece teslimi. Evrak gemiye değil, şehre gidiyor.")
	_radio(5582, "redmount", "REDMOUNT", "Kuru havuzda bir tekne iskeleti. Saklanmak için iyi yer.")
	_radio(8627, "gazelle", "GAZELLE", "Kemal Bey yakalandı. Kâtip'in yüzünü görmemiş... ama sesini duymuş.")
	_goal(10150, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Gece sokağı: vardiya düdüğü.
func _sahne_sokak(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	cs.actor("dd", "voice", Vector2(900, -300))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	await cs.say("dd", "UZAKTAN", "Fıııırt! Gece vardiyası başlıyor!", 1.4)
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Kemal Bey'in kayığı rıhtıma yanaşmış. Gece vardiyası onun kılıfı.")
	await cs.say("rm", "REDMOUNT", "Bu sefer kayığa binemeyecek. İskele uzun, ben hızlıyım.")


## Sevk bürosu: evrak gemiye değil şehre.
func _sahne_buro(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 200, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Sevk kâğıtlarında gemi adı yazıyor ama yük listesi boş. Hiçbir şey gemiye binmiyor.")
	await cs.say("rm", "REDMOUNT", "Liman sadece görüntü. Sahte kimlikler şehirde kalıyor, gerçek insanların yerine geçiyor.")
	await cs.say("gz", "GAZELLE", "Masada bir harita... İşaretlerin hepsi Aksaray'a çıkıyor.")


## Gece iskelesi: Kemal Bey yakalanır.
func _sahne_kemal(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("km", "elite", Vector2(p.x + 240, 0), -1)
	cs.pose("km", "hurt")
	await cs.pan(Vector2(p.x + 120, -200), 0.6)
	await cs.say("km", "KEMAL BEY", "Tamam... tamam! Kaçacak yer kalmadı.")
	await cs.say("gz", "GAZELLE", "Neden, Kemal Bey? Neden beni o minibüse bindirttiniz?")
	await cs.say("km", "KEMAL BEY", "Ben bindirtmedim! Haliç'teki fotoğrafları anlattığın gece Kâtip'e sadece... bir not yazdım.")
	await cs.say("km", "KEMAL BEY", "Kâtip'in yüzünü hiç görmedim. Emirler hep mektupla, hep beyaz eldivenli bir kuryeyle gelir.")
	await cs.say("rm", "REDMOUNT", "Mektuplar nereden geliyor?")
	await cs.say("km", "KEMAL BEY", "Aksaray. Eski pompa istasyonu. Ondan ötesini bilmiyorum, yemin ederim.")
	await cs.say("gz", "GAZELLE", "Sizi polise teslim ediyoruz. Ve ben bu hikâyeyi yazacağım. Hepsini.")
	cs.pose("km", "idle")
	await cs.say("km", "KEMAL BEY", "Yaz kızım. Ama yazdığın gün Kâtip de seni yazar.")

## Bölüm 25 — Cağaloğlu'nda İlk Baskın (Kitap 3 / "İstanbul'un Sesi", 1. bölüm).
##
## Kumanda anahtarının mührü Cağaloğlu'nda eski bir matbaaya çıkar. Su kesintisini
## önledikleri sabah: sokak -> kitapçı yokuşu (arena) -> matbaa avlusu -> baskı
## salonu (ağır düşman) -> kurutma çatısı (üstte tüfek) -> ciltçi geçidi (arena,
## erzak) -> dağıtım deposu -> arşiv kapısı (son arena). Matbaada sahte gazete
## baskıları: "Su kesintisinin sorumlusu gazeteci Gazelle". İlk sevkiyat Sirkeci'ye.
extends DtmLevel

const STREETS := preload("res://assets/backgrounds/book03_cagaloglu_streets_atlas.png")
const PRESS := preload("res://assets/backgrounds/book03_cagaloglu_press_atlas.png")


func _build() -> void:
	sky_atlas = STREETS
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3300.0], [0, 4800.0, PRESS],
		[1, 6150.0, PRESS], [3, 7300.0], [2, 8400.0, PRESS], [3, 9500.0, PRESS]]
	sky_tint = Color(0.94, 0.9, 0.86)
	sky_shade = Color(0.08, 0.05, 0.05)
	back_row_skip = [[4700.0, 6000.0], [8300.0, 9400.0]]

	# --- 1. Cağaloğlu sokağı: devriye, üst tente zırh ---------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_sabah, 240.0)
	var aw := AwningBounce.new()
	aw.width = 160
	aw.height = 60
	aw.position = Vector2(560, 0)
	add_child(aw)
	_scaffold(750, -260, 160)
	_scaffold(940, -300, 160)
	_pickup(ARMOR, 940, -345)
	_coin_line(720, 4, 70, -310)
	_enemy(STREET, 1100, 0)
	_prop("saksi", 1300)

	# --- 2. Kitapçı yokuşu: sığ alt yol, menzilli + yakın arena -----------------
	_checkpoint(1550, 0)
	_terrain(1700, 1850, 30)
	_terrain(1850, 3200, 60)
	_stall(2000)
	var yok: BattleArena = ARENA.instantiate()
	yok.position = Vector2(2500, 60)
	yok.gate_left_x = 2100
	yok.gate_right_x = 2950
	yok.floor_y = 60
	yok.wave1 = _wave(KNIFE, RIFLE)
	yok.wave2 = _wave(SHIELD, ASSASSIN, RIFLE)
	yok.reward = AMMO
	add_child(yok)
	_terrain(3200, 3350, 30)

	# --- 3. Matbaa avlusu: sabit açıklık, üstten tabanca --------------------------
	_terrain(3350, 3800, 0)
	_checkpoint(3400, 0)
	_canal(3800, 4000, 110)
	_scaffold(3900, -20, 220)
	_terrain(4000, 10300, 0)
	_scaffold(4200, -140, 130)
	_scaffold(4350, -250, 130)
	_pickup(PISTOL, 4350, -295)
	_enemy(SHIELD, 4550, 0)

	# --- 4. Baskı salonu: sandık ve raf arası ağır düşman; erzak ----------------
	_checkpoint(4750, 0)
	# Baskı salonu: matbaanın içi; makine galerileri, ortada ağır düşmanlar.
	_interior(4850, 5700, -345, [], 0)
	_crates(4900, 1, 1)
	_scaffold(5050, -150, 120)
	_crates(5600, 1, 1)
	var bask: BattleArena = ARENA.instantiate()
	bask.position = Vector2(5350, 0)
	bask.gate_left_x = 5150
	bask.gate_right_x = 5550
	bask.floor_y = 0
	bask.wave1 = _wave(BRUISER)
	bask.wave2 = _wave(BRUISER, KNIFE)
	bask.reward = HEALTH
	add_child(bask)
	_story(5100, _sahne_gazete)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5850, 0)
	shop.title = "MATBAA ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Kurutma çatısı: kesintisiz alt rota, üstte tüfek -------------------
	_checkpoint(6050, 0)
	var aw2 := AwningBounce.new()
	aw2.width = 160
	aw2.height = 60
	aw2.position = Vector2(6200, 0)
	add_child(aw2)
	for k in 5:
		_scaffold(6380.0 + k * 160.0, -260.0 - (k % 2) * 40.0, 140)
		_pickup(COIN, 6380.0 + k * 160.0, -310.0 - (k % 2) * 40.0)
	_pickup(RIFLE_PICKUP, 7020, -345)
	_enemy(ASSASSIN, 6600, 0)
	_enemy(STREET, 6900, 0)

	# --- 6. Ciltçi geçidi: karma arena ----------------------------------------
	_checkpoint(7250, 0)
	# Ciltçi atölyesi: iki kat; katlarda karma devriye (kilitsiz).
	_interior(7450, 8150, -230, [-115.0], 1)
	_enemy(ELITE, 7650, 0)
	_enemy(KNIFE, 7950, 0)
	_enemy(RIFLE, 7800, -115)
	_enemy(ASSASSIN, 7550, -115)
	_coin_line(7500, 8, 80, -160)
	_pickup(HEALTH, 8100, -160)

	# --- 7. Dağıtım deposu: sandık içi cephane, seçkin nöbetçi --------------------
	_checkpoint(8300, 0)
	_canal(8450, 8650, 110)
	_scaffold(8550, -20, 220)
	_prop("sandik", 8850, 0, AMMO)
	_crates(9000, 1, 1)
	_crates(9090, 1, 2)
	_enemy(ELITE, 9300, 0)

	# --- 8. Arşiv kapısı: son arena; Sirkeci ------------------------------------
	_checkpoint(9450, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9800, 0)
	final.gate_left_x = 9550
	final.gate_right_x = 10050
	final.floor_y = 0
	## Arşiv kapısı: nöbetçiler arasında tüfekli; sonra ağır zırhlıyı suikastçı kollar.
	final.wave1 = _wave(STREET, RIFLE, STREET)
	final.wave2 = _wave(BRUISER, ASSASSIN)
	final.reward = HEALTH
	add_child(final)
	_story(10100, _sahne_sirkeci)
	_han_gate(10200, "SİRKECİ")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2550, "gazelle", "GAZELLE", "Matbaada benim adıma manşet basıyorlar: \"Suyu kesen gazeteci.\"")
	_radio(5610, "redmount", "REDMOUNT", "Yalan hızlı koşar. Biz daha hızlı koşacağız.")
	_radio(8670, "gazelle", "GAZELLE", "İlk sevkiyat Sirkeci'ye gitmiş. Verici parçası...")
	_goal(10200, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Sabah: su kurtulmuş, gazeteler yanlış yazıyor.
func _sahne_sabah(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	cs.actor("muvezzi", "voice", Vector2(700, -150))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	await cs.say("muvezzi", "GAZETE MÜVEZZİSİ", "Son dakika! Su kesintisi girişiminin arkasında gazeteci çıktı! Okuyun okuyun!")
	cs.face("gz", 1)
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Ne?! Manşette... benim fotoğrafım. 'Suyu kesmeye çalışan gazeteci.'")
	await cs.say("rm", "REDMOUNT", "Kâğıt bitti, şimdi ses... Kâtip haberleri yazıyor. Seni suçlu yazmış.")
	cs.pose("gz", "freed")
	await cs.say("gz", "GAZELLE", "Bu baskı Cağaloğlu'nda yapılmış. Anahtarın mührüyle aynı matbaa. Gidip kalıbı kıracağım.")


## Baskı salonu: sahte gazete kalıpları.
func _sahne_gazete(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Yarının baskısı da hazır: 'Gazeteci kaçak, yardımcısı silahlı.' Bu sen oluyorsun.")
	await cs.say("rm", "REDMOUNT", "Silahlı kısmı doğru. Ama kaçmıyoruz, geliyoruz.")
	await cs.say("gz", "GAZELLE", "Bir şehir hikâyesini kaybederse kendini de kaybeder. Bunu Kâtip'e bırakmayacağım.")


## Arşiv kapısı: Sirkeci sevkiyatı.
func _sahne_sirkeci(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(10150, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Dağıtım defteri: mühürlü kâğıtlar ve bir 'verici parçası' Sirkeci garına indirilmiş.")
	await cs.say("rm", "REDMOUNT", "Verici. Ses. Kâtip radyoya geçiyor.")
	await cs.say("gz", "GAZELLE", "O zaman ben de kendi sesimi bulacağım. Sirkeci.")

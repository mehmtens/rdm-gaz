## Bölüm 17 — Beyazıt Posta Hattı (Kitap 2 / "Haliç'in İzi", 5. bölüm).
##
## Asıl liste üç mühürlü çuvalın Beyazıt posta binasına teslim edildiğini gösterir.
## Süleymaniye inişi -> Beyazıt meydanı (arena, sütun kaidesi siperi) -> sahaflar (saçak
## zinciri, erzak) -> posta dış cephesi (tüfekli, hareketli taşıma yolu) -> tasnif salonu
## (iki çuval boş) -> telgraf odası (telgraf bandı, seçkin) -> paket geçidi -> çıkış kulesi
## (son arena, Kapalıçarşı arka hanı fişi). Kâtip'in telgrafı: "Gazeteciyi sustur."
extends DtmLevel

const STREETS := preload("res://assets/backgrounds/book02_beyazit_streets_atlas.png")
const POST := preload("res://assets/backgrounds/book02_beyazit_post_atlas.png")


func _build() -> void:
	sky_atlas = STREETS
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3300.0], [3, 4800.0],
		[0, 6200.0, POST], [1, 7300.0, POST], [2, 8800.0, POST], [3, 9600.0, POST]]
	sky_tint = Color(0.92, 0.9, 0.86)
	sky_shade = Color(0.06, 0.05, 0.06)
	back_row_skip = [[6100.0, 9500.0]]

	# --- 1. Süleymaniye inişi: devriye, isteğe bağlı çatı ------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_inis, 240.0)
	var aw0 := AwningBounce.new()
	aw0.width = 160
	aw0.height = 60
	aw0.position = Vector2(560, 0)
	add_child(aw0)
	_scaffold(750, -260, 160)
	_scaffold(940, -300, 160)
	_pickup(ARMOR, 940, -345)
	_coin_line(720, 4, 70, -310)
	_enemy(KNIFE, 1150, 0)
	_prop("saksi", 1350)

	# --- 2. Beyazıt meydanı: sokak hizasında geniş arena, sütun kaidesi siperi -------
	# Kitap 2'nin ortak çukur avlusu yerine meydan düz. Sağ yarıda kırık bir sütun
	# kaidesi: ikinci dalganın tüfeklisine karşı siper, üstü yüksek zemin. Kaide dalga
	# doğum noktalarının (2125/2250/2500/2750/2875) arasında, kimse taşın içine doğmaz.
	_checkpoint(1550, 0)
	_terrain(1700, 3350, 0)
	_prop("vazo", 1950, 0)
	_stones(2600, 1, 1)
	_pickup(COIN, 2645, -135)
	var sq: BattleArena = ARENA.instantiate()
	sq.position = Vector2(2500, 0)
	sq.gate_left_x = 2000
	sq.gate_right_x = 3000
	sq.floor_y = 0
	sq.wave1 = _wave(STREET, STREET, KNIFE)
	sq.wave2 = _wave(RIFLE, SHIELD, STREET)
	sq.reward = HEALTH
	add_child(sq)

	# --- 3. Sahaflar: tezgâh geçişi, uzun saçak zinciri; erzak --------------------
	_terrain(3350, 6200, 0)
	_checkpoint(3400, 0)
	var aw := AwningBounce.new()
	aw.width = 160
	aw.height = 60
	aw.position = Vector2(3560, 0)
	add_child(aw)
	for k in 6:
		_scaffold(3730.0 + k * 160.0, -250.0 - (k % 2) * 40.0, 140)
		_pickup(COIN, 3730.0 + k * 160.0, -300.0 - (k % 2) * 40.0)
	_pickup(PISTOL, 4530, -345)
	_stall(3900)
	_stall(4350)
	_enemy(SHIELD, 4150, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(4750, 0)
	shop.title = "SAHAFLAR ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 4. Posta dış cephesi: tüfekli; hareketli üst taşıma yolu -----------------
	_checkpoint(4950, 0)
	_crates(5080, 1, 1)
	_crates(5170, 1, 2)
	_terrain(5260, 5500, -180)
	_enemy(RIFLE, 5440, -180)
	_moving(5650, -220, Vector2(280, 0), 140, 0.0)
	_scaffold(6050, -220, 120)
	_pickup(RIFLE_PICKUP, 6050, -265)
	_coin_line(5660, 4, 75, -280)
	_enemy(KNIFE, 5900, 0)

	# --- 5. Tasnif salonu: alt açık rota, üst galeri ----------------------------
	_terrain(6200, 7500, 0)
	_terrain(7700, 8850, 0)
	_terrain(9050, 10100, 0)
	_checkpoint(6250, 0)
	_story(6350, _sahne_tasnif)
	# Tasnif salonu: posta binasının içi; galeriler tavana yakın.
	_interior(6420, 7300, -345, [], 0)
	for k in 4:
		_scaffold(6600.0 + k * 170.0, -200.0, 150)
		_pickup(COIN, 6600.0 + k * 170.0, -250.0)
	_crates(6450, 1, 1)
	_scaffold(6520, -110, 90)
	_pickup(ARMOR, 7110, -245)
	_prop("sandik", 6800, 0, AMMO)
	_enemy(ASSASSIN, 7000, 0)

	# --- 6. Telgraf odası: servis kesintisi, seçkin devriye; telgraf ipucu ----------
	_checkpoint(7350, 0)
	_canal(7500, 7700, 110)
	_scaffold(7600, -20, 220)
	_enemy(ELITE, 8000, 0)
	_story(7800, _sahne_telgraf)
	# Telgraf odası: iki kat; üst katta mors masaları.
	_interior(7760, 8300, -230, [-115.0], 1)
	_enemy(KNIFE, 8150, -115)
	_coin_line(7820, 6, 70, -160)
	for x in [7400, 8200]:
		_lantern(float(x))

	# --- 7. Paket geçidi: tekli çatışma, son dar aralık ------------------------
	_checkpoint(8350, 0)
	_enemy(BRUISER, 8650, 0)
	_canal(8850, 9050, 110)
	_scaffold(8950, -20, 220)
	_pickup(HEALTH, 9200, -45)

	# --- 8. Çıkış kulesi: final; Kapalıçarşı fişi ------------------------------
	_checkpoint(9300, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9650, 0)
	final.gate_left_x = 9400
	final.gate_right_x = 9900
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, BOMBER, ASSASSIN)
	final.wave2 = _wave(ELITE, RIFLE)
	final.reward = HEALTH
	add_child(final)
	_story(9950, _sahne_fis)
	_han_gate(10050, "KAPALIÇARŞI")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2512, "gazelle", "GAZELLE", "Beyazıt postası her gazeteye aynı gün ulaşır. Yalan da öyle.")
	_radio(5527, "redmount", "REDMOUNT", "Tasnif salonunda Kâtip'in zarfları var. Beyaz mürekkep.")
	_radio(8542, "gazelle", "GAZELLE", "Telgraf: \"Kapalıçarşı arka hanı.\" Gidelim.")
	_goal(10050, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Süleymaniye inişi.
func _sahne_inis(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Üç mühürlü çuval, Beyazıt posta binasına teslim. Kâtip postayla mı çalışıyor?")
	await cs.say("rm", "REDMOUNT", "Posta her kapıya gider ve kimse içini açmaz. Kaçakçının rüyası.")
	await cs.say("gz", "GAZELLE", "Ben gazeteciyim. İçini açmak benim işim.")


## Tasnif salonu: iki çuval boş.
func _sahne_tasnif(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 200, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Çuvallar burada, mühürleri ters hilal. Ama... ikisi bomboş.")
	await cs.say("rm", "REDMOUNT", "Biri bizi bekliyormuş. Üçüncüsü nerede?")
	await cs.say("gz", "GAZELLE", "Kayıt defterinde 'telgrafla yönlendirildi' yazıyor. Telgraf odasına.")


## Telgraf odası: Kâtip'in emri banda düşmüş.
func _sahne_telgraf(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("tg", "voice", Vector2(p.x + 150, -120))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("tg", "TELGRAF (tık-tık)", "...ÜÇÜNCÜ ÇUVAL ARKA HANA STOP GAZETECİYİ SUSTURUN STOP K...", 2.6)
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Gazeteciyi susturun... Beni kastediyor. Kâtip beni tanıyor.")
	await cs.say("rm", "REDMOUNT", "Tanısın. Ben de onun telgrafını tanıyorum artık.")
	await cs.say("gz", "GAZELLE", "Bandı alıyorum. Kanıt.")


## Çıkış kulesi: Kapalıçarşı arka hanı.
func _sahne_fis(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(9980, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Çıkış fişi: üçüncü çuval Kapalıçarşı'nın arka hanına aktarılmış.")
	await cs.say("rm", "REDMOUNT", "Çarşının arkası. Kalabalığın içinde saklanmak kolay, kaçmak zor.")
	await cs.say("gz", "GAZELLE", "Bu sefer benim için değil, bizim için gelecekler. Hazır mısın?")
	await cs.say("rm", "REDMOUNT", "Balat'tan beri hazırım.")

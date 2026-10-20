## Bölüm 36 — Son Yayın (Kitap 3 finali, oyunun sonu).
##
## Göksu'da demirli mavna, Nüzhet'in son yayın istasyonu. Uzun final: kıyı
## iskeleleri -> kayıkhane -> mavna rampası (1. bağlantı kırılır) -> güverte altı
## (pistonlar, arena) -> jeneratör (2. bağlantı) -> kayıt arşivi (Gazelle kayıtları
## toplar) -> anten güvertesi (3. bağlantı) -> yayın odası (Gazelle canlı yayına
## başlar, son geçidi tut) -> köprü üstü: Yayın Şefi düellosu. Nüzhet teslim olur,
## Komiser Rıfat gelir. Şafak: oyun sonu sahnesi (play_ending).
extends DtmLevel

const SHORE := preload("res://assets/backgrounds/book03_final_shore_atlas.png")
const BROADCAST := preload("res://assets/backgrounds/book03_final_broadcast_atlas.png")
const DAWN := preload("res://assets/backgrounds/book03_final_dawn_atlas.png")
const DIRECTOR := preload("res://scenes/enemies/BroadcastDirector.tscn")
const MINIBOSS := preload("res://scenes/enemies/MiniBoss.tscn")


func _build() -> void:
	sky_atlas = SHORE
	sky_cells = [[0, -100000.0], [1, 1700.0], [2, 3300.0], [3, 5000.0],
		[0, 6600.0, BROADCAST], [1, 8200.0, BROADCAST], [2, 9800.0, BROADCAST], [3, 11400.0, BROADCAST],
		[0, 13200.0, DAWN], [2, 15000.0, DAWN]]
	sky_tint = Color(0.86, 0.86, 0.96)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_row_skip = [[2150.0, 18500.0]]
	_night(Color(0.76, 0.78, 0.94))

	# --- 1. Kıyı iskeleleri ----------------------------------------------------
	_terrain(-400, 1800, 0)
	_story(-1.0, _sahne_kiyi, 240.0)
	_lantern(300)
	_lantern(1300)
	_enemy(KNIFE, 900, 0)
	_enemy(ASSASSIN, 1150, 0)
	_canal(1800, 2000, 110)
	_scaffold(1900, -20, 220)
	_terrain(2000, 10300, 0)

	# --- 2. Kayıkhane: iki katlı ahşap kayıkhane, katlarda devriye; erzak -----------
	_checkpoint(2150, 0)
	_interior(2300, 3200, -230, [-115.0], 1)
	_enemy(ELITE, 2600, 0)
	_enemy(SHIELD, 2900, 0)
	_enemy(RIFLE, 2500, -115)
	_pickup(AMMO, 3130, -160)
	_coin_line(2350, 8, 70, -160)
	_coin_line(2400, 8, 90, -280)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(3450, 0)
	shop.title = "KAYIKHANE KİLERİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 3. Mavna rampası: sandık basamakları, güverte kenarı; 1. bağlantı -----------
	_checkpoint(3700, 0)
	_crates(3850, 1, 1)
	_crates(3940, 1, 2)
	_terrain(4030, 4400, -180)
	_enemy(RIFLE, 4350, -180)
	_coin_line(4060, 5, 70, -230)
	_link(4700, "1. BAĞLANTI")
	_enemy(ELITE, 5000, 0)

	# --- 4. Güverte altı: piston hattı, sonra galerili ambarda arena (Yüzbaşı) --------
	_checkpoint(5150, 0)
	_press(5350, 0.0, 2.4)
	_press(5600, 0.33, 2.4)
	_press(5850, 0.66, 2.4)
	_coin_line(5320, 6, 105, -60)
	_interior(6150, 7150, -345, [], 0)
	_scaffold(6320, -115, 180)
	_scaffold(6980, -115, 180)
	_scaffold(6650, -230, 240)
	_coin_line(6580, 4, 45, -280)
	_fight(6200, 7100, _wave(ELITE, KNIFE, ASSASSIN), _wave(MINIBOSS, RIFLE))

	# --- 5. Jeneratör: alevli ızgara, baca tırmanışı; 2. bağlantı ------------------
	_checkpoint(7250, 0)
	_flame(7400, 0.0)
	_flame(7650, 0.5)
	_scaffold(7525, -230, 360)
	_pickup(RIFLE_PICKUP, 7525, -275)
	_chimney(7950, -560, 140, 150, ARMOR)
	_link(8250, "2. BAĞLANTI")
	_story(8350, _sahne_jenerator)

	# --- 6. Kayıt arşivi: üç katlı raf odası; Gazelle kayıtları toplar ----------------
	_checkpoint(8500, 0)
	_interior(8650, 9500, -345, [-115.0, -230.0], 0)
	_enemy(ELITE, 9000, 0)
	_enemy(KNIFE, 8850, -115)
	_enemy(RIFLE, 9300, -230)
	_coin_line(8700, 6, 60, -160)
	_coin_line(8750, 6, 60, -275)
	_pickup(HEALTH, 9450, -275)
	_story(9650, _sahne_arsiv)

	# --- 7. Anten güvertesi: kablo makarası çukuru, paletler, 3. bağlantı ---------------
	_checkpoint(9850, 0)
	_antenna(10150, 0, 4.0)
	_antenna(11150, 0, 4.0)
	_scaffold(10000, -130, 120)
	_scaffold(10000, -240, 120)
	_moving(10220, -250, Vector2(280, 0), 140, 0.0)
	_spike_pit(10300, 10460)
	_terrain(10460, 18500, 0)
	_scaffold(10650, -250, 120)
	_pickup(HEALTH, 10650, -295)
	_coins_arc(10260, 6, 60, -330)
	_tower(10950, -260, 110)
	_enemy(RIFLE, 10950, -260)
	_scaffold(10740, -95, 100)
	_scaffold(10840, -180, 100)
	_enemy(ELITE, 11350, 0)
	_enemy(KNIFE, 11500, 0)
	_link(11800, "3. BAĞLANTI")

	# --- 8. Yayın odası: canlı yayın; son geçidi tut ------------------------------
	_checkpoint(12200, 0)
	_story(12300, _sahne_yayin)
	_fg("kolon", 12700.0, 40.0, 440.0)
	_fg("kolon", 13400.0, 40.0, 440.0)
	_fight(12650, 13450, _wave(KNIFE, ASSASSIN, KNIFE), _wave(ELITE, RIFLE, RIFLE), _wave(BRUISER, BRUISER))
	var revir: LevelShop = SHOP.new()
	revir.position = Vector2(13700, 0)
	revir.title = "SON KİLER"
	revir.items = PackedStringArray(["can", "cephane", "zirh"])
	revir.accent = Color("e7a449")
	add_child(revir)

	# --- 9. Köprü üstü: Yayın Şefi ------------------------------------------
	_checkpoint(13950, 0)
	_pickup(HEALTH, 14100, -45)
	_story(14250, _sahne_sef)
	_fight(14500, 15700, _wave(DIRECTOR), [])
	_story(15800, _sahne_nuzhet)
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(4075, "gazelle", "GAZELLE", "Göksu'daki mavna. Antenleri ışıl ışıl.")
	_radio(8965, "redmount", "REDMOUNT", "Üç bağlantı, bir jeneratör, bir Yayın Şefi.")
	_radio(13855, "gazelle", "GAZELLE", "Mikrofon bende. Bu kez şehir benim sesimi duyacak.")
	_goal(16300, 0)


## Kırılan yayın bağlantısı (kablo kutusu) + tabela.
func _link(x: float, title: String) -> void:
	var box := BREAKABLE_WALL.instantiate()
	box.set("hits_to_break", 5)
	box.position = Vector2(x, 0)
	add_child(box)
	var sign := _Sign.new()
	sign.text = title
	sign.position = Vector2(x, -260)
	add_child(sign)


## Main çağırır (bitişte): şafak, oyunun son sahnesi.
func play_ending(dialogue: Node) -> void:
	var cs := Cutscene.new()
	cs.trigger_x = -1.0
	cs.force_start = true
	cs.script_fn = _sahne_safak
	add_child(cs)
	await cs.done
	get_tree().paused = true
	dialogue.play([
		{"speaker": "İSTANBUL · SABAH", "text": "Kayıtlar çoğaltıldı. Suyu kesmeye, haberi susturmaya çalışanların adları sabah baskısıyla sokaklara çıktı."},
		{"speaker": "SON", "text": "Üç kitap. Bir şehir. Susturulamayan binlerce ses.\nREDMOUNT — İstanbul'un Sesi"},
	])
	await dialogue.finished
	get_tree().paused = false


# --- Hikâye sahneleri ----------------------------------------------------------

## Kıyı: mavna görünür.
func _sahne_kiyi(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Mavna şurada. Üç kalın kablo kıyıya bağlı: üç bağlantı.")
	await cs.say("rm", "REDMOUNT", "Ben bağlantıları keserim. Sen kayıtları korursun.")
	await cs.say("gz", "GAZELLE", "Su, mühürler, annem... Hepsi bu çantada. Şafakta şehir duyacak.")
	await cs.say("rm", "REDMOUNT", "Duyacak. Söz.")


## Jeneratör: Yayın Şefi hoparlörde.
func _sahne_jenerator(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("sf", "voice", Vector2(p.x + 300, -300))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("sf", "YAYIN ŞEFİ (hoparlör)", "Matbaayı aldınız, suyu açtınız. Sabah hangi habere inanacaklarını yine biz söyleriz.")
	await cs.say("rm", "REDMOUNT", "İki bağlantı gitti. Karadan emir alamıyorsunuz artık.")


## Kayıt arşivi: Gazelle kanıtları toplar.
func _sahne_arsiv(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	cs.pose("gz", "rescue_react")
	await cs.say("gz", "GAZELLE", "Asıllar burada! Nüzhet'in kendi sesinden emir kayıtları. Su, sevkiyatlar, susturulan matbaalar...")
	await cs.say("gz", "GAZELLE", "Ve annemin son röportajı. Yirmi yıldır bir kasette saklanmış.")
	await cs.say("rm", "REDMOUNT", "Hepsini al. Bu sabah hepsi okunacak.")


## Yayın odası: canlı yayın başlar.
func _sahne_yayin(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(60, 0), -1)
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Üç bağlantı kesildi. Yalnız bizim yayın açık. Kaseti takıyorum...")
	await cs.say("gz", "GAZELLE · CANLI YAYIN", "İstanbul, bu bir emir değil. Dinleyeceğiniz kayıtlar suyumuzu kesenlerin, haberimizi susturanların kendi sesleri.")
	await cs.say("gz", "GAZELLE", "Redmount, geçide geliyorlar! Kaset bitene kadar tut!")
	await cs.say("rm", "REDMOUNT", "Kimse bu kapıdan geçmeyecek.")


## Köprü üstü: Yayın Şefi.
func _sahne_sef(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("sf", "elite", Vector2(p.x + 500, 0), -1)
	await cs.pan(Vector2(p.x + 250, -200), 0.6)
	await cs.say("sf", "YAYIN ŞEFİ", "Bir kaseti durdurmak için bir düğme yeter.")
	await cs.say("rm", "REDMOUNT", "Kasetin kopyaları bütün kıyıda. Burada susturacağın kimse kalmadı.")
	await cs.say("sf", "YAYIN ŞEFİ", "O zaman seni susturayım.")
	await cs.move("sf", p.x + 900, 0.6, "walk")
	cs.remove("sf")


## Nüzhet teslim olur; Rıfat gelir.
func _sahne_nuzhet(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-90, 0))
	cs.actor("nz", "voice", Vector2(p.x + 320, -120))
	await cs.pan(Vector2(p.x + 150, -200), 0.6)
	await cs.say("nz", "NÜZHET HANIM", "Bir sesi susturmak için kırk yıl uğraştım. Sen bir gecede hepsini konuşturdun.")
	await cs.say("gz", "GAZELLE", "Annem de konuşuyordu. Siz sadece sesini kapatmıştınız. Ben açtım.")
	cs.actor("ko", "elite", Vector2(p.x - 400, 0))
	await cs.move("ko", p.x - 180, 0.8, "walk")
	await cs.say("ko", "KOMİSER RIFAT", "Nüzhet Hanım, bütün kıyı yayını dinledi. Sizi tutukluyorum.")
	await cs.say("ko", "KOMİSER RIFAT", "Gazelle Hanım... hakkınızdaki emir kaldırıldı. Ve özür dilerim.")
	await cs.say("gz", "GAZELLE", "Özrünüzü sabah baskısında yazarım, Komiser.")


## Şafak: son sahne.
func _sahne_safak(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(70, 0), -1)
	await cs.pan(Vector2(p.x + 40, -200), 0.8)
	await cs.say("gz", "GAZELLE", "Bitti. Yayın kesilmedi. Kıyıdan cevap geliyor; kayıtları herkes duydu.")
	await cs.say("rm", "REDMOUNT", "Seni almaya çıktığım gece bu kadar yolu görememiştim.")
	cs.pose("gz", "rescue_pose")
	await cs.say("gz", "GAZELLE", "O yolu tek başına yürümedin. İlk vapur kalkıyor... Balat'taki simit hâlâ geçerli mi?")
	await cs.say("rm", "REDMOUNT", "En güzeli. Ve bugün telefon gerçekten kapalı.")
	await cs.say("gz", "GAZELLE", "Neredeyse?")
	await cs.say("rm", "REDMOUNT", "Tamamen.")

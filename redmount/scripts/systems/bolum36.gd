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
	back_row_skip = [[3200.0, 18500.0]]
	_night(Color(0.76, 0.78, 0.94))

	# --- 1. Kıyı iskeleleri -------------------------------------------------
	_terrain(-400, 1800, 0)
	_story(-1.0, _sahne_kiyi, 240.0)
	_lantern(300)
	_lantern(1300)
	_enemy(KNIFE, 900, 0)
	_enemy(ASSASSIN, 1150, 0)
	_canal(1800, 2000, 110)
	_scaffold(1900, -20, 220)
	_terrain(2000, 18500, 0)

	# --- 2. Kayıkhane: arena; erzak ------------------------------------------
	_checkpoint(2150, 0)
	var kay: BattleArena = ARENA.instantiate()
	kay.position = Vector2(2800, 0)
	kay.gate_left_x = 2400
	kay.gate_right_x = 3200
	kay.floor_y = 0
	kay.wave1 = _wave(ELITE, KNIFE, RIFLE)
	kay.wave2 = _wave(BRUISER, ASSASSIN)
	kay.reward = AMMO
	add_child(kay)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(3450, 0)
	shop.title = "KAYIKHANE KİLERİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 3. Mavna rampası: 1. bağlantı --------------------------------------
	_checkpoint(3700, 0)
	_crates(3850, 1, 1)
	_crates(3940, 1, 2)
	_terrain(4030, 4400, -180)
	_enemy(RIFLE, 4350, -180)
	_link(4700, "1. BAĞLANTI")
	_enemy(ELITE, 5000, 0)

	# --- 4. Güverte altı: pistonlar, arena ----------------------------------
	_checkpoint(5250, 0)
	_press(5500, 0.0, 2.4)
	_press(5750, 0.33, 2.4)
	_press(6000, 0.66, 2.4)
	_coin_line(5470, 6, 105, -60)
	var gv: BattleArena = ARENA.instantiate()
	gv.position = Vector2(6650, 0)
	gv.gate_left_x = 6250
	gv.gate_right_x = 7050
	gv.floor_y = 0
	gv.wave1 = _wave(ELITE, KNIFE, ASSASSIN)
	gv.wave2 = _wave(MINIBOSS)
	gv.reward = HEALTH
	add_child(gv)

	# --- 5. Jeneratör: 2. bağlantı -------------------------------------------
	_checkpoint(7200, 0)
	_flame(7400, 0.0)
	_flame(7650, 0.5)
	_scaffold(7525, -230, 360)
	_pickup(RIFLE_PICKUP, 7525, -275)
	_link(8000, "2. BAĞLANTI")
	_story(8100, _sahne_jenerator)

	# --- 6. Kayıt arşivi: raflar ---------------------------------------------
	_checkpoint(8350, 0)
	_crates(8500, 1, 1)
	for k in 4:
		_scaffold(8660.0 + k * 160.0, -150.0 - (k % 2) * 100.0, 140)
		_pickup(COIN, 8660.0 + k * 160.0, -200.0 - (k % 2) * 100.0)
	_pickup(ARMOR, 9140, -295)
	_enemy(ELITE, 9400, 0)
	_story(9600, _sahne_arsiv)

	# --- 7. Anten güvertesi: vinç, 3. bağlantı, arena -------------------------
	_checkpoint(9850, 0)
	_scaffold(10000, -130, 120)
	_scaffold(10000, -240, 120)
	_moving(10200, -250, Vector2(320, 0), 140, 0.0)
	_scaffold(10650, -250, 120)
	_pickup(HEALTH, 10650, -295)
	var ant: BattleArena = ARENA.instantiate()
	ant.position = Vector2(11300, 0)
	ant.gate_left_x = 10900
	ant.gate_right_x = 11700
	ant.floor_y = 0
	ant.wave1 = _wave(ELITE, RIFLE, KNIFE)
	ant.wave2 = _wave(BRUISER, ELITE)
	ant.reward = AMMO
	add_child(ant)
	_link(11950, "3. BAĞLANTI")

	# --- 8. Yayın odası: canlı yayın; son geçidi tut ---------------------------
	_checkpoint(12200, 0)
	_story(12300, _sahne_yayin)
	var gecit: BattleArena = ARENA.instantiate()
	gecit.position = Vector2(13050, 0)
	gecit.gate_left_x = 12650
	gecit.gate_right_x = 13450
	gecit.floor_y = 0
	gecit.wave1 = _wave(KNIFE, ASSASSIN, KNIFE)
	gecit.wave2 = _wave(ELITE, RIFLE, RIFLE)
	gecit.wave3 = _wave(BRUISER, BRUISER)
	gecit.reward = HEALTH
	add_child(gecit)
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
	var duel: BattleArena = ARENA.instantiate()
	duel.position = Vector2(15100, 0)
	duel.gate_left_x = 14500
	duel.gate_right_x = 15700
	duel.floor_y = 0
	duel.wave1 = _wave(DIRECTOR)
	duel.reward = HEALTH
	add_child(duel)
	_story(15800, _sahne_nuzhet)
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

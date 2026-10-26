## Bölüm 16 — Süleymaniye Arşivi (Kitap 2 / "Haliç'in İzi", 4. bölüm).
##
## Zeyrek vanasının kaydı Süleymaniye'de bir ciltçi deposuna çıkar. Sokaklar ve
## servis binaları (ibadet alanlarına girilmez): yokuş -> ciltçiler sokağı (arena)
## -> dış avlu servis yolu (devriye, taş seki) -> kâğıt imalathanesi (asma yol) -> cilt atölyesi ->
## belge odası (arena) -> arşiv mahzeni -> arka teras (asıl liste: Beyazıt posta
## hattı). Kâtip'in "yardım malzemesi" kılıfı ortaya çıkar.
extends DtmLevel

const STREETS := preload("res://assets/backgrounds/book02_suleymaniye_streets_atlas.png")
const ARCHIVE := preload("res://assets/backgrounds/book02_suleymaniye_archive_atlas.png")


func _build() -> void:
	sky_atlas = STREETS
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3300.0], [3, 4800.0],
		[0, 6200.0, ARCHIVE], [1, 7600.0, ARCHIVE], [2, 8800.0, ARCHIVE], [3, 9450.0, ARCHIVE]]
	sky_tint = Color(0.92, 0.9, 0.86)
	sky_shade = Color(0.06, 0.05, 0.06)
	back_row_skip = [[4400.0, 9600.0]]

	# --- 1. Süleymaniye yokuşu: devriye, ilk çatı rotası ----------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_yokus, 240.0)
	var aw := AwningBounce.new()
	aw.width = 160
	aw.height = 60
	aw.position = Vector2(560, 0)
	add_child(aw)
	_scaffold(760, -260, 160)
	_scaffold(960, -300, 160)
	_pickup(ARMOR, 960, -345)
	_coin_line(720, 4, 70, -310)
	_enemy(STREET, 900, 0)
	_prop("saksi", 1250)

	# --- 2. Ciltçiler sokağı: sokak hizasında; saçak ödülü; arena; erzak ----------
	# Kitap 2'nin ortak çukur avlusu yerine dar sokak düz; cumbalar arenanın önünde.
	_checkpoint(1550, 0)
	_terrain(1700, 9900, 0)
	_balcony(2000, -40, 110)
	_balcony(2160, -140, 110)
	_coin_line(2120, 3, 50, -190)
	_prop("kasa", 2100, 0)
	var bind: BattleArena = ARENA.instantiate()
	bind.position = Vector2(2550, 0)
	bind.gate_left_x = 2250
	bind.gate_right_x = 2900
	bind.floor_y = 0
	bind.wave1 = _wave(STREET, KNIFE, STREET)
	bind.wave2 = _wave(SHIELD, RIFLE)
	bind.reward = AMMO
	add_child(bind)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(3100, 0)
	shop.title = "CİLTÇİ ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 3. Dış avlu servis yolu: revak önünde devriye; taş sekiden üst rafa -------
	# Drenaj kanalı yerine düz avlu (külliye avlusunda açık kanal yere ait değildi):
	# arena + erzaktan sonra nefes. İki kişilik devriye; taş sekiden rafa, tepede tabanca.
	_checkpoint(3500, 0)
	_enemy(STREET, 3800, 0)
	_enemy(KNIFE, 3950, 0)
	_stones(4150, 1, 1)
	_scaffold(4300, -140, 130)
	_scaffold(4450, -250, 130)
	_pickup(PISTOL, 4450, -295)
	_enemy(SHIELD, 4700, 0)

	# --- 4. Kâğıt imalathanesi: tüfekli; isteğe bağlı asma yol ------------------
	_checkpoint(4900, 0)
	_interior(4980, 6150, -345, [], 0)
	_crates(5050, 1, 1)
	_crates(5140, 1, 2)
	## Tüfekli tünek malzemesi yere göre: tüfekli kurutma iskelesinde (tek yön: altından geçilir, alttan çıkılır).
	_scaffold(5365, -180, 270)
	_enemy(RIFLE, 5440, -180)
	_moving(5650, -210, Vector2(250, 0), 130, 0.0)
	_scaffold(6030, -210, 120)
	_pickup(RIFLE_PICKUP, 6030, -255)
	_coin_line(5660, 4, 70, -270)
	_prop("varil", 5800)

	# --- 5. Cilt atölyesi: raf üstü ödül --------------------------------------------
	# Atölye ve mahzen kapalı odalar: eski plank'lı kanallar kaldırıldı (içeride su yok).
	_checkpoint(6250, 0)
	_interior(6330, 6860, -345, [], 1)
	_crates(6400, 1, 1)
	_scaffold(6560, -150, 140)
	_scaffold(6720, -250, 140)
	_pickup(ARMOR, 6720, -295)
	_enemy(ASSASSIN, 7300, 0)
	_story(6450, _sahne_atolye)

	# --- 6. Belge odası: seçkin + menzilli arena ----------------------------------
	_checkpoint(7450, 0)
	_interior(7560, 8400, -345, [], 0)
	_scaffold(7800, -120, 160)
	_scaffold(8150, -120, 160)
	_prop("vazo", 7650)
	_prop("sandik", 8250, 0, AMMO)
	var docs: BattleArena = ARENA.instantiate()
	docs.position = Vector2(7950, 0)
	docs.gate_left_x = 7600
	docs.gate_right_x = 8350
	docs.floor_y = 0
	docs.wave1 = _wave(ELITE, RIFLE)
	docs.wave2 = _wave(ELITE, KNIFE, RIFLE)
	docs.reward = HEALTH
	add_child(docs)

	# --- 7. Arşiv mahzeni: seçkin devriye ---------------------------------------
	_checkpoint(8500, 0)
	_enemy(ELITE, 9050, 0)
	for x in [8550, 9150]:
		_lantern(float(x))
	# Mahzen: kaya tavan, ön planda kemer ayakları.
	for cx in [8600.0, 9000.0]:
		_fg("kolon", cx, 40.0, 380.0)

	# --- 8. Arka teras: son arena, asıl liste ---------------------------------
	_checkpoint(9250, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9550, 0)
	final.gate_left_x = 9330
	final.gate_right_x = 9780
	final.floor_y = 0
	## Dar teras: önce çatı katının hızlıları, sonra kalkanlının arkasından bombacı.
	final.wave1 = _wave(ASSASSIN, KNIFE)
	final.wave2 = _wave(SHIELD, BOMBER)
	final.reward = HEALTH
	add_child(final)
	_story(9830, _sahne_liste)
	_han_gate(10000, "BEYAZIT YOLU")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2500, "gazelle", "GAZELLE", "Ciltçiler sokağı. Babam beni buraya getirirdi, kâğıt kokusu...")
	_radio(5500, "redmount", "REDMOUNT", "Kâğıt kokusu artık barut kokusu.")
	_radio(8500, "gazelle", "GAZELLE", "Asıl liste! Kemal Bey'in adı... editörüm. Olamaz.")
	_goal(10000, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Yokuş: Gazelle'in planı.
func _sahne_yokus(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Ciltçi deposu ciltçiler sokağının sonunda. Kayıtlarda 'yardım malzemesi' yazıyor.")
	await cs.say("rm", "REDMOUNT", "Silah ve kaçak mal, yardım kolisi kılığında. Kâtip iyi yalan yazıyor.")
	await cs.say("gz", "GAZELLE", "İyi yalan, kötü arşiv bırakır. Asıl liste bir yerde duruyor olmalı.")


## Cilt atölyesi: yaşlı ciltçi gerçeği söyler.
func _sahne_atolye(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("ust", "voice", Vector2(p.x + 220, -150))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("ust", "YAŞLI CİLTÇİ (tezgâhın ardından)", "Ben sadece cilt yaparım evlat. Ama o adamlar bana boş defterleri ciltletti.")
	await cs.say("ust", "YAŞLI CİLTÇİ", "Kâtip Efendi kendi eliyle dolduruyormuş. Asıl liste arka terasta, mühürlü bir sandıkta.")
	await cs.say("gz", "GAZELLE", "Kâtip Efendi'yi gördünüz mü? Yüzünü?")
	await cs.say("ust", "YAŞLI CİLTÇİ", "Görmedim. Yalnız eldivenlerini... mürekkep lekeli beyaz eldivenler.")


## Arka teras: asıl liste, Beyazıt adresi.
func _sahne_liste(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(9920, -200), 0.6)
	cs.pose("gz", "rescue_react")
	await cs.say("gz", "GAZELLE", "Asıl liste burada! Mühürlü üç çuval... Beyazıt'taki eski posta hattına gitmiş.")
	await cs.say("rm", "REDMOUNT", "Posta. Bir kâtip için ne güzel bir saklanma yeri.")
	await cs.say("gz", "GAZELLE", "Listenin altında bir imza var: sadece bir 'K' ve mürekkep lekesi.")
	await cs.say("rm", "REDMOUNT", "Beyaz eldiven, mürekkep, K. Yaklaşıyoruz.")

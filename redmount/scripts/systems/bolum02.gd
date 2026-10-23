## Bölüm 2 — Arka Sokak İzi (Kitap 1 / "Gazelle'in İzi").
##
## Konvoy Gazelle'i Kuzey Hanı'ndan arka sokaklara çıkardı. Redmount film rulosunu
## bulur, çift katlı sokakta konvoyu görür, kanalı vinç paletiyle geçer, çeşme
## meydanındaki pusuyu kırar, çatıdan iki kabadayının konuşmasını dinleyip rotayı
## (gece pazarı) öğrenir, Kasap Rıza'yı yener ve Gazelle'in tebeşir işaretini bulur.
extends DtmLevel


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/book02_cibali_streets_atlas.png")
	sky_cells = [[0, -100000.0], [1, 3500.0]]
	sky_tint = Color(0.86, 0.8, 0.8)

	# --- 1. Kuzey Hanı arka avlusu: film rulosu, avluda kavga --------------------
	_terrain(-400, 3700, 0)
	_han_gate(-60, "KUZEY HANI")
	_story(-1.0, _sahne_film_rulosu, 200.0)
	_deco(PLANT, 160, 0, 0.9)
	_prop("saksi", 300)
	_prop("vazo", 360)
	_coin_line(420, 4, 50, -50)
	_enemy(STREET, 700, 0)
	_enemy(STREET, 830, 0)
	_enemy(KNIFE, 960, 0)
	_prop("kasa", 1120)
	_prop("varil", 1190)
	_deco(TREE_POT, 1260, 0, 1.0)

	# --- 2. Çift katlı arka sokak: altta düşmanlar, üstte iskele yolu ------------
	_checkpoint(1330, 0)
	var awning := AwningBounce.new()
	awning.width = 160
	awning.height = 60
	awning.position = Vector2(1440, 0)
	add_child(awning)
	# Üst yol: iskele yürüme yolu (tek yön), arada küçük atlamalar ve bir tepe.
	_scaffold(1600, -230, 200)
	_scaffold(1860, -230, 200)
	_scaffold(2110, -230, 180)
	_scaffold(2360, -300, 180)
	_scaffold(2610, -230, 200)
	_scaffold(2870, -230, 200)
	_scaffold(3120, -260, 200)
	for x in [1540, 1600, 1660, 1800, 1860, 1920, 2050, 2110, 2170, 2560, 2620, 2680, 2810, 2870, 2930, 3060, 3120, 3180]:
		_pickup(COIN, float(x), -285 if x < 3000 else -315)
	_pickup(ARMOR, 2360, -345)
	_prop("vazo", 2610, -230)
	# Alt yol: sandıklar, bıçaklı, kabadayı, tüfekli.
	_crates(1700, 1, 1)
	_enemy(KNIFE, 2000, 0)
	_enemy(STREET, 2300, 0)
	_crates(2600, 1, 1)
	_crates(2690, 1, 2)
	# Sökük kaldırım: tüfekliye yaklaşmadan menzilden cevap verilsin (üç taş).
	_pickup(STONES, 2480, -45)
	_enemy(RIFLE, 3050, 0)
	_prop("saksi", 3250)
	_prop("vazo", 3320)
	_story(2150, _sahne_konvoy_gecer)

	# --- 3. Kanal: vinç paleti; düşen sığ suda yürür, basamaktan çıkar -------------
	_checkpoint(3500, 0)
	_canal(3700, 4150, 100)
	_terrain(4100, 4150, 50)
	_moving(3790, -30, Vector2(260, 0), 150)
	_coin_line(3800, 5, 60, -110)
	_terrain(4150, 6000, 0)

	# --- 4. Çeşme meydanı: kilitli arena -----------------------------------------
	_checkpoint(4320, 0)
	_stall(4640)
	_stall(5320)
	_pickup(BAT, 4600, -45)
	_prop("vazo", 4760)
	_prop("kasa", 4900)
	_prop("saksi", 5150)
	_prop("varil", 5420)
	_scaffold(5000, -150, 220)
	_coin_line(4920, 4, 55, -200)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(5000, 0)
	arena.gate_left_x = 4480
	arena.gate_right_x = 5520
	arena.floor_y = 0
	arena.wave1 = _wave(STREET, KNIFE, STREET)
	arena.wave2 = _wave(KNIFE, RIFLE)
	arena.wave3 = _wave(BRUISER, STREET)
	arena.reward = HEALTH
	add_child(arena)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5720, 0)
	shop.title = "ARKA SOKAK BAKKALI"
	shop.items = PackedStringArray(["can", "bicak", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Çatıdan gizli dinleme: sokak bina ile kapanır, yol çatılardan ---------
	_checkpoint(5880, 0)
	_terrain(6000, 9800, 0)
	var aw2 := AwningBounce.new()
	aw2.width = 180
	aw2.height = 60
	aw2.position = Vector2(5910, 0)
	add_child(aw2)
	# Tenteden sekmeyi kaçıran için evin önünde bir balkon basamağı.
	_balcony(5962, -125, 70)
	var h1 := _house(6000, -220, 0)
	_prop("saksi", h1 - 120, -220)
	_balcony(h1 + 45, -110, 90)
	_balcony(h1 + 115, -195, 90)
	var h2 := _house(h1 + 160, -280, 1)
	_coin_line(h2 - 170, 3, 55, -330)
	_building(h2, 6980, -300)
	_coin_line(h2 + 40, 5, 60, -350)
	_story(h2 - 100, _sahne_gizli_dinleme)
	# Çatıdan inilen sokakta Kasap Rıza'nın iki katlı dükkânı: adamları katlarda.
	_interior(7050, 7550, -230, [-115.0], 1)
	_enemy(STREET, 7200, 0)
	_enemy(KNIFE, 7420, -115)
	_prop("kasa", 7480, 0, COIN)
	_coin_line(7100, 5, 60, -160)
	_pickup(HEALTH, 7500, -160)

	# --- 6. Son avlu: Kasap Rıza + tebeşir işareti -------------------------------
	_checkpoint(7600, 0)
	_story(7700, _sahne_kasap_riza)
	_stall(8100)
	_prop("varil", 7950)
	_prop("vazo", 8550)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(8300, 0)
	final.gate_left_x = 7820
	final.gate_right_x = 8800
	final.floor_y = 0
	final.wave1 = _wave(STREET, KNIFE)
	final.wave2 = _wave(BRUISER)
	final.wave3 = _wave(KNIFE, STREET, ASSASSIN)
	final.reward = HEALTH
	add_child(final)
	# Avlunun ucundaki eski baca: duvar-zıplamayla tepede coin zulası.
	_chimney(8980, -520, 140, 150)
	_chalk(9200, -190, "G: GECE PAZARI")
	_story(9100, _sahne_tebesir)
	_coin_line(9250, 4, 50, -50)
	# Çevresel tehlikeler.
	_falling_pot(5962, -129)
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2387, "redmount", "REDMOUNT", "Film rulosu... Gazelle bunu bilerek düşürdü. İz bırakıyor.")
	_radio(5252, "telsiz", "KONVOY (telsiz)", "Arka sokaktan çıkıyoruz. Kız sessiz, ama gözleri her şeyi kaydediyor.")
	_radio(7830, "karahanli", "KARAHANLI (telsiz)", "Kasap Rıza'yı geçersen gece pazarında görüşürüz. Geçemezsin.")
	_goal(9550, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Kuzey Hanı'nın arka kapısı: Gazelle'in düşürdüğü film rulosu.
func _sahne_film_rulosu(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	await cs.pan(Vector2(300, -170), 0.01)
	await cs.move("rm", 200, 1.0, "walk")
	await cs.say("rm", "REDMOUNT", "Han bomboş. Arka kapı açık... lastik izleri taze.")
	cs.pose("rm", "crouch")
	await cs.wait(0.5)
	await cs.say("rm", "REDMOUNT", "Bu... Gazelle'in film rulosu. Kutusunu ezip kapının dibine bırakmış.")
	cs.pose("rm", "idle")
	await cs.say("rm", "REDMOUNT", "Bilerek düşürdü. Karahanlı'nın aradığı fotoğraflardan biri şimdi bende.")
	await cs.say("rm", "REDMOUNT", "İz bırakıyor. Tamam Gazelle, ben de takip ediyorum.")
	cs.actor("t1", "thug", Vector2(900, 0), -1)
	cs.actor("t2", "knife", Vector2(980, 0), -1)
	await cs.pan(Vector2(560, -170), 0.6)
	await cs.say("t1", "KABADAYI", "Patron haklıymış, peşimizden gelmiş. Konvoyun izini burada kaybettirin dedi.")
	await cs.say("rm", "REDMOUNT", "Konvoyu soran yok. Ben size nereye gittiğini soracağım.")
	await cs.move("t2", 960, 0.3, "walk")


## Çift katlı sokak: konvoy alttan geçer, Gazelle camı yumruklar.
func _sahne_konvoy_gecer(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("bus", "bus", Vector2(p.x - 900, 0), 1)
	await cs.pan(Vector2(p.x + 200, -200), 0.5)
	cs.move("bus", p.x + 1600, 3.0, "", false)
	await cs.wait(0.9)
	await cs.say("bus", "GAZELLE", "REDMOUNT! Buradayım! Camı açmıyorlar!", 1.8)
	await cs.say("bus", "KABADAYI", "Otur yerine! Bas gaza, bas!", 1.4)
	await cs.say("rm", "REDMOUNT", "Hızlılar... Ama bu sokaklar dar. Nereye dönerlerse orada olacağım.")


## Çatıdan gizli dinleme: aşağıdaki iki adam rotayı ele verir.
func _sahne_gizli_dinleme(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("t1", "thug", Vector2(7150, 0), 1)
	cs.actor("t2", "knife", Vector2(7240, 0), -1)
	cs.pose("rm", "crouch")
	await cs.say("rm", "REDMOUNT", "Şşş... Aşağıda iki kişi konuşuyor.", 1.6)
	await cs.pan(Vector2(7120, -170), 0.8)
	await cs.say("t1", "KABADAYI", "Konvoy rayların oradaki depoya gidiyormuş. Trene yüklenecek.")
	await cs.say("t2", "BIÇAKÇI", "Önce gece pazarından geçecekler. Patron, pazardaki çocuklar herifi orada karşılasın dedi.")
	await cs.say("t1", "KABADAYI", "Kız da bayağı inatçıymış. Yol boyu camı tekmeleyip durmuş.")
	await cs.say("t2", "BIÇAKÇI", "Karahanlı'nın derdi kız değil, fotoğraflar. Film rulolarından biri kayıpmış.")
	await cs.pan(Vector2(p.x + 150, -260), 0.6)
	await cs.say("rm", "REDMOUNT", "Kayıp rulo bende. Gece pazarı, sonra raylar... Önce şu ikisi.")


## Kasap Rıza: avlunun bekçisi, son kavga öncesi.
func _sahne_kasap_riza(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("rz", "bruiser", Vector2(8280, 0), -1)
	await cs.pan(Vector2(8050, -180), 0.7)
	await cs.say("rz", "KASAP RIZA", "Demek film rulosunu taşıyan sensin. Patron hem ruloyu hem kemiklerini istiyor.")
	await cs.say("rm", "REDMOUNT", "Kemiklerim bende kalsın. Sen konvoyun gittiği yolu söyle.")
	await cs.say("rz", "KASAP RIZA", "Yolu öğrenmek için önce benim avlumdan geçmen lazım. Çocuklar, kapıları kapatın!")
	await cs.move("rz", 8700, 0.6, "walk")
	cs.remove("rz")


## Tebeşir işareti: Gazelle'in bıraktığı yön.
func _sahne_tebesir(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	await cs.pan(Vector2(9180, -170), 0.6)
	await cs.say("rm", "REDMOUNT", "Duvarda tebeşirle bir işaret... G harfi ve bir ok.")
	await cs.say("rm", "REDMOUNT", "'Gece Pazarı.' Minibüsün camından tebeşir atmış olmalı. Akıllı kız.")
	await cs.say("rm", "REDMOUNT", "Pazarda bir pusu bekliyor beni. Olsun. Geliyorum, Gazelle.")

## Bölüm 4 — Silahlı Kontrol Bölgesi (Kitap 1 / "Gazelle'in İzi").
##
## Şehir çıkışı kuleler, kum torbaları ve projektörlerle kapalı. Redmount tepeden
## konvoyun bariyerden kontrolsüz geçişini görür; siperden sipere ilerleyip kuleleri
## temizler, telsizden "kız yük trenine aktarıldı" haberini, kontrol kulübesinin
## defterinden Gazelle'in kazıdığı izi bulur, hendek üstündeki kule köprüsünü geçer,
## bariyerde Yüzbaşı Demir'i yener. Uzaktan tren düdüğü: sıradaki durak demiryolu.
extends DtmLevel

const BOOTH := preload("res://assets/environment/mahalle/bufe.png")


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/level02_armed_checkpoint.png")
	sky_grid = 1
	sky_cells = [[0, -100000.0]]
	sky_tint = Color(0.9, 0.9, 1.0)
	sky_shade = Color(0.03, 0.03, 0.07)
	back_tint = Color(0.26, 0.28, 0.4)
	_night(Color(0.68, 0.7, 0.86))
	($PlayerSpawn as Node2D).position = Vector2(80, -160)

	# --- 1. Tepe: gözlem; inişte ilk karşılaşma ---------------------------------
	_terrain(-400, 700, -120)
	_terrain(700, 800, -80)
	_terrain(800, 900, -40)
	_terrain(900, 6200, 0)
	_story(-1.0, _sahne_tepe, 220.0)
	_prop("saksi", 420, -120)
	_prop("vazo", 520, -120)
	_coin_line(720, 4, 50, -140)
	_enemy(STREET, 1150, 0)
	_enemy(KNIFE, 1300, 0)
	_prop("kasa", 1420)
	_lantern(1000)

	# --- 2. Ateş hattı: kum torbaları, kuleye tırmanış, tepede tüfekli ------------
	_checkpoint(1560, 0)
	_sandbags(1800, 120)
	_sandbags(2130, 120)
	_coin_line(1780, 3, 70, -120)
	_scaffold(2340, -110, 120)
	_scaffold(2340, -220, 120)
	_tower(2450, -320)
	_enemy(RIFLE, 2450, -320)
	_pickup(COIN, 2340, -270)
	_sandbags(2750, 100)
	_sandbags(2880, 100)
	_enemy(RIFLE, 3020, 0)
	_hint(2900, "Kalkanlı Zabıta: arkasından vur, çömel tekmesiyle altından gir ya da ağır yumrukla (K) kalkanını düşür.", "heavy_attack")
	_enemy(SHIELD, 3150, 0)
	_prop("varil", 3080)
	_sandbags(3300, 110)
	_story(3230, _sahne_telsiz)

	# --- 3. Kontrol kulübesi: kayıt defteri; kilitli arena -----------------------
	_checkpoint(3520, 0)
	_deco(BOOTH, 3800, 0, 0.75, true, -12)
	_story(3740, _sahne_defter)
	# Arena içinde siper yok: düşmanlar siperi aşamaz, dövüş takılır.
	_scaffold(4650, -170, 200)
	_coin_line(4590, 3, 55, -220)
	_prop("vazo", 4200)
	_prop("kasa", 4560)
	_prop("varil", 5150)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(4650, 0)
	arena.gate_left_x = 4000
	arena.gate_right_x = 5300
	arena.floor_y = 0
	arena.wave1 = _wave(RIFLE, STREET, KNIFE)
	arena.wave2 = _wave(RIFLE, RIFLE, BRUISER)
	arena.wave3 = _wave(ASSASSIN, KNIFE, RIFLE)
	arena.reward = HEALTH
	add_child(arena)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5520, 0)
	shop.title = "SINIR KANTİNİ"
	shop.items = PackedStringArray(["can", "zirh", "cephane"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 4. Hendek ve kule köprüsü ------------------------------------------------
	_checkpoint(5700, 0)
	_scaffold(5840, -110, 120)
	_scaffold(5840, -210, 120)
	_tower(5950, -300)
	_enemy(RIFLE, 5950, -300)
	# Kuleler arası tahta köprü (tek yön); altta kuru hendek.
	for k in 5:
		_scaffold(6130.0 + k * 170.0, -300, 150)
		_pickup(COIN, 6130.0 + k * 170.0, -350)
	_pickup(ARMOR, 6470, -395)
	_terrain(6200, 6600, 110)
	_terrain(6550, 6600, 55)
	_terrain(6600, 9600, 0)
	_prop("vazo", 6300, 110)
	_prop("saksi", 6420, 110)
	_enemy(KNIFE, 6720, 0)
	_scaffold(6890, -110, 120)
	_scaffold(6890, -220, 120)
	_tower(7000, -320)
	_enemy(RIFLE, 7000, -320)
	_sandbags(7150, 100)

	# --- 5. Bariyer: Yüzbaşı Demir; tren düdüğü -----------------------------------
	_checkpoint(7320, 0)
	_story(7440, _sahne_demir)
	_sandbags(7460, 100)
	_prop("kasa", 8100)
	_prop("vazo", 8700)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(8250, 0)
	final.gate_left_x = 7600
	final.gate_right_x = 8900
	final.floor_y = 0
	final.wave1 = _wave(RIFLE, KNIFE, STREET)
	final.wave2 = _wave(ELITE)
	final.wave3 = _wave(ELITE, RIFLE)
	final.reward = HEALTH
	add_child(final)
	_lantern(9000)
	_story(9050, _sahne_duduk)
	_coin_line(9100, 3, 50, -50)
	_han_gate(9350, "ŞEHİR ÇIKIŞI")
	_goal(9350, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Tepeden gözlem: konvoy bariyerden kontrolsüz geçer, Yüzbaşı Demir emir verir.
func _sahne_tepe(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(120, -120))
	await cs.pan(Vector2(380, -260), 0.01)
	await cs.move("rm", 220, 0.8, "walk")
	await cs.say("rm", "REDMOUNT", "Şehrin çıkışı. Kuleler, siperler, projektörler... Karahanlı burayı kale gibi tutmuş.")
	cs.actor("g1", "rifle", Vector2(1450, 0), -1)
	cs.actor("dm", "elite", Vector2(1600, 0), -1)
	cs.actor("bus", "bus", Vector2(600, 0), 1)
	await cs.pan(Vector2(1150, -200), 1.0)
	cs.move("bus", 2600, 3.2, "", false)
	await cs.wait(0.8)
	await cs.say("g1", "MUHAFIZ", "Geç! Karahanlı Bey'in konvoyu. Kontrol yok!", 1.6)
	await cs.say("bus", "GAZELLE", "İmdat! Beni kaçırıyorlar! Kimse duymuyor mu?!", 1.8)
	await cs.say("dm", "YÜZBAŞI DEMİR", "Duymuyoruz hanımefendi. Kimse duymayacak.")
	await cs.say("dm", "YÜZBAŞI DEMİR", "Projektörler açık kalsın. Redmount denen adam bu hattı geçerse hepinizi trene ben bindiririm.")
	await cs.pan(Vector2(380, -260), 0.8)
	await cs.say("rm", "REDMOUNT", "Bağırıyor... iyi. Ne kadar gürültü yaparsa o kadar zor saklarlar.")
	await cs.say("rm", "REDMOUNT", "Siperden sipere. Başımı kaldırmadan. Kulelerdeki tüfeklileri önce susturmalıyım.")


## Siper arkasında: muhafızın telsizi rotayı söyler.
func _sahne_telsiz(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("telsiz", "voice", Vector2(p.x + 260, -150))
	cs.pose("rm", "crouch")
	await cs.say("rm", "REDMOUNT", "Kum torbalarının arkasında bir telsiz cızırdıyor...", 1.6)
	await cs.say("telsiz", "TELSİZ", "Kontrol İki'den merkeze: kız yük trenine aktarıldı. Altıncı peron.")
	await cs.say("telsiz", "TELSİZ", "Tekrar ediyorum, kadın yolcu trende. Konvoy geri dönüyor.")
	cs.pose("rm", "idle")
	await cs.say("rm", "REDMOUNT", "Yük treni, altıncı peron. Önce bu hattı geçmem gerek.")


## Kontrol kulübesi: kayıt defterinde Gazelle'in izi.
func _sahne_defter(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	await cs.pan(Vector2(3800, -170), 0.5)
	await cs.say("rm", "REDMOUNT", "Kontrol kulübesi boş. Masada açık bir kayıt defteri...")
	await cs.say("rm", "REDMOUNT", "'Yolcu: 1 kadın. Karahanlı Bey'in emriyle. Yük treni, 6. peron. Kontrol edilmedi.'")
	await cs.say("rm", "REDMOUNT", "Sayfanın kenarına biri tırnağıyla bir harf kazımış: 'G'. Gazelle buradaydı.")
	cs.actor("t1", "rifle", Vector2(4500, 0), -1)
	await cs.say("t1", "MUHAFIZ", "Hey! Kulübeden uzak dur! Alarm! ALARM!", 1.6)


## Bariyer: Yüzbaşı Demir'in karşılaması.
func _sahne_demir(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("dm", "elite", Vector2(8100, 0), -1)
	cs.actor("g1", "rifle", Vector2(8250, 0), -1)
	await cs.pan(Vector2(7800, -180), 0.7)
	await cs.say("dm", "YÜZBAŞI DEMİR", "Kuleleri tek tek düşürdün. Takdir ediyorum. Ama bariyer benim.")
	await cs.say("rm", "REDMOUNT", "Bir kızı kaçırıp kontrolsüz geçirdin. Bariyerin de rütben de bu gece düşüyor.")
	await cs.say("dm", "YÜZBAŞI DEMİR", "Kalkanımı geçemeyen çok kahraman gördüm. Kapıları kapatın!")
	cs.move("g1", 8800, 0.6, "walk", false)
	await cs.move("dm", 8750, 0.6, "walk")
	cs.remove("dm")
	cs.remove("g1")


## Hat düştü: uzaktan tren düdüğü.
func _sahne_duduk(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("tren", "voice", Vector2(p.x + 500, -260))
	await cs.pan(Vector2(p.x + 250, -200), 0.5)
	await cs.say("tren", "UZAKTAN", "DÜÜÜÜÜT!", 1.4)
	await cs.say("rm", "REDMOUNT", "Tren düdüğü... Yük treni hareket ediyor!")
	await cs.say("rm", "REDMOUNT", "Gazelle o trende. Raylara! Yetişmeliyim!")

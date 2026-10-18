## Bölüm 1 — Balat Sokakları (Kitap 1 / "Gazelle'in İzi").
##
## Dan the Man tarzı kısa, yoğun bölüm: Gazelle'in kaçırılışı (oyun içi sahne) ->
## açık sokakta ilk kavga -> tenteyle çatılara (minibüs görülür) -> taş set + gizli
## oda -> kilitli pazar meydanı (3 dalga) -> büfe -> inşaat iskelesi + vinç paleti ->
## Kuzey Hanı kapısında son kavga ve Karahanlı. `--ornek` de bu bölümü açar.
extends DtmLevel


func _build() -> void:
	sky_cells = [[0, -100000.0], [2, 4500.0]]

	# --- 1. Balat girişi: kaçırılma sahnesi, kırılanlar, açık sokakta ilk kavga ---
	_terrain(-400, 2200, 0)
	_story(-1.0, _sahne_kacirma, 470.0)
	_deco(PLANT, 40, 0, 0.9)
	_deco(TREE_POT, 560, 0, 1.0)
	_prop("saksi", 330)
	_prop("vazo", 400)
	_coin_line(470, 4, 55, -50)
	# İlk kavga geniş, düz sokakta: iki kabadayı, arkalarında kırılacak ödül.
	_hint(640, "Koşarken çömel: kayma tekmesi düşmanı ayağından alır.", "slide")
	_hint(150, "Sağa değil sola bak: çatlak duvarların ardında gizli alanlar var.", "")
	_enemy(STREET, 820, 0)
	_enemy(STREET, 960, 0)
	_prop("kasa", 1050)
	_prop("vazo", 1110)

	# --- 2. Tente -> çatılar ---------------------------------------------------
	# Tezgâh evin duvarına dayalı: duvara çarpan yeniden tenteye düşer.
	var awning := AwningBounce.new()
	awning.width = 180
	awning.height = 60
	awning.position = Vector2(1200, 0)
	add_child(awning)
	_coins_arc(1150, 5, 45, -330)
	var h1 := _house(1290, -240, 0)
	_coin_line(h1 - 170, 3, 55, -290)
	_enemy(KNIFE, h1 - 60, -240)
	# Ara sokak: düşen oyuncu karşı evin balkonlarıyla yeniden çatıya çıkar.
	_balcony(h1 + 45, -110, 90)
	_balcony(h1 + 115, -195, 90)
	_coins_arc(h1 + 20, 3, 60, -360)
	var h2 := _house(h1 + 160, -280, 1)
	_coin_line(h2 - 170, 3, 55, -330)
	_pickup(HEALTH, h2 - 40, -320)
	_prop("saksi", h1 - 150, -240)
	_prop("vazo", h2 - 120, -280)
	# Çatıdan minibüs görülür: Gazelle pencereden seslenir.
	_story(h1 - 150, _sahne_catidan_minibus)

	# --- 3. Taş set, tüfekli, gizli oda ---------------------------------------
	_checkpoint(2280, 0)
	_terrain(2200, 2480, 0)
	_terrain(2480, 2580, -45)
	_terrain(2580, 3060, -90)
	_terrain(3060, 3160, -45)
	_terrain(3160, 3700, 0)
	_enemy(KNIFE, 2380, 0)
	_prop("vazo", 2640, -90)
	_prop("saksi", 2700, -90)
	_enemy(RIFLE, 2900, -90)
	_coin_line(2650, 6, 70, -150)
	_prop("vazo", 3010, -90)
	_secret_han(3350)

	# --- 4. Pazar meydanı: kapılar kapanır, 3 dalga ----------------------------
	_checkpoint(3780, 0)
	_terrain(3700, 5300, 0)
	_story(3810, _sahne_pazar_pususu)
	# Pazar tezgâhları (süs): meydan gerçekten pazar gibi okunsun.
	_stall(4020)
	_stall(4560)
	_pickup(BAT, 3960, -45)
	_prop("varil", 4180)
	_prop("vazo", 4300)
	_prop("vazo", 4480)
	_prop("kasa", 4620)
	_prop("saksi", 4760)
	_scaffold(4400, -150, 220)
	_coin_line(4320, 4, 55, -200)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(4350, 0)
	arena.gate_left_x = 3880
	arena.gate_right_x = 4900
	arena.floor_y = 0
	arena.wave1 = _wave(STREET, STREET, KNIFE)
	arena.wave2 = _wave(KNIFE, BRUISER)
	arena.wave3 = _wave(ASSASSIN, STREET, KNIFE)
	arena.reward = HEALTH
	add_child(arena)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5080, 0)
	shop.title = "BALAT BÜFESİ"
	shop.items = PackedStringArray(["can", "sopa", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. İnşaat iskelesi + vinç paleti --------------------------------------
	_checkpoint(5260, 0)
	_terrain(5300, 8900, 0)
	# İskele katları binanın önünde üst üste: her biri bir zıplama (110 px).
	_scaffold(5560, -110, 150)
	_scaffold(5560, -220, 150)
	_scaffold(5560, -330, 150)
	_scaffold(5380, -260, 130)
	_coin_line(5345, 3, 35, -310)
	for k in 3:
		_pickup(COIN, 5560, -160.0 - k * 110.0)
	_building(5640, 6300, -420)
	_enemy(KNIFE, 5900, -420)
	_enemy(RIFLE, 6220, -420)
	_prop("saksi", 5760, -420)
	_prop("vazo", 6060, -420)
	_coin_line(5700, 6, 70, -470)
	_moving(6390, -410, Vector2(220, 0), 150)
	_coin_line(6420, 3, 70, -470)
	# Paletten düşen sokağa iner; karşı binanın önündeki iskeleyle yeniden çıkar.
	_scaffold(6620, -110, 150)
	_scaffold(6620, -220, 150)
	_scaffold(6620, -310, 150)
	_building(6700, 7000, -380)
	_pickup(ARMOR, 6900, -425)

	# --- 6. Han kapısı: son kavga + çıkış --------------------------------------
	_checkpoint(7150, 0)
	_prop("vazo", 7260)
	_prop("saksi", 7330)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(7850, 0)
	final.gate_left_x = 7420
	final.gate_right_x = 8300
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN)
	final.wave2 = _wave(STREET, KNIFE, BRUISER)
	final.wave3 = _wave(ELITE)
	final.reward = HEALTH
	add_child(final)
	_story(8360, _sahne_han_kapisi)
	_coin_line(8420, 3, 50, -50)
	_han_gate(8650, "KUZEY HANI")
	_goal(8650, 0)


## Açılış (uzun, ESC ile geçilir): Balat'ta yürüyüş ve sohbet -> Gazelle'in limanda
## çektiği fotoğraflar (kartal başı işareti) -> gözcü telsizle haber verir -> minibüs
## gelir, Redmount araya girer, arkadan sopayla yere serilir -> Gazelle debelenerek
## minibüse sürüklenir, "Kuzey Hanı" diye bağırır -> Redmount kalkar, yemin eder.
func _sahne_kacirma(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(-40, 0))
	cs.actor("gz", "gazelle", Vector2(30, 0))
	await cs.pan(Vector2(330, -170), 0.01)
	# Yürüyüş: konuşurken birlikte ilerlerler.
	cs.move("rm", 150, 3.2, "walk", false)
	cs.move("gz", 220, 3.2, "walk", false)
	await cs.say("gz", "GAZELLE", "Balat'ın en güzel simidi şu köşede. Söz verdin: bugün iş yok!")
	await cs.say("rm", "REDMOUNT", "Söz. Telefon cebimde, kapalı... neredeyse.")
	cs.face("gz", -1)
	await cs.say("gz", "GAZELLE", "Neredeyse mi? Redmount!")
	await cs.say("rm", "REDMOUNT", "Tamam, tamam. Kapattım. Bak, kapalı.")
	cs.move("rm", 260, 1.6, "walk", false)
	await cs.move("gz", 330, 1.6, "walk")
	cs.face("gz", -1)
	await cs.say("gz", "GAZELLE", "Aslında... sana bir şey göstermem lazım. Dün gece Haliç'te fotoğraf çekiyordum.")
	await cs.say("gz", "GAZELLE", "Gece yarısı, mühürsüz kamyonlar. Hepsinin kasasında aynı işaret vardı: bir kartal başı.")
	await cs.say("rm", "REDMOUNT", "Kartal başı... Karahanlı'nın işareti. Gazelle, o adamın işine burnunu sokma.")
	await cs.say("gz", "GAZELLE", "Gazeteye vermeden önce sana göstermek istedim. Filmler çantamda.")
	await cs.say("rm", "REDMOUNT", "Akşam beraber bakarız. Şimdi simit. Söz söz.")
	# Gözcü: köşede biri telsizle konuşur.
	cs.actor("gozcu", "knife", Vector2(930, 0), -1)
	await cs.pan(Vector2(620, -170), 0.7)
	await cs.say("gozcu", "GÖZCÜ", "(telsize) Kız burada, yanında bir adam var. Gönderin.", 2.6)
	cs.move("gozcu", 1300, 0.8, "walk", false)
	await cs.pan(Vector2(400, -170), 0.6)
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "...Redmount, biri bizi izliyordu sanki.")
	# Minibüs fren yaparak gelir.
	cs.actor("bus", "bus", Vector2(1500, 0), -1)
	Sfx.play(&"dash", 0.6)
	await cs.move("bus", 640, 1.0)
	cs.dust(560, 14)
	cs.shake(5.0)
	Sfx.play(&"land", 0.5)
	await cs.wait(0.3)
	cs.actor("t1", "thug", Vector2(560, 0), -1)
	await cs.wait(0.2)
	cs.actor("t2", "thug", Vector2(620, 0), -1)
	await cs.wait(0.2)
	cs.actor("t3", "thug", Vector2(680, 0), -1)
	# Redmount Gazelle'in önüne geçer.
	cs.move("gz", 230, 0.4, "walk", false)
	cs.face("gz", 1)
	await cs.move("rm", 360, 0.4, "run")
	cs.move("t1", 440, 0.6, "walk", false)
	await cs.move("t2", 500, 0.6, "walk")
	await cs.say("t1", "KABADAYI", "Karahanlı Bey fotoğrafları istiyor. Bir de fotoğrafçıyı.")
	await cs.say("rm", "REDMOUNT", "Bir adım daha atarsan dişlerini Haliç'ten toplarsın.")
	await cs.say("t1", "KABADAYI", "Hep böyle konuşurlar. Sonra da yere bakarlar.")
	# Kısa kavga: Redmount birini yere serer...
	await cs.move("rm", 400, 0.15, "run")
	await cs.strike("rm", "combo_b")
	cs.knock_down("t1", 520)
	cs.pose("rm", "fight")
	await cs.wait(0.4)
	# ...ama üçüncüsü arkadan dolaşıp sopayı indirir.
	await cs.move("t3", 330, 0.7, "walk")
	cs.face("t3", 1)
	await cs.say("gz", "GAZELLE", "Redmount, ARKANDA!", 1.0)
	await cs.strike("t3", "attack")
	cs.shake(9.0)
	await cs.knock_down("rm", 470)
	# Gazelle'i yakalayıp minibüse sürüklerler.
	await cs.move("t2", 260, 0.5, "walk")
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Bırak beni! REDMOUNT!", 1.2)
	cs.move("t2", 580, 1.6, "walk", false)
	await cs.struggle("gz", 600, 4)
	await cs.say("gz", "GAZELLE", "Fotoğraflar... KUZEY HANI! Kuzey Hanı'nda—", 1.8)
	cs.remove("gz")
	cs.remove("t2")
	await cs.get_up("t1", 0.4)
	await cs.say("t1", "KABADAYI", "Bu da sana Karahanlı'nın selamı olsun.", 1.6)
	cs.move("t1", 620, 0.5, "run", false)
	await cs.move("t3", 620, 0.5, "run")
	cs.remove("t1")
	cs.remove("t3")
	Sfx.play(&"dash", 0.5)
	cs.dust(640, 16)
	await cs.move("bus", 1800, 1.4)
	cs.remove("bus")
	await cs.wait(0.5)
	await cs.get_up("rm", 0.7)
	cs.face("rm", 1)
	await cs.say("rm", "REDMOUNT", "GAZELLE!", 1.0)
	await cs.say("rm", "REDMOUNT", "Kuzey Hanı... Minibüs yokuşa saptı. Çatılardan kestirirsem yetişirim.")
	await cs.say("rm", "REDMOUNT", "Dayan. Seni geri alacağım, Karahanlı'nın elinden de, bu şehrin elinden de.")


## Çatıda: aşağıdaki sokaktan minibüs geçer, Gazelle pencereden bağırır.
func _sahne_catidan_minibus(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	await cs.pan(Vector2(p.x + 520, -260), 0.6)
	cs.actor("bus", "bus", Vector2(p.x + 100, 0), 1)
	cs.move("bus", p.x + 1500, 2.6, "", false)
	await cs.wait(0.5)
	await cs.say("bus", "GAZELLE", "REDMOUNT! Pazar meydanına götürüyorlar!", 1.8)
	await cs.pan(Vector2(p.x + 120, -260), 0.5)
	await cs.say("rm", "REDMOUNT", "Duydum seni! Pazar meydanı... geliyorum.")


## Pazar meydanı girişi: pusu. Adam lafı uzatır, kapılar kapanır.
func _sahne_pazar_pususu(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("t1", "knife", Vector2(4250, 0), -1)
	await cs.pan(Vector2(4080, -170), 0.6)
	await cs.say("t1", "KARAHANLI'NIN ADAMI", "Minibüs çoktan geçti, kahraman. Senin yolun bu meydanda bitiyor.")
	await cs.say("rm", "REDMOUNT", "Gazelle'i nereye götürdünüz?")
	await cs.say("t1", "KARAHANLI'NIN ADAMI", "Kuzey Hanı'na kadar sağ çıkarsan görürsün. Çocuklar!")
	await cs.move("t1", 4700, 0.6, "walk")
	cs.remove("t1")


## Kuzey Hanı: Karahanlı'nın konvoyu hazır; Gazelle'i arka sokaklardan çıkarırlar.
## Bölüm 2'nin (Arka Sokak İzi) kapısı.
func _sahne_han_kapisi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("kh", "karahanli", Vector2(8740, 0), -1)
	cs.actor("gz", "gazelle", Vector2(8810, 0), -1)
	cs.actor("t1", "thug", Vector2(8870, 0), -1)
	cs.pose("gz", "bound_idle")
	await cs.pan(Vector2(8600, -180), 0.7)
	await cs.say("kh", "KARAHANLI", "Redmount... Kuzey Hanı'na kadar geldin demek. Adamlarım seni hafife almış.")
	await cs.say("gz", "GAZELLE", "Redmount! Fotoğrafları istiyorlar, vermedim!")
	await cs.say("rm", "REDMOUNT", "Karahanlı! Onu bırak. Derdin benimle.")
	await cs.say("kh", "KARAHANLI", "Derdim bu şehirle. Kız da, fotoğrafları da benim kartal başımı fazla yakından gördü.")
	await cs.say("kh", "KARAHANLI", "Konvoy hazır. Arka sokaklardan çıkacağız. Peşimize düşersen şehir sana dar gelir.")
	cs.face("kh", 1)
	cs.move("kh", 8660, 0.5, "walk", false)
	cs.move("t1", 8700, 0.6, "walk", false)
	await cs.struggle("gz", 8680, 2)
	cs.fade_out("kh", 0.4)
	cs.fade_out("t1", 0.4)
	await cs.fade_out("gz", 0.5)
	await cs.say("rm", "REDMOUNT", "Arka sokaklar... Konvoyun izini kaybetmem. Dayan Gazelle.")

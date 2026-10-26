## Bölüm 24 — Bozdoğan Kemeri / Son Kumanda (Kitap 2 finali).
##
## Uzun final (12 mekân): Saraçhane yaklaşımı (bulvar arenası) -> kemer altı (varil
## pusu) -> su kapısı avlusu -> gizli bakım avlusu -> alt su galerisi -> ölçüm salonu ->
## denetim merdivenleri -> kemer üst yolu -> dağıtım haznesi -> komuta arşivi -> servis
## kulesi -> kule terası (Ana Vana Muhafızı). Kumanda anahtarı alınır, şehrin suyu kurtulur.
## Kâtip kuleden kaçmıştır; masasında bıraktığı not Kitap 3'ü açar: "Kâğıt bitti.
## Şimdi ses." Anahtarın mührü Cağaloğlu'ndaki eski matbaayı gösterir.
extends DtmLevel

const APPROACH := preload("res://assets/backgrounds/book02_final_approach_atlas.png")
const AQUEDUCT := preload("res://assets/backgrounds/book02_final_aqueduct_atlas.png")
const TOWER := preload("res://assets/backgrounds/book02_final_tower_atlas.png")
const CHIEF := preload("res://scenes/enemies/WaterworksChief.tscn")
const MINIBOSS := preload("res://scenes/enemies/MiniBoss.tscn")


func _build() -> void:
	sky_atlas = APPROACH
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3200.0], [3, 4800.0],
		[0, 6400.0, AQUEDUCT], [1, 8000.0, AQUEDUCT], [2, 9600.0, AQUEDUCT], [3, 11200.0, AQUEDUCT],
		[0, 12800.0, TOWER], [1, 14400.0, TOWER], [2, 16000.0, TOWER], [3, 17600.0, TOWER]]
	sky_tint = Color(0.94, 0.88, 0.84)
	sky_shade = Color(0.08, 0.05, 0.05)
	back_row_skip = [[6300.0, 19500.0]]

	# --- 1. Saraçhane yaklaşımı: devriye, kemer bulvarında arena -------------------
	# Kitap 2'nin ortak çukur avlusu yerine arena kemerin altındaki düz bulvarda.
	_terrain(-400, 19500, 0)
	_story(-1.0, _sahne_baslangic, 240.0)
	_enemy(STREET, 700, 0)
	_prop("saksi", 900)
	var a1: BattleArena = ARENA.instantiate()
	a1.position = Vector2(2400, 0)
	a1.gate_left_x = 2000
	a1.gate_right_x = 2850
	a1.floor_y = 0
	a1.wave1 = _wave(STREET, KNIFE, STREET)
	a1.wave2 = _wave(RIFLE, KNIFE)
	a1.reward = ARMOR
	add_child(a1)

	# --- 2. Kemer altı: fıçılar arasında pusu, menzilli kule; erzak -----------------
	# Kanal yerine kemer ayağının dibindeki fıçı yığını: patlayıcı varil iki kişilik
	# pusunun önünde — tekmelenirse ikisini birden savurur.
	_checkpoint(3200, 0)
	_prop("patlayici", 3640)
	_enemy(STREET, 3760, 0)
	_enemy(KNIFE, 3830, 0)
	_crates(3950, 1, 1)
	_crates(4040, 1, 2)
	_terrain(4130, 4400, -180)
	_enemy(RIFLE, 4350, -180)
	_enemy(BOMBER, 4600, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(4900, 0)
	shop.title = "KEMER ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 3. Su kapısı avlusu: üst bakım yolu ya da alt ana yol ---------------------
	_checkpoint(5100, 0)
	var aw := AwningBounce.new()
	aw.width = 160
	aw.height = 60
	aw.position = Vector2(5250, 0)
	add_child(aw)
	for k in 5:
		_scaffold(5430.0 + k * 160.0, -260.0 - (k % 2) * 40.0, 140)
		_pickup(COIN, 5430.0 + k * 160.0, -310.0 - (k % 2) * 40.0)
	_pickup(RIFLE_PICKUP, 6070, -345)
	_enemy(SHIELD, 5600, 0)
	_enemy(ASSASSIN, 5900, 0)

	# --- 4. Gizli bakım avlusu: karma savunma ------------------------------------
	_checkpoint(6300, 0)
	# Bakım kulesi: kemerden geçilir, içi duvar-zıplamayla tırmanılır (zırh).
	_enemy(KNIFE, 6550, 0)
	_enemy(STREET, 6650, 0)
	_chimney(6900, -540, 140, 150, ARMOR)
	_enemy(BRUISER, 7200, 0)

	# --- 5. Alt su galerisi: sığ su hattı (çöken tahtalar), ağır nöbet ----------
	_checkpoint(7450, 0)
	_canal(7600, 8300, 120)
	# Kemerin altı: taş tonoz, ön planda kemer ayakları.
	for cx in [7600.0, 8000.0, 8350.0]:
		_fg("kolon", cx, 40.0, 380.0)
	_terrain(8250, 8300, 60)
	for k in 4:
		var cx := 7690.0 + k * 165.0
		_collapse(cx, -10.0, 145)
		_pickup(COIN, cx, -65.0)
	_enemy(BRUISER, 8550, 0)
	_pickup(HEALTH, 8700, -45)

	# --- 6. Ölçüm salonu: kısa kanal, gösterge nöbeti ---------------------------
	_checkpoint(8850, 0)
	_canal(9000, 9200, 110)
	_scaffold(9100, -20, 220)
	_interior(9300, 9900, -345, [], 0)
	_stones(9350, 1, 1)
	_stones(9440, 1, 2)
	_pickup(AMMO, 9485, -225)
	_enemy(ELITE, 9750, 0)

	# --- 7. Denetim merdivenleri: üst raf, alt arena ----------------------------
	_checkpoint(9950, 0)
	_crates(10050, 1, 1)
	_scaffold(10200, -150, 130)
	_scaffold(10350, -260, 130)
	_pickup(ARMOR, 10350, -305)
	_enemy(ELITE, 10650, 0)
	_enemy(RIFLE, 10350, -260)
	_enemy(ASSASSIN, 10900, 0)
	_story(11180, _sahne_merdiven)

	# --- 8. Kemer üst yolu: açıklık, revak savaşı --------------------------------
	_checkpoint(11300, 0)
	_canal(11450, 11650, 110)
	_scaffold(11550, -20, 220)
	_moving(11800, -230, Vector2(300, 0), 140, 0.0)
	_scaffold(12220, -230, 120)
	_pickup(RIFLE_PICKUP, 12220, -275)
	_enemy(ELITE, 12000, 0)
	_enemy(RIFLE, 12300, 0)

	# --- 9. Dağıtım haznesi: alt servis yolu, ağır savunma ------------------------
	_checkpoint(12500, 0)
	var a9: BattleArena = ARENA.instantiate()
	a9.position = Vector2(13050, 0)
	a9.gate_left_x = 12650
	a9.gate_right_x = 13450
	a9.floor_y = 0
	a9.wave1 = _wave(BRUISER, KNIFE)
	a9.wave2 = _wave(MINIBOSS)
	a9.reward = ARMOR
	add_child(a9)

	# --- 10. Komuta arşivi: son açıklık, anahtar ipucu ----------------------------
	_checkpoint(13600, 0)
	_canal(13750, 13950, 110)
	_scaffold(13850, -20, 220)
	_interior(14050, 14650, -230, [-115.0], 1)
	_story(14150, _sahne_arsiv)
	_enemy(ASSASSIN, 14400, 0)
	_enemy(KNIFE, 14500, -115)
	_pickup(AMMO, 14600, -160)
	_coin_line(14100, 6, 70, -160)

	# --- 11. Servis kulesi: pistonlar, son ağır arena; kule revir --------------
	_checkpoint(14750, 0)
	# İki pres arası geniş: ezilen oyuncu iki presin arasında yeniden doğmasın.
	_press(14950, 0.0, 3.0)
	_press(15350, 0.5, 3.0)
	_pickup(HEALTH, 15480, -45)
	_coin_line(14970, 5, 70, -60)
	var a11: BattleArena = ARENA.instantiate()
	a11.position = Vector2(15900, 0)
	a11.gate_left_x = 15550
	a11.gate_right_x = 16250
	a11.floor_y = 0
	a11.wave1 = _wave(ELITE, ASSASSIN)
	a11.wave2 = _wave(RIFLE, BRUISER)
	a11.reward = HEALTH
	add_child(a11)
	var revir: LevelShop = SHOP.new()
	revir.position = Vector2(16450, 0)
	revir.title = "KULE REVİRİ"
	revir.items = PackedStringArray(["can", "cephane", "zirh"])
	revir.accent = Color("e7a449")
	add_child(revir)

	# --- 12. Kule terası: iki dalga + Ana Vana Muhafızı --------------------------
	_checkpoint(16700, 0)
	_pickup(HEALTH, 16850, -45)
	_story(16950, _sahne_teras)
	var fin: BattleArena = ARENA.instantiate()
	fin.position = Vector2(17700, 0)
	fin.gate_left_x = 17150
	fin.gate_right_x = 18250
	fin.floor_y = 0
	fin.wave1 = _wave(ASSASSIN, KNIFE)
	fin.wave2 = _wave(ELITE, RIFLE)
	fin.wave3 = _wave(CHIEF)
	fin.reward = HEALTH
	add_child(fin)
	_story(18350, _sahne_anahtar)
	_han_gate(18700, "CAĞALOĞLU")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(4675, "gazelle", "GAZELLE", "Kemerin üstünden bütün şehir görünüyor. Kâtip de bizi görüyor.")
	_radio(10285, "redmount", "REDMOUNT", "Ana Vana Muhafızı kulenin tepesinde. Önce dağıtım haznesi.")
	_radio(15895, "gazelle", "GAZELLE", "Notta tek satır: \"Kâğıt bitti, şimdi ses.\" Radyo...")
	_goal(18700, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Başlangıç: kemer görünür, son yürüyüş.
func _sahne_baslangic(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Bozdoğan Kemeri. Bin yıldır bu şehre su taşıyor. Kâtip onu bir musluk gibi kapatmak istiyor.")
	await cs.say("rm", "REDMOUNT", "Servis kulesi kemerin ucunda. Galeriler, merdivenler, revaklar... uzun bir yol.")
	await cs.say("gz", "GAZELLE", "Kale de uzundu. Yan yana yürüdük mü, kısalıyor.")
	await cs.say("rm", "REDMOUNT", "Yan yana.")


## Denetim merdivenleri: Kâtip'in hoparlör sesi.
func _sahne_merdiven(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("kt", "voice", Vector2(p.x + 300, -330))
	await cs.pan(Vector2(p.x + 150, -220), 0.5)
	await cs.say("kt", "KÂTİP (kemerin hoparlörleri)", "Hâlâ yürüyorsunuz. Satırlarınız uzadıkça sonunuz daha iyi yazılır.")
	await cs.say("gz", "GAZELLE", "Nüzhet Hanım? Siz misiniz? Gazetenin sahibi?")
	await cs.say("kt", "KÂTİP", "İsimler kâğıt üzerinde değişir, gazeteci kız. Kulede beni bulamayacaksınız. Sadece sonumu.")


## Komuta arşivi: anahtar ipucu.
func _sahne_arsiv(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Arşivde kumanda şeması: tek bir anahtar, terastaki muhafızda. Onsuz kapama geri alınamaz.")
	await cs.say("rm", "REDMOUNT", "Ana Vana Muhafızı. Adı kadar büyükse, iyi.")


## Kule terası: muhafız hazırlığı.
func _sahne_teras(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("mh", "bruiser", Vector2(p.x + 700, 0), -1)
	await cs.pan(Vector2(p.x + 350, -220), 0.7)
	await cs.say("mh", "ANA VANA MUHAFIZI", "Anahtar boynumda. Şafak geçti; şehir susuzluğa uyandı mı, görmek istiyorum.")
	await cs.say("rm", "REDMOUNT", "Şehir uyandı. Ama suyunu benden alacak.")
	await cs.say("gz", "GAZELLE", "Redmount! Zırhı altı vuruştan sonra açılıyor; şemada yazıyordu!")
	await cs.move("mh", p.x + 1200, 0.7, "walk")
	cs.remove("mh")


## Anahtar: su kurtulur, Kâtip'in notu Kitap 3'ü açar.
func _sahne_anahtar(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("su", "voice", Vector2(p.x + 300, -250))
	await cs.pan(Vector2(p.x + 150, -220), 0.6)
	await cs.say("rm", "REDMOUNT", "Anahtar bende. Kumanda... açık konuma.")
	Sfx.play(&"goal", 0.9)
	cs.shake(4.0)
	await cs.say("su", "KEMERİN İÇİNDEN", "Gürrrr... şşşşşş...", 1.6)
	cs.pose("gz", "rescue_pose")
	await cs.say("gz", "GAZELLE", "Su! Basınç normale dönüyor! İstanbul'un suyu kesilmedi!")
	cs.pose("gz", "freed")
	await cs.say("gz", "GAZELLE", "Masada bir not... Kâtip'in mürekkep lekeli eldiveni ve bir kâğıt.")
	await cs.say("gz", "GAZELLE", "'Kâğıt bitti, Gazelle. Şimdi ses. Şehrin haberlerini kim yazarsa, şehri o yazar.'")
	await cs.say("rm", "REDMOUNT", "Anahtarın mührü... Cağaloğlu'nda eski bir matbaa.")
	await cs.say("gz", "GAZELLE", "Gazeteler, matbaalar, radyo... Haberlere el atıyor. Bu artık benim işim, Redmount.")
	await cs.say("rm", "REDMOUNT", "Bizim işimiz. Kitap bitmedi Gazelle; bir sayfa çevirdik, o kadar.")

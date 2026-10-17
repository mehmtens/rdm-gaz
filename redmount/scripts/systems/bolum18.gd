## Bölüm 18 — Kapalıçarşı Arka Hanı (Kitap 2 / "Haliç'in İzi", 6. bölüm).
##
## Posta fişi sevkiyatın çarşının arka hanında dağıtıldığını gösterir. Çarşı kapısı
## -> kalpakçılar geçidi (arena) -> bedesten (raf üstü rota) -> bakırcılar (tüfekli,
## kısa arena, erzak) -> han avlusu (üst revak) -> han ambarı (sahte mühür
## çuvalları, arena) -> gizli defter odası -> han çatısı (üç dalga). Defterin son
## işareti Çemberlitaş hamamının külhanı. Gazelle'in eski editörü ilk kez anılır.
extends DtmLevel

const STREETS := preload("res://assets/backgrounds/book02_bazaar_streets_atlas.png")
const HAN := preload("res://assets/backgrounds/book02_bazaar_han_atlas.png")


func _build() -> void:
	sky_atlas = STREETS
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3200.0], [3, 4600.0],
		[0, 6100.0, HAN], [1, 7500.0, HAN], [2, 8550.0, HAN], [3, 10150.0, HAN]]
	sky_tint = Color(0.92, 0.88, 0.84)
	sky_shade = Color(0.07, 0.05, 0.05)
	back_row_skip = [[1700.0, 9600.0]]

	# --- 1. Çarşı kapısı: devriye, ilk saçak rotası ---------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_kapi, 240.0)
	var aw := AwningBounce.new()
	aw.width = 160
	aw.height = 60
	aw.position = Vector2(560, 0)
	add_child(aw)
	_scaffold(750, -260, 160)
	_scaffold(940, -300, 160)
	_pickup(ARMOR, 940, -345)
	_coin_line(720, 4, 70, -310)
	_stall(420)
	_enemy(STREET, 1150, 0)
	_prop("vazo", 1350)

	# --- 2. Kalpakçılar geçidi: alçak zemin, geniş arena ------------------------
	_checkpoint(1550, 0)
	_terrain(1700, 1850, 30)
	_terrain(1850, 3200, 60)
	_stall(2050)
	_stall(2850)
	var gec: BattleArena = ARENA.instantiate()
	gec.position = Vector2(2500, 60)
	gec.gate_left_x = 2000
	gec.gate_right_x = 3000
	gec.floor_y = 60
	gec.wave1 = _wave(STREET, KNIFE, STREET)
	gec.wave2 = _wave(KNIFE, ASSASSIN, STREET)
	gec.reward = HEALTH
	add_child(gec)
	_terrain(3200, 3350, 30)

	# --- 3. Bedesten: sabit taş geçiş, raf üstü riskli rota ------------------------
	_terrain(3350, 10200, 0)
	_checkpoint(3400, 0)
	# Bedesten: kubbeli kapalı çarşı içi; raf üstü rota tavanın altında.
	_interior(3500, 4560, -420, [], 0)
	_crates(3550, 1, 1)
	for k in 5:
		_scaffold(3730.0 + k * 160.0, -220.0 - (k % 2) * 60.0, 140)
		_pickup(COIN, 3730.0 + k * 160.0, -270.0 - (k % 2) * 60.0)
	_scaffold(3640, -120, 100)
	_pickup(PISTOL, 4370, -335)
	_enemy(KNIFE, 4100, 0)
	_prop("sandik", 4450, 0, AMMO)

	# --- 4. Bakırcılar: tüfekli, kısa arena, erzak ------------------------------
	_checkpoint(4650, 0)
	_crates(4780, 1, 1)
	_crates(4870, 1, 2)
	_terrain(4960, 5200, -180)
	_enemy(RIFLE, 5140, -180)
	_pickup(RIFLE_PICKUP, 5000, -225)
	_enemy(KNIFE, 5450, 0)
	_enemy(BRUISER, 5650, 0)
	_prop("kasa", 5780, 0, COIN)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5950, 0)
	shop.title = "BAKIRCI ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Han avlusu: alt yol serbest, üst revak isteğe bağlı ------------------
	_checkpoint(6150, 0)
	var aw2 := AwningBounce.new()
	aw2.width = 160
	aw2.height = 60
	aw2.position = Vector2(6320, 0)
	add_child(aw2)
	for k in 4:
		_scaffold(6500.0 + k * 170.0, -260.0, 150)
		_pickup(COIN, 6500.0 + k * 170.0, -310.0)
	_pickup(ARMOR, 7010, -305)
	_enemy(ASSASSIN, 6700, 0)
	_prop("vazo", 6900)

	# --- 6. Han ambarı: sahte mühür çuvalları; seçkin + menzilli arena ---------
	_checkpoint(7250, 0)
	_story(7330, _sahne_ambar)
	_canal(7450, 7650, 110)
	_scaffold(7550, -20, 220)
	_prop("kasa", 7720)
	# Ambar: çuval yığınlı galerili salon.
	_interior(7760, 8490, -345, [], 0)
	_scaffold(7920, -115, 160)
	_scaffold(8330, -115, 160)
	_scaffold(8125, -230, 200)
	var amb: BattleArena = ARENA.instantiate()
	amb.position = Vector2(8100, 0)
	amb.gate_left_x = 7800
	amb.gate_right_x = 8450
	amb.floor_y = 0
	amb.wave1 = _wave(ELITE, RIFLE)
	amb.wave2 = _wave(ELITE, KNIFE, RIFLE)
	amb.reward = AMMO
	add_child(amb)

	# --- 7. Gizli defter odası: son servis aralığı, devriye ------------------------
	_checkpoint(8600, 0)
	_canal(8700, 8900, 110)
	_scaffold(8800, -20, 220)
	_interior(8960, 9330, -230, [-115.0], 1)
	_enemy(ELITE, 9050, 0)
	_pickup(HEALTH, 9280, -160)
	_coin_line(9000, 5, 60, -160)
	_story(9150, _sahne_defter)
	for x in [8650, 9250]:
		_lantern(float(x))

	# --- 8. Han çatısı: hızlı, menzilli, zırhlı üç dalga -------------------------
	_checkpoint(9350, 0)
	var roof: BattleArena = ARENA.instantiate()
	roof.position = Vector2(9700, 0)
	roof.gate_left_x = 9450
	roof.gate_right_x = 9950
	roof.floor_y = 0
	roof.wave1 = _wave(KNIFE, ASSASSIN, KNIFE)
	roof.wave2 = _wave(ELITE, RIFLE)
	roof.wave3 = _wave(BRUISER, BRUISER)
	roof.reward = HEALTH
	add_child(roof)
	_story(10000, _sahne_cati)
	_han_gate(10100, "ÇEMBERLİTAŞ")
	_goal(10100, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Çarşı kapısı: kalabalık ve takip hissi.
func _sahne_kapi(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Kapalıçarşı. Çocukken babamla buraya gelirdim... şimdi her köşede bir göz var gibi.")
	await cs.say("rm", "REDMOUNT", "Var. Üç kişi bizi kapıdan beri izliyor. Telgraf işini görmüş.")
	await cs.say("gz", "GAZELLE", "Arka han bedestenin arkasında. Kalabalığa karışalım, sonra hızlı olalım.")


## Han ambarı: çuvallarda mal yok, sahte mühür ve rota fişleri var.
func _sahne_ambar(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 200, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Çuvallarda mal yok. Yüzlerce sahte mühür ve rota fişi... Kâtip bütün şehri dağıtım ağına çevirmiş.")
	await cs.say("rm", "REDMOUNT", "Mal başka yerden geçiyor; burası sadece kâğıdın kalbi.")
	cs.actor("e1", "elite", Vector2(p.x + 600, 0), -1)
	await cs.say("e1", "HAN BEKÇİSİ", "Kâğıtlara dokunmayın! Kâtip Efendi her fişi sayar!")
	await cs.move("e1", p.x + 1000, 0.5, "walk")
	cs.remove("e1")


## Gizli defter odası: editörün adı.
func _sahne_defter(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Bu el yazısı... Redmount, bunu tanıyorum. Gazetedeki eski editörüm Kemal Bey'in yazısı.")
	await cs.say("rm", "REDMOUNT", "Editör. Kâtip. K. Mürekkep lekeli eldivenler...")
	await cs.say("gz", "GAZELLE", "Hayır... Bana ilk fotoğraf makinemi o vermişti. Haliç'teki kamyonları ona da anlatmıştım!")
	await cs.say("rm", "REDMOUNT", "Henüz kesin değil. Ama defterin son sayfasını alalım; biri kâğıdı korumaya gelecek.")


## Han çatısı: Çemberlitaş adresi.
func _sahne_cati(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(10030, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Defterin son işareti: Çemberlitaş, eski hamamın külhanı.")
	await cs.say("rm", "REDMOUNT", "Külhan. Ateşle, dumanla, sıcakla korunan bir yer.")
	await cs.say("gz", "GAZELLE", "Kemal Bey olmasın diye dua ediyorum. Ama olursa... yüzüne söyleyeceğim.")

## Bölüm 3 — Gece Pazarı Baskını (Kitap 1 / "Gazelle'in İzi").
##
## Karahanlı'nın adamları gece pazarının çıkışlarını tuttu; minibüsteki kızı gören
## herkesi topluyorlar. Redmount esnafı dinler, düşen telsizde Karahanlı'yı ve
## Gazelle'i duyar (raylar), tente ve çapraz iskelelerle pazar duvarını aşar,
## meydandaki örgütlü pusuyu kırar, toplanan esnafı kurtarır: sıradaki durak şehir
## çıkışındaki kontrol noktası.
extends DtmLevel


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/book03_kuzguncuk_streets_atlas.png")
	sky_cells = [[0, -100000.0], [2, 3000.0], [0, 6000.0]]
	sky_tint = Color(0.78, 0.8, 0.92)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_tint = Color(0.28, 0.3, 0.46)
	_night()

	# --- 1. Pazar girişi: saklanan esnaf, tezgâhlar arası ilk kavga -------------
	_terrain(-400, 3400, 0)
	_story(-1.0, _sahne_esnaf, 200.0)
	for x in [120, 520, 900, 1300]:
		_lantern(float(x))
	_stall(330)
	_stall(720)
	_stall(1150)
	_prop("vazo", 260)
	_prop("saksi", 430)
	_prop("kasa", 600)
	_enemy(STREET, 850, 0)
	_enemy(KNIFE, 980, 0)
	_prop("vazo", 1030)
	_prop("varil", 1250)

	# --- 2. Çapraz iskeleler: altta tezgâh sandıkları, üstte zikzak yol ----------
	_checkpoint(1420, 0)
	var awning := AwningBounce.new()
	awning.width = 160
	awning.height = 60
	awning.position = Vector2(1560, 0)
	add_child(awning)
	var zig := [[1720, -200], [1890, -300], [2060, -200], [2230, -300], [2400, -380],
		[2570, -300], [2740, -220], [2900, -150]]
	for z in zig:
		_scaffold(float(z[0]), float(z[1]), 150)
		_pickup(COIN, float(z[0]) - 30, float(z[1]) - 50)
		_pickup(COIN, float(z[0]) + 30, float(z[1]) - 50)
	_pickup(ARMOR, 2400, -425)
	_prop("saksi", 2230, -300)
	_crates(1700, 1, 1)
	_enemy(STREET, 1950, 0)
	_crates(2100, 2, 1)
	_enemy(KNIFE, 2560, 0)
	_crates(2700, 1, 1)
	_prop("vazo", 2820)
	for x in [1650, 2050, 2450, 2850, 3250]:
		_lantern(float(x), -150.0)
	_story(2950, _sahne_telsiz)

	# --- 3. Pazar duvarı: tenteyle duvarın üstüne, tepede tüfekli ----------------
	_checkpoint(3120, 0)
	_terrain(3400, 9200, 0)
	var aw2 := AwningBounce.new()
	aw2.width = 180
	aw2.height = 60
	aw2.position = Vector2(3410, 0)
	add_child(aw2)
	_balcony(3462, -125, 70)
	_building(3500, 3800, -280)
	_enemy(RIFLE, 3720, -280)
	_coin_line(3540, 4, 50, -330)
	_prop("vazo", 3600, -280)

	# --- 4. Meydan pususu: kilitli arena ----------------------------------------
	_checkpoint(3980, 0)
	_story(4060, _sahne_pusu)
	_stall(4450)
	_stall(5350)
	for x in [4250, 4900, 5550]:
		_lantern(float(x))
	_pickup(BAT, 4320, -45)
	_scaffold(4650, -150, 200)
	_scaffold(5200, -150, 200)
	_coin_line(4590, 3, 55, -200)
	_coin_line(5140, 3, 55, -200)
	_prop("vazo", 4560)
	_prop("kasa", 4780)
	_prop("saksi", 5050)
	_prop("varil", 5450)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(4900, 0)
	arena.gate_left_x = 4200
	arena.gate_right_x = 5620
	arena.floor_y = 0
	arena.wave1 = _wave(STREET, STREET, KNIFE)
	arena.wave2 = _wave(KNIFE, RIFLE, STREET)
	arena.wave3 = _wave(ASSASSIN, BRUISER)
	arena.reward = HEALTH
	add_child(arena)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5860, 0)
	shop.title = "GECE ÇAYCISI"
	shop.items = PackedStringArray(["can", "sopa", "cephane"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Fenerli ara sokak: altta düşmanlar, üstte çamaşır ipi yolu ----------
	_checkpoint(6150, 0)
	var aw3 := AwningBounce.new()
	aw3.width = 160
	aw3.height = 60
	aw3.position = Vector2(6320, 0)
	add_child(aw3)
	for k in 6:
		var cx := 6500.0 + k * 175.0
		_scaffold(cx, -220.0 - (k % 2) * 40.0, 150)
		_pickup(COIN, cx, -275.0 - (k % 2) * 40.0)
	_pickup(HEALTH, 7375, -320)
	_enemy(KNIFE, 6650, 0)
	_prop("vazo", 6800)
	_enemy(RIFLE, 7050, 0)
	_prop("kasa", 7200)
	_enemy(STREET, 7350, 0)
	_prop("saksi", 7520)
	for x in [6400, 6900, 7400, 7900, 8400, 8900]:
		_lantern(float(x))
	_stall(7700)

	# --- 6. Çıkış: toplanan esnaf kurtarılır --------------------------------------
	_checkpoint(7950, 0)
	# Esnafı topladıkları iki katlı depo: içeri girince cephe açılır, adamlar katlarda.
	_interior(8050, 8550, -230, [-115.0], 0)
	_enemy(STREET, 8250, 0)
	_enemy(KNIFE, 8400, -115)
	_enemy(ASSASSIN, 8450, 0)
	_prop("kasa", 8120, -115, HEALTH)
	_coin_line(8180, 5, 60, -160)
	_crates(8650, 2, 1)
	_story(8580, _sahne_esnaf_kurtulur)
	_coin_line(8800, 4, 50, -140)
	_han_gate(9050, "PAZAR ÇIKIŞI")
	_goal(9050, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Pazar girişi: tezgâhın arkasına saklanmış esnaf anlatır.
func _sahne_esnaf(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(20, 0))
	cs.actor("esnaf", "voice", Vector2(720, -120))
	await cs.pan(Vector2(380, -170), 0.01)
	await cs.move("rm", 200, 1.0, "walk")
	await cs.say("rm", "REDMOUNT", "Gece pazarı... ama ne bir ses var ne bir müşteri.")
	await cs.say("esnaf", "ESNAF (tezgâhın arkasından)", "Şşşt! Eğil evladım! Karahanlı'nın adamları pazarı kapattı.")
	await cs.say("esnaf", "ESNAF", "Minibüsteki kızı gören, çığlığını duyan kim varsa topluyorlar. Komşum Hasan'ı da götürdüler.")
	await cs.say("rm", "REDMOUNT", "O kız benim... Gazelle. Minibüs nereye gitti?")
	await cs.say("esnaf", "ESNAF", "Pazarın öbür ucundan geçti. Ama çıkışların hepsini tuttular, kimse kaçamıyor.")
	await cs.say("rm", "REDMOUNT", "Ben kaçmaya gelmedim. Saklanmaya devam et; komşunu da getireceğim.")


## Düşen telsiz: Karahanlı'nın emri ve arkada Gazelle'in sesi.
func _sahne_telsiz(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("telsiz", "voice", p + Vector2(60, -60))
	cs.pose("rm", "crouch")
	await cs.say("rm", "REDMOUNT", "Yere düşmüş bir telsiz... hâlâ açık.", 1.6)
	await cs.say("telsiz", "KARAHANLI (telsiz)", "Pazar kapandı mı? Kızı trene yetiştirin. Redmount'u da o pazarda gömün.")
	await cs.say("telsiz", "GAZELLE (uzaktan)", "Redmount! Raylar! Raylara götürüyor—", 1.6)
	await cs.say("telsiz", "KARAHANLI (telsiz)", "Susturun şunu.", 1.2)
	cs.pose("rm", "idle")
	await cs.say("rm", "REDMOUNT", "Yaşıyor. Hâlâ savaşıyor. Raylar... önce bu pazardan çıkmalıyım.")


## Meydan: örgütlü pusu.
func _sahne_pusu(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("km", "knife", Vector2(4720, 0), -1)
	cs.actor("t1", "thug", Vector2(4840, 0), -1)
	cs.actor("t2", "rifle", Vector2(4950, 0), -1)
	await cs.pan(Vector2(4560, -170), 0.7)
	await cs.say("km", "PUSUCU KEMAL", "Hoş geldin Redmount. Pazarın her çıkışı bizde, her çatısı bizde.")
	await cs.say("rm", "REDMOUNT", "Ben de çıkışı sormuyorum. Tek tek geçeceğim.")
	await cs.say("km", "PUSUCU KEMAL", "Patron sağ istemedi seni. Kapıları kilitleyin!")
	cs.move("t1", 5400, 0.7, "walk", false)
	cs.move("t2", 5450, 0.7, "walk", false)
	await cs.move("km", 5500, 0.7, "walk")
	cs.remove("km")
	cs.remove("t1")
	cs.remove("t2")


## Çıkış: toplanan esnaf kurtulur, sıradaki durak öğrenilir.
func _sahne_esnaf_kurtulur(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("hasan", "voice", Vector2(8700, -150))
	await cs.pan(Vector2(8650, -170), 0.6)
	await cs.say("hasan", "HASAN (sandıkların arkasından)", "Kimse yok mu? Bizi buraya kilitlediler!")
	await cs.say("rm", "REDMOUNT", "Sen Hasan'sın. Komşun seni bekliyor. Kapı açık, çıkın.")
	await cs.say("hasan", "HASAN", "Allah razı olsun! Kızı gördüm, evladım. Kızgın, inatçı... kelepçeli ama dimdik.")
	await cs.say("hasan", "HASAN", "Trene yetiştirecekler. Ama önce şehir çıkışındaki kontrol noktasından geçmeleri lazım.")
	await cs.say("rm", "REDMOUNT", "Kontrol noktası: siperler, tüfekli muhafızlar... Fark etmez. Yoldayım, Gazelle.")

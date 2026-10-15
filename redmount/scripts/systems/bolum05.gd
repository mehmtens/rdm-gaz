## Bölüm 5 — Demiryolu Ablukası (Kitap 1 / "Gazelle'in İzi").
##
## Altıncı peronda Gazelle yük treninin yedinci vagonuna itilir; tren yarım saat
## sonra kalkacak. Redmount vagon tepelerinden ve zamanlı vinç paletlerinden geçer,
## makas kulesinde demiryolcunun yardımıyla treni yavaş hatta alır, depoyu temizler,
## uzun trenin üstünde savaşır, Makinist Cemil'i yener ve kalkan trenin son vagonuna
## atlar: sıradaki durak sanayi kuşağı.
extends DtmLevel


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/level02_locations_atlas.png")
	sky_cells = [[1, -100000.0], [0, 4300.0], [2, 7800.0]]
	sky_tint = Color(0.86, 0.82, 0.86)
	back_tint = Color(0.3, 0.3, 0.42)

	_terrain(-400, 9700, 0)
	_rails(-400, 9700)

	# --- 1. Altıncı peron: Gazelle vagon yediye itilir ---------------------------
	_story(-1.0, _sahne_peron, 200.0)
	_prop("vazo", 300)
	_prop("saksi", 360)
	_enemy(STREET, 470, 0)
	_crates(600, 1, 1)
	var x := _wagon(690)
	_coin_line(760, 5, 60, -190)
	_enemy(KNIFE, 1170, 0)
	_prop("varil", 1110)
	_crates(1250, 1, 1)
	x = _wagon(1340, Color(0.9, 0.95, 1.0))
	_enemy(RIFLE, 1620, -140)
	_prop("vazo", 1450, -140)

	# --- 2. Vagon tepeleri + zamanlı vinç paletleri (üstte isteğe bağlı yol) ------
	_checkpoint(1820, 0)
	_crates(1810, 1, 1)
	_wagon(1900)
	_enemy(KNIFE, 2150, -140)
	_crates(2380, 1, 1)
	_wagon(2470, Color(1.0, 0.92, 0.88))
	_enemy(STREET, 2930, 0)
	_crates(2950, 1, 1)
	_wagon(3040)
	_enemy(RIFLE, 3330, -140)
	# Vinç paletleri: aynı ritimde gidip gelir, aralarında yarım tur fark.
	_moving(2150, -240, Vector2(300, 0), 150, 0.0)
	_moving(2700, -300, Vector2(300, 0), 150, 0.5)
	_scaffold(3330, -340, 200)
	_pickup(ARMOR, 3330, -385)
	for k in 6:
		_pickup(COIN, 2150.0 + k * 150.0, -350.0)

	# --- 3. Makas kulesi: treni yavaş hatta al ------------------------------------
	_checkpoint(3560, 0)
	_scaffold(3740, -110, 120)
	_scaffold(3740, -210, 120)
	_tower(3870, -280, 150, false)
	_coin_line(3820, 3, 50, -330)
	_story(3830, _sahne_makas)
	_prop("kasa", 4050)

	# --- 4. Depo arenası; istasyon büfesi -----------------------------------------
	_checkpoint(4200, 0)
	_scaffold(4750, -160, 220)
	_coin_line(4690, 3, 55, -210)
	_prop("vazo", 4450)
	_prop("kasa", 4600)
	_prop("varil", 4980)
	_prop("saksi", 5200)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(4800, 0)
	arena.gate_left_x = 4320
	arena.gate_right_x = 5380
	arena.floor_y = 0
	arena.wave1 = _wave(STREET, KNIFE, STREET)
	arena.wave2 = _wave(RIFLE, KNIFE, ASSASSIN)
	arena.wave3 = _wave(BRUISER, RIFLE)
	arena.reward = HEALTH
	add_child(arena)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5600, 0)
	shop.title = "İSTASYON BÜFESİ"
	shop.items = PackedStringArray(["can", "sopa", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Uzun tren: bitişik vagonların tepesinde kavga --------------------------
	_checkpoint(5800, 0)
	_crates(5900, 1, 1)
	var tints := [Color.WHITE, Color(0.9, 0.95, 1.0), Color(1.0, 0.92, 0.88), Color.WHITE]
	for k in 4:
		_wagon(5990.0 + k * WAGON_W, tints[k])
	for k in 8:
		_pickup(COIN, 6080.0 + k * 200.0, -190)
	_enemy(KNIFE, 6300, -140)
	_enemy(RIFLE, 6800, -140)
	_prop("vazo", 7000, -140)
	_enemy(STREET, 7200, -140)
	_enemy(ASSASSIN, 7600, -140)
	_prop("kasa", 7400, -140)

	# --- 6. Makinist Cemil; kalkan trene atlayış ----------------------------------
	_checkpoint(7950, 0)
	_story(8000, _sahne_makinist)
	_prop("vazo", 8300)
	_prop("varil", 8700)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(8550, 0)
	final.gate_left_x = 8100
	final.gate_right_x = 9000
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, STREET, RIFLE)
	final.wave2 = _wave(BRUISER, KNIFE)
	final.wave3 = _wave(ELITE, BRUISER)
	final.reward = HEALTH
	add_child(final)
	_story(9100, _sahne_tren_kalkar, 9380.0)
	_goal(9420, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Altıncı peron: Gazelle vagon yediye itilir.
func _sahne_peron(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(60, 0))
	await cs.pan(Vector2(350, -180), 0.01)
	await cs.move("rm", 200, 1.0, "walk")
	await cs.say("rm", "REDMOUNT", "Haydarpaşa'nın arka hattı. Altıncı peron... şu bekleyen yük treni.")
	cs.actor("w1", "wagon", Vector2(1450, 0))
	cs.actor("gz", "gazelle", Vector2(1150, 0))
	cs.actor("t1", "thug", Vector2(1080, 0))
	cs.actor("mk", "elite", Vector2(1300, 0), -1)
	cs.pose("gz", "flinch")
	await cs.pan(Vector2(1180, -190), 0.9)
	await cs.say("gz", "GAZELLE", "Bırak kolumu! Kendim yürürüm!")
	await cs.say("t1", "KABADAYI", "Yürü o zaman. Yedinci vagon, prenses.")
	cs.face("gz", -1)
	await cs.say("gz", "GAZELLE", "...REDMOUNT! Vagon yedi! YEDİ!", 1.6)
	await cs.struggle("gz", 1300, 2)
	await cs.fade_out("gz", 0.4)
	await cs.say("mk", "MAKİNİST CEMİL", "Kapıyı mühürleyin. Tren yarım saate kalkıyor; sanayi kuşağında bekliyorlar.")
	await cs.say("mk", "MAKİNİST CEMİL", "O adam peronu geçmeye çalışırsa vagonların üstünde karşılayın.")
	await cs.pan(Vector2(350, -180), 0.8)
	await cs.say("rm", "REDMOUNT", "Yarım saat. Yedinci vagon. Bu ablukayı yarım saatte geçeceğim.")


## Makas kulesi: saklanan demiryolcu yolu gösterir, treni yavaş hatta alırız.
func _sahne_makas(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("isci", "voice", Vector2(p.x + 60, -360))
	await cs.say("isci", "DEMİRYOLCU (kulenin içinden)", "Vurma! Ben burada çalışıyorum! Onlar kuleyi zorla aldı.")
	await cs.say("rm", "REDMOUNT", "Yük treni. Altıncı peron. Onu durdurabilir misin?")
	await cs.say("isci", "DEMİRYOLCU", "Durduramam, fren hattını kilitlediler. Ama makası ikinci hatta çevirirsen tren yavaş yoldan, yokuştan gider.")
	cs.pose("rm", "fight")
	Sfx.play(&"hit", 0.6)
	cs.shake(4.0)
	await cs.wait(0.4)
	await cs.say("rm", "REDMOUNT", "Çevrildi. Yavaş yol: bana birkaç dakika kazandırır.")
	await cs.say("isci", "DEMİRYOLCU", "Kızı sanayi kuşağındaki haddehaneye götürüyorlar. Makinist Cemil konuşuyordu. Dikkat et evlat.")


## Makinist Cemil: trenin başında son kavga.
func _sahne_makinist(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("mk", "elite", Vector2(8500, 0), -1)
	cs.actor("t1", "bruiser", Vector2(8640, 0), -1)
	await cs.pan(Vector2(8300, -180), 0.7)
	await cs.say("mk", "MAKİNİST CEMİL", "Makası sen çevirdin, değil mi? Tren yokuşta sürünüyor. Karahanlı Bey bundan hoşlanmayacak.")
	await cs.say("rm", "REDMOUNT", "Ben de kızın kelepçesinden hoşlanmadım. Yedinci vagonun anahtarı nerede?")
	await cs.say("mk", "MAKİNİST CEMİL", "Anahtar bende. Gel de al.")
	cs.move("t1", 8950, 0.6, "walk", false)
	await cs.move("mk", 8900, 0.6, "walk")
	cs.remove("mk")
	cs.remove("t1")


## Tren kalkar: Redmount koşup son vagona atlar.
func _sahne_tren_kalkar(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("w1", "wagon", Vector2(p.x + 500, 0))
	cs.actor("w2", "wagon", Vector2(p.x + 900, 0))
	cs.actor("tren", "voice", Vector2(p.x + 700, -260))
	await cs.pan(Vector2(p.x + 300, -200), 0.5)
	await cs.say("tren", "TREN", "DÜÜÜÜT! Çuf... çuf...", 1.4)
	await cs.say("rm", "REDMOUNT", "Kalkıyor! Hayır, hayır, hayır...")
	cs.move("w1", p.x + 1500, 3.0, "", false)
	cs.move("w2", p.x + 1900, 3.0, "", false)
	await cs.move("rm", p.x + 330, 0.9, "run")
	cs.pose("rm", "jump")
	await cs.hop("rm", Vector2(p.x + 560, -140), 0.45, 90.0)
	cs.pose("rm", "crouch")
	var rm := cs.get_actor("rm")
	var t := cs.create_tween()
	t.tween_property(rm, ^"position:x", rm.position.x + 700.0, 2.0)
	await cs.say("rm", "REDMOUNT", "Tutundum! Son vagon... Yedinci vagona kadar çatıdan gideceğim.", 2.0)
	await cs.say("rm", "REDMOUNT", "Sanayi kuşağı. Gazelle'e yaklaşıyorum.")

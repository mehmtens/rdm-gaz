## Bölüm 10 — Kuzey Surları (Kitap 1 / "Gazelle'in İzi").
##
## Karahanlı ana kapıyı açık bırakıp meydan okur; Redmount kör noktadan, burçtan
## burca yükselerek tırmanır. İkinci burçta Gazelle'in ayna sinyalini görür, çifte
## hareketli köprüyü geçer, burç tepesindeki arenada savaşır ve en üst surda Sur
## Ağası'nı yener. Kör noktada duvarın ardından Gazelle'in sesi gelir.
extends DtmLevel

const MINIBOSS := preload("res://scenes/enemies/MiniBoss.tscn")


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/level04_fortress_atlas.png")
	sky_cells = [[3, -100000.0], [2, 3000.0], [0, 6500.0]]
	sky_tint = Color(0.86, 0.84, 0.92)
	sky_shade = Color(0.04, 0.04, 0.08)
	back_row_on = false
	_night(Color(0.74, 0.74, 0.9))

	# --- 1. Surların dibi: açık kapı, meydan okuma --------------------------------
	_terrain(-400, 1700, 0)
	_han_gate(560, "ANA KAPI")
	_story(-1.0, _sahne_acik_kapi, 220.0)
	_enemy(STREET, 900, 0)
	_enemy(KNIFE, 1050, 0)
	_prop("varil", 1250)
	_prop("vazo", 1320)
	_lantern(300)
	_lantern(1450)

	# --- 2. Birinci burç ---------------------------------------------------------
	_checkpoint(1500, 0)
	_crates(1610, 1, 1)
	_terrain(1700, 2600, -150)
	_enemy(RIFLE, 2350, -150)
	_prop("saksi", 1900, -150)
	_coin_line(1780, 6, 70, -200)
	_terrain(2600, 3200, 0)
	_moving(2700, -140, Vector2(330, 0), 150, 0.0)
	_coin_line(2720, 4, 90, -200)

	# --- 3. İkinci burç: Gazelle'in ayna sinyali ------------------------------------
	_scaffold(3140, -110, 120)
	_scaffold(3140, -200, 120)
	_terrain(3200, 3350, -200)
	_terrain(3350, 4400, -300)
	_checkpoint(3450, -300)
	_story(3600, _sahne_ayna)
	_enemy(KNIFE, 3900, -300)
	_enemy(BRUISER, 4150, -300)
	_prop("kasa", 4280, -300)
	_tower(4330, -390, 110)

	# --- 4. Çifte hareketli köprü --------------------------------------------------
	_terrain(4400, 5100, 0)
	_moving(4500, -300, Vector2(250, 0), 140, 0.0)
	_moving(4850, -340, Vector2(180, -40), 130, 0.5)
	_coin_line(4520, 6, 95, -400)
	# Köprüden düşen: üçüncü burcun önündeki iskele merdiveni.
	for k in 3:
		_scaffold(5040, -110.0 - k * 105.0, 120)
	_terrain(5100, 6400, -380)

	# --- 5. Üçüncü burç tepesi: arena ---------------------------------------------
	_checkpoint(5200, -380)
	_prop("vazo", 5400, -380)
	_prop("varil", 6100, -380)
	_scaffold(5800, -540, 220)
	_pickup(ARMOR, 5800, -585)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(5800, -380)
	arena.gate_left_x = 5300
	arena.gate_right_x = 6300
	arena.floor_y = -380
	arena.wave1 = _wave(KNIFE, STREET, BOMBER)
	arena.wave2 = _wave(ELITE, ASSASSIN)
	arena.wave3 = _wave(BRUISER, ELITE)
	arena.reward = HEALTH
	add_child(arena)

	# --- 6. Dördüncü burç: projektörlü kuleler -------------------------------------
	_terrain(6400, 6500, -420)
	_terrain(6500, 9500, -460)
	_checkpoint(6560, -460)
	_tower(6900, -560, 110)
	_enemy(RIFLE, 6900, -560)
	_sandbags_on_wall(7150, 100)
	_enemy(KNIFE, 7350, -460)
	_tower(7550, -560, 110)
	_enemy(RIFLE, 7550, -560)
	_prop("saksi", 7700, -460)

	# --- 7. Sur Ağası; kör nokta ----------------------------------------------------
	_checkpoint(7780, -460)
	_story(7830, _sahne_sur_agasi)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(8400, -460)
	final.gate_left_x = 7900
	final.gate_right_x = 8900
	final.floor_y = -460
	final.wave1 = _wave(ELITE, KNIFE)
	final.wave2 = _wave(MINIBOSS)
	final.wave3 = _wave(ELITE, ELITE)
	final.reward = HEALTH
	add_child(final)
	_story(9000, _sahne_kor_nokta)
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2312, "gazelle", "GAZELLE (ayna sinyali)", "Işık: kısa-uzun-kısa. \"Burçlar... dördüncü.\"")
	_radio(5087, "redmount", "REDMOUNT", "Ayna sinyali. Gazelle hâlâ gazeteci gibi düşünüyor.")
	_radio(7862, "telsiz", "SUR AĞASI (telsiz)", "Kör noktayı kapatın! Adam surun içinde!")
	_goal(9250, -460)


## Kum torbası burç üstünde (taban -460): `_sandbags` zemini 0 kabul eder.
func _sandbags_on_wall(left: float, w: float, h := 70.0) -> void:
	var body := _solid_box(left, -460.0 - h, w, h)
	body.add_child(_Art.new(_Art.A_SANDBAG, Vector2(w, h)))


# --- Hikâye sahneleri ----------------------------------------------------------

## Surların dibi: kapı açık; Karahanlı meydan okur.
func _sahne_acik_kapi(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(60, 0))
	cs.actor("kh", "voice", Vector2(560, -320))
	await cs.pan(Vector2(360, -220), 0.01)
	await cs.move("rm", 220, 0.9, "walk")
	await cs.say("rm", "REDMOUNT", "Kuzey surları... Ve ana kapı ardına kadar açık.")
	await cs.say("kh", "KARAHANLI (surların üstünden)", "Kapı açık, Redmount. Gir de bir çay içelim. Gazelle de bize katılır.")
	await cs.say("rm", "REDMOUNT", "Açık kapı tuzaktır. Ev sahibi kapıda değil, kör noktada karşılanır.")
	await cs.say("kh", "KARAHANLI", "Kör nokta mı? Bu surlarda kör nokta yok. Burçlarımı sayarak tırman o zaman.")


## İkinci burç: iç kaleden ayna ile ışık sinyali.
func _sahne_ayna(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	await cs.pan(Vector2(p.x + 300, -520), 0.7)
	# Üç kısa, üç uzun ayna parıltısı (piksel kıvılcım).
	var at := Vector2(p.x + 520, -620)
	for i in 6:
		await cs.wait(0.18 if i < 3 else 0.42)
		Fx.spark(at, Vector2.ZERO, 6, Color(1.0, 1.0, 0.85), 0.8)
	await cs.say("rm", "REDMOUNT", "İç kalenin penceresinde bir ışık... Üç kısa, üç uzun.")
	await cs.say("rm", "REDMOUNT", "Ayna. Gazelle güneşi değil fenerleri yakalamış, bana sinyal veriyor: buradayım.")
	await cs.say("rm", "REDMOUNT", "Seni gördüm. İki burç daha.")
	await cs.pan(Vector2(p.x + 120, -420), 0.5)


## Sur Ağası: en üst surun bekçisi.
func _sahne_sur_agasi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("sa", "elite", Vector2(8300, -460), -1)
	cs.actor("e1", "elite", Vector2(8440, -460), -1)
	await cs.pan(Vector2(8150, -660), 0.7)
	await cs.say("sa", "SUR AĞASI", "Burçları tek tek aştın. Sonuncusu benim. Bu surlarda kırk yıl nöbet tuttum.")
	await cs.say("rm", "REDMOUNT", "Kırk yıl çok uzun. Bugün nöbet değişiyor.")
	cs.move("e1", 8900, 0.6, "walk", false)
	await cs.move("sa", 8850, 0.6, "walk")
	cs.remove("sa")
	cs.remove("e1")


## Kör nokta: duvarın ardından Gazelle'in sesi.
func _sahne_kor_nokta(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "voice", Vector2(p.x + 220, -600))
	await cs.pan(Vector2(p.x + 150, -660), 0.5)
	await cs.say("rm", "REDMOUNT", "Kör nokta. Surları aştım.")
	await cs.say("gz", "GAZELLE (duvarın ardından)", "Redmount? O sen misin? Taş duvarın hemen arkasındayım!")
	await cs.say("rm", "REDMOUNT", "Benim. İç koridora iniyorum. Seçkin muhafızlar var; sessiz olmam lazım.")
	await cs.say("gz", "GAZELLE", "Acele et... Beni iç kaleye taşımaya hazırlanıyorlar.")

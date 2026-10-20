## Bölüm 8 — Yeraltı Sevkiyatı (Kitap 1 / "Gazelle'in İzi").
##
## Gazelle dağın içindeki tünellerden taşınıyor; geçtiği her kapının sesini sayıp
## iz bırakıyor. Redmount asansör kuyusundan iner, duvardaki tebeşir çizgilerini
## bulur, çöken tahtalarla su kanalını durmadan koşarak geçer, mağara çukurunu yön
## değiştiren paletlerle aşar (1. kapı), sarnıç salonunda savaşır, ikinci kanalı ve
## 2. kapıyı geçer, tünel bekçisini yenip gün ışığına çıkar: dağ geçidi.
extends DtmLevel

const MINIBOSS := preload("res://scenes/enemies/MiniBoss.tscn")


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/book02_zeyrek_cistern_atlas.png")
	sky_cells = [[2, -100000.0], [0, 4800.0], [1, 7600.0]]
	sky_tint = Color(0.8, 0.82, 0.88)
	sky_shade = Color(0.02, 0.03, 0.05)
	back_row_on = false
	_night(Color(0.72, 0.76, 0.86))
	_ceiling(-400, 9700, -440)

	# --- 1. Asansör kuyusu dibi: tebeşir çizgileri ------------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_kuyu, 220.0)
	_chalk(520, -170, "I I I")
	for x in [300, 900, 1450]:
		_lantern(float(x))
	_prop("varil", 640)
	_enemy(KNIFE, 820, 0)
	_enemy(STREET, 980, 0)
	_prop("kasa", 1150)
	_prop("vazo", 1220)

	# --- 2. Kesintisiz hız: su kanalı üstünde çöken tahtalar ---------------------
	_checkpoint(1500, 0)
	_canal(1700, 2950, 110)
	_terrain(2900, 2950, 55)
	for k in 7:
		var cx := 1790.0 + k * 175.0
		_collapse(cx, -20.0, 150)
		_pickup(COIN, cx, -75.0)
	_terrain(2950, 3500, 0)
	_enemy(BOMBER, 3200, 0)
	_prop("varil", 3350)

	# --- 3. Mağara çukuru: yön değiştiren paletler; 1. kapı ----------------------
	_checkpoint(3380, 0)
	_terrain(3500, 4300, 160)
	_moving(3600, -20, Vector2(250, -60), 150, 0.0)
	_moving(3980, -60, Vector2(180, 40), 130, 0.5)
	_coin_line(3620, 6, 110, -130)
	# Çukura düşen: sağ duvarın önündeki iskelelerle çıkar.
	_scaffold(4230, 50, 120)
	_scaffold(4230, -55, 120)
	_prop("vazo", 3700, 160)
	_prop("saksi", 3900, 160)
	_terrain(4300, 9700, 0)
	_han_gate(4560, "1. KAPI")
	_story(4440, _sahne_kapi1)

	# --- 4. Sarnıç salonu: kilitli arena ------------------------------------------
	_checkpoint(4720, 0)
	_scaffold(5350, -170, 240)
	_coin_line(5280, 4, 50, -220)
	_prop("vazo", 5000)
	_prop("kasa", 5650)
	_lantern(4900)
	_lantern(5800)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(5350, 0)
	arena.gate_left_x = 4850
	arena.gate_right_x = 5900
	arena.floor_y = 0
	arena.wave1 = _wave(KNIFE, STREET, KNIFE)
	arena.wave2 = _wave(ASSASSIN, RIFLE)
	arena.wave3 = _wave(BRUISER, ASSASSIN)
	arena.reward = HEALTH
	add_child(arena)

	# --- 5. İkinci kanal: kaya çıkıntılarında tüfekliler; 2. kapı -----------------
	_checkpoint(6050, 0)
	_crates(6200, 1, 1)
	_terrain(6290, 6500, -180)  # kaya çıkıntısı
	_enemy(RIFLE, 6420, -180)
	_canal(6500, 7300, 110)
	_terrain(7250, 7300, 55)
	for k in 4:
		var cx2 := 6600.0 + k * 175.0
		_collapse(cx2, -20.0, 150)
		_pickup(COIN, cx2, -75.0)
	_terrain(7300, 9700, 0)
	_moving(6900, -170, Vector2(0, -120), 130, 0.25)
	_pickup(ARMOR, 6900, -380)
	_enemy(SHIELD, 7500, 0)
	_enemy(STREET, 7650, 0)
	_han_gate(7950, "2. KAPI")
	_story(7830, _sahne_kapi2)

	# --- 6. Tünel bekçisi; gün ışığı ----------------------------------------------
	_checkpoint(8100, 0)
	_prop("varil", 8350)
	_prop("vazo", 8800)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(8650, 0)
	final.gate_left_x = 8200
	final.gate_right_x = 9100
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, STREET, BOMBER)
	final.wave2 = _wave(MINIBOSS)
	final.wave3 = _wave(ASSASSIN, BRUISER)
	final.reward = HEALTH
	add_child(final)
	_story(9200, _sahne_gun_isigi)
	_han_gate(9450, "DAĞ GEÇİDİ")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2362, "redmount", "REDMOUNT", "Tebeşir çizgisi. Gazelle, tünelin içinden de iz bırakmış.")
	_radio(5197, "telsiz", "TÜNEL BEKÇİSİ (telsiz)", "Su yükseliyor. Sevkiyatı sarnıçtan geçirin, çabuk.")
	_radio(8032, "gazelle", "GAZELLE (tebeşir notu)", "\"Zırhlı üs. Köprü. Acele et.\" — G.")
	_goal(9450, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Kuyu dibi: duvarda Gazelle'in tebeşir çizgileri, uzaktan sesi.
func _sahne_kuyu(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(120, -420))
	await cs.pan(Vector2(330, -220), 0.01)
	cs.pose("rm", "jump")
	await cs.hop("rm", Vector2(150, 0), 0.7, 10.0)
	Fx.dust(Vector2(150, 0), 0.0, 10)
	cs.pose("rm", "crouch")
	await cs.wait(0.3)
	cs.pose("rm", "idle")
	await cs.say("rm", "REDMOUNT", "Asansör kuyusunun dibi. Hava ağır, su damlıyor.")
	await cs.move("rm", 420, 1.0, "walk")
	await cs.say("rm", "REDMOUNT", "Duvarda tebeşirle üç çizgi... Üç kapı mı?")
	cs.actor("echo", "voice", Vector2(1200, -260))
	await cs.say("echo", "GAZELLE (uzaktan, yankı)", "...bir kapı daha geçtik... üç kapı kaldı... Redmount, sayıyorum...", 2.6)
	await cs.say("rm", "REDMOUNT", "Kapıları sayıyorsun Gazelle. Ben de sayıyorum.")


## Birinci kapı: Gazelle'in yankısı.
func _sahne_kapi1(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("echo", "voice", Vector2(p.x + 500, -260))
	await cs.pan(Vector2(4560, -220), 0.5)
	await cs.say("rm", "REDMOUNT", "Birinci kapı. Demirde taze çizikler var.")
	await cs.say("echo", "GAZELLE (yankı)", "...gümm... iki kapı kaldı... soğuk... su sesi...", 2.2)
	await cs.say("rm", "REDMOUNT", "Su sesi: sarnıç salonu. Çok gerimde değilsin, dayan.")


## İkinci kapı: adamların konuşması ve Gazelle.
func _sahne_kapi2(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("echo", "voice", Vector2(p.x + 520, -260))
	await cs.pan(Vector2(7950, -220), 0.5)
	await cs.say("echo", "KABADAYI (uzaktan)", "Yürü! Zırhlı üsse kadar daha çok yolumuz var!", 1.8)
	await cs.say("echo", "GAZELLE (yankı)", "...son kapı... zırhlı üs... dağ geçidi...", 2.0)
	await cs.say("rm", "REDMOUNT", "İkinci kapı. Bir kapı kaldı ve o kapı zırhlı bir üsse açılıyor.")


## Gün ışığı: tünel dağ geçidine açılır.
func _sahne_gun_isigi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	await cs.pan(Vector2(9380, -220), 0.6)
	await cs.say("rm", "REDMOUNT", "Gün ışığı... Tünel dağ geçidine açılıyor.")
	await cs.say("rm", "REDMOUNT", "Önümde Karahanlı'nın zırhlı üssü var. Üçüncü kapı orada.")

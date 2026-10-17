## Bölüm 12 — İç Kale / Karahanlı (Kitap 1 finali).
##
## İç kale: cephanelik, sarnıç, tutukevi ve taht salonu. Karahanlı taht salonunda
## Gazelle'i zincirli tutar; uzun bir yüzleşmeden sonra boss dövüşü. Karahanlı
## yenilince (is_story_boss) Main bu bölümün `rescue_scene`'ini oynatır: Gazelle
## kurtulur, film rulosu ve taht odasından çıkan sevkiyat defteri Kitap 2'yi açar.
extends DtmLevel

const KARAHANLI := preload("res://scenes/enemies/Karahanli.tscn")
const GAZELLE_NODE := preload("res://scenes/characters/Gazelle.tscn")
const POWERUP := preload("res://scenes/pickups/PowerupPickup.tscn")
const PU_DAMAGE := preload("res://resources/powerups/damage_x2.tres")
const PU_SHIELD := preload("res://resources/powerups/shield.tres")

const THRONE_X := 7400.0


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/book03_cengelkoy_mansion_atlas.png")
	sky_cells = [[2, -100000.0], [3, 3300.0], [0, 6200.0]]
	sky_tint = Color(0.86, 0.84, 0.92)
	sky_shade = Color(0.04, 0.03, 0.07)
	back_row_on = false
	_night(Color(0.78, 0.74, 0.9))
	_ceiling(-400, 8700, -440)

	# --- 1. İç kale girişi ---------------------------------------------------------
	_terrain(-400, 3300, 0)
	_story(-1.0, _sahne_giris, 220.0)
	for x in [300, 1000]:
		_lantern(float(x))
	_prop("vazo", 450)
	_prop("sandik", 600, 0, HEALTH)
	_enemy(ELITE, 900, 0)
	_enemy(KNIFE, 1100, 0)

	# --- 2. Cephanelik: güçlendiriciler + kilitli arena ---------------------------
	_checkpoint(1380, 0)
	_powerup(1500, -60, PU_DAMAGE)
	_powerup(1580, -60, PU_SHIELD)
	_scaffold(2300, -170, 240)
	_coin_line(2230, 4, 50, -220)
	_prop("varil", 1900)
	_prop("kasa", 2700)
	var armory: BattleArena = ARENA.instantiate()
	armory.position = Vector2(2300, 0)
	armory.gate_left_x = 1750
	armory.gate_right_x = 2850
	armory.floor_y = 0
	armory.wave1 = _wave(ELITE, KNIFE, RIFLE)
	armory.wave2 = _wave(BRUISER, ELITE)
	armory.wave3 = _wave(ASSASSIN, ELITE, ELITE)
	armory.reward = HEALTH
	add_child(armory)

	# --- 3. Sarnıç: çöken tahtalar, palet asansörü --------------------------------
	_checkpoint(3050, 0)
	_canal(3300, 4300, 120)
	_terrain(4250, 4300, 60)
	for k in 6:
		var cx := 3390.0 + k * 160.0
		_collapse(cx, -10.0, 140)
		_pickup(COIN, cx, -65.0)
	_moving(3800, -150, Vector2(0, -90), 120, 0.0)
	_pickup(ARMOR, 3800, -330)
	_terrain(4300, 8700, 0)
	_terrain(4500, 4720, -180)
	_crates(4410, 1, 1)
	_enemy(RIFLE, 4640, -180)

	# --- 4. Tutukevi: Hasan'ın sesi -------------------------------------------------
	_checkpoint(4950, 0)
	_story(5150, _sahne_tutukevi)
	# Tutukevi: iki katlı hücre bloğu; üst koğuşta gardiyan, altta nöbet.
	_interior(5250, 6150, -230, [-115.0], 0)
	_enemy(ELITE, 5600, 0)
	_enemy(ASSASSIN, 5800, 0)
	_enemy(KNIFE, 5500, -115)
	_coin_line(5300, 8, 90, -160)
	_pickup(HEALTH, 6100, -160)
	_prop("vazo", 6000)
	_lantern(5300)
	_lantern(6100)

	# --- 5. Taht salonu: Karahanlı ---------------------------------------------------
	_checkpoint(6350, 0)
	_story(6450, _sahne_taht)
	var gz := GAZELLE_NODE.instantiate()
	gz.position = Vector2(8250, 0)
	gz.z_index = -3
	add_child(gz)
	var throne: BattleArena = ARENA.instantiate()
	throne.position = Vector2(THRONE_X, 0)
	throne.gate_left_x = 6650
	throne.gate_right_x = 8150
	throne.floor_y = 0
	throne.wave1 = _wave(KARAHANLI)
	add_child(throne)
	_lantern(6800)
	_lantern(8000)


func _powerup(x: float, y: float, res: PowerupConfig) -> void:
	var p := POWERUP.instantiate()
	p.set("powerup", res)
	p.position = Vector2(x, y)
	add_child(p)


## Main çağırır (Karahanlı yenilince): oyun içi kurtarma sahnesi.
func rescue_scene() -> void:
	var cs := Cutscene.new()
	cs.trigger_x = -1.0
	cs.force_start = true
	cs.script_fn = _sahne_kurtarma
	add_child(cs)
	await cs.done


# --- Hikâye sahneleri ----------------------------------------------------------

## İç kale girişi: Karahanlı'nın son daveti.
func _sahne_giris(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(60, 0))
	cs.actor("kh", "voice", Vector2(600, -330))
	await cs.pan(Vector2(360, -220), 0.01)
	await cs.move("rm", 220, 0.9, "walk")
	await cs.say("kh", "KARAHANLI (her yerden)", "İç kaleme hoş geldin, Redmount. Cephanelik, sarnıç, tutukevi... sonra taht salonu.")
	await cs.say("kh", "KARAHANLI", "Her odada biraz daha yorulacaksın. Taht salonuna vardığında ben dinlenmiş olacağım.")
	await cs.say("rm", "REDMOUNT", "Balat'tan beri dinleniyorsun Karahanlı. Ben yürüyorum.")


## Tutukevi: Hasan ve diğer tutsaklar.
func _sahne_tutukevi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("hs", "voice", Vector2(p.x + 280, -180))
	await cs.pan(Vector2(p.x + 200, -220), 0.5)
	await cs.say("hs", "HASAN (hücreden)", "Evladım! Gece pazarındaki sen misin? Beni de buraya getirdiler!")
	await cs.say("rm", "REDMOUNT", "Hasan! Çıkaracağım seni, söz. Kızı gördün mü?")
	await cs.say("hs", "HASAN", "Az önce taht salonuna götürdüler. Zincirliydi ama başı dikti. Karahanlı'ya laf yetiştiriyordu.")
	await cs.say("rm", "REDMOUNT", "Gazelle'in ta kendisi.")


## Taht salonu: Karahanlı ve zincirli Gazelle; uzun yüzleşme.
func _sahne_taht(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("kh", "karahanli", Vector2(7700, 0), -1)
	cs.actor("gzv", "voice", Vector2(8250, -150))
	await cs.pan(Vector2(7300, -220), 1.0)
	await cs.say("kh", "KARAHANLI", "Sonunda. Balat'tan taht salonuma... Bir film rulosu için bu kadar yol.")
	await cs.say("rm", "REDMOUNT", "Rulo için değil. Onun için.")
	await cs.say("gzv", "GAZELLE (zincirli)", "Redmount! Rulo neredeyse onu gösteriyor: mühürleri, rotaları, kimin imza attığını!")
	await cs.say("kh", "KARAHANLI", "Sessiz ol kız. Rulodaki her yüz, bu şehirden benden daha güçlü birine çıkar.")
	await cs.say("kh", "KARAHANLI", "Ben sadece bir halkayım Redmount. Ama bu gece seni zincirime ekleyecek halka benim.")
	await cs.say("rm", "REDMOUNT", "O zaman zincirini burada, senin halkandan kıracağım.")
	await cs.say("kh", "KARAHANLI", "Kapıları kapatın. Bu dans ikimizin.")
	await cs.move("kh", 7500, 0.6, "walk")
	cs.remove("kh")


## Kurtarma: Karahanlı yenilir, Gazelle serbest; defter Kitap 2'yi açar.
func _sahne_kurtarma(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", Vector2(p.x, 0))
	cs.actor("gz", "gazelle", Vector2(8250, 0), -1)
	cs.pose("gz", "rescue_react")
	for g in get_tree().get_nodes_in_group(&"gazelle"):
		(g as CanvasItem).visible = false
	await cs.pan(Vector2((p.x + 8250.0) * 0.5, -220), 0.8)
	await cs.say("gz", "GAZELLE", "Zincir... kırıldı. Redmount!")
	cs.pose("gz", "freed")
	await cs.move("gz", p.x + 70.0, 1.2, "freed")
	cs.face("rm", 1)
	cs.face("gz", -1)
	await cs.say("gz", "GAZELLE", "Geleceğini biliyordum. Her kapıyı sayarken bunu biliyordum.")
	await cs.say("rm", "REDMOUNT", "Söz vermiştim. Bugün iş yok demiştim... Biraz uzun sürdü.")
	cs.pose("gz", "rescue_pose")
	await cs.say("gz", "GAZELLE", "Balat'taki simit hâlâ geçerli mi?")
	await cs.say("rm", "REDMOUNT", "En güzeli. Ama önce şunu al.")
	await cs.say("gz", "GAZELLE", "Film rulosu! Saklamışsın... Taht odasında bir de bunu buldum: bir sevkiyat defteri.")
	await cs.say("gz", "GAZELLE", "Karahanlı tek başına değildi. Defterin ilk adresi Haliç kıyısı.")
	await cs.say("rm", "REDMOUNT", "O zaman zinciri halka halka sökeceğiz. Ama bu sefer yanımda olacaksın.")
	await cs.say("gz", "GAZELLE", "Yanında olacağım. Bir daha kimse beni bir minibüse bindiremez.")

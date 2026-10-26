## Bölüm 14 — Sahte Mühür (Kitap 2 / "Haliç'in İzi", 2. bölüm).
##
## Gümrükteki kayıt sahte bir sevkiyat mührü çıktı. Redmount ve Gazelle kalıbın
## kaynağını Cibali'de arar: Unkapanı uncu sokağı, kemerli geçit, halat atölyesi
## (zırhlı + vinç), tütün fabrikası dışı, fener basamakları (seçkin muhafız),
## sahte mühür baskıhanesi ve arşiv avlusu. Kalıbın arkasındaki ikinci adres
## Zeyrek su yolları. Ağın başındaki kişi açıklanmaz; yalnız bir lakap duyulur.
extends DtmLevel

const STREETS := preload("res://assets/backgrounds/book02_cibali_streets_atlas.png")
const PRESS := preload("res://assets/backgrounds/book02_cibali_press_atlas.png")


func _build() -> void:
	sky_atlas = STREETS
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3200.0], [3, 4300.0],
		[0, 5600.0, PRESS], [1, 6900.0, PRESS], [2, 8000.0, PRESS], [3, 9000.0, PRESS]]
	sky_tint = Color(0.9, 0.86, 0.84)
	sky_shade = Color(0.08, 0.05, 0.06)
	back_row_skip = [[3500.0, 5600.0], [7950.0, 9000.0]]

	# --- 1. Gümrük avlusu: ısınma, ilk tüfekli ---------------------------------
	_terrain(-400, 1600, 0)
	_story(-1.0, _sahne_muhur, 240.0)
	_prop("saksi", 380)
	_enemy(STREET, 700, 0)
	_crates(900, 1, 1)
	_crates(990, 1, 2)
	_terrain(1080, 1400, -180)
	_enemy(RIFLE, 1300, -180)
	_pickup(ARMOR, 1150, -225)
	_coin_line(1110, 4, 60, -230)
	_prop("vazo", 1500)

	# --- 2. Unkapanı uncu sokağı: 60 px iner, balkon yolu, fırın tezgâhı --------
	_checkpoint(1550, 0)
	_terrain(1600, 1800, 30)
	_terrain(1800, 3300, 60)
	_balcony(1950, -40, 110)
	_balcony(2120, -140, 110)
	_balcony(2300, -220, 110)
	_coin_line(2250, 3, 50, -270)
	_pickup(HEALTH, 2300, -265)
	_stall(2550)
	_prop("kasa", 2450, 60)
	_prop("saksi", 2700, 60)
	_enemy(KNIFE, 2800, 60)
	_enemy(STREET, 2950, 60)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(3150, 60)
	shop.title = "UNKAPANI FIRINI"
	shop.items = PackedStringArray(["can", "semsiye", "cephane"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 3. Kemerli taş geçit: kısa iskele, devriye ------------------------------
	_checkpoint(3350, 60)
	_terrain(3300, 3450, 30)
	_terrain(3450, 3900, 0)
	_canal(3900, 4100, 110)
	_scaffold(4000, -20, 220)
	_terrain(4100, 9800, 0)
	_scaffold(3700, -150, 160)
	_pickup(PISTOL, 3700, -195)
	_enemy(SHIELD, 4300, 0)
	for x in [3500, 4250]:
		_lantern(float(x))

	# --- 4. Halat atölyesi: zırhlı dövüşü ya da vinçle üst rota; iki dalga -------
	_checkpoint(4450, 0)
	# Atölye kapalı salon: içeri girince cephe açılır; vinç rayı tavanın altında.
	_interior(4520, 5480, -400, [], 0)
	_fg("zincir", 4700.0, -560.0, 200.0)
	_scaffold(4650, -130, 140)
	_scaffold(4650, -240, 140)
	_moving(4800, -250, Vector2(320, 0), 140, 0.0)
	_scaffold(5280, -250, 140)
	_pickup(RIFLE_PICKUP, 5280, -295)
	_coin_line(4820, 5, 75, -310)
	_prop("varil", 4750)
	_prop("kasa", 5350)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(5000, 0)
	arena.gate_left_x = 4550
	arena.gate_right_x = 5450
	arena.floor_y = 0
	arena.wave1 = _wave(BRUISER, STREET)
	arena.wave2 = _wave(SHIELD, RIFLE, STREET)
	arena.reward = HEALTH
	add_child(arena)

	# --- 5. Tütün fabrikası dışı: menzilli düşmana açık yaklaşım ------------------
	_checkpoint(5650, 0)
	_factory(5900, 6300, -200)
	_crates(5720, 1, 1)
	_crates(5810, 1, 2)
	_enemy(RIFLE, 6200, -200)
	_coin_line(5940, 5, 70, -250)
	_pickup(ARMOR, 6250, -245)
	_enemy(BOMBER, 6600, 0)
	_enemy(KNIFE, 6750, 0)
	_prop("varil", 6450)

	# --- 6. Fener basamakları: seçkin muhafız avlusu ---------------------------
	_checkpoint(6900, 0)
	_story(6960, _sahne_fener)
	_prop("vazo", 7150)
	_prop("saksi", 7800)
	_lantern(7050)
	_lantern(7850)
	# Fener kulesi: altından geçilen kemer, içi duvar-zıplamayla tırmanılır.
	_enemy(ELITE, 7250, 0)
	_enemy(KNIFE, 7350, 0)
	chimney_brick = true   # gündüz sokağı: tuğla kule
	_chimney(7550, -520, 140, 150, AMMO)
	chimney_brick = false
	_enemy(ASSASSIN, 7780, 0)

	# --- 7. Baskıhane: kalıp; üst kirişte riskli ödül ------------------------------
	_checkpoint(8000, 0)
	_story(8050, _sahne_baskihane)
	# Baskıhane içi: üst kirişler çürük; altta kalıp sandığı.
	_interior(8120, 8780, -345, [], 0)
	_enemy(STREET, 8600, 0)
	_collapse(8300, -170, 130)
	_collapse(8450, -230, 130)
	_pickup(ARMOR, 8450, -275)
	_crates(8180, 1, 1)
	_prop("sandik", 8700, 0, AMMO)

	# --- 8. Arşiv avlusu: final karşılaşması; Zeyrek adresi -----------------------
	_checkpoint(8850, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9200, 0)
	final.gate_left_x = 8950
	final.gate_right_x = 9450
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN, BOMBER)
	final.wave2 = _wave(ELITE, BRUISER)
	final.reward = HEALTH
	add_child(final)
	_story(9500, _sahne_zeyrek)
	_han_gate(9700, "ARŞİV")
	# Çevresel tehlikeler.
	_falling_pot(1950, -44)
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2425, "gazelle", "GAZELLE", "Sahte mühür! Kâğıtlar resmi görünüyor ama mühür ters basılmış.")
	_radio(5335, "redmount", "REDMOUNT", "Kim mühür basıyorsa, baskıhanede olmalı.")
	_radio(8245, "gazelle", "GAZELLE", "Arşiv avlusunda bir adres: Zeyrek su hattı.")
	_goal(9700, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Gümrük avlusu: sahte mührün incelenmesi.
func _sahne_muhur(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Bak şu mühre. Gümrük mührü gibi ama hilal ters, harfler bir milim kaymış.")
	await cs.say("rm", "REDMOUNT", "Taklit. Ama iyi bir taklit. Bunu ancak bir matbaacı yapar.")
	await cs.say("gz", "GAZELLE", "Cibali'de eski bir baskıhane var. Babam orada gazete dizerdi.")
	await cs.say("rm", "REDMOUNT", "O zaman yolu biliyorsun. Önden sen, arkadan yumruklar.")


## Fener basamakları: "Kâtip" lakabı ilk kez duyulur.
func _sahne_fener(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("e1", "elite", Vector2(7450, 0), -1)
	await cs.pan(Vector2(7250, -200), 0.6)
	await cs.say("e1", "SEÇKİN MUHAFIZ", "Kâtip Efendi baskıhaneye kimseyi sokmayın dedi. Kimseyi.")
	await cs.say("gz", "GAZELLE", "Kâtip Efendi? Karahanlı'nın patronunun adı bu mu?")
	await cs.say("e1", "SEÇKİN MUHAFIZ", "Adını sorduğun an mezarına yazılır, gazeteci.")
	await cs.say("rm", "REDMOUNT", "Mezar taşı yazmayı ben de bilirim. Kapıları kapat bakalım.")
	await cs.move("e1", 7800, 0.6, "walk")
	cs.remove("e1")


## Baskıhane: kalıp ve dizgi masası.
func _sahne_baskihane(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 250, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Burası... babamın çalıştığı yer. Ama makineler yenilenmiş.")
	cs.pose("gz", "rescue_react")
	await cs.say("gz", "GAZELLE", "Kalıp burada basılmış! Dizgi masasında aynı ters hilal.")
	await cs.say("rm", "REDMOUNT", "Kalıbın arkasında bir adres kazınmış... 'Zeyrek, eski su yolu, üçüncü vana.'")
	await cs.say("gz", "GAZELLE", "Su yolları. Kaçak malı borulardan mı taşıyorlar?")


## Arşiv avlusu: bir sonraki adres.
func _sahne_zeyrek(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(9600, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Kalıp burada basılmış. Arkasındaki ikinci adres Zeyrek'in su yollarını gösteriyor.")
	await cs.say("rm", "REDMOUNT", "Mührü kimin bastırdığı hâlâ belli değil. Ama bir lakabı var artık: Kâtip.")
	await cs.say("gz", "GAZELLE", "Kâtipler iz bırakır. Her sayfaya bir imza. Devam.")

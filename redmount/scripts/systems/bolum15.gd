## Bölüm 15 — Zeyrek Su Hattı (Kitap 2 / "Haliç'in İzi", 3. bölüm).
##
## Kalıptaki ikinci adres Zeyrek'in eski su yolları. Mahalle -> çeşme meydanı
## (arena) -> açık su kemeri (ayak taşları) -> bakım galerisi (tüfekli, hareketli köprü) -> sarnıç
## -> su çarkı (üst dişli yolu, arena) -> gizli kemer -> Zeyrek terası (son arena).
## Üçüncü vanada aynı sahte mühür: şebeke kaçak sevkiyat geçidi olmuş. Çıkış kaydı
## Süleymaniye'yi gösterir.
extends DtmLevel

const SURFACE := preload("res://assets/backgrounds/book02_zeyrek_surface_atlas.png")
const CISTERN := preload("res://assets/backgrounds/book02_zeyrek_cistern_atlas.png")


func _build() -> void:
	sky_atlas = SURFACE
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3100.0], [3, 4400.0],
		[0, 5800.0, CISTERN], [1, 7000.0, CISTERN], [2, 8200.0, CISTERN], [3, 9100.0, CISTERN]]
	sky_tint = Color(0.9, 0.88, 0.86)
	sky_shade = Color(0.05, 0.06, 0.07)
	back_row_skip = [[4500.0, 8900.0]]

	# --- 1. Zeyrek mahallesi: devriye, balkon seçimi, erzak tezgâhı -------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_mahalle, 240.0)
	_balcony(560, -70, 110)
	_balcony(720, -170, 110)
	_pickup(ARMOR, 720, -215)
	_coin_line(520, 4, 50, -120)
	_enemy(KNIFE, 1000, 0)
	_prop("saksi", 1150)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(1400, 0)
	shop.title = "ZEYREK ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 2. Çeşme meydanı: sokak hizasında ilk arena -------------------------------
	# Kitap 2'nin ortak çukur avlusu yerine meydan çeşmenin önünde düz.
	_checkpoint(1620, 0)
	_terrain(1700, 3450, 0)
	_prop("vazo", 2000, 0)
	_prop("kasa", 2800, 0)
	var square: BattleArena = ARENA.instantiate()
	square.position = Vector2(2400, 0)
	square.gate_left_x = 1950
	square.gate_right_x = 2850
	square.floor_y = 0
	square.wave1 = _wave(STREET, KNIFE, STREET)
	square.wave2 = _wave(RIFLE, SHIELD)
	square.reward = AMMO
	add_child(square)

	# --- 3. Açık su kemeri: ayak taşlarından geçiş; üst taş rafında tabanca ---------
	# Tahta iskeleli 200 px kanal yerine 500 px açık su: kemer ayaklarının sudan çıkan
	# başları (90 px) basamak taşı. Kaçıran ıslanır, dipte (110) yürüyüp çıkar; ölüm yok.
	_checkpoint(3150, 0)
	_canal(3450, 3950, 110)
	_terrain(3900, 3950, 55)  # çıkış taşı: dipten rıhtıma iki adımda
	_pier(3530)
	_pier(3700)
	_coin_line(3620, 3, 40, -150)
	_terrain(3950, 4400, 0)
	_scaffold(3900, -140, 130)
	_scaffold(4050, -250, 130)
	_pickup(PISTOL, 4050, -295)
	_enemy(SHIELD, 4250, 0)

	# --- 4. Bakım galerisi: tüfekliye yaklaşma, hareketli köprü (isteğe bağlı) -----
	_checkpoint(4450, 0)
	_terrain(4400, 6000, 0)
	_terrain(6200, 8000, 0)
	_terrain(8200, 9900, 0)
	_crates(4650, 1, 1)
	_crates(4740, 1, 2)
	_terrain(4830, 5150, -180)
	_enemy(RIFLE, 5080, -180)
	_moving(5250, -200, Vector2(260, 0), 130, 0.0)
	_scaffold(5650, -200, 120)
	_pickup(RIFLE_PICKUP, 5650, -245)
	_coin_line(5260, 4, 70, -260)
	_prop("varil", 5450)

	# --- 5. Sarnıç: ikinci sabit iskele, karışık devriye -------------------------
	_checkpoint(5850, 0)
	_canal(6000, 6200, 110)
	_scaffold(6100, -20, 220)
	_enemy(KNIFE, 6400, 0)
	_enemy(ASSASSIN, 6600, 0)
	_pickup(ARMOR, 6500, -45)
	for x in [5950, 6700]:
		_lantern(float(x))
	_story(6250, _sahne_vana)
	# Sarnıç: kaya tavan, ön planda sarnıç sütunları.
	for cx in [6050.0, 6350.0, 6650.0]:
		_fg("kolon", cx, 40.0, 380.0)

	# --- 6. Su çarkı: alçak servis yolu + üst dişli yolu; arena ----------------------
	_checkpoint(6850, 0)
	for k in 4:
		_scaffold(7050.0 + k * 170.0, -240.0, 140)
		_pickup(COIN, 7050.0 + k * 170.0, -290.0)
	_crates(6950, 1, 1)
	_scaffold(7000, -130, 100)
	_prop("varil", 7250)
	var wheel: BattleArena = ARENA.instantiate()
	wheel.position = Vector2(7350, 0)
	wheel.gate_left_x = 7000
	wheel.gate_right_x = 7700
	wheel.floor_y = 0
	wheel.wave1 = _wave(BRUISER, KNIFE)
	wheel.wave2 = _wave(RIFLE, STREET, ASSASSIN)
	wheel.reward = HEALTH
	add_child(wheel)

	# --- 7. Gizli kemer: üçüncü kesinti, seçkin devriye -----------------------------
	_checkpoint(7850, 0)
	_canal(8000, 8200, 110)
	_scaffold(8100, -20, 220)
	_enemy(ELITE, 8350, 0)
	_chimney(8530, -500, 140, 150, ARMOR)
	_pickup(HEALTH, 8300, -45)

	# --- 8. Zeyrek terası: son arena; Süleymaniye kaydı ---------------------------
	_checkpoint(8650, 0)
	_prop("vazo", 8800)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9150, 0)
	final.gate_left_x = 8750
	final.gate_right_x = 9500
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, BOMBER, STREET)
	final.wave2 = _wave(ELITE, ASSASSIN)
	final.reward = HEALTH
	add_child(final)
	_story(9580, _sahne_teras)
	_han_gate(9780, "SÜLEYMANİYE YOLU")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2445, "gazelle", "GAZELLE", "Zeyrek'te sular kesiliyor. Bu bir rastlantı değil, deneme.")
	_radio(5379, "redmount", "REDMOUNT", "Vanayı kim çeviriyorsa, şehri susuz bırakarak susturmak istiyor.")
	_radio(8313, "gazelle", "GAZELLE", "Teras kaydı: Süleymaniye arşivi. Kâtip kayıtları orada saklıyor.")
	_goal(9780, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Zeyrek mahallesi: su kesik, çeşmeler kurumuş.
func _sahne_mahalle(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	cs.actor("teyze", "voice", Vector2(620, -200))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	await cs.say("teyze", "TEYZE (pencereden)", "Üç gündür musluklardan su akmıyor! Belediye 'bakım' diyor, bakımcılar da tüfekli!")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Tüfekli bakımcılar. Su yolunu boşaltıp borulardan başka şey taşıyorlar.")
	await cs.say("rm", "REDMOUNT", "Üçüncü vana. Çeşme meydanından aşağı inelim.")


## Sarnıçtaki üçüncü vana: aynı sahte mühür.
func _sahne_vana(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 180, -200), 0.5)
	cs.pose("gz", "rescue_react")
	await cs.say("gz", "GAZELLE", "Üçüncü vana! Kapağında aynı ters hilal. Kâtip'in mührü.")
	await cs.say("rm", "REDMOUNT", "Su şebekesini kaçak sevkiyat geçidine çevirmişler. Borulardan şehir altına mal taşıyorlar.")
	await cs.say("gz", "GAZELLE", "Fotoğrafını çektim. Bir rulo daha Kâtip'in koleksiyonuna eklenmedi, bizimkine eklendi.")


## Zeyrek terası: çıkış kaydı Süleymaniye'yi gösterir.
func _sahne_teras(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(9680, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Vanaların hepsinde aynı sahte mühür. Çıkış kaydı... Süleymaniye'de bir ciltçi deposu.")
	await cs.say("rm", "REDMOUNT", "Ciltçi. Kâtip. Kitaplarla yaşayan biri bu.")
	await cs.say("gz", "GAZELLE", "Ya da kitapların arkasına saklanan biri. Süleymaniye'ye.")


## Kemer ayağının sudan çıkan başı: tepesi zeminden 90 px yukarıda, gövdesi kanal
## dibine (110) kadar iner; alt kısmı suyun arkasında kalır, havada asılı durmaz.
func _pier(left: float) -> void:
	var body := _solid_box(left, -90.0, 90.0, 200.0)
	body.add_child(_Art.new(_Art.A_STONES, Vector2(90.0, 200.0)))

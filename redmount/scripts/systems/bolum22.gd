## Bölüm 22 — Aksaray Pompa İstasyonu (Kitap 2 / "Haliç'in İzi", 10. bölüm).
##
## Kemal Bey'in verdiği adres: Aksaray eski pompa istasyonu. Sokak -> istasyon
## avlusu (arena) -> filtre salonu (kanal, taş raf) -> vana galerisi (boru rafı,
## arena, erzak) -> pompa salonu (presler gibi işleyen pistonlar, makine rafı) ->
## bakım şaftı (arena) -> kontrol odası (kapatma çizelgesi) -> tahliye avlusu (üç
## dalga). Sahte yardımın yükü değiştirilmiş yedek vanalar: şafakta Saraçhane ana
## vanasından şehrin suyu kesilecek. Kâtip'in sesi ilk kez bir gramofondan duyulur.
extends DtmLevel

const APPROACH := preload("res://assets/backgrounds/book02_aksaray_approach_atlas.png")
const PUMP := preload("res://assets/backgrounds/book02_aksaray_pump_atlas.png")


func _build() -> void:
	sky_atlas = APPROACH
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3300.0], [3, 4600.0],
		[0, 6100.0, PUMP], [1, 7400.0, PUMP], [2, 8700.0, PUMP], [3, 9800.0, PUMP]]
	sky_tint = Color(0.86, 0.86, 0.94)
	sky_shade = Color(0.03, 0.04, 0.08)
	back_row_skip = [[3300.0, 9700.0]]
	_night(Color(0.78, 0.8, 0.94))

	# --- 1. Aksaray sokağı: devriye, balkon ----------------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_sokak, 240.0)
	_balcony(560, -70, 110)
	_balcony(720, -170, 110)
	_pickup(ARMOR, 720, -215)
	_enemy(STREET, 1050, 0)
	for x in [300, 1400]:
		_lantern(float(x))

	# --- 2. İstasyon avlusu: sığ iniş, iki dalga -------------------------------
	_checkpoint(1550, 0)
	_terrain(1700, 1850, 30)
	_terrain(1850, 3200, 60)
	_lantern(1950)
	_lantern(3050)
	var avlu: BattleArena = ARENA.instantiate()
	avlu.position = Vector2(2500, 60)
	avlu.gate_left_x = 2050
	avlu.gate_right_x = 2950
	avlu.floor_y = 60
	avlu.wave1 = _wave(STREET, KNIFE, STREET)
	avlu.wave2 = _wave(RIFLE, ASSASSIN)
	avlu.reward = AMMO
	add_child(avlu)
	_terrain(3200, 3350, 30)

	# --- 3. Filtre salonu: kısa kanal, yüksek taş raf ---------------------------
	_terrain(3350, 3800, 0)
	_checkpoint(3400, 0)
	_canal(3800, 4000, 110)
	_scaffold(3900, -20, 220)
	_terrain(4000, 10300, 0)
	_stones(4150, 1, 1)
	_stones(4240, 1, 2)
	_pickup(PISTOL, 4285, -225)
	_enemy(SHIELD, 4550, 0)

	# --- 4. Vana galerisi: menzilli savunma, boru rafı, arena, erzak ------------
	_checkpoint(4750, 0)
	_crates(4880, 1, 1)
	_scaffold(5030, -150, 120)
	_scaffold(5180, -260, 120)
	_pickup(RIFLE_PICKUP, 5180, -305)
	# Vana galerisi: boru rafının altında tüfekliler; kilitsiz.
	_enemy(BOMBER, 5450, 0)
	_enemy(RIFLE, 5180, -260)
	_enemy(KNIFE, 5650, 0)
	_prop("varil", 5800, 0, AMMO)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6000, 0)
	shop.title = "SU ERZAKÇISI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Pompa salonu: pistonlar (pres), makine rafı ------------------------
	_checkpoint(6200, 0)
	# Pompa salonu: tonoz altında pistonlar; makine rafı üstte (riskli ama güvenli).
	for cx in [6330.0, 7200.0]:
		_fg("kolon", cx, 40.0, 440.0)
	_press(6450, 0.0, 3.0)
	_press(6750, 1.0, 3.0)
	_press(7050, 2.0, 3.0)
	_coin_line(6420, 6, 105, -60)
	_crates(6300, 1, 1)
	for k in 4:
		_scaffold(6450.0 + k * 175.0, -300.0, 150)
	_pickup(ARMOR, 6975, -345)
	_enemy(ASSASSIN, 7250, 0)

	# --- 6. Bakım şaftı: yakın/menzilli arena; gramofon -------------------------
	_checkpoint(7450, 0)
	_story(7520, _sahne_gramofon)
	_interior(7660, 8340, -345, [], 0)
	_scaffold(7800, -115, 150)
	_scaffold(8200, -115, 150)
	_scaffold(8000, -230, 180)
	var saft: BattleArena = ARENA.instantiate()
	saft.position = Vector2(8000, 0)
	saft.gate_left_x = 7700
	saft.gate_right_x = 8300
	saft.floor_y = 0
	saft.wave1 = _wave(ELITE, BOMBER)
	saft.wave2 = _wave(ELITE, SHIELD, RIFLE)
	saft.reward = HEALTH
	add_child(saft)

	# --- 7. Kontrol odası: son açıklık, kapatma çizelgesi ------------------------
	_checkpoint(8450, 0)
	_canal(8600, 8800, 110)
	_scaffold(8700, -20, 220)
	_interior(8900, 9280, -230, [-115.0], 0)
	_story(9000, _sahne_cizelge)
	_enemy(ELITE, 9150, 0)
	_pickup(HEALTH, 9240, -160)
	_coin_line(8950, 5, 60, -160)

	# --- 8. Tahliye avlusu: üç dalga; Saraçhane --------------------------------
	_checkpoint(9350, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9700, 0)
	final.gate_left_x = 9450
	final.gate_right_x = 10000
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN, KNIFE)
	final.wave2 = _wave(ELITE, RIFLE)
	final.wave3 = _wave(BRUISER, BRUISER)
	final.reward = HEALTH
	add_child(final)
	_story(10050, _sahne_safak)
	_han_gate(10150, "SARAÇHANE")
	_goal(10150, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Aksaray sokağı: yardım arabaları.
func _sahne_sokak(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Kemal Bey yazımı polise verdi mi bilmiyorum. Ama ben gazeteye taslağı bıraktım.")
	await cs.say("rm", "REDMOUNT", "İyi. Bir şey olursa hikâye yine çıkar.")
	await cs.say("gz", "GAZELLE", "Pompa istasyonunun kapısında 'yardım malzemesi' yazılı arabalar. Gece yarısı, su idaresinde.")


## Bakım şaftı: Kâtip'in sesi gramofondan.
func _sahne_gramofon(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("kt", "voice", Vector2(p.x + 300, -160))
	await cs.pan(Vector2(p.x + 200, -200), 0.5)
	await cs.say("kt", "KÂTİP (gramofon kaydı)", "Redmount. Gazelle. Sizi okuyorum. Satır satır, sayfa sayfa.")
	await cs.say("kt", "KÂTİP", "Bu şehir bir defterdir. Ben yazarım, o yaşar. Kimin adı silinirse, o hiç olmamıştır.")
	await cs.say("kt", "KÂTİP", "Şafakta suyu keseceğim. Şehir susadığında yeni defterime imza atmak için sıraya girecek.")
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Bu ses... Tanıyorum ama çıkaramıyorum. Gazetede bir yerden...")
	await cs.say("rm", "REDMOUNT", "Kayıt yapmayı seviyor. İnsanlar kayıt bırakmayı sevdiklerinde hata yaparlar.")


## Kontrol odası: kapatma çizelgesi.
func _sahne_cizelge(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Çizelge: 'Şafak, Saraçhane ana vana: tam kapama. Yedek vanalar değiştirildi.'")
	await cs.say("rm", "REDMOUNT", "Yardım diye taşıdıkları yedek vanalar. Şehrin musluğu Kâtip'in elinde.")


## Tahliye avlusu: şafak yaklaşıyor.
func _sahne_safak(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(10080, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Gökyüzü ağarıyor. Saraçhane ana vanası... vaktimiz yok.")
	await cs.say("rm", "REDMOUNT", "O zaman koşarız. Bu şehrin suyunu kimse bir kâtibin defterine yazamaz.")

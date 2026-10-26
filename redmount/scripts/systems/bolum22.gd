## Bölüm 22 — Aksaray Pompa İstasyonu (Kitap 2 / "Haliç'in İzi", 10. bölüm).
##
## Kemal Bey'in verdiği adres: Aksaray eski pompa istasyonu. Sokak -> kömür
## rampası (bombacı) -> filtre salonu (kuru havuz, boru köprüsü) -> vana galerisi (boru rafı,
## arena, erzak) -> pompa salonu (presler gibi işleyen pistonlar, makine rafı) ->
## bakım şaftı (arena) -> kontrol odası (kapatma çizelgesi) -> tahliye avlusu (kopuk
## kablo). Sahte yardımın yükü değiştirilmiş yedek vanalar: şafakta Saraçhane ana
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

	# --- 2. İstasyon önü: kömür rampası, rampada bombacı (kilitsiz) ---------------
	# Kitap 2'nin ortak çukur avlu arenası yerine kapısız bir yaklaşma kavgası: istasyonun
	# kömür rampası sokaktan iki basamak yukarıda, bombacı rampadan aşağı atıyor. Rampanın
	# üstündeki yük iskelesinde cephane; rampanın öbür ucundan avluya inilir.
	_checkpoint(1550, 0)
	_terrain(1700, 2200, 0)
	_terrain(2200, 2290, -45)
	_terrain(2290, 2900, -90)
	_terrain(2900, 3350, 0)
	_lantern(1950)
	_lantern(3050)
	_enemy(STREET, 1950, 0)
	_enemy(KNIFE, 2100, 0)
	_enemy(BOMBER, 2700, -90)
	_scaffold(2560, -205, 160)
	_pickup(AMMO, 2560, -250)
	_coin_line(2350, 4, 60, -135)
	_enemy(ASSASSIN, 3150, 0)

	# --- 3. Filtre salonu: kuru çökeltme havuzu, üstte boru köprüsü ---------------
	# İki yol: üstteki boru köprüsünde tabanca (güvenli, hızlı), havuzun dibinde
	# kalkanlı ve altın dizisi (riskli). Havuz basamaklı; ölüm yok.
	_terrain(3350, 3750, 0)
	_checkpoint(3400, 0)
	_basin(3750, 4250, 90, 80.0)
	_terrain(4250, 10300, 0)
	_scaffold(4000, -70, 300)
	_pickup(PISTOL, 4000, -115)
	_enemy(SHIELD, 4000, 90)
	_coin_line(3880, 5, 60, 45)

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
	saft.wave1 = _wave(BOMBER, SHIELD)
	saft.wave2 = _wave(ELITE, KNIFE)
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

	# --- 8. Tahliye avlusu: ortada kopuk kablo; Saraçhane ------------------------
	_checkpoint(9350, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9700, 0)
	final.gate_left_x = 9450
	final.gate_right_x = 10000
	final.floor_y = 0
	## Avlunun ortasında kopuk pompa kablosu: dövüş kablonun sönük anlarında ortadan
	## geçer. Bombacının ateşi oyuncuyu kabloya iter; son dalgada ağır + tüfekli.
	final.wave1 = _wave(KNIFE, BOMBER, KNIFE)
	final.wave2 = _wave(SHIELD, ELITE)
	final.wave3 = _wave(BRUISER, RIFLE)
	final.reward = HEALTH
	add_child(final)
	_live_wire(9660, 9790, 0.8)
	_story(10050, _sahne_safak)
	_han_gate(10150, "SARAÇHANE")
	# Çevresel tehlikeler.
	_live_wire(4400, 4560, 0.0)
	_live_wire(7200, 7380, 1.2)
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2537, "gazelle", "GAZELLE", "Aksaray pompa istasyonu. Emirler buradan çıkıyormuş.")
	_radio(5582, "redmount", "REDMOUNT", "Pistonlar bir ritimle çalışıyor. Ritmi yakala, geç.")
	_radio(8627, "gazelle", "GAZELLE", "Kapatma çizelgesi: şafakta Saraçhane ana vanası.")
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

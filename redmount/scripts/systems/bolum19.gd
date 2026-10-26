## Bölüm 19 — Çemberlitaş Külhanı (Kitap 2 / "Haliç'in İzi", 7. bölüm).
##
## Kapalıçarşı defteri dağıtım emirlerinin Çemberlitaş'taki kapalı hamamın
## külhanından çıktığını gösterir. Gece: arka sokak -> meydan (arena) -> hamam
## girişi (kanal) -> soyunmalık (galeri, arena, erzak) -> ılıklık (çini rafı) ->
## su servisi (60 px alt rota, arena) -> külhan yaklaşımı (alev bacaları) -> külhan
## (alev bacaları arasında Külhanbeyi). Külhanda Kemal Bey'in yarım yanmış mektubu: "Samatya taş depoları".
extends DtmLevel

const APPROACH := preload("res://assets/backgrounds/book02_hamam_approach_atlas.png")
const INNER := preload("res://assets/backgrounds/book02_hamam_inner_atlas.png")


func _build() -> void:
	sky_atlas = APPROACH
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3200.0], [3, 4500.0],
		[0, 6100.0, INNER], [1, 7400.0, INNER], [2, 8700.0, INNER], [3, 10050.0, INNER]]
	sky_tint = Color(0.86, 0.84, 0.92)
	sky_shade = Color(0.04, 0.03, 0.07)
	back_row_skip = [[4300.0, 10300.0]]
	_night(Color(0.8, 0.78, 0.92))

	# --- 1. Arka sokak: devriye, ilk balkon seçimi ------------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_sokak, 240.0)
	_balcony(560, -70, 110)
	_balcony(720, -170, 110)
	_pickup(ARMOR, 720, -215)
	_coin_line(520, 4, 50, -120)
	_enemy(KNIFE, 1050, 0)
	_prop("saksi", 1250)
	for x in [300, 1400]:
		_lantern(float(x))

	# --- 2. Çemberlitaş meydanı: sığ servis yolu, arena -------------------------
	_checkpoint(1550, 0)
	_terrain(1700, 1850, 30)
	_terrain(1850, 3200, 60)
	_lantern(1950)
	_lantern(3050)
	var sq: BattleArena = ARENA.instantiate()
	sq.position = Vector2(2500, 60)
	sq.gate_left_x = 2000
	sq.gate_right_x = 3000
	sq.floor_y = 60
	sq.wave1 = _wave(STREET, KNIFE, STREET)
	sq.wave2 = _wave(RIFLE, ASSASSIN)
	sq.reward = HEALTH
	add_child(sq)
	_terrain(3200, 3350, 30)

	# --- 3. Hamam girişi: kısa kanal, üst kapı rafı ----------------------------
	_terrain(3350, 3800, 0)
	_checkpoint(3400, 0)
	_canal(3800, 4000, 110)
	_scaffold(3900, -20, 220)
	_terrain(4000, 10300, 0)
	_scaffold(4200, -140, 130)
	_scaffold(4350, -250, 130)
	_pickup(PISTOL, 4350, -295)
	_enemy(SHIELD, 4550, 0)

	# --- 4. Soyunmalık: galeri ödülü, menzilli düşman, arena, erzak --------------
	_checkpoint(4750, 0)
	var aw := AwningBounce.new()
	aw.width = 160
	aw.height = 60
	aw.position = Vector2(4900, 0)
	add_child(aw)
	# Soyunmalık: hamamın ahşap galerili büyük salonu.
	_interior(5000, 5700, -400, [], 1)
	for k in 4:
		_scaffold(5080.0 + k * 160.0, -270.0, 140)
		_pickup(COIN, 5080.0 + k * 160.0, -320.0)
	_pickup(RIFLE_PICKUP, 5560, -315)
	var soy: BattleArena = ARENA.instantiate()
	soy.position = Vector2(5350, 0)
	soy.gate_left_x = 5050
	soy.gate_right_x = 5650
	soy.floor_y = 0
	soy.wave1 = _wave(BOMBER, KNIFE)
	soy.wave2 = _wave(BRUISER, SHIELD)
	soy.reward = HEALTH
	add_child(soy)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5850, 0)
	shop.title = "HAMAM ERZAKÇISI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Ilıklık: alt yol serbest, üst çini rafı ---------------------------
	_checkpoint(6100, 0)
	_interior(6200, 7000, -345, [], 1)
	_crates(6250, 1, 1)
	_scaffold(6420, -150, 140)
	_scaffold(6580, -250, 140)
	_pickup(ARMOR, 6580, -295)
	_enemy(ASSASSIN, 6800, 0)
	_story(6300, _sahne_iliklik)

	# --- 6. Su servisi: 60 px alt rota; seçkin + tüfekli arena -----------------
	_checkpoint(7050, 0)
	_canal(7200, 7400, 110)
	_scaffold(7300, -20, 220)
	# Su servisi: kemerli tonoz altında servis yolu, sarnıç sütunları önde.
	for cx in [7600.0, 7950.0]:
		_fg("kolon", cx, 40.0, 380.0)
	_enemy(ELITE, 7700, 0)
	_enemy(BOMBER, 8050, 0)
	_prop("sandik", 8180, 0, AMMO)

	# --- 7. Külhan yaklaşımı: yakıt rafı, alevler, son kanal ---------------------
	_checkpoint(8350, 0)
	# Külhan yaklaşımı: ocak dairesi; yakıt rafı üstte, alevler altta.
	_interior(8440, 8880, -345, [], 0)
	_flame(8550, 0.0)
	_flame(8750, 0.5)
	_coin_line(8500, 5, 80, -60)
	_scaffold(8650, -230, 300)
	_pickup(HEALTH, 8650, -275)
	_canal(8950, 9150, 110)
	_scaffold(9050, -20, 220)

	# --- 8. Külhan: alev bacaları arasında Külhanbeyi; Samatya adresi -----------
	_checkpoint(9300, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9700, 0)
	final.gate_left_x = 9400
	final.gate_right_x = 10000
	final.floor_y = 0
	## Külhancılar evrak yakıyor; ikinci dalgada külhanın sahibiyle bire bir. Ocak
	## ağzındaki iki alev bacası ters fazda: dövüş yerinde kalmaz, oyuncu alevin sönük
	## yanına çekilir.
	final.wave1 = _wave(KNIFE, STREET, KNIFE)
	final.wave2 = _wave(BRUISER)
	final.named_title = "KÜLHANBEYİ"
	final.named_wave = 2
	final.reward = HEALTH
	add_child(final)
	_flame(9640, 0.0)
	_flame(9760, 1.35)
	_story(10050, _sahne_mektup)
	_han_gate(10150, "SAMATYA")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2537, "gazelle", "GAZELLE", "Külhan sıcak. Belgeleri yakarak iz siliyorlar.")
	_radio(5582, "redmount", "REDMOUNT", "Ateş ne kadar büyük olursa olsun, duman bir yere gider.")
	_radio(8627, "gazelle", "GAZELLE", "Kemal Bey'in yarım yanmış mektubu: \"Samatya taş depoları.\"")
	_goal(10150, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Arka sokak: Gazelle Kemal Bey'i anlatır.
func _sahne_sokak(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Kemal Bey her pazar Çemberlitaş hamamına giderdi. Gazetede hep bununla övünürdü.")
	await cs.say("rm", "REDMOUNT", "Hamam aylardır kapalı. Ama bacası tütüyor.")
	await cs.say("gz", "GAZELLE", "Ben gerçeği yazmayı ondan öğrendim, Redmount. Eğer o ise...")
	await cs.say("rm", "REDMOUNT", "O zaman gerçeği yazarsın. Sana öğrettiği gibi.")


## Ilıklık: ıslak taşta mürekkep izi.
func _sahne_iliklik(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	cs.pose("gz", "crouch")
	await cs.say("gz", "GAZELLE", "Islak mermerde mavi bir leke... Mürekkep. Biri buradan eldiveniyle geçmiş.")
	await cs.say("rm", "REDMOUNT", "Kâtip burada çalışıyor. Külhanın sıcağı kâğıdı kurutur, kanıtı da yakar.")
	cs.pose("gz", "freed")
	await cs.say("gz", "GAZELLE", "O zaman acele edelim. Yanmadan önce okumalıyım.")


## Külhan: yarım yanmış mektup, Samatya.
func _sahne_mektup(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(10080, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Ocağa atılmış ama yanmamış bir mektup... 'Sevgili Kemal' diye başlıyor.")
	await cs.say("gz", "GAZELLE", "'...son teslim Samatya taş depolarında. Gazeteci kızın ağzı kapanmazsa sen kapatırsın.'")
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Kemal Bey'e yazılmış... Yani o da bir halka. Yukarıda biri daha var.")
	await cs.say("rm", "REDMOUNT", "Bir emir alan, bir emir veren. İkisini de bulacağız. Samatya.")

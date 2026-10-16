## Bölüm 26 — Sirkeci Sevkiyatı (Kitap 3 / "İstanbul'un Sesi", 2. bölüm).
##
## Mühürlü kâğıtlar ve verici parçası Sirkeci garına inmiş; yolcu tarafı yem. Gar
## meydanı -> gar cephesi (arena: polis kılığında adamlar) -> yolcu peronu (duran
## vagonların tepesi) -> bekleme salonu (erzak) -> yük rampası (vinç, vagonlar) ->
## arka yük peronu (arena) -> sevk odası (telgraf makbuzu: Galata). Gazelle'in sahte
## manşeti yüzünden gerçek polis de peşlerinde: Komiser Rıfat ilk kez görünür.
extends DtmLevel

const STATION := preload("res://assets/backgrounds/book03_sirkeci_station_atlas.png")
const DISPATCH := preload("res://assets/backgrounds/book03_sirkeci_dispatch_atlas.png")


func _build() -> void:
	sky_atlas = STATION
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3300.0], [3, 4700.0],
		[0, 6100.0, DISPATCH], [2, 7400.0, DISPATCH], [1, 8700.0, DISPATCH], [3, 9800.0, DISPATCH]]
	sky_tint = Color(0.96, 0.94, 0.9)
	sky_shade = Color(0.08, 0.06, 0.05)
	back_row_skip = [[3300.0, 10400.0]]

	_terrain(-400, 10400, 0)

	# --- 1. Gar meydanı: polis devriyesinden saklan ----------------------------
	_story(-1.0, _sahne_meydan, 240.0)
	var aw := AwningBounce.new()
	aw.width = 160
	aw.height = 60
	aw.position = Vector2(560, 0)
	add_child(aw)
	_scaffold(750, -260, 160)
	_scaffold(940, -300, 160)
	_pickup(ARMOR, 940, -345)
	_enemy(STREET, 1150, 0)
	_prop("saksi", 1350)

	# --- 2. Gar cephesi: sahte polisler, arena ----------------------------------
	_checkpoint(1550, 0)
	var cep: BattleArena = ARENA.instantiate()
	cep.position = Vector2(2350, 0)
	cep.gate_left_x = 1900
	cep.gate_right_x = 2800
	cep.floor_y = 0
	cep.wave1 = _wave(KNIFE, STREET, KNIFE)
	cep.wave2 = _wave(RIFLE, ELITE)
	cep.reward = AMMO
	add_child(cep)
	_story(2900, _sahne_komiser)

	# --- 3. Yolcu peronu: duran vagonların tepesi -------------------------------
	_checkpoint(3150, 0)
	_rails(3200, 4700)
	_crates(3300, 1, 1)
	_wagon(3390)
	_wagon(3790, Color(0.9, 0.95, 1.0))
	_enemy(KNIFE, 3650, -140)
	_enemy(RIFLE, 4050, -140)
	_coin_line(3450, 8, 85, -190)
	_pickup(PISTOL, 4100, -190)

	# --- 4. Bekleme salonu: erzak ---------------------------------------------
	_checkpoint(4500, 0)
	_enemy(ASSASSIN, 4800, 0)
	_prop("vazo", 5000)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5300, 0)
	shop.title = "GAR ERZAKÇISI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Yük rampası: vinç paleti, vagon sırtı --------------------------------
	_checkpoint(5550, 0)
	_rails(5600, 7400)
	_crates(5650, 1, 1)
	_wagon(5740)
	_moving(6300, -240, Vector2(300, 0), 140, 0.0)
	_crates(6610, 1, 1)
	_wagon(6700, Color(1.0, 0.92, 0.88))
	_pickup(RIFLE_PICKUP, 6750, -190)
	_enemy(BRUISER, 6450, 0)
	_coin_line(6310, 4, 75, -300)

	# --- 6. Arka yük peronu: arena -------------------------------------------
	_checkpoint(7300, 0)
	var per: BattleArena = ARENA.instantiate()
	per.position = Vector2(7900, 0)
	per.gate_left_x = 7500
	per.gate_right_x = 8300
	per.floor_y = 0
	per.wave1 = _wave(ELITE, RIFLE)
	per.wave2 = _wave(BRUISER, KNIFE, ASSASSIN)
	per.reward = HEALTH
	add_child(per)

	# --- 7. Sevk odası: makbuz -------------------------------------------------
	_checkpoint(8450, 0)
	_crates(8600, 1, 1)
	_crates(8690, 1, 2)
	_terrain(8780, 9050, -180)
	_enemy(RIFLE, 9000, -180)
	_pickup(HEALTH, 9200, -45)
	_story(9450, _sahne_makbuz)
	_han_gate(9800, "GALATA")
	_goal(9800, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Gar meydanı: aranan gazeteci.
func _sahne_meydan(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	cs.actor("ilan", "voice", Vector2(700, -260))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	await cs.say("ilan", "GAR HOPARLÖRÜ", "Dikkat: gazeteci Gazelle ve silahlı yardımcısı aranıyor. Görenler polise bildirsin.")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Artık bütün şehir beni arıyor. Kâtip bir manşetle beni suçlu yaptı.")
	await cs.say("rm", "REDMOUNT", "O zaman gerçek manşeti biz basacağız. Verici parçası arka yük peronunda.")


## Gar cephesi: Komiser Rıfat.
func _sahne_komiser(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("ko", "voice", Vector2(p.x + 400, -150))
	await cs.pan(Vector2(p.x + 200, -200), 0.5)
	await cs.say("ko", "KOMİSER RIFAT (uzaktan)", "Durun! Gazelle Hanım, teslim olun! Hakkınızda emir var!")
	await cs.say("gz", "GAZELLE", "Komiser, o polis üniformalı adamlar sizin adamlarınız değil! Kâtip'in adamları!")
	await cs.say("ko", "KOMİSER RIFAT", "...Ne diyorsunuz siz? Kanıtınız varsa getirin. Yoksa sizi ben getiririm.")
	await cs.say("rm", "REDMOUNT", "Kanıtı getireceğiz. Arka perondan.")


## Sevk odası: telgraf makbuzu.
func _sahne_makbuz(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(9600, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Verici parçası çoktan gitmiş. Ama makbuz burada: 'Galata telgraf binası, acil.'")
	await cs.say("rm", "REDMOUNT", "Emirler telgrafla yayılıyor. Hattı keselim, Kâtip'in sesi kısılsın.")
	await cs.say("gz", "GAZELLE", "Ve makbuzu saklıyorum. Komiser Rıfat'a ilk kanıt.")

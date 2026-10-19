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

	_terrain(-400, 6300, 0)
	_spike_pit(6300, 6460)
	_terrain(6460, 10400, 0)

	# --- 1. Gar meydanı: kemerli revak, tenteyle saçağa ------------------------
	_story(-1.0, _sahne_meydan, 240.0)
	for fx in [180.0, 760.0, 1320.0]:
		_fg("kolon", fx, 40.0, 420.0)
	_lantern(120)
	_lantern(980)
	_prop("vazo", 420)
	var aw := AwningBounce.new()
	aw.width = 160
	aw.height = 60
	aw.position = Vector2(560, 0)
	add_child(aw)
	# Üst yol: gar saçağı (zırh + coin); alt yol: devriye.
	_scaffold(750, -260, 160)
	_scaffold(940, -300, 160)
	_scaffold(1140, -300, 160)
	_pickup(ARMOR, 940, -345)
	_coin_line(1090, 4, 40, -350)
	_enemy(STREET, 1100, 0)
	_enemy(KNIFE, 1350, 0)
	_prop("kasa", 1430, 0, COIN)

	# --- 2. Gar cephesi: sahte polisler (orta iskele zıplamaya) ------------------
	_checkpoint(1600, 0)
	_scaffold(2350, -150, 200)
	_coin_line(2280, 4, 45, -200)
	_fight(1900, 2800, _wave(KNIFE, STREET, KNIFE), _wave(RIFLE, ELITE), [], AMMO)
	_story(2900, _sahne_komiser)

	# --- 3. Yolcu peronu: iki vagon, aradan aşağıda gizli sandık ----------------
	_checkpoint(3150, 0)
	_rails(3200, 4500)
	_crates(3300, 1, 1)
	var w1 := _wagon(3390)
	_wagon(w1 + 140.0, Color(0.9, 0.95, 1.0))
	_enemy(KNIFE, 3650, -140)
	_enemy(RIFLE, w1 + 400.0, -140)
	_coins_arc(w1 - 60.0, 5, 55, -300)
	_prop("sandik", w1 + 70.0, 0, HEALTH)
	_pickup(PISTOL, w1 + 300.0, -190)

	# --- 4. Bekleme salonu: iki katlı iç mekân -----------------------------------
	_checkpoint(4500, 0)
	_interior(4600, 5380, -345, [-115.0, -230.0], 1)
	_enemy(ASSASSIN, 4850, 0)
	_enemy(KNIFE, 5050, -115)
	_enemy(STREET, 4800, -230)
	_prop("vazo", 4700, -115)
	_coin_line(4900, 5, 50, -160)
	_coin_line(4700, 4, 50, -275)
	_pickup(HEALTH, 5300, -275)
	_coin_line(4720, 6, 90, -395)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5560, 0)
	shop.title = "GAR ERZAKÇISI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Yük rampası: vagon -> yükleme çukuru (vinç paleti) -> vagon -----------
	_checkpoint(5750, 0)
	_rails(5800, 7400)
	_crates(5800, 1, 1)
	_wagon(5890)
	_moving(6390, -260, Vector2(260, 0), 140, 0.0)
	_coin_line(6300, 5, 50, -320)
	_enemy(BRUISER, 6750, 0)
	_crates(6900, 1, 1)
	_wagon(6990, Color(1.0, 0.92, 0.88))
	_pickup(RIFLE_PICKUP, 7100, -190)
	_enemy(RIFLE, 7300, -140)

	# --- 6. Su kulesi: bacadan duvar-zıplamayla tepeye (zırh) -------------------
	_chimney(7670, -470, 140, 150, ARMOR)

	# --- 7. Arka yük peronu: arena ------------------------------------------
	_checkpoint(7850, 0)
	_scaffold(8300, -150, 180)
	_fight(7900, 8700, _wave(ELITE, BOMBER), _wave(BRUISER, SHIELD, ASSASSIN))

	# --- 8. Sevk odası: telgraf makbuzu (iki katlı büro) -------------------------
	_checkpoint(8800, 0)
	_interior(8900, 9380, -230, [-115.0], 0)
	_enemy(SHIELD, 9050, 0)
	_enemy(RIFLE, 9250, -115)
	_pickup(HEALTH, 9320, -160)
	_coin_line(8960, 4, 50, -160)
	_story(9500, _sahne_makbuz)
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

## Bölüm 29 — Kuzguncuk Kıyı Deposu (Kitap 3 / "İstanbul'un Sesi", 5. bölüm).
##
## Alıcı listesinin ilk adresi: Kuzguncuk'taki eski kıyı deposu. Gece, sessiz mahalle
## -> renkli evler (çatı rotası) -> çeşme meydanı (arena) -> bahçe duvarı -> rıhtım
## (kayıklar, vinç) -> depo (erzak; çöken iskele) -> defter odası (arena) -> gizli
## rıhtım kapısı (son arena). Depo defterleri: kâğıtların Beylerbeyi iskele arşivinde
## toplanıp yakılacağı yazıyor. Gazelle defterde annesinin adını görür (eski bir dava).
extends DtmLevel

const STREETS := preload("res://assets/backgrounds/book03_kuzguncuk_streets_atlas.png")
const DEPOT := preload("res://assets/backgrounds/book03_kuzguncuk_depot_atlas.png")


func _build() -> void:
	sky_atlas = STREETS
	sky_cells = [[0, -100000.0], [1, 1600.0], [3, 3200.0], [2, 4500.0],
		[0, 5900.0, DEPOT], [1, 7200.0, DEPOT], [2, 8500.0, DEPOT], [3, 9700.0, DEPOT]]
	sky_tint = Color(0.86, 0.86, 0.96)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_row_skip = [[6950.0, 9100.0]]
	_night(Color(0.76, 0.78, 0.94))

	# --- 1. Sessiz mahalle: sarmaşıklı bahçe duvarları ---------------------------
	_terrain(-400, 5300, 0)
	_story(-1.0, _sahne_mahalle, 240.0)
	for x in [300, 1000]:
		_lantern(float(x))
	for vx in [520.0, 860.0, 1240.0]:
		_fg("sarmasik", vx, -600.0)
	_enemy(KNIFE, 900, 0)
	_enemy(STREET, 1100, 0)
	_prop("saksi", 1200)

	# --- 2. Renkli evler: tente -> çatılar ---------------------------------------
	_checkpoint(1400, 0)
	var aw := AwningBounce.new()
	aw.width = 180
	aw.height = 60
	aw.position = Vector2(1600, 0)
	add_child(aw)
	_balcony(1652, -125, 70)
	var h1 := _house(1690, -220, 1)
	_balcony(h1 + 45, -110, 90)
	_balcony(h1 + 115, -195, 90)
	var h2 := _house(h1 + 160, -260, 0)
	_coin_line(1740, 4, 60, -270)
	_coin_line(h2 - 160, 3, 50, -310)
	_enemy(STREET, h1 - 100, -220)
	_enemy(KNIFE, h2 - 90, -260)
	_pickup(ARMOR, h2 - 40, -305)
	_prop("vazo", h1 - 160, -220)

	# --- 3. Çeşme meydanı: arena (ortada sundurma) --------------------------------
	_checkpoint(2950, 0)
	_lantern(3100)
	_scaffold(3650, -110, 200)
	_coin_line(3580, 4, 45, -160)
	_fight(3250, 4050, _wave(KNIFE, ASSASSIN, STREET), _wave(RIFLE, ELITE), [], AMMO)

	# --- 4. Bahçe duvarı: taş duvar sırtında tüfekli ---------------------------
	_checkpoint(4200, 0)
	_crates(4350, 1, 1)
	_stones(4440, 1, 2)
	_stones(4530, 4, 2)
	_enemy(RIFLE, 4800, -180)
	_pickup(PISTOL, 4600, -225)
	_coin_line(4560, 5, 60, -240)
	_fg("sarmasik", 4700.0, -600.0)
	_lantern(5000)

	# --- 5. Rıhtım: kayıklar, vinç paleti ---------------------------------------
	_checkpoint(5150, 0)
	_canal(5300, 5500, 110)
	_scaffold(5400, -20, 220)
	_terrain(5500, 9250, 0)
	_crates(5600, 1, 1)
	_scaffold(5760, -150, 120)
	_moving(5950, -240, Vector2(300, 0), 140, 0.0)
	_scaffold(6370, -240, 120)
	_pickup(RIFLE_PICKUP, 6370, -285)
	_coin_line(5900, 6, 70, -300)
	_enemy(BRUISER, 6200, 0)

	# --- 6. Kıyı deposu: erzak, üç katlı depo -------------------------------------
	_checkpoint(6550, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6750, 0)
	shop.title = "KIYI ERZAKÇISI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)
	_interior(7000, 8000, -345, [-115.0, -230.0], 0)
	_crates(7300, 1, 1)
	_enemy(ASSASSIN, 7550, 0)
	_enemy(KNIFE, 7750, -115)
	_enemy(RIFLE, 7350, -230)
	_prop("kasa", 7150, -115, COIN)
	_coin_line(7450, 5, 50, -160)
	_pickup(HEALTH, 7920, -275)
	_coin_line(7550, 5, 60, -395)

	# --- 7. Defter odası: galerili salonda arena ----------------------------------
	_checkpoint(8100, 0)
	_story(8170, _sahne_defter)
	_interior(8250, 9050, -345, [], 1)
	_scaffold(8420, -115, 180)
	_scaffold(8880, -115, 180)
	_scaffold(8650, -230, 200)
	_coin_line(8590, 3, 50, -280)
	_fight(8300, 9000, _wave(ELITE, KNIFE), _wave(ELITE, RIFLE, BRUISER))

	# --- 8. Gizli rıhtım kapısı: çürük iskele tahtaları, nöbetçiler ----------------
	_checkpoint(9150, 0)
	_canal(9250, 9700, 110)
	for k in 3:
		_collapse(9330.0 + k * 140.0, -30.0, 110)
		_pickup(COIN, 9330.0 + k * 140.0, -80.0)
	_terrain(9700, 10300, 0)
	_enemy(KNIFE, 9800, 0)
	_enemy(ASSASSIN, 9880, 0)
	_story(9950, _sahne_kapi)
	_han_gate(10150, "BEYLERBEYİ")
	_goal(10150, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Sessiz mahalle.
func _sahne_mahalle(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Kuzguncuk ne kadar sessiz... Işıklar yanıyor ama kimse dışarıda değil.")
	await cs.say("rm", "REDMOUNT", "Herkes radyosunun başında. Sabah okunacak haberi bekliyorlar.")
	await cs.say("gz", "GAZELLE", "O haberi biz değiştireceğiz. Depo rıhtımın ucunda.")


## Defter odası: Gazelle'in annesi.
func _sahne_defter(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Depo defterleri: on yıllık 'silinmiş' kayıtlar. Tapular, davalar, gazete yazıları...")
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Redmount... burada annemin adı var. 'Gazeteci Leyla. Yazısı yayından kaldırıldı. Dava kapatıldı.'")
	await cs.say("gz", "GAZELLE", "Annem de gerçeği yazmıştı. Ve biri onu kâğıttan sildi.")
	await cs.say("rm", "REDMOUNT", "Bu sefer silinmeyecek. Defterleri alıyoruz.")


## Gizli rıhtım kapısı: Beylerbeyi.
func _sahne_kapi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(10050, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Son sayfa: 'Bütün evrak Beylerbeyi iskele arşivine. Şafakta yakılsın.'")
	await cs.say("rm", "REDMOUNT", "Yakılmadan yetişeceğiz. Annenin dosyası da orada olabilir.")

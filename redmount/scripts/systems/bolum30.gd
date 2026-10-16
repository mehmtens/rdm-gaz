## Bölüm 30 — Beylerbeyi İskele Arşivi (Kitap 3 / "İstanbul'un Sesi", 6. bölüm).
##
## Evrak Beylerbeyi iskele arşivinde yakılmayı bekliyor. Gece sahili -> yalı
## sokağı (balkonlar) -> iskele (kanal, arena) -> merdivenli bahçe (alev mangalları)
## -> arşiv binası (raflar, erzak) -> evrak salonu (arena; mangallar) -> kasa odası
## (kırılır) -> arka iskele (son arena). Arşivin kasasında: Kâtip'in mühürünün
## Çengelköy sahil konağındaki "mühür odasında" saklandığı. Leyla dosyası kurtarılır.
extends DtmLevel

const SHORE := preload("res://assets/backgrounds/book03_beylerbeyi_shore_atlas.png")
const ARCHIVE := preload("res://assets/backgrounds/book03_beylerbeyi_archive_atlas.png")


func _build() -> void:
	sky_atlas = SHORE
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3300.0], [3, 4600.0],
		[0, 4950.0, ARCHIVE], [1, 6300.0, ARCHIVE], [2, 7550.0, ARCHIVE], [3, 8750.0, ARCHIVE]]
	sky_tint = Color(0.86, 0.86, 0.96)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_row_skip = [[4900.0, 8700.0]]
	_night(Color(0.76, 0.78, 0.94))

	# --- 1. Gece sahili ----------------------------------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_sahil, 240.0)
	for x in [300, 1100]:
		_lantern(float(x))
	_enemy(STREET, 800, 0)
	_enemy(KNIFE, 1000, 0)

	# --- 2. Yalı sokağı: balkonlar --------------------------------------------
	_checkpoint(1450, 0)
	_terrain(1700, 10300, 0)
	_balcony(1750, -70, 110)
	_balcony(1910, -170, 110)
	_balcony(2070, -270, 110)
	_pickup(ARMOR, 2070, -315)
	_coin_line(1710, 5, 70, -330)
	_enemy(ASSASSIN, 2400, 0)

	# --- 3. İskele: kanal, arena --------------------------------------------
	_checkpoint(2650, 0)
	_canal(2800, 3000, 110)
	_scaffold(2900, -20, 220)
	var isk: BattleArena = ARENA.instantiate()
	isk.position = Vector2(3550, 0)
	isk.gate_left_x = 3150
	isk.gate_right_x = 3950
	isk.floor_y = 0
	isk.wave1 = _wave(KNIFE, STREET, RIFLE)
	isk.wave2 = _wave(BRUISER, ASSASSIN)
	isk.reward = AMMO
	add_child(isk)

	# --- 4. Merdivenli bahçe: alev mangalları ------------------------------------
	_checkpoint(4100, 0)
	_flame(4350, 0.0)
	_flame(4600, 0.5)
	_coin_line(4300, 5, 75, -60)
	_scaffold(4480, -230, 360)
	_pickup(PISTOL, 4480, -275)
	_lantern(4800)

	# --- 5. Arşiv binası: raflar, erzak ---------------------------------------
	_checkpoint(4950, 0)
	_crates(5100, 1, 1)
	_scaffold(5260, -150, 130)
	_scaffold(5410, -260, 130)
	_pickup(RIFLE_PICKUP, 5410, -305)
	_enemy(ELITE, 5700, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6050, 0)
	shop.title = "İSKELE ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 6. Evrak salonu: arena; mangallar ----------------------------------------
	_checkpoint(6300, 0)
	_story(6380, _sahne_ates)
	var evrak: BattleArena = ARENA.instantiate()
	evrak.position = Vector2(7000, 0)
	evrak.gate_left_x = 6600
	evrak.gate_right_x = 7400
	evrak.floor_y = 0
	evrak.wave1 = _wave(ELITE, KNIFE)
	evrak.wave2 = _wave(ELITE, RIFLE, ASSASSIN)
	evrak.reward = HEALTH
	add_child(evrak)

	# --- 7. Kasa odası: kır ------------------------------------------------
	_checkpoint(7550, 0)
	_flame(7750, 0.3)
	var kasa := BREAKABLE_WALL.instantiate()
	kasa.set("hits_to_break", 6)
	kasa.position = Vector2(8150, 0)
	add_child(kasa)
	var sign := _Sign.new()
	sign.text = "ARŞİV KASASI"
	sign.position = Vector2(8150, -260)
	add_child(sign)
	_story(8250, _sahne_kasa)
	_enemy(BRUISER, 8500, 0)

	# --- 8. Arka iskele: son arena ------------------------------------------
	_checkpoint(8750, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9300, 0)
	final.gate_left_x = 8950
	final.gate_right_x = 9650
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN, RIFLE)
	final.wave2 = _wave(ELITE, BRUISER)
	final.reward = HEALTH
	add_child(final)
	_han_gate(10050, "ÇENGELKÖY")
	_goal(10050, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Gece sahili: iskeleden duman.
func _sahne_sahil(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "İskelenin arkasından duman yükseliyor. Yakmaya başlamışlar!")
	await cs.say("rm", "REDMOUNT", "Koşuyoruz. Annenin dosyası o yığının içindeyse, dumana karışmadan alacağız.")


## Evrak salonu: yakılan kâğıtlar.
func _sahne_ates(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("e1", "elite", Vector2(p.x + 500, 0), -1)
	await cs.pan(Vector2(p.x + 250, -200), 0.5)
	await cs.say("e1", "ARŞİV BEKÇİSİ", "Kâtip Hanım şafağa kadar tek kâğıt kalmasın dedi. Onlar da kâğıt sayılır!")
	await cs.say("gz", "GAZELLE", "'Kâtip HANIM'... Duydun mu Redmount?")
	await cs.say("rm", "REDMOUNT", "Duydum. Önce bunlar.")
	await cs.move("e1", p.x + 1000, 0.5, "walk")
	cs.remove("e1")


## Kasa odası: Leyla dosyası ve mühür odası.
func _sahne_kasa(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 100, -200), 0.5)
	cs.pose("gz", "rescue_react")
	await cs.say("gz", "GAZELLE", "Annemin dosyası! Yanmamış... Son yazısının taslağı: 'Su idaresindeki mühürler.'")
	await cs.say("gz", "GAZELLE", "Yirmi yıl önce aynı işi yazmış. Ve aynı kişi onu susturmuş.")
	await cs.say("rm", "REDMOUNT", "Kasada başka ne var?")
	await cs.say("gz", "GAZELLE", "Bir not: 'Mühür, Çengelköy sahil konağında, mühür odasında. Konak N. hanımın.'")
	await cs.say("rm", "REDMOUNT", "N. Nüzhet. Çengelköy'e.")

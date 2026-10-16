## Bölüm 32 — Kuleli Gözetleme Hattı (Kitap 3 / "İstanbul'un Sesi", 8. bölüm).
##
## Kıyı fenerleri Nüzhet'in teknesinin yolunu çiziyor; boş görünen nöbet noktaları
## sahte. Kuleli kıyısı -> okul cephesi (arena) -> taş rıhtım (kanal, kayıklar) ->
## fener kulesi (tırmanış, projektör) -> sinyal kulübesi (erzak) -> gözetleme
## koridoru (arena) -> sinyal kayıt odası (fener defteri) -> sahil kapısı (son
## arena). Kayıtta teknenin Vaniköy iskelesine yanaştığı yazıyor.
extends DtmLevel

const SHORE := preload("res://assets/backgrounds/book03_kuleli_shore_atlas.png")
const SIGNAL := preload("res://assets/backgrounds/book03_kuleli_signal_atlas.png")


func _build() -> void:
	sky_atlas = SHORE
	sky_cells = [[0, -100000.0], [1, 1500.0], [2, 3000.0], [0, 4200.0, SIGNAL],
		[3, 5600.0], [1, 6900.0, SIGNAL], [2, 8300.0, SIGNAL], [3, 9500.0, SIGNAL]]
	sky_tint = Color(0.86, 0.86, 0.96)
	sky_shade = Color(0.03, 0.03, 0.08)
	back_row_skip = [[6800.0, 9400.0]]
	_night(Color(0.74, 0.76, 0.94))

	# --- 1. Kuleli kıyısı ----------------------------------------------------
	_terrain(-400, 10300, 0)
	_story(-1.0, _sahne_kiyi, 240.0)
	_lantern(300)
	_lantern(1100)
	_enemy(KNIFE, 900, 0)

	# --- 2. Okul cephesi: arena ---------------------------------------------
	_checkpoint(1300, 0)
	var okul: BattleArena = ARENA.instantiate()
	okul.position = Vector2(2000, 0)
	okul.gate_left_x = 1600
	okul.gate_right_x = 2400
	okul.floor_y = 0
	okul.wave1 = _wave(STREET, KNIFE, ASSASSIN)
	okul.wave2 = _wave(RIFLE, ELITE)
	okul.reward = AMMO
	add_child(okul)

	# --- 3. Taş rıhtım: kanal, kayık kirişi ---------------------------------
	_checkpoint(2550, 0)
	_canal(2700, 2900, 110)
	_scaffold(2800, -20, 220)
	_crates(3050, 1, 1)
	_scaffold(3210, -150, 130)
	_scaffold(3360, -260, 130)
	_pickup(ARMOR, 3360, -305)
	_enemy(STREET, 3600, 0)

	# --- 4. Fener kulesi: tırmanış, projektör, tepede tüfekli ----------------
	_checkpoint(3850, 0)
	_scaffold(4000, -110, 120)
	_scaffold(4000, -220, 120)
	_scaffold(4000, -330, 120)
	_tower(4140, -420, 130)
	_enemy(RIFLE, 4140, -420)
	_scaffold(4320, -330, 120)
	_scaffold(4460, -220, 120)
	_scaffold(4600, -110, 120)
	_pickup(PISTOL, 4140, -470)
	_coin_line(4000, 5, 150, -380)
	_story(4800, _sahne_fener)

	# --- 5. Sinyal kulübesi: erzak --------------------------------------------
	_checkpoint(5050, 0)
	_enemy(ASSASSIN, 5300, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5600, 0)
	shop.title = "FENERCİ KİLERİ"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 6. Gözetleme koridoru: arena ----------------------------------------
	_checkpoint(5850, 0)
	_flame(6050, 0.0)
	_coin_line(6000, 3, 50, -60)
	var gz: BattleArena = ARENA.instantiate()
	gz.position = Vector2(6800, 0)
	gz.gate_left_x = 6400
	gz.gate_right_x = 7200
	gz.floor_y = 0
	gz.wave1 = _wave(ELITE, KNIFE)
	gz.wave2 = _wave(ELITE, RIFLE, BRUISER)
	gz.reward = HEALTH
	add_child(gz)

	# --- 7. Sinyal kayıt odası ----------------------------------------------
	_checkpoint(7350, 0)
	_crates(7500, 1, 1)
	_scaffold(7660, -150, 130)
	_pickup(RIFLE_PICKUP, 7660, -195)
	_story(8000, _sahne_kayit)
	_enemy(ELITE, 8300, 0)

	# --- 8. Sahil kapısı: son arena --------------------------------------
	_checkpoint(8550, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9150, 0)
	final.gate_left_x = 8750
	final.gate_right_x = 9550
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN, RIFLE)
	final.wave2 = _wave(BRUISER, ELITE)
	final.reward = HEALTH
	add_child(final)
	_han_gate(9900, "VANİKÖY")
	_goal(9900, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Kuleli kıyısı: fenerler.
func _sahne_kiyi(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Fenerler yanıp sönüyor. Haritadaki sırayla aynı: bir kısa, iki uzun.")
	await cs.say("rm", "REDMOUNT", "Teknesine yol gösteriyorlar. Nöbet noktaları boş görünüyor... fazla boş.")


## Fener kulesi tepesi: işaret kodu.
func _sahne_fener(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 100, -220), 0.5)
	await cs.say("gz", "GAZELLE", "Fener kodu değişti: 'Tekne yanaştı. Yük boşalt.' Kuzeye işaret ediyor.")
	await cs.say("rm", "REDMOUNT", "Sinyal kayıt odası yolun sonunda. Hangi iskele, orada yazar.")


## Sinyal kayıt odası: Vaniköy.
func _sahne_kayit(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Fener defteri: 'N. teknesi Vaniköy iskelesine. Kasalar kapalı yükleme hattına.'")
	await cs.say("rm", "REDMOUNT", "Kasaları takip edersek Nüzhet'in sesini taşıdığı yeri buluruz.")
	await cs.say("gz", "GAZELLE", "Verici parçaları... Sirkeci'den beri onları topluyor. Bir yayın istasyonu kuruyor.")

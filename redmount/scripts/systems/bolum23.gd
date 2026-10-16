## Bölüm 23 — Saraçhane Ana Vana (Kitap 2 / "Haliç'in İzi", 11. bölüm).
##
## Şafakta Saraçhane ana vanasından su kesilecek. Sokak -> dış avlu (arena) -> su
## terazisi (kanal, taş raf) -> basınç galerisi (tüfekli, arena, erzak) -> ana vana
## salonu (değiştirilmiş vana: vurarak kırılır, yerel kesinti durur) -> bakım
## geçidi (arena) -> kontrol masası (üst hat Bozdoğan Kemeri servis kulesinde) ->
## taşma avlusu (üç dalga). Kâtip'in kim olduğuna dair ilk somut ipucu: gazete arşivi.
extends DtmLevel

const STREETS := preload("res://assets/backgrounds/book02_sarachane_streets_atlas.png")
const VALVES := preload("res://assets/backgrounds/book02_sarachane_valves_atlas.png")


func _build() -> void:
	sky_atlas = STREETS
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3300.0], [3, 4600.0],
		[0, 6100.0, VALVES], [1, 7400.0, VALVES], [2, 8700.0, VALVES], [3, 9800.0, VALVES]]
	sky_tint = Color(0.92, 0.88, 0.86)
	sky_shade = Color(0.07, 0.05, 0.06)
	back_row_skip = [[3300.0, 9700.0]]

	# --- 1. Saraçhane sokağı: şafak, devriye ------------------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_sokak, 240.0)
	_balcony(560, -70, 110)
	_balcony(720, -170, 110)
	_pickup(ARMOR, 720, -215)
	_enemy(STREET, 1050, 0)

	# --- 2. Dış avlu: sığ alt yol, hızlı/zırhlı iki dalga ------------------------
	_checkpoint(1550, 0)
	_terrain(1700, 1850, 30)
	_terrain(1850, 3200, 60)
	var avlu: BattleArena = ARENA.instantiate()
	avlu.position = Vector2(2500, 60)
	avlu.gate_left_x = 2050
	avlu.gate_right_x = 2950
	avlu.floor_y = 60
	avlu.wave1 = _wave(KNIFE, ASSASSIN, STREET)
	avlu.wave2 = _wave(BRUISER, KNIFE)
	avlu.reward = AMMO
	add_child(avlu)
	_terrain(3200, 3350, 30)

	# --- 3. Su terazisi: kısa kanal, üst taş raf ---------------------------------
	_terrain(3350, 3800, 0)
	_checkpoint(3400, 0)
	_canal(3800, 4000, 110)
	_scaffold(3900, -20, 220)
	_terrain(4000, 10300, 0)
	_stones(4150, 1, 1)
	_stones(4240, 1, 2)
	_pickup(PISTOL, 4285, -225)
	_enemy(KNIFE, 4550, 0)

	# --- 4. Basınç galerisi: tüfekli, gösterge rafı, arena, erzak ----------------
	_checkpoint(4750, 0)
	_crates(4880, 1, 1)
	_crates(4970, 1, 2)
	_terrain(5060, 5300, -180)
	_enemy(RIFLE, 5240, -180)
	_pickup(RIFLE_PICKUP, 5100, -225)
	var bas: BattleArena = ARENA.instantiate()
	bas.position = Vector2(5600, 0)
	bas.gate_left_x = 5380
	bas.gate_right_x = 5850
	bas.floor_y = 0
	bas.wave1 = _wave(RIFLE, KNIFE)
	bas.wave2 = _wave(ELITE, STREET)
	bas.reward = HEALTH
	add_child(bas)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6000, 0)
	shop.title = "SARAÇHANE ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Ana vana salonu: vanayı kır -----------------------------------------
	_checkpoint(6200, 0)
	_story(6280, _sahne_vana)
	for k in 3:
		_scaffold(6450.0 + k * 175.0, -250.0, 150)
		_pickup(COIN, 6450.0 + k * 175.0, -300.0)
	_crates(6330, 1, 1)
	_scaffold(6390, -150, 80)
	_pickup(ARMOR, 6800, -295)
	_enemy(ELITE, 6700, 0)
	var vana := BREAKABLE_WALL.instantiate()
	vana.set("hits_to_break", 6)
	vana.position = Vector2(7100, 0)
	add_child(vana)
	var sign := _Sign.new()
	sign.text = "ANA VANA"
	sign.position = Vector2(7100, -260)
	add_child(sign)

	# --- 6. Bakım geçidi: seçkin + menzilli arena ---------------------------------
	_checkpoint(7350, 0)
	var bak: BattleArena = ARENA.instantiate()
	bak.position = Vector2(7950, 0)
	bak.gate_left_x = 7600
	bak.gate_right_x = 8300
	bak.floor_y = 0
	bak.wave1 = _wave(ELITE, RIFLE)
	bak.wave2 = _wave(ELITE, KNIFE, RIFLE)
	bak.reward = HEALTH
	add_child(bak)

	# --- 7. Kontrol masası: son açıklık, üst hat ipucu ---------------------------
	_checkpoint(8450, 0)
	_canal(8600, 8800, 110)
	_scaffold(8700, -20, 220)
	_story(9000, _sahne_masa)
	_enemy(ASSASSIN, 9150, 0)
	_pickup(HEALTH, 9250, -45)

	# --- 8. Taşma avlusu: üç dalga; Bozdoğan Kemeri -----------------------------
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
	_story(10050, _sahne_kemer)
	_han_gate(10150, "BOZDOĞAN KEMERİ")
	_goal(10150, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Saraçhane sokağı: şafak, kemer uzakta.
func _sahne_sokak(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Güneş doğmak üzere. Arkada Bozdoğan Kemeri... Ana vana bu binada.")
	await cs.say("rm", "REDMOUNT", "Önce vanayı durduralım. Sonra Kâtip'in kalemini kıralım.")


## Ana vana salonu: değiştirilmiş vana.
func _sahne_vana(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 400, -200), 0.6)
	await cs.say("gz", "GAZELLE", "İşte! Yedek vana takmışlar, üstünde ters hilal. Kapanmak için ayarlanmış.")
	await cs.say("rm", "REDMOUNT", "Kırılırsa eski hat devreye girer mi?")
	await cs.say("gz", "GAZELLE", "Çizelgeye göre evet. Kır onu Redmount!")


## Kontrol masası: üst hat ve gazete arşivi.
func _sahne_masa(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Yerel vana durdu. Ama masadaki şemaya göre üst hat Bozdoğan Kemeri servis kulesinden kumanda ediliyor.")
	cs.pose("gz", "rescue_react")
	await cs.say("gz", "GAZELLE", "Bak... Şemanın arkası bir gazete sayfası. Bizim gazetenin arşiv damgası var.")
	await cs.say("rm", "REDMOUNT", "Kâtip gazeteyle bağlantılı. Kemal Bey'den daha yukarıda biri.")
	await cs.say("gz", "GAZELLE", "Gazetede Kemal Bey'den yukarıda tek bir kişi var: sahibi. Nüzhet Hanım.")


## Taşma avlusu: kemere.
func _sahne_kemer(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(10080, -200), 0.6)
	await cs.say("gz", "GAZELLE", "Su yeniden akıyor! Ama kuleden ikinci bir kesinti verilebilir.")
	await cs.say("rm", "REDMOUNT", "O zaman kuleye çıkıyoruz. Kemerin tepesinde Kâtip'in son satırı yazılacak.")

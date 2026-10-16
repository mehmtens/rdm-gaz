## Bölüm 28 — Üsküdar Yedek Hattı (Kitap 3 / "İstanbul'un Sesi", 4. bölüm).
##
## Galata sustu, yayın Üsküdar'daki yedek röleye geçti. Vapur iskelesi -> sahil
## parkı (arena) -> çeşme meydanı (balkon) -> çarşı (erzak) -> röle istasyonu
## avlusu (kablo direği, tüfekli) -> röle salonu (arena; şerit makinesi kırılır) ->
## arşiv (alıcı listesi) -> Kız Kulesi manzaralı rıhtım (son arena). Alıcı listesinin
## ilk adresi Kuzguncuk. Komiser Rıfat Gazelle'in makbuzunu doğrular: müttefik.
extends DtmLevel

const SHORE := preload("res://assets/backgrounds/book03_uskudar_shore_atlas.png")
const RELAY := preload("res://assets/backgrounds/book03_uskudar_relay_atlas.png")


func _build() -> void:
	sky_atlas = SHORE
	sky_cells = [[0, -100000.0], [1, 1700.0], [2, 3300.0], [3, 4600.0],
		[0, 5900.0, RELAY], [1, 7200.0, RELAY], [2, 8500.0, RELAY], [3, 9700.0, RELAY]]
	sky_tint = Color(0.96, 0.94, 0.9)
	sky_shade = Color(0.06, 0.06, 0.07)
	back_row_skip = [[7100.0, 9600.0]]

	# --- 1. Vapur iskelesi: varış --------------------------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_iskele, 240.0)
	_enemy(STREET, 900, 0)
	_enemy(KNIFE, 1100, 0)
	_prop("saksi", 1300)

	# --- 2. Sahil parkı: arena ----------------------------------------------
	_checkpoint(1550, 0)
	_canal(1700, 1900, 110)
	_scaffold(1800, -20, 220)
	_terrain(1900, 10300, 0)
	var park: BattleArena = ARENA.instantiate()
	park.position = Vector2(2550, 0)
	park.gate_left_x = 2100
	park.gate_right_x = 3000
	park.floor_y = 0
	park.wave1 = _wave(KNIFE, ASSASSIN, STREET)
	park.wave2 = _wave(RIFLE, ELITE)
	park.reward = AMMO
	add_child(park)

	# --- 3. Çeşme meydanı: balkon rotası ----------------------------------------
	_checkpoint(3150, 0)
	_balcony(3400, -70, 110)
	_balcony(3560, -170, 110)
	_balcony(3720, -260, 110)
	_pickup(ARMOR, 3720, -305)
	_coin_line(3360, 5, 70, -320)
	_enemy(KNIFE, 3900, 0)

	# --- 4. Çarşı: erzak ---------------------------------------------------
	_checkpoint(4200, 0)
	_stall(4400)
	_stall(4900)
	_enemy(ASSASSIN, 4650, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5250, 0)
	shop.title = "ÜSKÜDAR ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Röle avlusu: kablo direği, tüfekli -------------------------------
	_checkpoint(5450, 0)
	_crates(5600, 1, 1)
	_scaffold(5750, -130, 120)
	_scaffold(5750, -240, 120)
	_tower(5880, -330)
	_enemy(RIFLE, 5880, -330)
	_scaffold(6050, -250, 140)
	_pickup(PISTOL, 6050, -295)
	_enemy(BRUISER, 6400, 0)

	# --- 6. Röle salonu: arena; şerit makinesi ---------------------------------
	_checkpoint(6700, 0)
	var rol: BattleArena = ARENA.instantiate()
	rol.position = Vector2(7350, 0)
	rol.gate_left_x = 6950
	rol.gate_right_x = 7750
	rol.floor_y = 0
	rol.wave1 = _wave(ELITE, KNIFE)
	rol.wave2 = _wave(ELITE, RIFLE, ASSASSIN)
	rol.reward = HEALTH
	add_child(rol)
	var serit := BREAKABLE_WALL.instantiate()
	serit.set("hits_to_break", 5)
	serit.position = Vector2(7950, 0)
	add_child(serit)
	var sign := _Sign.new()
	sign.text = "ŞERİT MAKİNESİ"
	sign.position = Vector2(7950, -260)
	add_child(sign)

	# --- 7. Arşiv: alıcı listesi ----------------------------------------------
	_checkpoint(8150, 0)
	_story(8250, _sahne_liste)
	_crates(8450, 1, 1)
	_scaffold(8610, -150, 130)
	_pickup(RIFLE_PICKUP, 8610, -195)
	_enemy(ELITE, 8900, 0)

	# --- 8. Kız Kulesi rıhtımı: son arena; Rıfat -------------------------------
	_checkpoint(9100, 0)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9500, 0)
	final.gate_left_x = 9200
	final.gate_right_x = 9800
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN, RIFLE)
	final.wave2 = _wave(BRUISER, ELITE)
	final.reward = HEALTH
	add_child(final)
	_story(9900, _sahne_rifat)
	_han_gate(10150, "KUZGUNCUK")
	_goal(10150, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Vapur iskelesi.
func _sahne_iskele(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Üsküdar. Vapurda herkes gazeteyi okuyordu; kimse yüzüme bakmadı. Şimdilik.")
	await cs.say("rm", "REDMOUNT", "Röle istasyonu tepede. Şerit makineye girerse yalan bütün radyolardan okunacak.")


## Arşiv: alıcı listesi.
func _sahne_liste(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Şerit kırıldı, yayın durdu. Masada alıcı listesi: Kuzguncuk, Beylerbeyi, Çengelköy...")
	await cs.say("rm", "REDMOUNT", "Boğaz boyunca bir zincir daha. Her kıyıda bir halka.")


## Rıhtım: Komiser Rıfat müttefik olur.
func _sahne_rifat(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("ko", "elite", Vector2(p.x + 300, 0), -1)
	await cs.pan(Vector2(p.x + 150, -200), 0.6)
	await cs.say("ko", "KOMİSER RIFAT", "Makbuzu inceledim. Sirkeci'deki 'polisler' benim kadromda yok. Haklıymışsınız.")
	await cs.say("gz", "GAZELLE", "O zaman bize yardım edin, Komiser. Kâtip'in kim olduğunu bulmamız lazım.")
	await cs.say("ko", "KOMİSER RIFAT", "Resmen size yardım edemem; emir yukarıdan. Ama Kuzguncuk'ta bir depo var, kimse oraya bakmıyor.")
	await cs.say("ko", "KOMİSER RIFAT", "Ve gazeteci... dikkat edin. Yukarıdan gelen emirlerin altında hep aynı imza var: K.")
	await cs.say("rm", "REDMOUNT", "Kuzguncuk. Teşekkürler, Komiser.")

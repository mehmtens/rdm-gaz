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
	back_row_skip = [[6800.0, 9600.0]]

	# --- 1. Vapur iskelesi: rıhtım, iskele kazıkları arasında su ----------------
	_terrain(-400, 1150, 0)
	_story(-1.0, _sahne_iskele, 240.0)
	_lantern(200)
	_lantern(1000)
	_enemy(STREET, 750, 0)
	_enemy(KNIFE, 950, 0)
	_prop("varil", 1080)
	_canal(1150, 1600, 110)
	_scaffold(1270, -20, 120)
	_scaffold(1480, -20, 120)
	_coins_arc(1220, 6, 55, -150)
	_terrain(1600, 1700, 0)

	# --- 2. Sahil parkı: arena (ortada çardak) ----------------------------------
	_checkpoint(1700, 0)
	_scaffold(2550, -110, 200)
	_coin_line(2480, 4, 45, -160)
	_fight(2100, 3000, _wave(KNIFE, ASSASSIN, STREET), _wave(RIFLE, ELITE), [], AMMO)

	# --- 3. Çeşme meydanı: saat kulesi bacası, balkon yolu -----------------------
	_checkpoint(3150, 0)
	_balcony(3330, -80, 110)
	_balcony(3330, -190, 110)
	_coin_line(3290, 3, 40, -240)
	_chimney(3600, -500, 140, 150, ARMOR)
	_enemy(KNIFE, 3850, 0)
	_enemy(STREET, 3980, 0)

	# --- 4. Çarşı: gizli han, tezgâhlar, erzak -------------------------------
	_checkpoint(4150, 0)
	_secret_han(4500)
	_stall(4950)
	_enemy(ASSASSIN, 4950, 0)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5250, 0)
	shop.title = "ÜSKÜDAR ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Röle avlusu: kule, anten, kablo hendeği ------------------------------
	_checkpoint(5450, 0)
	_antenna(5500, 0, 4.0)
	_crates(5600, 1, 1)
	_scaffold(5750, -130, 120)
	_scaffold(5750, -240, 120)
	_tower(5880, -330)
	_enemy(RIFLE, 5880, -330)
	_scaffold(6050, -250, 140)
	_pickup(PISTOL, 6050, -295)
	_terrain(1700, 6180, 0)
	_spike_pit(6180, 6340)
	_scaffold(6270, -150, 120)
	_coin_line(6230, 3, 40, -200)
	_terrain(6340, 10300, 0)
	_enemy(BRUISER, 6550, 0)

	# --- 6. Röle salonu: iç mekânda arena (galerilerle) -----------------------
	_checkpoint(6750, 0)
	_interior(6850, 7800, -345, [], 0)
	_scaffold(7020, -115, 180)
	_scaffold(7630, -115, 180)
	_scaffold(7325, -230, 200)
	_coin_line(7260, 4, 45, -280)
	_fight(6900, 7750, _wave(ELITE, KNIFE), _wave(ELITE, RIFLE, ASSASSIN))
	var serit := BREAKABLE_WALL.instantiate()
	serit.set("hits_to_break", 5)
	serit.position = Vector2(7950, 0)
	add_child(serit)
	var sign := _Sign.new()
	sign.text = "ŞERİT MAKİNESİ"
	sign.position = Vector2(7950, -260)
	add_child(sign)

	# --- 7. Arşiv: iki katlı alıcı listesi odası ------------------------------
	_checkpoint(8100, 0)
	_interior(8200, 8800, -230, [-115.0], 1)
	_story(8260, _sahne_liste)
	_enemy(ELITE, 8550, 0)
	_enemy(KNIFE, 8650, -115)
	_pickup(RIFLE_PICKUP, 8740, -160)
	_coin_line(8280, 5, 50, -160)

	# --- 8. Kız Kulesi rıhtımı: son arena; Rıfat -------------------------------
	_checkpoint(9050, 0)
	_lantern(9150)
	_fight(9200, 9800, _wave(KNIFE, ASSASSIN, RIFLE), _wave(BRUISER, ELITE))
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

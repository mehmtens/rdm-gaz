## Bölüm 7 — Karahanlı Haddehanesi (Kitap 1 / "Gazelle'in İzi").
##
## Redmount Karahanlı'nın sesini ilk kez hoparlörden duyar; Gazelle çoktan
## taşınmıştır. Buharlı su verme kanalını paletlerle geçer, dikey servis hattıyla
## döküm duvarına tırmanır (Gazelle'in saç tokası: yük asansörü yeraltına iner),
## zırhlı arenada Karahanlı'yı ilk kez görür, fırın yolunu geçer ve vericiyi kırarak
## Karahanlı'nın yayınını keser: Gazelle yeraltı hattıyla dağa götürülüyor.
extends DtmLevel

const MINIBOSS := preload("res://scenes/enemies/MiniBoss.tscn")


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/level03_high_furnace.png")
	sky_grid = 1
	sky_tint = Color(0.92, 0.84, 0.82)
	sky_shade = Color(0.07, 0.03, 0.03)
	back_row_on = false
	_night(Color(0.86, 0.76, 0.74))

	_terrain(-400, 1700, 0)

	# --- 1. Giriş: Karahanlı'nın sesi -------------------------------------------
	_story(-1.0, _sahne_ses, 220.0)
	_prop("varil", 420)
	_prop("kasa", 480)
	_enemy(BRUISER, 820, 0)
	_enemy(STREET, 1000, 0)
	_prop("varil", 1200)
	_lantern(640)
	_lantern(1350)

	# --- 2. Su verme kanalı: buharlı su, paletler, kenarda alevler --------------
	_checkpoint(1480, 0)
	_canal(1700, 2300, 100)
	_terrain(2250, 2300, 50)
	_moving(1790, -30, Vector2(220, 0), 150, 0.0)
	_moving(2080, -60, Vector2(140, 0), 130, 0.5)
	_coin_line(1780, 6, 90, -120)
	_terrain(2300, 3500, 0)
	_flame(2450, 0.0)
	_flame(2650, 0.5)
	_enemy(SHIELD, 2850, 0)
	_prop("varil", 3000)
	_prop("vazo", 3060)

	# --- 3. Dikey servis hattı: döküm duvarına tırmanış --------------------------
	_checkpoint(3220, 0)
	_terrain(3500, 4100, 0)
	for k in 4:
		_scaffold(3430, -110.0 - k * 105.0, 140)
		_pickup(COIN, 3430, -160.0 - k * 105.0)
	_factory(3500, 4100, -480)
	_enemy(RIFLE, 3980, -480)
	_coin_line(3560, 6, 80, -530)
	_story(3640, _sahne_toka)
	# İniş: kademeli iskeleler.
	_scaffold(4180, -330, 140)
	_scaffold(4310, -220, 140)
	_scaffold(4440, -110, 140)
	_terrain(4100, 9800, 0)

	# --- 4. Zırhlı arena: Karahanlı ilk kez görünür ------------------------------
	_checkpoint(4620, 0)
	_story(4700, _sahne_karahanli)
	_scaffold(5300, -170, 240)
	_coin_line(5230, 4, 50, -220)
	_prop("varil", 5000)
	_prop("kasa", 5500)
	_prop("vazo", 5700)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(5350, 0)
	arena.gate_left_x = 4800
	arena.gate_right_x = 5900
	arena.floor_y = 0
	arena.wave1 = _wave(BRUISER, STREET)
	arena.wave2 = _wave(BRUISER, SHIELD, RIFLE)
	arena.wave3 = _wave(MINIBOSS)
	arena.reward = HEALTH
	add_child(arena)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6100, 0)
	shop.title = "DÖKÜMHANE ÇAYOCAĞI"
	shop.items = PackedStringArray(["can", "zirh", "sopa"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Fırın yolu: pres + alev ritmi, üstte isteğe bağlı iskele ------------
	_checkpoint(6320, 0)
	_press(6550, 0.0)
	_flame(6750, 0.4)
	_press(6950, 0.5)
	_flame(7150, 0.9)
	_enemy(KNIFE, 7400, 0)
	_enemy(BRUISER, 7600, 0)
	for k in 5:
		_scaffold(6560.0 + k * 200.0, -260.0, 150)
		_pickup(COIN, 6560.0 + k * 200.0, -310.0)
	_crates(6400, 1, 1)
	_pickup(ARMOR, 7360, -305)
	_prop("varil", 7800)

	# --- 6. Verici: kır, yayını kes ------------------------------------------------
	_checkpoint(8000, 0)
	_enemy(STREET, 8300, 0)
	_hint(8150, "Bombacı: bomba yanıp sönerken uzaklaş ya da vurup geri yolla!", "attack")
	_enemy(BOMBER, 8450, 0)
	var mast := _Art.new(_Art.A_TOWER, Vector2(90, 380))
	mast.position = Vector2(8960, -190)
	mast.z_index = -6
	add_child(mast)
	var verici := BREAKABLE_WALL.instantiate()
	verici.set("hits_to_break", 6)
	verici.position = Vector2(8900, 0)
	add_child(verici)
	var sign := _Sign.new()
	sign.text = "VERİCİ"
	sign.position = Vector2(8900, -260)
	add_child(sign)
	_story(8980, _sahne_verici)
	_goal(9300, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Haddehane girişi: Karahanlı'nın sesi ilk kez.
func _sahne_ses(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("kh", "voice", Vector2(520, -330))
	await cs.pan(Vector2(330, -200), 0.01)
	await cs.move("rm", 220, 0.9, "walk")
	await cs.say("kh", "KARAHANLI (hoparlör)", "Redmount. Sonunda. Sesimi ilk kez duyuyorsun, değil mi?")
	await cs.say("kh", "KARAHANLI", "Balat'tan buraya, pazar pazar, vagon vagon... Sadakatini takdir ediyorum. Ama geç kaldın.")
	await cs.say("rm", "REDMOUNT", "Gazelle nerede, Karahanlı?")
	await cs.say("kh", "KARAHANLI", "Senin bulamayacağın kadar derinde. Burası çelik döker, adam döker. Rulo sende kalsın; cesedinden alırım.")
	await cs.say("rm", "REDMOUNT", "Sesin yorgun geliyor. Çok konuşan adamlar hep böyle olur.")


## Döküm duvarının tepesi: Gazelle'in saç tokası.
func _sahne_toka(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.pose("rm", "crouch")
	await cs.say("rm", "REDMOUNT", "Kızıl bir saç tokası... Gazelle'in. Buradan geçirmişler.")
	cs.pose("rm", "idle")
	await cs.say("rm", "REDMOUNT", "Yük asansörünün halatları aşağı, yeraltına iniyor. Onu dağın içine götürüyorlar.")


## Zırhlı arena: Karahanlı köprü kirişinden görünür, adamlarını salar.
func _sahne_karahanli(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("kh", "karahanli", Vector2(5350, -300), -1)
	await cs.pan(Vector2(5050, -260), 0.8)
	await cs.say("kh", "KARAHANLI", "Yüz yüze. İşte böyle görünüyormuşsun. Daha uzun boylu sanırdım.")
	await cs.say("rm", "REDMOUNT", "Aşağı in de boyumu ölç.")
	await cs.say("kh", "KARAHANLI", "Benim işim ölçmek değil, dökmek. Çelik dövücülerim seninle ilgilenecek.")
	await cs.say("kh", "KARAHANLI", "Gazelle'e selamını iletirim. Tabii karanlıkta beni görebilirse.")
	await cs.fade_out("kh", 0.6)
	await cs.say("rm", "REDMOUNT", "KARAHANLI!", 1.0)


## Verici: yayın kesilir, son söz yeraltını ele verir.
func _sahne_verici(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("kh", "voice", Vector2(p.x + 120, -300))
	await cs.say("kh", "KARAHANLI (cızırtılı)", "...bütün birimlere... Gazelle'i dağa, yeraltı hattından... kapıları say...", 2.2)
	await cs.say("kh", "TELSİZ", "kkhhhzzzt...", 1.2)
	await cs.say("rm", "REDMOUNT", "Verici sustu. Beni oyalamak için bekletmiş. Gazelle yeraltı hattıyla dağa götürülüyor.")
	await cs.say("rm", "REDMOUNT", "Tünele iniyorum.")

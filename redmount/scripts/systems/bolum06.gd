## Bölüm 6 — Ağır Güvenlik Bölgesi (Kitap 1 / "Gazelle'in İzi").
##
## Tren sanayi kuşağına girer; Redmount trenden atlar, zırhlı adamların Gazelle'i
## fabrikaya götürdüğünü görür. Zamanlı alev bacalarının, preslerin altından ve
## metal iskelelerin üstünden geçer, döküm avlusunu temizler, havalandırma
## ızgarasından Gazelle'in uyarısını duyar (Karahanlı haddehanede, tuzak) ve Zırhlı
## Ustabaşı'yı yenip haddehane kapısına varır.
extends DtmLevel

const MINIBOSS := preload("res://scenes/enemies/MiniBoss.tscn")


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/level03_industry_atlas.png")
	sky_cells = [[1, -100000.0], [2, 4300.0], [3, 8000.0]]
	sky_tint = Color(0.86, 0.8, 0.82)
	sky_shade = Color(0.06, 0.04, 0.05)
	back_row_on = false
	_night(Color(0.8, 0.76, 0.82))

	_terrain(-400, 9800, 0)
	_rails(-400, 1200)

	# --- 1. Varış: trenden atlayış, Gazelle fabrikaya götürülür --------------------
	_story(-1.0, _sahne_varis, 260.0)
	_prop("varil", 420)
	_prop("kasa", 480)
	_enemy(STREET, 700, 0)
	_enemy(BRUISER, 960, 0)
	_prop("varil", 1150)
	_lantern(560)
	_lantern(1240)

	# --- 2. Alev koridoru: altta zamanlı alevler, üstte metal iskele yolu ---------
	_checkpoint(1400, 0)
	_crates(1560, 1, 1)
	for k in 5:
		_scaffold(1720.0 + k * 170.0, -210.0 - (k % 2) * 50.0, 150)
		_pickup(COIN, 1720.0 + k * 170.0, -265.0 - (k % 2) * 50.0)
	_flame(1800, 0.0)
	_flame(2050, 0.33)
	_flame(2300, 0.66)
	_flame(2550, 0.0)
	_coin_line(1900, 4, 210, -60)
	_enemy(SHIELD, 2780, 0)
	_prop("varil", 2700, 0, HEALTH)
	_factory(3000, 3300, -200)
	_crates(2820, 1, 1)
	_crates(2910, 1, 2)
	_enemy(RIFLE, 3200, -200)
	_coin_line(3040, 4, 60, -250)

	# --- 3. Pres salonu: zamanla altından geç ----------------------------------
	_checkpoint(3420, 0)
	_story(3460, _sahne_hoparlor)
	_press(3650, 0.0)
	_press(3880, 0.35)
	_press(4110, 0.7)
	_coin_line(3620, 6, 92, -60)
	_prop("kasa", 4300)

	# --- 4. Döküm avlusu: kilitli arena; işçi kantini ----------------------------
	_checkpoint(4420, 0)
	_scaffold(5050, -170, 240)
	_coin_line(4980, 4, 50, -220)
	_prop("varil", 4700)
	_prop("vazo", 4850)
	_prop("kasa", 5300)
	_prop("varil", 5450)
	_lantern(4600)
	_lantern(5500)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(5050, 0)
	arena.gate_left_x = 4520
	arena.gate_right_x = 5620
	arena.floor_y = 0
	arena.wave1 = _wave(STREET, BRUISER)
	arena.wave2 = _wave(KNIFE, RIFLE, STREET)
	arena.wave3 = _wave(BRUISER, BRUISER)
	arena.reward = HEALTH
	add_child(arena)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5820, 0)
	shop.title = "İŞÇİ KANTİNİ"
	shop.items = PackedStringArray(["can", "zirh", "cephane"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Havalandırma: Gazelle'in uyarısı; fabrika çatıları + presler ----------
	_checkpoint(6050, 0)
	_crates(6150, 1, 1)
	_factory(6240, 6700, -180)
	_story(6400, _sahne_izgara)
	_enemy(KNIFE, 6600, -180)
	_coin_line(6300, 6, 70, -230)
	_flame(6800, 0.2)
	_press(6960, 0.5)
	_crates(7160, 1, 1)
	_crates(7250, 1, 2)
	_factory(7340, 7800, -200)
	_enemy(RIFLE, 7700, -200)
	_prop("varil", 7500, -200)
	_pickup(ARMOR, 7420, -245)

	# --- 6. Zırhlı Ustabaşı; haddehane kapısı -------------------------------------
	_checkpoint(7950, 0)
	_story(8020, _sahne_ustabasi)
	_prop("varil", 8300)
	_prop("kasa", 8900)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(8600, 0)
	final.gate_left_x = 8120
	final.gate_right_x = 9100
	final.floor_y = 0
	final.wave1 = _wave(STREET, KNIFE, BRUISER)
	final.wave2 = _wave(MINIBOSS)
	final.wave3 = _wave(BRUISER, RIFLE)
	final.reward = HEALTH
	add_child(final)
	_story(9200, _sahne_baca)
	_han_gate(9500, "HADDEHANE")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2375, "telsiz", "USTABAŞI (telsiz)", "Kızı haddehaneye indirin. Alevleri açık bırakın, gelen yansın.")
	_radio(5225, "redmount", "REDMOUNT", "Bu fabrikanın her bacası Karahanlı'nın imzası.")
	_radio(8075, "gazelle", "GAZELLE (ızgaradan, fısıltı)", "Redmount... buradayım. Haddehane bir tuzak, dikkat et!")
	_goal(9500, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Varış: tren yavaşlar, Redmount atlar; Gazelle fabrikaya götürülür.
func _sahne_varis(cs: Cutscene) -> void:
	cs.actor("w1", "wagon", Vector2(-500, 0))
	cs.actor("w2", "wagon", Vector2(-100, 0))
	cs.actor("rm", "redmount", Vector2(-100, -140))
	cs.pose("rm", "crouch")
	await cs.pan(Vector2(300, -200), 0.01)
	var t := cs.create_tween().set_parallel(true)
	t.tween_property(cs.get_actor("w1"), ^"position:x", 200.0, 2.2).set_ease(Tween.EASE_OUT)
	t.tween_property(cs.get_actor("w2"), ^"position:x", 600.0, 2.2).set_ease(Tween.EASE_OUT)
	t.tween_property(cs.get_actor("rm"), ^"position:x", 600.0, 2.2).set_ease(Tween.EASE_OUT)
	await t.finished
	await cs.say("rm", "REDMOUNT", "Tren sanayi kuşağında durdu. Burnuma yanık demir kokusu geliyor.")
	cs.actor("b1", "bruiser", Vector2(1150, 0), -1)
	cs.actor("gz", "gazelle", Vector2(1260, 0), -1)
	cs.actor("b2", "bruiser", Vector2(1370, 0), -1)
	cs.pose("gz", "bound_idle")
	await cs.pan(Vector2(1000, -200), 0.8)
	await cs.say("gz", "GAZELLE", "Redmount! O film... rulo sende mi?!")
	await cs.say("rm", "REDMOUNT", "Bende!", 1.0)
	await cs.say("gz", "GAZELLE", "Sakla onu! Ne olursa olsun Karahanlı'ya verme! İçinde her şey var!")
	await cs.say("b1", "ZIRHLI MUHAFIZ", "Konuşma bitti. Fabrikaya.")
	cs.face("b1", 1)
	cs.face("b2", 1)
	cs.move("b1", 1900, 1.6, "walk", false)
	cs.move("b2", 2100, 1.6, "walk", false)
	await cs.struggle("gz", 2000, 4)
	cs.remove("gz")
	cs.remove("b1")
	cs.remove("b2")
	await cs.pan(Vector2(400, -200), 0.6)
	cs.pose("rm", "jump")
	await cs.hop("rm", Vector2(260, 0), 0.45, 40.0)
	cs.pose("rm", "idle")
	await cs.say("rm", "REDMOUNT", "'İçinde her şey var'... Bu rulo Karahanlı'nın bütün sevkiyatını gösteriyor olmalı.")
	await cs.say("rm", "REDMOUNT", "Alevler, presler, zırhlı adamlar. Hepsi bir kızı ve bir film rulosunu korumak için.")


## Pres salonu: hoparlör anonsu.
func _sahne_hoparlor(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("hop", "voice", Vector2(p.x + 400, -330))
	await cs.pan(Vector2(p.x + 350, -220), 0.5)
	await cs.say("hop", "HOPARLÖR", "Haddehane vardiyasına dikkat: misafirimiz geldi. Presleri tam güçte çalıştırın.")
	await cs.say("hop", "HOPARLÖR", "Tekrar ediyorum: Karahanlı Bey misafirin haddehaneye kadar gelmesini istiyor. Canlı.")
	await cs.say("rm", "REDMOUNT", "Canlı mı? Beni bekliyor demek. Preslerin ritmini say, sonra koş.")


## Havalandırma ızgarası: Gazelle'in sesi.
func _sahne_izgara(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "voice", Vector2(p.x + 90, -200))
	cs.pose("rm", "crouch")
	await cs.say("gz", "GAZELLE (ızgaranın altından)", "Redmount? Ayak seslerini tanırım. Beni duyuyor musun?")
	await cs.say("rm", "REDMOUNT", "Duyuyorum. Neredesin? Seni oradan çıkaracağım.")
	await cs.say("gz", "GAZELLE", "Karahanlı haddehanede, beni değil seni bekliyor. Bir tuzak kurdu. Rulo için.")
	await cs.say("gz", "GAZELLE", "Beni şimdi başka yere taşıyacaklar... yeraltından bir şey dediler. Gelme, lütfen!")
	await cs.say("rm", "REDMOUNT", "Tuzak olduğunu bilmek, tuzağı yarı yarıya bozmaktır. Geliyorum.")


## Zırhlı Ustabaşı: avlunun bekçisi.
func _sahne_ustabasi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("us", "bruiser", Vector2(8550, 0), -1)
	await cs.pan(Vector2(8350, -190), 0.7)
	await cs.say("us", "ZIRHLI USTABAŞI", "Bu avluda çelik dövülür, kemik değil. Ama senin için bir istisna yapabilirim.")
	await cs.say("rm", "REDMOUNT", "Zırhın sağlam görünüyor. Bakalım içindeki adam ne kadar sağlam.")
	await cs.move("us", 9000, 0.7, "walk")
	cs.remove("us")


## Haddehanenin bacası: Karahanlı ile ilk karşılaşmanın eşiği.
func _sahne_baca(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	await cs.pan(Vector2(9420, -260), 0.7)
	await cs.say("rm", "REDMOUNT", "Haddehanenin bacası. Sanayi hattı çöktü...")
	await cs.say("rm", "REDMOUNT", "Karahanlı içeride. Onunla ilk kez yüz yüze geleceğim.")

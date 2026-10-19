## Bölüm 11 — Sessiz Koridor (Kitap 1 / "Gazelle'in İzi").
##
## Kalenin dar iç koridorları. Redmount surdan iner, duvarı tıklatan Gazelle'in
## yönlendirmesiyle ilerler, tuzak preslerini geçer ve parmaklıklı hücre
## penceresinde Gazelle'le ilk kez yüz yüze konuşur: film rulosu Karahanlı'nın
## bütün sevkiyat ağını gösteriyor. Gazelle iç kaleye götürülür; seçkin muhafız
## pususu, arşivdeki sarnıç çukuru ve Muhafız Başı ile kavga: son kapı iç kale.
extends DtmLevel

const MINIBOSS := preload("res://scenes/enemies/MiniBoss.tscn")
const BARS := preload("res://assets/environment/pixel/parmaklik.png")


func _build() -> void:
	sky_atlas = preload("res://assets/backgrounds/book03_anadoluhisari_inner_atlas.png")
	sky_cells = [[1, -100000.0], [0, 3200.0], [2, 6300.0]]
	sky_tint = Color(0.84, 0.82, 0.92)
	sky_shade = Color(0.04, 0.03, 0.07)
	back_row_on = false
	_night(Color(0.74, 0.72, 0.88))
	_ceiling(-400, 8900, -440)

	# --- 1. Surdan iniş: duvardaki tıkırtı -----------------------------------------
	_terrain(-400, 3400, 0)
	_story(-1.0, _sahne_inis, 220.0)
	for x in [300, 900, 1500]:
		_lantern(float(x))
	_prop("vazo", 420)
	_prop("sandik", 560, 0, AMMO)
	_enemy(KNIFE, 820, 0)
	_enemy(ASSASSIN, 1050, 0)
	_prop("kasa", 1250)

	# --- 2. Tuzaklı koridor: presler; üstte galeri -----------------------------
	_checkpoint(1420, 0)
	_press(1750, 0.0, 2.4)
	_press(2000, 0.33, 2.4)
	_press(2250, 0.66, 2.4)
	_coin_line(1720, 6, 105, -60)
	var aw := AwningBounce.new()
	aw.width = 160
	aw.height = 60
	aw.position = Vector2(1560, 0)
	add_child(aw)
	for k in 5:
		_scaffold(1730.0 + k * 170.0, -260.0, 150)
		_pickup(COIN, 1730.0 + k * 170.0, -310.0)
	_pickup(HEALTH, 2410, -305)
	_enemy(ELITE, 2700, 0)
	_prop("vazo", 2900)
	_lantern(2600)
	_lantern(3200)

	# --- 3. Hücre penceresi: Gazelle; ardından pusu ----------------------------
	_checkpoint(3120, 0)
	_cell_window(3700)
	_story(3480, _sahne_hucre)
	_terrain(3400, 6300, 0)
	_prop("varil", 4300)
	_prop("vazo", 4900)
	_scaffold(4600, -170, 220)
	_coin_line(4540, 4, 45, -220)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(4600, 0)
	arena.gate_left_x = 4100
	arena.gate_right_x = 5100
	arena.floor_y = 0
	arena.wave1 = _wave(ELITE, KNIFE)
	arena.wave2 = _wave(ASSASSIN, ELITE, SHIELD)
	arena.wave3 = _wave(ELITE, ELITE)
	arena.reward = HEALTH
	add_child(arena)

	# --- 4. Arşiv: sarnıç çukurunun üstünde çöken tahtalar ----------------------
	_checkpoint(5300, 0)
	_enemy(BOMBER, 5600, 0)
	_canal(6300, 7000, 120)
	_terrain(6950, 7000, 60)
	for k in 4:
		var cx := 6390.0 + k * 165.0
		_collapse(cx, -10.0, 145)
		_pickup(COIN, cx, -65.0)
	_terrain(7000, 8900, 0)
	_pickup(ARMOR, 6640, -200)
	_moving(6640, -150, Vector2(0, -60), 120, 0.0)

	# --- 5. Muhafız Başı; iç kale kapısı ---------------------------------------
	_checkpoint(7150, 0)
	_story(7220, _sahne_muhafiz_basi)
	_prop("vazo", 7500)
	_prop("sandik", 8150, 0, HEALTH)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(7850, 0)
	final.gate_left_x = 7350
	final.gate_right_x = 8350
	final.floor_y = 0
	final.wave1 = _wave(ELITE, ASSASSIN)
	final.wave2 = _wave(MINIBOSS)
	final.wave3 = _wave(ELITE, KNIFE)
	final.reward = HEALTH
	add_child(final)
	_story(8450, _sahne_son_kapi)
	_han_gate(8700, "İÇ KALE")
	_goal(8700, 0)


## Hücre penceresi: karanlık oda + önünde piksel demir parmaklık (aktörlerin önünde).
func _cell_window(cx: float) -> void:
	var room := _Art.new(_Art.A_ROOM, Vector2(300, 260))
	room.position = Vector2(cx, -150)
	room.z_index = -8
	add_child(room)
	var bars := Sprite2D.new()
	bars.texture = BARS
	bars.region_enabled = true
	bars.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	bars.region_rect = Rect2(0, 0, 100, 84)
	bars.scale = Vector2(3, 3)
	bars.position = Vector2(cx, -150)
	bars.z_index = 9
	bars.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(bars)
	var sign := _Sign.new()
	sign.text = "TUTUKEVİ"
	sign.position = Vector2(cx, -320)
	add_child(sign)


# --- Hikâye sahneleri ----------------------------------------------------------

## Surdan iniş: Gazelle duvarı tıklatarak yön verir.
func _sahne_inis(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(60, -360))
	await cs.pan(Vector2(360, -220), 0.01)
	cs.pose("rm", "jump")
	await cs.hop("rm", Vector2(160, 0), 0.6, 10.0)
	Fx.dust(Vector2(160, 0), 0.0, 8)
	cs.pose("rm", "crouch")
	await cs.say("rm", "REDMOUNT", "İçerideyim. Sessiz... Seçkin muhafızlar her köşede olabilir.")
	cs.actor("tik", "voice", Vector2(420, -200))
	await cs.say("tik", "DUVARIN İÇİNDEN", "tık... tık-tık... tık", 1.6)
	cs.pose("rm", "idle")
	await cs.say("rm", "REDMOUNT", "Bu ritim... Gazelle'in kapı sayışı. Sağ duvar boyunca ilerle diyor.")
	await cs.say("tik", "GAZELLE (fısıltı)", "Redmount... sağ koridor, tutukevi penceresi. Acele et.")


## Hücre penceresi: Gazelle ile yüz yüze.
func _sahne_hucre(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", Vector2(3720, 0), -1)
	cs.pose("gz", "bound_idle")
	await cs.pan(Vector2(3640, -200), 0.7)
	await cs.move("rm", 3600, 0.8, "run")
	await cs.say("gz", "GAZELLE", "Redmount... Gerçekten sensin. Balat'tan beri her kapıda seni düşündüm.")
	await cs.say("rm", "REDMOUNT", "Söz vermiştim, değil mi? Bugün iş yok demiştim. Biraz geç kaldım.")
	cs.pose("gz", "rescue_react")
	await cs.say("gz", "GAZELLE", "Dinle, vaktimiz yok. Film rulosu sende mi?")
	await cs.say("rm", "REDMOUNT", "Ceketimin iç cebinde. Haddehaneden beri.")
	await cs.say("gz", "GAZELLE", "O rulo yalnız kamyonları göstermiyor. Mühürleri, rotaları, kimin imza attığını... Karahanlı tek başına değil.")
	await cs.say("gz", "GAZELLE", "Beni değil, bütün şehri kaçırıyorlar Redmount. Ben sadece fazla yakından baktım.")
	await cs.say("rm", "REDMOUNT", "O zaman önce seni çıkaracağım, sonra şehri.")
	cs.actor("e1", "elite", Vector2(4000, 0), -1)
	await cs.say("e1", "SEÇKİN MUHAFIZ", "Konuşma bitti. Karahanlı Bey kızı iç kaleye istiyor. Şimdi!")
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Taht salonu! Beni taht salonuna indiriyorlar! Redmount—", 1.8)
	await cs.fade_out("gz", 0.5)
	await cs.say("rm", "REDMOUNT", "GAZELLE!", 1.0)
	await cs.say("e1", "SEÇKİN MUHAFIZ", "Davetsiz misafir. Koridoru kapatın!")
	await cs.move("e1", 5000, 0.6, "walk")
	cs.remove("e1")


## Muhafız Başı: son kapının bekçisi.
func _sahne_muhafiz_basi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("mb", "elite", Vector2(7800, 0), -1)
	cs.actor("e1", "elite", Vector2(7940, 0), -1)
	await cs.pan(Vector2(7550, -200), 0.7)
	await cs.say("mb", "MUHAFIZ BAŞI", "Bu koridorda yirmi yıldır tek bir ayak sesi duyulmadı. Seninki fazla gürültülü.")
	await cs.say("rm", "REDMOUNT", "Sessiz olmaya çalıştım. Sonra Gazelle'in sesini duydum.")
	await cs.say("mb", "MUHAFIZ BAŞI", "Kalkanlar kalksın. Bu adam taht salonuna yürümeyecek.")
	cs.move("e1", 8350, 0.6, "walk", false)
	await cs.move("mb", 8300, 0.6, "walk")
	cs.remove("mb")
	cs.remove("e1")


## Son kapı: iç kalenin eşiği.
func _sahne_son_kapi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "voice", Vector2(8700, -300))
	await cs.pan(Vector2(8620, -220), 0.6)
	await cs.say("gz", "GAZELLE (aşağıdan, yankı)", "Redmount! Beni iç kaleye indiriyorlar. Karahanlı taht salonunda bekliyor!")
	await cs.say("rm", "REDMOUNT", "Dayan. Son kapıya geldim.")

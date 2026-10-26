## Bölüm 20 — Samatya Taş Depoları (Kitap 2 / "Haliç'in İzi", 8. bölüm).
##
## Külhandaki mektup son teslimi Samatya taş depolarına bağlar. Gece: arka sokak ->
## balık pazarı (rıhtım düzünde arena) -> deniz kapısı (kayık iskelesi + vinç paleti,
## üstte sur kemeri) -> taş depo girişi (tüfekli, arena, erzak) -> tasnif salonu (vinç
## kirişi) -> tuzlu servis geçidi (arena) -> gizli kayıt odası (oyulmuş taş bloklar) ->
## yükleme avlusu (yük iskelesi). Kemal Bey ilk kez görünür: bir kayıkla kaçar.
## Çıkış fişi: Yenikapı gece vardiyası.
extends DtmLevel

const COAST := preload("res://assets/backgrounds/book02_samatya_coast_atlas.png")
const DEPOT := preload("res://assets/backgrounds/book02_samatya_depot_atlas.png")


func _build() -> void:
	sky_atlas = COAST
	sky_cells = [[0, -100000.0], [1, 1600.0], [2, 3300.0], [3, 4600.0],
		[0, 6000.0, DEPOT], [1, 7300.0, DEPOT], [2, 8600.0, DEPOT], [3, 9550.0, DEPOT]]
	sky_tint = Color(0.86, 0.86, 0.94)
	sky_shade = Color(0.03, 0.04, 0.08)
	back_row_skip = [[5900.0, 9900.0]]
	_night(Color(0.78, 0.8, 0.94))

	# --- 1. Arka sokak: devriye, güvenli balkon -------------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_sahil, 240.0)
	_balcony(560, -70, 110)
	_balcony(720, -170, 110)
	_pickup(ARMOR, 720, -215)
	_enemy(STREET, 1050, 0)
	_prop("saksi", 1250)
	for x in [300, 1400]:
		_lantern(float(x))

	# --- 2. Balık pazarı: sur dibindeki rıhtım düzünde, hızlı + zırhlı arena -----
	# Pazar sokakla aynı hizada surun dibinde (Kitap 2'nin ortak çukur avlusu yerine);
	# iniş bir sonraki kesimde, deniz kapısından iskeleye.
	_checkpoint(1550, 0)
	_terrain(1700, 3200, 0)
	_stall(2000)
	_stall(2950)
	_prop("kasa", 2300, 0, COIN)
	var pazar: BattleArena = ARENA.instantiate()
	pazar.position = Vector2(2500, 0)
	pazar.gate_left_x = 2050
	pazar.gate_right_x = 2950
	pazar.floor_y = 0
	pazar.wave1 = _wave(KNIFE, ASSASSIN, STREET)
	pazar.wave2 = _wave(BRUISER, SHIELD)
	pazar.reward = AMMO
	add_child(pazar)

	# --- 3. Deniz kapısı: alçak kayık iskelesi + vinç paleti, üstte sur kemeri -------
	# Alt yol: kapıdan iskeleye iki basamak inilir, 450 px su vinç paletiyle (ya da
	# ıslanarak, dip 110) geçilir; palet hattında altınlar. Üst yol: sur taşlarından
	# kemerin altındaki iskele kirişlerine, tepede tabanca; karşı rıhtımda taşlardan inilir.
	_stones(3020, 1, 1)
	_stones(3110, 1, 2)
	_terrain(3200, 3350, 30)
	_terrain(3350, 3700, 60)
	_checkpoint(3400, 60)
	_enemy(KNIFE, 3560, 60)
	_canal(3700, 4150, 110)
	_moving(3780, 20, Vector2(290, 0), 140, 0.0)
	_coin_line(3800, 5, 65, -25)
	_scaffold(3330, -230, 140)
	_scaffold(3560, -250, 140)
	_scaffold(3800, -250, 140)
	_scaffold(4040, -230, 140)
	_pickup(PISTOL, 3800, -295)
	_terrain(4150, 10300, 0)
	## Sudan çıkan için önce 90'lık taş, sonra 180'lik; üst yol 180'liğe iner.
	_stones(4160, 1, 1)
	_stones(4250, 1, 2)
	_enemy(SHIELD, 4550, 0)

	# --- 4. Taş depo girişi: tüfekli, ikinci arena, erzak ----------------------
	_checkpoint(4750, 0)
	_stones(4880, 1, 1)
	_stones(4970, 1, 2)
	_terrain(5060, 5300, -180)
	_enemy(RIFLE, 5240, -180)
	_pickup(RIFLE_PICKUP, 5100, -225)
	# Depo kapısında nöbet: kilitsiz, tüfekli yukarıdan destekler.
	_enemy(KNIFE, 5500, 0)
	_enemy(BRUISER, 5700, 0)
	_prop("kasa", 5820, 0, COIN)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6000, 0)
	shop.title = "SAMATYA ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Tasnif salonu: alt yol açık, vinç kirişi -----------------------------
	_checkpoint(6200, 0)
	# Tasnif salonu: taş deponun içi; vinç kirişi tavanın altında.
	_interior(6280, 7180, -360, [], 0)
	_stones(6350, 1, 1)
	_scaffold(6510, -150, 120)
	_moving(6650, -240, Vector2(300, 0), 140, 0.0)
	_scaffold(7070, -240, 120)
	_pickup(ARMOR, 7070, -285)
	_coin_line(6660, 5, 75, -300)
	_enemy(ASSASSIN, 6850, 0)
	_stones(7250, 2, 1)

	# --- 6. Tuzlu servis geçidi: arena -------------------------------------------
	_checkpoint(7450, 0)
	_canal(7550, 7750, 110)
	_scaffold(7650, -20, 220)
	_fg("kolon", 7950.0, 40.0, 380.0)
	_fg("kolon", 8350.0, 40.0, 380.0)
	var tuz: BattleArena = ARENA.instantiate()
	tuz.position = Vector2(8150, 0)
	tuz.gate_left_x = 7850
	tuz.gate_right_x = 8450
	tuz.floor_y = 0
	tuz.wave1 = _wave(BOMBER, ELITE)
	tuz.wave2 = _wave(KNIFE, RIFLE, ASSASSIN)
	tuz.reward = HEALTH
	add_child(tuz)

	# --- 7. Gizli kayıt odası: oyulmuş blok -----------------------------------
	_checkpoint(8600, 0)
	_canal(8700, 8900, 110)
	_scaffold(8800, -20, 220)
	_interior(8960, 9320, -230, [-115.0], 1)
	_stones(9050, 1, 1)
	_story(9000, _sahne_blok)
	_pickup(HEALTH, 9280, -160)
	_coin_line(9000, 5, 60, -160)

	# --- 8. Yükleme avlusu: yük iskelesi, hamallar; Kemal Bey kaçar -------------
	_checkpoint(9350, 0)
	_scaffold(9700, -115, 180)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(9700, 0)
	final.gate_left_x = 9450
	final.gate_right_x = 9950
	final.floor_y = 0
	## Taş hamalları kalkanlıların arkasından gelir; ikinci dalgada tüfekli, ortadaki
	## yük iskelesinden atlanarak aşılır; son dalga ağır ve seçkin birlikte.
	final.wave1 = _wave(STREET, SHIELD, STREET)
	final.wave2 = _wave(RIFLE, ASSASSIN)
	final.wave3 = _wave(BRUISER, ELITE)
	final.reward = HEALTH
	add_child(final)
	_kemal_watches(final)
	_story(10000, _sahne_kemal)
	_han_gate(10150, "YENİKAPI")
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2537, "gazelle", "GAZELLE", "Samatya. Kemal Bey burada görülmüş. Ona sormam gereken çok şey var.")
	_radio(5582, "redmount", "REDMOUNT", "Soru sormak için önce yakalamak lazım.")
	_radio(8627, "gazelle", "GAZELLE", "Kayıkla kaçıyor! Çıkış fişi: Yenikapı gece vardiyası.")
	_goal(10150, 0)


## Set-piece: Kemal Bey avlu dövüşünü sağ kapının ardından (arka planda, loş) izler;
## üçüncü dalga başlayınca arkasını dönüp kayığa koşar, Gazelle telsizden bağırır.
## Hedef dövüş boyunca görünür (DTM'de kaçan hedef oyuncunun gözü önündedir); hikâye
## sahnesi onu kayığın başında yakalar. Dokunulmaz süs: çarpışması yok.
func _kemal_watches(arena: BattleArena) -> void:
	var k := AnimatedSprite2D.new()
	k.sprite_frames = Cutscene.ELITE_FRAMES
	k.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	k.scale = Vector2(0.52, 0.52)  # arka planda: oyuncudan küçük
	k.offset = Vector2(0, -114)
	k.flip_h = true  # avluya (sola) bakar
	k.position = Vector2(arena.gate_right_x - 40.0, -6.0)
	k.z_index = -6
	k.modulate = Color(0.7, 0.68, 0.8)
	k.play(&"idle")
	add_child(k)
	arena.wave_changed.connect(func(wave: int, _total: int, _left: int) -> void:
		if wave < 3 or not is_instance_valid(k) or k.has_meta(&"gone"):
			return
		k.set_meta(&"gone", true)
		k.flip_h = false
		k.play(&"walk")
		k.speed_scale = 2.2
		var t := k.create_tween()
		t.tween_property(k, ^"position:x", k.position.x + 520.0, 1.1)
		t.tween_callback(k.queue_free)
		RadioPanel.say(get_tree(), "gazelle", "GAZELLE", "Kemal Bey kaçıyor! Çabuk, Redmount!"))
	arena.cleared.connect(func() -> void:
		if is_instance_valid(k):
			k.queue_free())


# --- Hikâye sahneleri ----------------------------------------------------------

## Samatya sahili: gece, taş sevkiyatları.
func _sahne_sahil(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.2, "walk", false)
	await cs.move("rm", 240, 1.2, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Samatya. Gecenin bu saatinde taş depolarında ne işleri var?")
	await cs.say("rm", "REDMOUNT", "Taş ağırdır, kimse kaldırıp içine bakmaz. Kâtip için mükemmel kutu.")
	await cs.say("gz", "GAZELLE", "Mektupta 'son teslim' diyordu. Kemal Bey bu gece burada olabilir.")


## Gizli kayıt odası: oyulmuş taş blok.
func _sahne_blok(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 100, -200), 0.5)
	cs.pose("rm", "fight")
	Sfx.play(&"hit", 0.6)
	cs.shake(5.0)
	await cs.wait(0.3)
	cs.pose("rm", "idle")
	await cs.say("rm", "REDMOUNT", "Blok çatladı... İçi oyulmuş. Evrak dolu.")
	await cs.say("gz", "GAZELLE", "Tapu kayıtları, gümrük beyannameleri, nüfus kâğıtları! Şehrin yarısının sahtesi burada.")
	await cs.say("gz", "GAZELLE", "Kâtip mal kaçırmıyor Redmount. Kimlik kaçırıyor. İnsanları kâğıt üzerinde yok edip yeniden yazıyor.")


## Yükleme avlusu: Kemal Bey ilk kez görünür, kayıkla kaçar.
func _sahne_kemal(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("km", "elite", Vector2(p.x + 420, 0), -1)
	await cs.pan(Vector2(p.x + 200, -200), 0.6)
	await cs.say("km", "KEMAL BEY", "Gazelle... Seni o kaleden sağ çıkardıklarını duyunca inanmamıştım.")
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Kemal Bey! Bana gerçeği yazmayı siz öğrettiniz!")
	await cs.say("km", "KEMAL BEY", "Gerçek, kim yazarsa onundur kızım. Ben sadece yazana çalışıyorum.")
	await cs.say("rm", "REDMOUNT", "Kime? Kâtip kim?")
	await cs.say("km", "KEMAL BEY", "Yenikapı'da gece vardiyası başlıyor. Oraya kadar yaşarsanız, sorun.")
	cs.face("km", 1)
	await cs.move("km", p.x + 900, 0.9, "run")
	cs.remove("km")
	await cs.say("gz", "GAZELLE", "Kayığa atladı... Yenikapı. Redmount, onu ben yakalamak istiyorum.")
	await cs.say("rm", "REDMOUNT", "Birlikte yakalayacağız. Sen soruları sor, ben kapıyı tutayım.")

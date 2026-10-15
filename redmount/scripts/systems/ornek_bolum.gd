## Örnek bölüm — "Balat Sokakları" (Dan the Man tarzı, elle yerleştirilmiş).
##
## Kampanyadan bağımsız deneme bölümü: `--ornek` ile açılır. Akış Dan the Man'in
## ilk bölümlerini izler: kısa sokak + ilk kavga -> tenteyle çatılara -> taş set
## ve gizli oda -> kilitli pazar meydanı (3 dalga) -> büfe -> inşaat iskelesi ve
## vinç paleti -> han kapısında son kavga -> çıkış. ~2-3 dakika.
##
## Görsel katmanlar: uzak boyalı İstanbul (yavaş paralaks) -> karartılmış arka sıra
## evler (orta paralaks) -> oynanan katı zemin / evler / iskeleler (mahalle seti).
extends StoryBlockout

const SKY := preload("res://assets/backgrounds/book02_suleymaniye_streets_atlas.png")
const GROUND_TOP := preload("res://assets/environment/mahalle/ground_long.png")
const STONE := preload("res://assets/environment/mahalle/stone_fill.png")
const WALL := preload("res://assets/environment/mahalle/wall_plain.png")
const ROOF_SLAB := preload("res://assets/environment/mahalle/roof_a.png")
const ROOF_CAP := preload("res://assets/environment/kit/roof_b.png")
const SCAFFOLD_DECK := preload("res://assets/environment/mahalle/scaffold_deck_v2.png")
const SCAFFOLD_POST := preload("res://assets/environment/kit/scaffold_post.png")
const BALCONY := preload("res://assets/environment/mahalle/window_balcony.png")
const CRATE := preload("res://assets/environment/mahalle/crate_wood_v2.png")
const BUFE := preload("res://assets/environment/mahalle/bufe.png")
const TREE_POT := preload("res://assets/environment/mahalle/tree_pot.png")
const PLANT := preload("res://assets/environment/mahalle/plant_small.png")
const POTS := preload("res://assets/environment/kit/pots.png")
const AWNING_TEX := preload("res://assets/environment/mahalle/market_awning_v2.png")
const HOUSES := [
	preload("res://assets/environment/mahalle/house_a.png"),
	preload("res://assets/environment/mahalle/house_b.png"),
	preload("res://assets/environment/mahalle/house_c.png"),
]
## Ev sanatlarında kiremit saçağının bittiği oran (gövde üst kenarı).
const HOUSE_EAVE := [0.2, 0.17, 0.0]
const BREAKABLE_WALL := preload("res://scenes/systems/BreakableWall.tscn")
const ZOOM := 1.12

var _cam: Camera2D


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_Sky.new())
	_back_row()

	# --- 1. Balat girişi: kaçırılma sahnesi, kırılanlar, açık sokakta ilk kavga ---
	_terrain(-400, 2200, 0)
	_story(-1.0, _sahne_kacirma, 470.0)
	_deco(PLANT, 40, 0, 0.9)
	_deco(TREE_POT, 560, 0, 1.0)
	_prop("saksi", 330)
	_prop("vazo", 400)
	_coin_line(470, 4, 55, -50)
	# İlk kavga geniş, düz sokakta: iki kabadayı, arkalarında kırılacak ödül.
	_enemy(STREET, 820, 0)
	_enemy(STREET, 960, 0)
	_prop("kasa", 1050)
	_prop("vazo", 1110)

	# --- 2. Tente -> çatılar ---------------------------------------------------
	# Tezgâh evin duvarına dayalı: duvara çarpan yeniden tenteye düşer.
	var awning := AwningBounce.new()
	awning.width = 180
	awning.height = 60
	awning.position = Vector2(1200, 0)
	add_child(awning)
	_coins_arc(1150, 5, 45, -330)
	var h1 := _house(1290, -240, 0)
	_coin_line(h1 - 170, 3, 55, -290)
	_enemy(KNIFE, h1 - 60, -240)
	# Ara sokak: düşen oyuncu karşı evin balkonlarıyla yeniden çatıya çıkar.
	_balcony(h1 + 45, -110, 90)
	_balcony(h1 + 115, -195, 90)
	_coins_arc(h1 + 20, 3, 60, -360)
	var h2 := _house(h1 + 160, -280, 1)
	_coin_line(h2 - 170, 3, 55, -330)
	_pickup(HEALTH, h2 - 40, -320)
	_prop("saksi", h1 - 150, -240)
	_prop("vazo", h2 - 120, -280)
	# Çatıdan minibüs görülür: Gazelle pencereden seslenir.
	_story(h1 - 150, _sahne_catidan_minibus)

	# --- 3. Taş set, tüfekli, gizli oda ---------------------------------------
	_checkpoint(2280, 0)
	_terrain(2200, 2480, 0)
	_terrain(2480, 2580, -45)
	_terrain(2580, 3060, -90)
	_terrain(3060, 3160, -45)
	_terrain(3160, 3700, 0)
	_enemy(KNIFE, 2380, 0)
	_prop("vazo", 2640, -90)
	_prop("saksi", 2700, -90)
	_enemy(RIFLE, 2900, -90)
	_coin_line(2650, 6, 70, -150)
	_prop("vazo", 3010, -90)
	_secret_han(3350)

	# --- 4. Pazar meydanı: kapılar kapanır, 3 dalga ----------------------------
	_checkpoint(3780, 0)
	_terrain(3700, 5300, 0)
	_story(3810, _sahne_pazar_pususu)
	# Pazar tezgâhları (süs): meydan gerçekten pazar gibi okunsun.
	_stall(4020)
	_stall(4560)
	_pickup(BAT, 3960, -45)
	_prop("varil", 4180)
	_prop("vazo", 4300)
	_prop("vazo", 4480)
	_prop("kasa", 4620)
	_prop("saksi", 4760)
	_scaffold(4400, -150, 220)
	_coin_line(4320, 4, 55, -200)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(4350, 0)
	arena.gate_left_x = 3880
	arena.gate_right_x = 4900
	arena.floor_y = 0
	arena.wave1 = _wave(STREET, STREET, KNIFE)
	arena.wave2 = _wave(KNIFE, BRUISER)
	arena.wave3 = _wave(ASSASSIN, STREET, KNIFE)
	arena.reward = HEALTH
	add_child(arena)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(5080, 0)
	shop.title = "BALAT BÜFESİ"
	shop.items = PackedStringArray(["can", "sopa", "zirh"])
	shop.accent = Color("e7a449")
	shop.facade_texture = BUFE
	add_child(shop)

	# --- 5. İnşaat iskelesi + vinç paleti --------------------------------------
	_checkpoint(5260, 0)
	_terrain(5300, 8900, 0)
	# İskele katları binanın önünde üst üste: her biri bir zıplama (110 px).
	_scaffold(5560, -110, 150)
	_scaffold(5560, -220, 150)
	_scaffold(5560, -330, 150)
	_scaffold(5380, -260, 130)
	_coin_line(5345, 3, 35, -310)
	for k in 3:
		_pickup(COIN, 5560, -160.0 - k * 110.0)
	_building(5640, 6300, -420)
	_enemy(KNIFE, 5900, -420)
	_enemy(RIFLE, 6220, -420)
	_prop("saksi", 5760, -420)
	_prop("vazo", 6060, -420)
	_coin_line(5700, 6, 70, -470)
	_moving(6390, -410, Vector2(220, 0), 150)
	_coin_line(6420, 3, 70, -470)
	# Paletten düşen sokağa iner; karşı binanın önündeki iskeleyle yeniden çıkar.
	_scaffold(6620, -110, 150)
	_scaffold(6620, -220, 150)
	_scaffold(6620, -310, 150)
	_building(6700, 7000, -380)
	_pickup(ARMOR, 6900, -425)

	# --- 6. Han kapısı: son kavga + çıkış --------------------------------------
	_checkpoint(7150, 0)
	_prop("vazo", 7260)
	_prop("saksi", 7330)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(7850, 0)
	final.gate_left_x = 7420
	final.gate_right_x = 8300
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN)
	final.wave2 = _wave(STREET, KNIFE, BRUISER)
	final.wave3 = _wave(ELITE)
	final.reward = HEALTH
	add_child(final)
	_story(8360, _sahne_han_kapisi)
	_coin_line(8420, 3, 50, -50)
	_han_gate(8650)
	_goal(8650, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

func _story(x: float, fn: Callable, end_x := NAN) -> void:
	var cs := Cutscene.new()
	cs.trigger_x = x
	cs.script_fn = fn
	cs.player_end_x = end_x
	add_child(cs)


## Açılış (uzun, ESC ile geçilir): Balat'ta yürüyüş ve sohbet -> Gazelle'in limanda
## çektiği fotoğraflar (kartal başı işareti) -> gözcü telsizle haber verir -> minibüs
## gelir, Redmount araya girer, arkadan sopayla yere serilir -> Gazelle debelenerek
## minibüse sürüklenir, "Kuzey Hanı" diye bağırır -> Redmount kalkar, yemin eder.
func _sahne_kacirma(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(-40, 0))
	cs.actor("gz", "gazelle", Vector2(30, 0))
	await cs.pan(Vector2(330, -170), 0.01)
	# Yürüyüş: konuşurken birlikte ilerlerler.
	cs.move("rm", 150, 3.2, "walk", false)
	cs.move("gz", 220, 3.2, "walk", false)
	await cs.say("gz", "GAZELLE", "Balat'ın en güzel simidi şu köşede. Söz verdin: bugün iş yok!")
	await cs.say("rm", "REDMOUNT", "Söz. Telefon cebimde, kapalı... neredeyse.")
	cs.face("gz", -1)
	await cs.say("gz", "GAZELLE", "Neredeyse mi? Redmount!")
	await cs.say("rm", "REDMOUNT", "Tamam, tamam. Kapattım. Bak, kapalı.")
	cs.move("rm", 260, 1.6, "walk", false)
	await cs.move("gz", 330, 1.6, "walk")
	cs.face("gz", -1)
	await cs.say("gz", "GAZELLE", "Aslında... sana bir şey göstermem lazım. Dün gece Haliç'te fotoğraf çekiyordum.")
	await cs.say("gz", "GAZELLE", "Gece yarısı, mühürsüz kamyonlar. Hepsinin kasasında aynı işaret vardı: bir kartal başı.")
	await cs.say("rm", "REDMOUNT", "Kartal başı... Karahanlı'nın işareti. Gazelle, o adamın işine burnunu sokma.")
	await cs.say("gz", "GAZELLE", "Gazeteye vermeden önce sana göstermek istedim. Filmler çantamda.")
	await cs.say("rm", "REDMOUNT", "Akşam beraber bakarız. Şimdi simit. Söz söz.")
	# Gözcü: köşede biri telsizle konuşur.
	cs.actor("gozcu", "knife", Vector2(930, 0), -1)
	await cs.pan(Vector2(620, -170), 0.7)
	await cs.say("gozcu", "GÖZCÜ", "(telsize) Kız burada, yanında bir adam var. Gönderin.", 2.6)
	cs.move("gozcu", 1300, 0.8, "walk", false)
	await cs.pan(Vector2(400, -170), 0.6)
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "...Redmount, biri bizi izliyordu sanki.")
	# Minibüs fren yaparak gelir.
	cs.actor("bus", "bus", Vector2(1500, 0), -1)
	Sfx.play(&"dash", 0.6)
	await cs.move("bus", 640, 1.0)
	cs.dust(560, 14)
	cs.shake(5.0)
	Sfx.play(&"land", 0.5)
	await cs.wait(0.3)
	cs.actor("t1", "thug", Vector2(560, 0), -1)
	await cs.wait(0.2)
	cs.actor("t2", "thug", Vector2(620, 0), -1)
	await cs.wait(0.2)
	cs.actor("t3", "thug", Vector2(680, 0), -1)
	# Redmount Gazelle'in önüne geçer.
	cs.move("gz", 230, 0.4, "walk", false)
	cs.face("gz", 1)
	await cs.move("rm", 360, 0.4, "run")
	cs.move("t1", 440, 0.6, "walk", false)
	await cs.move("t2", 500, 0.6, "walk")
	await cs.say("t1", "KABADAYI", "Karahanlı Bey fotoğrafları istiyor. Bir de fotoğrafçıyı.")
	await cs.say("rm", "REDMOUNT", "Bir adım daha atarsan dişlerini Haliç'ten toplarsın.")
	await cs.say("t1", "KABADAYI", "Hep böyle konuşurlar. Sonra da yere bakarlar.")
	# Kısa kavga: Redmount birini yere serer...
	await cs.move("rm", 400, 0.15, "run")
	await cs.strike("rm", "combo_b")
	cs.knock_down("t1", 520)
	cs.pose("rm", "fight")
	await cs.wait(0.4)
	# ...ama üçüncüsü arkadan dolaşıp sopayı indirir.
	await cs.move("t3", 330, 0.7, "walk")
	cs.face("t3", 1)
	await cs.say("gz", "GAZELLE", "Redmount, ARKANDA!", 1.0)
	await cs.strike("t3", "attack")
	cs.shake(9.0)
	await cs.knock_down("rm", 470)
	# Gazelle'i yakalayıp minibüse sürüklerler.
	await cs.move("t2", 260, 0.5, "walk")
	cs.pose("gz", "flinch")
	await cs.say("gz", "GAZELLE", "Bırak beni! REDMOUNT!", 1.2)
	cs.move("t2", 580, 1.6, "walk", false)
	await cs.struggle("gz", 600, 4)
	await cs.say("gz", "GAZELLE", "Fotoğraflar... KUZEY HANI! Kuzey Hanı'nda—", 1.8)
	cs.remove("gz")
	cs.remove("t2")
	await cs.get_up("t1", 0.4)
	await cs.say("t1", "KABADAYI", "Bu da sana Karahanlı'nın selamı olsun.", 1.6)
	cs.move("t1", 620, 0.5, "run", false)
	await cs.move("t3", 620, 0.5, "run")
	cs.remove("t1")
	cs.remove("t3")
	Sfx.play(&"dash", 0.5)
	cs.dust(640, 16)
	await cs.move("bus", 1800, 1.4)
	cs.remove("bus")
	await cs.wait(0.5)
	await cs.get_up("rm", 0.7)
	cs.face("rm", 1)
	await cs.say("rm", "REDMOUNT", "GAZELLE!", 1.0)
	await cs.say("rm", "REDMOUNT", "Kuzey Hanı... Minibüs yokuşa saptı. Çatılardan kestirirsem yetişirim.")
	await cs.say("rm", "REDMOUNT", "Dayan. Seni geri alacağım, Karahanlı'nın elinden de, bu şehrin elinden de.")


## Çatıda: aşağıdaki sokaktan minibüs geçer, Gazelle pencereden bağırır.
func _sahne_catidan_minibus(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	await cs.pan(Vector2(p.x + 520, -260), 0.6)
	cs.actor("bus", "bus", Vector2(p.x + 100, 0), 1)
	cs.move("bus", p.x + 1500, 2.6, "", false)
	await cs.wait(0.5)
	await cs.say("bus", "GAZELLE", "REDMOUNT! Pazar meydanına götürüyorlar!", 1.8)
	await cs.pan(Vector2(p.x + 120, -260), 0.5)
	await cs.say("rm", "REDMOUNT", "Duydum seni! Pazar meydanı... geliyorum.")


## Pazar meydanı girişi: pusu. Adam lafı uzatır, kapılar kapanır.
func _sahne_pazar_pususu(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("t1", "knife", Vector2(4250, 0), -1)
	await cs.pan(Vector2(4080, -170), 0.6)
	await cs.say("t1", "KARAHANLI'NIN ADAMI", "Minibüs çoktan geçti, kahraman. Senin yolun bu meydanda bitiyor.")
	await cs.say("rm", "REDMOUNT", "Gazelle'i nereye götürdünüz?")
	await cs.say("t1", "KARAHANLI'NIN ADAMI", "Han kapısına kadar sağ çıkarsan görürsün. Çocuklar!")
	await cs.move("t1", 4700, 0.6, "walk")
	cs.remove("t1")


## Han kapısı: Karahanlı Gazelle'i hanın içine götürür. Sonraki bölümün kapısı.
func _sahne_han_kapisi(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("kh", "karahanli", Vector2(8740, 0), -1)
	cs.actor("gz", "gazelle", Vector2(8810, 0), -1)
	cs.actor("t1", "thug", Vector2(8870, 0), -1)
	cs.pose("gz", "bound_idle")
	await cs.pan(Vector2(8600, -180), 0.7)
	await cs.say("kh", "KARAHANLI", "Redmount... Balat'ı dolaşmak yordu mu? Kız bende, oyun da bende.")
	await cs.say("gz", "GAZELLE", "Redmount, gelme! Tuzak bu!")
	await cs.say("rm", "REDMOUNT", "Karahanlı! Onu bırak!")
	await cs.say("kh", "KARAHANLI", "Kuzey Hanı'nda görüşürüz. Tabii oraya kadar yaşarsan.")
	cs.face("kh", 1)
	cs.move("kh", 8660, 0.5, "walk", false)
	cs.move("t1", 8700, 0.6, "walk", false)
	await cs.move("gz", 8680, 0.6, "flinch")
	cs.fade_out("kh", 0.4)
	cs.fade_out("t1", 0.4)
	await cs.fade_out("gz", 0.5)
	await cs.say("rm", "REDMOUNT", "Kuzey Hanı... Dayan Gazelle. Geliyorum.")


# --- Yapı taşları -------------------------------------------------------------

## Katı zemin: üstte kaldırım taşı şeridi, altta koyu taş dolgu.
func _terrain(x0: float, x1: float, top: float) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var w := x1 - x0
	var h := 520.0
	body.position = Vector2(x0 + w * 0.5, top + h * 0.5)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(w, h)
	col.shape = shape
	body.add_child(col)
	body.add_child(_Art.new(_Art.A_TERRAIN, Vector2(w, h)))
	add_child(body)


## Ev: sanat oranı korunur, çatı saçağı yürünür. Sağ kenarı döndürür.
func _house(left: float, top: float, idx: int) -> float:
	var tex: Texture2D = HOUSES[idx]
	var eave: float = HOUSE_EAVE[idx]
	var body_h := -top
	var full_h := body_h / (1.0 - eave) if eave > 0.0 else body_h
	var w := roundf(full_h * tex.get_width() / tex.get_height())
	var body := _solid_box(left, top, w, body_h)
	var art := _Art.new(_Art.A_HOUSE, Vector2(w, body_h))
	art.tex = tex
	art.eave = eave
	body.add_child(art)
	return left + w


## İnşaat hâlindeki han: taş duvar gövde, kiremit başlık, önünde iskele dikmeleri.
func _building(x0: float, x1: float, top: float) -> void:
	var body := _solid_box(x0, top, x1 - x0, -top)
	body.add_child(_Art.new(_Art.A_BUILDING, Vector2(x1 - x0, -top)))


func _solid_box(left: float, top: float, w: float, h: float) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = Vector2(left + w * 0.5, top + h * 0.5)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(w, h)
	col.shape = shape
	body.add_child(col)
	add_child(body)
	return body


## Sandık yığını: `cols` sütun, `rows` sıra (90 px kare).
func _crates(left: float, cols: int, rows: int) -> void:
	var body := _solid_box(left, -90.0 * rows, 90.0 * cols, 90.0 * rows)
	body.add_child(_Art.new(_Art.A_CRATES, Vector2(90.0 * cols, 90.0 * rows)))


## Tek yön ahşap iskele katı (alttan geçilir, üstüne inilir).
func _scaffold(cx: float, y: float, w: float) -> void:
	_oneway_art(cx, y, w, _Art.A_SCAFFOLD)


func _balcony(cx: float, y: float, w: float) -> void:
	_oneway_art(cx, y, w, _Art.A_BALCONY)


func _oneway_art(cx: float, y: float, w: float, kind: int) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 128
	body.collision_mask = 0
	body.position = Vector2(cx, y)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(w, 12.0)
	col.shape = shape
	col.position = Vector2(0, 6.0)
	col.one_way_collision = true
	body.add_child(col)
	var art := _Art.new(kind, Vector2(w, -y))
	body.add_child(art)
	add_child(body)


## Çarpışmasız süs (zemine oturur). `scale_f` sanat ölçeği, `z` çizim sırası.
func _deco(tex: Texture2D, cx: float, ground: float, scale_f: float, behind := true, z := -6) -> void:
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2(scale_f, scale_f)
	s.centered = true
	s.position = Vector2(cx, ground - tex.get_height() * scale_f * 0.5)
	s.z_index = z if behind else 2
	add_child(s)


## Pazar tezgâhı (süs, çarpışmasız): iki direk, çizgili tente, altında sandıklar.
func _stall(cx: float) -> void:
	var art := _Art.new(_Art.A_STALL, Vector2(220, 170))
	art.position = Vector2(cx, -85)
	art.z_index = -7
	add_child(art)


## Gizli oda: hanın kapısı kırılabilir duvar. İçeri girince ön cephe şeffaflaşır;
## içeride Osmanlı sandığı (zırh + coin). Yol, sandık basamağıyla hanın damından geçer.
func _secret_han(left: float) -> void:
	var w := 300.0
	var roof_top := -200.0
	# Sandık basamakları (90 -> 180) hanın damına (200) dayanır: arada yarık yok.
	_crates(left - 180.0, 1, 1)
	_crates(left - 90.0, 1, 2)
	# Dam (yürünür) ve sağ duvar.
	var roof := _solid_box(left, roof_top, w, 30.0)
	roof.add_child(_Art.new(_Art.A_ROOF, Vector2(w, 30.0)))
	var back := _solid_box(left + w - 20.0, roof_top + 30.0, 20.0, -roof_top - 30.0)
	back.add_child(_Art.new(_Art.A_WALL_STRIP, Vector2(20.0, -roof_top - 30.0)))
	var door := BREAKABLE_WALL.instantiate()
	door.position = Vector2(left + 20.0, 0)
	add_child(door)
	# İç mekân: karanlık oda + sandık + coin.
	var inside := _Art.new(_Art.A_ROOM, Vector2(w - 40.0, -roof_top - 30.0))
	inside.position = Vector2(left + w * 0.5, (roof_top + 30.0) * 0.5)
	inside.z_index = -8
	add_child(inside)
	_prop("sandik", left + 180.0, 0, ARMOR)
	_coin_line(left + 80.0, 4, 45, -60)
	# Ön cephe: oyuncu odaya girince kaybolur.
	var facade := _Facade.new()
	facade.rect = Rect2(left + 40.0, roof_top + 30.0, w - 60.0, -roof_top - 30.0)
	add_child(facade)
	_coin_line(left + 40.0, 4, 70, roof_top - 50.0)


## Bitiş: hanın kemerli kapısı (süs).
func _han_gate(cx: float) -> void:
	var art := _Art.new(_Art.A_GATE, Vector2(260, 300))
	art.position = Vector2(cx, -150)
	art.z_index = -7
	add_child(art)


## Arka sıra evler: karartılmış, yavaş kayan orta katman (derinlik hissi).
func _back_row() -> void:
	var row := _BackRow.new()
	add_child(row)


func _ready() -> void:
	super._ready()
	set_process(true)


func _process(_delta: float) -> void:
	if _cam == null:
		_cam = get_viewport().get_camera_2d()
		if _cam != null:
			_cam.set("_base_zoom", Vector2(ZOOM, ZOOM))


func _exit_tree() -> void:
	if _cam != null and is_instance_valid(_cam):
		_cam.set("_base_zoom", Vector2.ONE)


## Level'in biome arka planı yerine kendi gökyüzü katmanımız var.
func _spawn_backdrop() -> void:
	pass


# --- Çizim sınıfları ------------------------------------------------------------

class _Art extends Node2D:
	enum { A_TERRAIN, A_HOUSE, A_BUILDING, A_CRATES, A_SCAFFOLD, A_BALCONY, A_ROOF, A_WALL_STRIP, A_ROOM, A_GATE, A_STALL }
	var kind: int
	var size: Vector2
	var tex: Texture2D
	var eave := 0.0

	func _init(k: int, s: Vector2) -> void:
		kind = k
		size = s
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		z_index = -1

	func _draw() -> void:
		var hw := size.x * 0.5
		var hh := size.y * 0.5
		match kind:
			A_TERRAIN:
				# Üst şerit: kaldırım taşı (90 px), altı koyulaşan taş dolgu.
				var x := -hw
				while x < hw - 0.5:
					var w := minf(436.0, hw - x)
					draw_texture_rect_region(GROUND_TOP, Rect2(x, -hh, w, 90.0), Rect2(0, 0, w, 90.0))
					x += 436.0
				var y := -hh + 84.0
				var row := 0
				while y < hh - 0.5:
					var dark := clampf(0.78 - row * 0.09, 0.32, 1.0)
					x = -hw
					while x < hw - 0.5:
						var w2 := minf(420.0, hw - x)
						draw_texture_rect_region(STONE, Rect2(x, y, w2, 56.0), Rect2(0, 0, w2, 56.0),
							Color(dark, dark, dark * 1.05))
						x += 420.0
					y += 56.0
					row += 1
			A_HOUSE:
				var full_h := size.y / (1.0 - eave) if eave > 0.0 else size.y
				var roof_h := full_h - size.y
				draw_texture_rect(tex, Rect2(-hw - 6.0, -hh - roof_h, size.x + 12.0, full_h), false)
				if eave <= 0.0:
					draw_texture_rect(ROOF_SLAB, Rect2(-hw - 10.0, -hh - 22.0, size.x + 20.0, 34.0), false)
			A_BUILDING:
				# Yan yana bitişik evler (saçak hizası yürünür dam); en üstte düz kiremit sırtı.
				var count := maxi(1, int(roundf(size.x / 330.0)))
				var each := size.x / count
				for k in count:
					var idx := (k + int(size.y)) % 3
					var tex2: Texture2D = HOUSES[idx]
					var ev: float = HOUSE_EAVE[idx]
					var fh := size.y / (1.0 - ev) if ev > 0.0 else size.y
					draw_texture_rect(tex2, Rect2(-hw + k * each - 4.0, -hh - (fh - size.y), each + 8.0, fh), false)
				draw_texture_rect(ROOF_CAP, Rect2(-hw - 14.0, -hh - 22.0, size.x + 28.0, 34.0), false)
			A_CRATES:
				var side := 90.0
				var cy := hh
				var row2 := 0
				while cy > -hh + 0.5:
					var cx := -hw
					while cx < hw - 0.5:
						var tint := Color("e2d2bc") if (row2 + int((cx + hw) / side)) % 2 == 0 else Color("cbb8a0")
						draw_texture_rect_region(CRATE, Rect2(cx, cy - side, side, side), Rect2(227, 193, 893, 781), tint)
						cx += side
					cy -= side
					row2 += 1
			A_SCAFFOLD:
				# Tabla + yere inen iki dikme (size.y = yerden yükseklik).
				for lx in [-hw + 12.0, hw - 16.0]:
					draw_texture_rect(SCAFFOLD_POST, Rect2(lx - 7.0, 6.0, 16.0, size.y - 6.0), true)
				draw_texture_rect_region(SCAFFOLD_DECK, Rect2(-hw - 6.0, -8.0, size.x + 12.0, 40.0),
					Rect2(27, 149, 1929, 260))
			A_BALCONY:
				var bw := size.x + 30.0
				var bh := bw * 72.0 / 204.0
				draw_texture_rect_region(BALCONY, Rect2(-bw * 0.5, -bh * 47.0 / 72.0, bw, bh), Rect2(0, 60, 204, 72))
			A_ROOF:
				draw_texture_rect(ROOF_SLAB, Rect2(-hw - 10.0, -hh - 14.0, size.x + 20.0, 34.0), false)
				draw_rect(Rect2(-hw, -hh + 16.0, size.x, size.y - 16.0), Color("4a3a30"))
			A_WALL_STRIP:
				draw_texture_rect_region(WALL, Rect2(-hw, -hh, size.x, size.y), Rect2(0, 0, 20, 160), Color(0.8, 0.78, 0.76))
			A_ROOM:
				draw_rect(Rect2(-hw, -hh, size.x, size.y), Color("2a211d"))
				draw_texture_rect_region(WALL, Rect2(-hw, -hh, size.x, size.y), Rect2(0, 0, 80, 160), Color(0.36, 0.32, 0.3))
				# Mum ışığı
				draw_circle(Vector2(0, -hh + 50.0), 46.0, Color(1.0, 0.75, 0.35, 0.10))
				draw_circle(Vector2(0, -hh + 50.0), 22.0, Color(1.0, 0.8, 0.4, 0.16))
			A_STALL:
				for lx in [-hw + 10.0, hw - 18.0]:
					draw_texture_rect(SCAFFOLD_POST, Rect2(lx - 6.0, -hh + 20.0, 14.0, size.y - 20.0), true)
				draw_texture_rect_region(AWNING_TEX, Rect2(-hw - 14.0, -hh, size.x + 28.0, 56.0), Rect2(6, 147, 2161, 320))
				for k in 3:
					var cx2 := -hw + 22.0 + k * 62.0
					var sz := 56.0 - (k % 2) * 10.0
					draw_texture_rect_region(CRATE, Rect2(cx2, hh - sz, sz, sz), Rect2(227, 193, 893, 781), Color("d8c8b4"))
				draw_texture_rect(POTS, Rect2(hw - 46.0, hh - 64.0 - 50.0, 28.0, 50.0), false)
			A_GATE:
				# Kemerli han kapısı: taş çerçeve + koyu açıklık + kiremit başlık.
				draw_texture_rect_region(WALL, Rect2(-hw, -hh, size.x, size.y), Rect2(0, 0, 80, 160), Color(0.92, 0.88, 0.82))
				var ow := size.x * 0.5
				draw_rect(Rect2(-ow * 0.5, -hh + size.y * 0.35, ow, size.y * 0.65), Color("1d1714"))
				draw_circle(Vector2(0, -hh + size.y * 0.35), ow * 0.5, Color("1d1714"))
				draw_texture_rect(ROOF_CAP, Rect2(-hw - 16.0, -hh - 26.0, size.x + 32.0, 38.0), false)


## Gizli odanın ön cephesi: oyuncu dikdörtgenin içindeyken saydamlaşır.
class _Facade extends Node2D:
	var rect: Rect2
	var _a := 1.0
	var _player: Node2D

	func _ready() -> void:
		z_index = 3
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _process(delta: float) -> void:
		if _player == null or not is_instance_valid(_player):
			_player = get_tree().get_first_node_in_group(&"player") as Node2D
			return
		var p := _player.global_position + Vector2(0, -50)
		var target := 0.0 if rect.grow(10.0).has_point(p) else 1.0
		_a = move_toward(_a, target, delta * 4.0)
		modulate.a = _a
		queue_redraw()

	func _draw() -> void:
		draw_texture_rect_region(WALL, rect, Rect2(0, 0, 80, 160), Color(0.88, 0.84, 0.8))
		# Pencere izi: içerisi olduğunu ima eder.
		var c := rect.get_center() + Vector2(10, -20)
		draw_rect(Rect2(c - Vector2(22, 26), Vector2(44, 52)), Color("2a211d"))
		draw_rect(Rect2(c - Vector2(22, 26), Vector2(44, 52)), Color("8a6a48"), false, 3.0)


## Uzak gökyüzü: boyalı Süleymaniye sahnesi, kameranın %4'ü hızla kayar.
class _Sky extends Node2D:
	var _camera: Camera2D

	func _ready() -> void:
		z_index = -90
		z_as_relative = false
		process_mode = Node.PROCESS_MODE_ALWAYS
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _process(_delta: float) -> void:
		# Her kare güncel kamerayı izle (hikâye sahnesi kendi kamerasıyla oynar).
		_camera = get_viewport().get_camera_2d()
		if _camera == null:
			return
		global_position = _camera.get_screen_center_position()
		queue_redraw()

	func _draw() -> void:
		var half := SKY.get_size() * 0.5
		# Hücre 0 (merdivenli sokak + cami) ilk yarıda, hücre 2 (cami avlusu) sonra.
		var x := global_position.x
		var t := clampf((x - 3600.0) / 900.0, 0.0, 1.0)
		_cell(0, x, 1.0)
		if t > 0.0:
			_cell(2, x, t)
		# Alt kısım koyulaşır: oynanan zemin ve arka sıra evler öne çıkar.
		for i in 6:
			draw_rect(Rect2(-1100, 60 + i * 40, 2200, 40), Color(0.08, 0.07, 0.1, 0.12 + i * 0.08))
		draw_rect(Rect2(-1100, 300, 2200, 500), Color(0.08, 0.07, 0.1, 0.62))

	func _cell(index: int, x: float, alpha: float) -> void:
		var half := SKY.get_size() * 0.5
		var cell := Vector2(index % 2, index / 2) * half
		var src_w := half.x * 0.8
		var scroll := fposmod(x * 0.04, half.x - src_w)
		draw_texture_rect_region(SKY, Rect2(-760, -560, 1520, 860),
			Rect2(cell + Vector2(2.0 + scroll, 2.0), Vector2(src_w - 4.0, half.y * 0.86)),
			Color(0.82, 0.8, 0.86, alpha))


## Arka sıra evler: orta paralaks (kameranın %35'i), karartılmış ve mavimsi.
class _BackRow extends Node2D:
	var _camera: Camera2D

	func _ready() -> void:
		z_index = -40
		z_as_relative = false
		process_mode = Node.PROCESS_MODE_ALWAYS
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		modulate = Color(0.34, 0.36, 0.5)

	func _process(_delta: float) -> void:
		# Her kare güncel kamerayı izle (hikâye sahnesi kendi kamerasıyla oynar).
		_camera = get_viewport().get_camera_2d()
		if _camera == null:
			return
		queue_redraw()

	func _draw() -> void:
		if _camera == null:
			return
		var cx := _camera.get_screen_center_position().x
		var shift := cx * 0.35
		var seq := [0, 2, 1, 0, 1, 2, 2, 0, 1]
		var x := -600.0
		var i := 0
		while x < 9800.0:
			var idx: int = seq[i % seq.size()]
			var tex: Texture2D = HOUSES[idx]
			var h := 270.0 + float((i * 37) % 3) * 35.0
			var w := h * tex.get_width() / tex.get_height()
			var sx := x + shift
			if sx > cx - 1300.0 and sx < cx + 1300.0:
				draw_texture_rect(tex, Rect2(sx, 30.0 - h, w, h), false)
			x += w + 30.0 + float((i * 53) % 4) * 20.0
			i += 1

## DtmLevel — Dan the Man tarzı elle yerleştirilmiş bölümlerin ortak tabanı.
##
## Görsel katmanlar: uzak boyalı İstanbul (yavaş paralaks, `sky_cells`) ->
## karartılmış arka sıra evler (orta paralaks) -> mahalle setinden oynanan katı zemin,
## evler, iskeleler, tezgâhlar. Hikâye: `_story(x, sahne_fn)` ile oyun içi Cutscene.
## Bölüm betiği yalnız `_build()` yazar (zemin, düşman, parkur, sahneler).
class_name DtmLevel
extends StoryBlockout

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
const WAGON := preload("res://assets/environment/mahalle/freight_wagon.png")
## Piksel art parçalar (tools/gen_pixel_props.py; 1 sanat pikseli = 3 ekran pikseli).
const PX := 3.0
const PIX_SANDBAG := preload("res://assets/environment/pixel/kum_torbasi.png")
const PIX_CABIN := preload("res://assets/environment/pixel/kule_kulube.png")
const PIX_TOWER_LEG := preload("res://assets/environment/pixel/kule_ayak.png")
const PIX_LANTERN := preload("res://assets/environment/pixel/fener.png")
const PIX_HALO := preload("res://assets/environment/pixel/fener_hale.png")
const PIX_WATER_TOP := preload("res://assets/environment/pixel/su_yuzey.png")
const PIX_WATER := preload("res://assets/environment/pixel/su_govde.png")
const PIX_RAIL := preload("res://assets/environment/pixel/ray.png")
const PIX_CEILING := preload("res://assets/environment/pixel/tavan.png")
const PIX_BRICK := preload("res://assets/environment/pixel/tugla.png")
const PIX_WINDOW := preload("res://assets/environment/pixel/fabrika_pencere.png")
const PIX_GATE := preload("res://assets/environment/pixel/han_kapisi.png")
const PIX_BEAM := preload("res://assets/environment/pixel/huzme.png")
const NICHE := preload("res://assets/environment/kit/wall_niche.png")
## Vagon: 400 px genişlik; gövde üstü yerden 140 px (tekerlekler altta).
const WAGON_W := 400.0
const WAGON_TOP := 140.0
const HOUSES := [
	preload("res://assets/environment/mahalle/house_a.png"),
	preload("res://assets/environment/mahalle/house_b.png"),
	preload("res://assets/environment/mahalle/house_c.png"),
]
## Ev sanatlarında kiremit saçağının bittiği oran (gövde üst kenarı).
const HOUSE_EAVE := [0.2, 0.17, 0.0]
const BREAKABLE_WALL := preload("res://scenes/systems/BreakableWall.tscn")
const CRUSHER := preload("res://scenes/systems/Crusher.tscn")
const FLAME := preload("res://scenes/systems/FlameVent.tscn")


## Uzak katman: atlas + [hücre, başlangıç x] listesi; ton ve alt gölge rengi.
var sky_atlas: Texture2D = preload("res://assets/backgrounds/book02_suleymaniye_streets_atlas.png")
var sky_cells: Array = [[0, -100000.0]]
## 2: atlas 2x2 hücre; 1: tek parça resim.
var sky_grid := 2
var sky_tint := Color(0.82, 0.8, 0.86)
var sky_shade := Color(0.08, 0.07, 0.1)
var back_tint := Color(0.34, 0.36, 0.5)
var back_row_on := true
var zoom_level := 1.12

var _cam: Camera2D


func _build_chapter() -> void:
	_spawn_marker()
	# Önce içerik: bölüm sky_* / back_row_on ayarlarını _build içinde verir.
	_build()
	var sky := _Sky.new()
	sky.level = self
	add_child(sky)
	if back_row_on:
		_back_row()


## Bölüm içeriği (alt sınıf yazar).
func _build() -> void:
	pass


# --- Hikâye sahneleri ----------------------------------------------------------

func _story(x: float, fn: Callable, end_x := NAN) -> void:
	var cs := Cutscene.new()
	cs.trigger_x = x
	cs.script_fn = fn
	cs.player_end_x = end_x
	add_child(cs)


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


## Gece feneri (süs): direk + sıcak ışık halesi. `y` fenerin yüksekliği.
func _lantern(x: float, y := -170.0) -> void:
	var l := _Lantern.new()
	l.position = Vector2(x, y)
	l.pole = -y
	add_child(l)


## Gece tonu: dünya katmanını karartır (arayüz etkilenmez); fenerler parlak kalır.
func _night(tint := Color(0.6, 0.62, 0.82)) -> void:
	var cm := CanvasModulate.new()
	cm.color = tint
	add_child(cm)


## Kum torbası siperi: katı, alçak (mermiyi keser); üstünden atlanır.
func _sandbags(left: float, w: float, h := 70.0) -> void:
	var body := _solid_box(left, -h, w, h)
	body.add_child(_Art.new(_Art.A_SANDBAG, Vector2(w, h)))


## Gözetleme kulesi: dar katı gövde, tepesi yürünür (nöbetçi durur), projektörlü.
func _tower(cx: float, top: float, w := 110.0, light := true) -> void:
	var body := _solid_box(cx - w * 0.5, top, w, -top)
	body.add_child(_Art.new(_Art.A_TOWER, Vector2(w, -top)))
	if light:
		var sl := _Searchlight.new()
		sl.position = Vector2(cx, top - 40.0)
		add_child(sl)


## Yük vagonu: katı gövde, üstü yürünür. `tint` vagonları birbirinden ayırır.
func _wagon(left: float, tint := Color.WHITE) -> float:
	var body := _solid_box(left, -WAGON_TOP, WAGON_W, WAGON_TOP)
	var art := _Art.new(_Art.A_WAGON, Vector2(WAGON_W, WAGON_TOP))
	art.modulate = tint
	body.add_child(art)
	return left + WAGON_W


## Ray hattı (süs): zemine gömülü traversler ve iki ray.
func _rails(x0: float, x1: float) -> void:
	var r := _Art.new(_Art.A_RAILS, Vector2(x1 - x0, 16.0))
	r.position = Vector2((x0 + x1) * 0.5, 2.0)
	r.z_index = -2
	add_child(r)


## Fabrika binası: katı tuğla gövde, üstü yürünür (metal korniş).
func _factory(x0: float, x1: float, top: float) -> void:
	var body := _solid_box(x0, top, x1 - x0, -top)
	body.add_child(_Art.new(_Art.A_FACTORY, Vector2(x1 - x0, -top)))


## Pres: tavandan periyodik inen ezici (alt kenarı inince zemine değer).
func _press(cx: float, phase := 0.0, period := 2.8, ground := 0.0) -> void:
	var c := CRUSHER.instantiate()
	c.set("width", 100.0)
	c.set("thickness", 60.0)
	c.set("drop_height", 165.0)
	c.set("period", period)
	c.set("phase_offset", phase)
	c.position = Vector2(cx, ground - 165.0 - 30.0)
	add_child(c)


## Alev bacası: zeminden periyodik fışkıran alev (uyarı titremesiyle).
func _flame(cx: float, phase := 0.0, ground := 0.0) -> void:
	var f := FLAME.instantiate()
	f.set("phase_offset", phase)
	f.position = Vector2(cx, ground)
	add_child(f)


## Kaya tavan (süs): yeraltı bölümlerinde ekranın üstünü kapatan sarkıtlı şerit.
func _ceiling(x0: float, x1: float, bottom: float) -> void:
	var c := _Art.new(_Art.A_CEILING, Vector2(x1 - x0, 500.0))
	c.position = Vector2((x0 + x1) * 0.5, bottom - 250.0)
	c.z_index = 5
	add_child(c)


## Çürük tahta: basınca yarım saniyede çöker, sonra yerine döner. `top` yürüme yüzeyi.
func _collapse(cx: float, top: float, w := 140.0) -> void:
	var plank := CollapsingPlatform.new()
	plank.width = w
	plank.position = Vector2(cx, top + 10.0)
	add_child(plank)
	# Alttan geçilebilir (tek yön): sudan/çukurdan çıkarken kafa tahtaya çarpmasın.
	var pcol: CollisionShape2D = plank.get("_col")
	pcol.one_way_collision = true
	var vis: Polygon2D = plank.get("_vis")
	vis.color = Color(0, 0, 0, 0)
	for ch in vis.get_children():
		if ch is Line2D:
			ch.visible = false
	var art := _Art.new(_Art.A_PLANK, Vector2(w, 0))
	art.position = Vector2(0, -10.0)
	vis.add_child(art)


## Sığ kanal: zemin `depth` px aşağıda, su yüzeyi oyuncunun bacaklarının önünde
## (içinden yürünür, ölümcül değil). Çıkış için uçlara alçak taş basamak konur.
func _canal(x0: float, x1: float, depth: float) -> void:
	_terrain(x0, x1, depth)
	var water := _Art.new(_Art.A_WATER, Vector2(x1 - x0, depth + 30.0))
	water.position = Vector2((x0 + x1) * 0.5, (depth - 30.0) * 0.5 + 30.0)
	water.z_index = 4
	add_child(water)


## Tebeşir işareti (süs): Gazelle'in bıraktığı iz ya da sokak yazısı.
func _chalk(x: float, y: float, text: String) -> void:
	var c := _Chalk.new()
	c.text = text
	c.position = Vector2(x, y)
	add_child(c)


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


## Bitiş: hanın kemerli kapısı (süs); `title` tabelaya yazılır.
func _han_gate(cx: float, title := "") -> void:
	var art := _Art.new(_Art.A_GATE, Vector2(260, 300))
	art.position = Vector2(cx, -150)
	art.z_index = -7
	add_child(art)
	if title != "":
		var sign := _Sign.new()
		sign.text = title
		sign.position = Vector2(cx, -340)
		add_child(sign)


## Arka sıra evler: karartılmış, yavaş kayan orta katman (derinlik hissi).
func _back_row() -> void:
	var row := _BackRow.new()
	row.level = self
	add_child(row)


func _ready() -> void:
	super._ready()
	set_process(true)


func _process(_delta: float) -> void:
	if _cam == null:
		_cam = get_viewport().get_camera_2d()
		if _cam != null:
			_cam.set("_base_zoom", Vector2(zoom_level, zoom_level))


func _exit_tree() -> void:
	if _cam != null and is_instance_valid(_cam):
		_cam.set("_base_zoom", Vector2.ONE)


## Level'in biome arka planı yerine kendi gökyüzü katmanımız var.
func _spawn_backdrop() -> void:
	pass


# --- Çizim sınıfları ------------------------------------------------------------

class _Art extends Node2D:
	enum { A_TERRAIN, A_HOUSE, A_BUILDING, A_CRATES, A_SCAFFOLD, A_BALCONY, A_ROOF, A_WALL_STRIP, A_ROOM, A_GATE, A_STALL, A_WATER, A_SANDBAG, A_TOWER, A_WAGON, A_RAILS, A_FACTORY, A_PRESS_FRAME, A_CEILING, A_PLANK }
	var kind: int
	var size: Vector2
	var tex: Texture2D
	var eave := 0.0

	func _init(k: int, s: Vector2) -> void:
		kind = k
		size = s
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		z_index = -1

	var _t := 0.0

	func _process(delta: float) -> void:
		# Yalnız su animasyonlu (3 kare dalga).
		_t += delta
		queue_redraw()

	func _ready() -> void:
		set_process(kind == A_WATER)

	## Piksel dokuyu PX ölçekte döşer; kenarda yarım kalan döşeme tam pikselden kırpılır.
	func _tiled(t: Texture2D, r: Rect2, tint := Color.WHITE, src := Rect2()) -> void:
		var region := src if src.size.x > 0.0 else Rect2(Vector2.ZERO, t.get_size())
		var tw := region.size.x * PX
		var th := region.size.y * PX
		var y := r.position.y
		while y < r.end.y - 0.5:
			var h := minf(th, r.end.y - y)
			var x := r.position.x
			while x < r.end.x - 0.5:
				var w := minf(tw, r.end.x - x)
				draw_texture_rect_region(t, Rect2(x, y, w, h),
					Rect2(region.position, Vector2(floorf(w / PX), floorf(h / PX))), tint)
				x += tw
			y += th

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
				draw_texture_rect_region(WALL, Rect2(-hw, -hh + 16.0, size.x, size.y - 16.0), Rect2(0, 0, 80, 40), Color(0.5, 0.44, 0.4))
			A_WALL_STRIP:
				draw_texture_rect_region(WALL, Rect2(-hw, -hh, size.x, size.y), Rect2(0, 0, 20, 160), Color(0.8, 0.78, 0.76))
			A_ROOM:
				# Karanlık oda duvarı + mumlu duvar nişi (kit sanatı).
				draw_texture_rect_region(WALL, Rect2(-hw, -hh, size.x, size.y), Rect2(0, 0, 80, 160), Color(0.36, 0.32, 0.3))
				var nw := 121.0 * 0.9
				draw_texture_rect(NICHE, Rect2(-nw * 0.5, -hh + 6.0, nw, minf(232.0 * 0.9, size.y - 6.0)), false)
			A_SANDBAG:
				# Piksel art kum torbaları (32x24 döşeme), altta hizalı.
				_tiled(PIX_SANDBAG, Rect2(-hw, -hh, size.x, size.y))
			A_TOWER:
				# Piksel art kule: çelik kafes ayak (döşenir) + tepede ahşap kulübe.
				var cab := PIX_CABIN.get_size() * PX
				_tiled(PIX_TOWER_LEG, Rect2(-PIX_TOWER_LEG.get_width() * PX * 0.5, -hh + cab.y - 12.0, PIX_TOWER_LEG.get_width() * PX, size.y - cab.y + 12.0))
				draw_texture_rect(PIX_CABIN, Rect2(-cab.x * 0.5, -hh - 12.0, cab.x, cab.y), false)
			A_WAGON:
				# Sanatın gövde üstü (satır 80/793) katı kutunun üstüne oturur.
				var art_h := size.x * 793.0 / 1983.0
				var top := -hh - art_h * 80.0 / 793.0
				draw_texture_rect(WAGON, Rect2(-hw, top, size.x, art_h), false)
			A_RAILS:
				_tiled(PIX_RAIL, Rect2(-hw, -6.0, size.x, PIX_RAIL.get_height() * PX))
			A_FACTORY:
				# Piksel art tuğla + kemerli yanan pencereler + çelik korniş.
				_tiled(PIX_BRICK, Rect2(-hw, -hh, size.x, size.y))
				var ws := PIX_WINDOW.get_size() * PX
				var wy := -hh + 30.0
				while wy < hh - ws.y - 20.0:
					var wx := -hw + 24.0
					while wx < hw - ws.x - 12.0:
						draw_texture_rect(PIX_WINDOW, Rect2(wx, wy, ws.x, ws.y), false)
						wx += ws.x + 36.0
					wy += ws.y + 48.0
				_tiled(PIX_RAIL, Rect2(-hw - 6.0, -hh - 9.0, size.x + 12.0, 6.0), Color(0.8, 0.82, 0.9), Rect2(0, 0, 16, 2))
			A_PRESS_FRAME:
				pass
			A_CEILING:
				# Piksel art kaya: üst kısım taş dolgu, en altta sarkıtlı şerit.
				var strip_h := PIX_CEILING.get_height() * PX
				_tiled(PIX_CEILING, Rect2(-hw, -hh, size.x, size.y - strip_h), Color.WHITE, Rect2(0, 0, 48, 20))
				_tiled(PIX_CEILING, Rect2(-hw, hh - strip_h, size.x, strip_h))
			A_PLANK:
				# Çatlak ahşap tahta (dikmesiz); koyu ton çürüklüğü anlatır.
				draw_texture_rect_region(SCAFFOLD_DECK, Rect2(-hw - 4.0, -8.0, size.x + 8.0, 34.0),
					Rect2(27, 149, 1929, 260), Color(0.78, 0.66, 0.56))
			A_WATER:
				# Piksel art su: 3 karelik dalgalı yüzey + dither gövde.
				var fr := int(_t * 5.0) % 3
				var top_h := PIX_WATER_TOP.get_height() * PX
				_tiled(PIX_WATER_TOP, Rect2(-hw, -hh + 26.0, size.x, top_h), Color(1, 1, 1, 0.9), Rect2(fr * 32, 0, 32, 12))
				_tiled(PIX_WATER, Rect2(-hw, -hh + 26.0 + top_h, size.x, size.y - 26.0 - top_h), Color(1, 1, 1, 0.82))
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
				# Piksel art kemerli han kapısı (86x100 sanat, 3x).
				draw_texture_rect(PIX_GATE, Rect2(-hw, -hh, size.x, size.y), false)


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
		# Pencere izi: içerisi olduğunu ima eder (piksel art pencere, ışıksız).
		var ws := PIX_WINDOW.get_size() * PX
		draw_texture_rect(PIX_WINDOW, Rect2(rect.get_center() - ws * 0.5 + Vector2(10, -20), ws), false, Color(0.45, 0.4, 0.42))


## Uzak gökyüzü: boyalı Süleymaniye sahnesi, kameranın %4'ü hızla kayar.
## Uzak gökyüzü: boyalı İstanbul atlası, kameranın %4'ü hızla kayar. Bölüm
## `sky_cells` ile hangi hücrenin hangi x'ten sonra görüneceğini verir (çapraz geçiş).
class _Sky extends Node2D:
	var level: Node
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
		var atlas: Texture2D = level.sky_atlas
		var cells: Array = level.sky_cells
		var x := global_position.x
		var cur := 0
		for k in cells.size():
			if x >= float(cells[k][1]):
				cur = k
		_cell(atlas, int(cells[cur][0]), x, 1.0)
		if cur + 1 < cells.size():
			var t := clampf((x - float(cells[cur + 1][1]) + 900.0) / 900.0, 0.0, 1.0)
			if t > 0.0:
				_cell(atlas, int(cells[cur + 1][0]), x, t)
		var dark: Color = level.sky_shade
		# Alt kısım koyulaşır: oynanan zemin ve arka sıra evler öne çıkar.
		for i in 6:
			draw_rect(Rect2(-1100, 60 + i * 40, 2200, 40), Color(dark.r, dark.g, dark.b, 0.12 + i * 0.08))
		draw_rect(Rect2(-1100, 300, 2200, 500), Color(dark.r, dark.g, dark.b, 0.62))

	func _cell(atlas: Texture2D, index: int, x: float, alpha: float) -> void:
		var half := atlas.get_size() / float(level.sky_grid)
		var cell := Vector2(index % 2, index / 2) * half
		var src_w := half.x * 0.8
		var scroll := fposmod(x * 0.04, half.x - src_w)
		var tint: Color = level.sky_tint
		draw_texture_rect_region(atlas, Rect2(-760, -560, 1520, 860),
			Rect2(cell + Vector2(2.0 + scroll, 2.0), Vector2(src_w - 4.0, half.y * 0.86)),
			Color(tint.r, tint.g, tint.b, alpha))


## Arka sıra evler: orta paralaks (kameranın %35'i), karartılmış ve mavimsi.
class _BackRow extends Node2D:
	var level: Node
	var _camera: Camera2D

	func _ready() -> void:
		z_index = -40
		z_as_relative = false
		process_mode = Node.PROCESS_MODE_ALWAYS
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		modulate = level.back_tint

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
		while x < float(level.camera_limit_right) + 1200.0:
			var idx: int = seq[i % seq.size()]
			var tex: Texture2D = HOUSES[idx]
			var h := 270.0 + float((i * 37) % 3) * 35.0
			var w := h * tex.get_width() / tex.get_height()
			var sx := x + shift
			if sx > cx - 1300.0 and sx < cx + 1300.0:
				draw_texture_rect(tex, Rect2(sx, 30.0 - h, w, h), false)
			x += w + 30.0 + float((i * 53) % 4) * 20.0
			i += 1


## Tabela: piksel yazılı ahşap levha.
class _Sign extends Node2D:
	var text := ""

	func _ready() -> void:
		z_index = -6
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _draw() -> void:
		PixelText.sign_board(self, Vector2.ZERO, text, Color("e7a449"), 3.0, false)


## Tebeşir yazısı: duvara çizilmiş beyazımsı piksel harfler.
class _Chalk extends Node2D:
	var text := ""

	func _ready() -> void:
		z_index = -5
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _draw() -> void:
		PixelText.draw_centered(self, 0.0, 0.0, text, 3.0, Color(0.95, 0.95, 0.9, 0.9), Color(0.2, 0.2, 0.25, 0.6))


## Fener: piksel art direk + cam fener; eklemeli karışımlı dither hale.
class _Lantern extends Node2D:
	var pole := 170.0

	func _ready() -> void:
		z_index = -4
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var post := Sprite2D.new()
		post.texture = PIX_LANTERN
		post.centered = false
		post.scale = Vector2(PX, PX)
		# Fener başı (sanat y≈6) node konumunda, direğin dibi zeminde.
		post.position = Vector2(-PIX_LANTERN.get_width() * PX * 0.5, -6.0 * PX)
		post.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(post)
		var halo := _Halo.new()
		add_child(halo)

	class _Halo extends Sprite2D:
		var _t := randf() * 6.0

		func _ready() -> void:
			texture = PIX_HALO
			scale = Vector2(PX, PX)
			texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var mat := CanvasItemMaterial.new()
			mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			material = mat

		func _process(delta: float) -> void:
			_t += delta
			modulate.a = 0.75 + 0.25 * sin(_t * 3.0)


## Projektör: kule tepesinden yavaşça süpüren piksel art (dither) ışık huzmesi.
class _Searchlight extends Sprite2D:
	var _t := randf() * 6.0

	func _ready() -> void:
		z_index = -5
		process_mode = Node.PROCESS_MODE_ALWAYS
		texture = PIX_BEAM
		centered = false
		offset = Vector2(-PIX_BEAM.get_width() * 0.5, 0)
		scale = Vector2(PX, PX)
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = mat

	func _process(delta: float) -> void:
		_t += delta
		rotation = sin(_t * 0.6) * 0.75

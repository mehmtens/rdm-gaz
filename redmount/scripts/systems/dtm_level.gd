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
const HOUSES := [
	preload("res://assets/environment/mahalle/house_a.png"),
	preload("res://assets/environment/mahalle/house_b.png"),
	preload("res://assets/environment/mahalle/house_c.png"),
]
## Ev sanatlarında kiremit saçağının bittiği oran (gövde üst kenarı).
const HOUSE_EAVE := [0.2, 0.17, 0.0]
const BREAKABLE_WALL := preload("res://scenes/systems/BreakableWall.tscn")


## Uzak katman: atlas + [hücre, başlangıç x] listesi; ton ve alt gölge rengi.
var sky_atlas: Texture2D = preload("res://assets/backgrounds/book02_suleymaniye_streets_atlas.png")
var sky_cells: Array = [[0, -100000.0]]
var sky_tint := Color(0.82, 0.8, 0.86)
var sky_shade := Color(0.08, 0.07, 0.1)
var back_tint := Color(0.34, 0.36, 0.5)
var back_row_on := true
var zoom_level := 1.12

var _cam: Camera2D


func _build_chapter() -> void:
	_spawn_marker()
	var sky := _Sky.new()
	sky.level = self
	add_child(sky)
	if back_row_on:
		_back_row()
	_build()


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
	enum { A_TERRAIN, A_HOUSE, A_BUILDING, A_CRATES, A_SCAFFOLD, A_BALCONY, A_ROOF, A_WALL_STRIP, A_ROOM, A_GATE, A_STALL, A_WATER }
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
			A_WATER:
				# Bulanık kanal suyu: yarı saydam gövde + parlak yüzey çizgisi.
				draw_rect(Rect2(-hw, -hh + 30.0, size.x, size.y - 30.0), Color(0.16, 0.3, 0.38, 0.62))
				draw_rect(Rect2(-hw, -hh + 30.0, size.x, 4.0), Color(0.6, 0.82, 0.9, 0.8))
				for k in int(size.x / 70.0):
					draw_rect(Rect2(-hw + 20.0 + k * 70.0, -hh + 40.0 + (k % 3) * 9.0, 26.0, 2.0), Color(0.7, 0.9, 1.0, 0.35))
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
		var half := atlas.get_size() * 0.5
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


## Fener: ince direk, cam fener, nabız atan sıcak hale (eklemeli karışım).
class _Lantern extends Node2D:
	var pole := 170.0
	var _t := randf() * 6.0

	func _ready() -> void:
		z_index = -4
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		var glow := _Glow.new()
		glow.material = mat
		add_child(glow)

	func _draw() -> void:
		draw_rect(Rect2(-3, 0, 6, pole), Color("2b2622"))
		draw_rect(Rect2(-10, -16, 20, 22), Color("3a2d22"))
		draw_rect(Rect2(-7, -13, 14, 16), Color("ffc46b"))
		draw_rect(Rect2(-12, -20, 24, 5), Color("2b2622"))

	class _Glow extends Node2D:
		var _t := 0.0

		func _process(delta: float) -> void:
			_t += delta
			queue_redraw()

		func _draw() -> void:
			var p := 0.85 + 0.15 * sin(_t * 3.0)
			for k in 4:
				draw_circle(Vector2(0, -4), (90.0 - k * 20.0) * p, Color(1.0, 0.7, 0.35, 0.05 + k * 0.03))

## Level — bölüm tabanı. Alt sınıf `build()` içinde kit API'siyle dünyayı kurar:
## ground / ledge / platform / prop / coin_* / enemy / breakable / arena / checkpoint / secret / hint / goal.
## Koordinatlar sanat pikseli; zemin çizgisi y=0, yukarı negatif.
class_name Level
extends Node2D

const ZOOM := 0.6
const KIT := "res://art/kit/%s.png"
const VIEW_BOTTOM := 380.0 ## Kamera zemin çizgisinin altını en fazla bu kadar gösterir.

var level_end := 10000.0
var kill_y := 900.0
var start_pos := Vector2(200, 0)
var bg_path := "res://art/bg/urban_dusk.png"
var music := "street"

var back: Node2D ## Cepheler / uzak dekor (oyuncunun arkası)
var world: Node2D ## Zemin, platformlar, varlıklar
var front: Node2D ## Ön plan dekor
var fx_layer: Node2D
var player: Player
var cam: Camera2D
var hud: Hud

var totals := {"coins": 0, "secrets": 0}
var arenas: Array[Arena] = []
var finished := false

var _ids := {}
var _lock_target := Vector2(-1e9, 1e9)
var _lock := Vector2(-1e9, 1e9)
var _was_locked := false
var _shake := 0.0
var _attackers: Array = []
var _combo := 0
var _combo_t := 0.0
var _bg_layer: CanvasLayer
var _bg_sprites: Array[Sprite2D] = []
var _bg_w := 0.0


func build() -> void:
	pass ## Alt sınıf doldurur.


func _ready() -> void:
	_build_backdrop()
	back = _layer(-10)
	world = _layer(0)
	front = _layer(30)
	fx_layer = _layer(20)
	build()
	player = Player.new()
	player.level = self
	var cp = Game.run.get("checkpoint")
	player.position = cp if cp != null else start_pos
	world.add_child(player)
	cam = Camera2D.new()
	cam.zoom = Vector2(ZOOM, ZOOM)
	add_child(cam)
	cam.make_current()
	hud = Hud.new()
	hud.level = self
	add_child(hud)
	add_child(TouchControls.new())
	Music.play(music)
	snap_camera()


func _layer(z: int) -> Node2D:
	var n := Node2D.new()
	n.z_index = z
	add_child(n)
	return n


func _id(prefix: String) -> String:
	_ids[prefix] = int(_ids.get(prefix, 0)) + 1
	return "%s%d" % [prefix, _ids[prefix]]


func _taken(id: String) -> bool:
	return Game.run.get("collected", {}).has(id)


func tex(name: String) -> Texture2D:
	return load(KIT % name)


# --- Kurulum API'si ---------------------------------------------------------

## Katı zemin bloğu: taş kaldırım kapağı + koyu taş dolgu. Yükseltilmiş bloklar için de kullanılır.
func ground(x0: float, x1: float, top := 0.0, depth := 1600.0) -> void:
	var w := x1 - x0
	var body := StaticBody2D.new()
	body.collision_layer = Game.L_WORLD
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(w, depth)
	cs.shape = r
	cs.position = Vector2(x0 + w / 2, top + depth / 2)
	body.add_child(cs)
	world.add_child(body)
	if depth > 70.0:
		_tile(tex("stone_fill"), Rect2(x0, top + 60, w, depth - 60), world)
	_tile(tex("ground_long"), Rect2(x0, top - 10, w, minf(90.0, depth + 10.0)), world)
	for x in [x0, x1 - 8]:
		var edge := ColorRect.new()
		edge.color = Color(0.04, 0.03, 0.07, 0.8)
		edge.position = Vector2(x, top - 4)
		edge.size = Vector2(8, depth)
		edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		world.add_child(edge)


## Tek yönlü taş çıkıntı (alttan geçilir, ▼+ZIPLA ile inilir). x = sol kenar, y = üst yüzey.
func ledge(x: float, y: float, kind := "ledge_m") -> void:
	var t := tex(kind)
	_sprite(t, Vector2(x, y - 8), world)
	_oneway(x + 6, x + t.get_width() - 6, y)


## Üstüne basılabilen prop (minibüs, araba, çatı, iskele, bulut). surface = dokunun üstünden yüzeye mesafe.
func platform(kind: String, x: float, y: float, surface := 8.0, inset := 10.0, flip := false, parent: Node2D = null) -> Sprite2D:
	var t := tex(kind)
	var s := _sprite(t, Vector2(x, y - surface), parent if parent else world)
	s.flip_h = flip
	_oneway(x + inset, x + t.get_width() - inset, y)
	return s


## Dekor: alt-orta noktasından yerleştirilir.
func prop(kind: String, x: float, y := 0.0, layer := "back", scale := 1.0, flip := false, tint := Color.WHITE) -> Sprite2D:
	var t := tex(kind)
	var parent: Node2D = back if layer == "back" else (front if layer == "front" else world)
	var s := _sprite(t, Vector2(x - t.get_width() * scale / 2, y - t.get_height() * scale), parent)
	s.scale = Vector2(scale, scale)
	s.flip_h = flip
	s.modulate = tint
	return s


## Dükkân tabelası (bordo zemin, altın yazı) — mekân kimliği için.
func sign_board(text: String, x: float, y: float, size := 40) -> void:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.45, 0.1, 0.12)
	sb.border_color = Color(0.95, 0.8, 0.45)
	sb.set_border_width_all(5)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	p.add_theme_stylebox_override("panel", sb)
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color(1, 0.93, 0.78))
	l.add_theme_color_override("font_outline_color", Color(0.15, 0.03, 0.05))
	l.add_theme_constant_override("outline_size", 6)
	p.add_child(l)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.add_child(p)
	p.position = Vector2(x, y)
	p.reset_size()
	p.position.x -= p.size.x / 2.0


func coin(x: float, y: float) -> void:
	var id := _id("c")
	totals["coins"] += 1
	if not _taken(id):
		add_pickup("coin", Vector2(x, y), id)


func coin_row(x0: float, y: float, n: int, dx := 70.0) -> void:
	for i in n:
		coin(x0 + i * dx, y)


func coin_arc(x0: float, y: float, n: int, dx := 70.0, h := 140.0) -> void:
	for i in n:
		var t := float(i) / maxf(1.0, n - 1.0)
		coin(x0 + i * dx, y - sin(t * PI) * h)


func item(kind: String, x: float, y: float) -> void:
	var id := _id("i")
	if not _taken(id):
		add_pickup(kind, Vector2(x, y), id)


func enemy(kind: String, x: float, y := 0.0) -> void:
	var id := _id("e")
	if not _taken(id):
		add_enemy(kind, Vector2(x, y - 4), id, false)


func breakable(kind: String, x: float, y := 0.0, coins := 3, drop := "", hp := 1, solid := false, shard := Color(0.75, 0.42, 0.28)) -> void:
	var id := _id("b")
	if _taken(id):
		return
	var b := Breakable.new()
	b.tex = tex(kind)
	b.position = Vector2(x, y)
	b.coins = coins
	b.drop = drop
	b.hp = hp
	b.solid = solid
	b.id = id
	b.level = self
	b.shard_color = shard
	world.add_child(b)


func arena(x0: float, x1: float, waves: Array, floor_y := 0.0) -> void:
	var id := _id("a")
	if Game.run["cleared"].has(id):
		return
	var a := Arena.new()
	a.id = id
	a.x0 = x0
	a.x1 = x1
	a.floor_y = floor_y
	a.waves = waves
	a.level = self
	add_child(a)
	arenas.append(a)


func checkpoint(x: float, y := 0.0) -> void:
	var z := _zone("checkpoint", Rect2(x - 60, y - 300, 120, 320))
	z.position = Vector2(x, y)
	z.rect = Rect2(x - 60, y - 300, 120, 320)
	var cp = Game.run.get("checkpoint")
	z.triggered = cp != null and (cp as Vector2).is_equal_approx(z.position)


func secret(r: Rect2) -> void:
	var id := _id("s")
	totals["secrets"] += 1
	var z := _zone("secret", r)
	z.id = id
	z.triggered = Game.run["secrets"].has(id)


func hint(r_or_text, text := "") -> void:
	if r_or_text is Rect2:
		var z := _zone("hint", r_or_text)
		z.text = text
	elif hud:
		hud.show_hint(str(r_or_text))


func goal(x: float, y := 0.0) -> void:
	_zone("goal", Rect2(x, y - 400, 200, 420))


func _zone(kind: String, r: Rect2) -> Zone:
	var z := Zone.new()
	z.kind = kind
	z.rect = r
	z.level = self
	world.add_child(z)
	return z


func _tile(t: Texture2D, r: Rect2, parent: Node) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = t
	tr.stretch_mode = TextureRect.STRETCH_TILE
	tr.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	tr.position = r.position
	tr.size = r.size
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(tr)
	return tr


func _sprite(t: Texture2D, top_left: Vector2, parent: Node) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = t
	s.centered = false
	s.position = top_left
	parent.add_child(s)
	return s


func _oneway(x0: float, x1: float, y: float) -> void:
	var b := StaticBody2D.new()
	b.collision_layer = Game.L_ONEWAY
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(x1 - x0, 16)
	cs.shape = r
	cs.one_way_collision = true
	cs.position = Vector2((x0 + x1) / 2, y + 8)
	b.add_child(cs)
	world.add_child(b)


# --- Çalışma zamanı yardımcıları -------------------------------------------

func add_pickup(kind: String, pos: Vector2, id: String) -> Pickup:
	var p := Pickup.new()
	p.kind = kind
	p.id = id
	p.level = self
	p.position = pos
	world.add_child(p)
	return p


func spawn_coins(pos: Vector2, n: int) -> void:
	for i in n:
		var p := Pickup.new()
		p.kind = "coin"
		p.level = self
		p.loose = true
		p.position = pos
		p.vel = Vector2(randf_range(-320, 320), randf_range(-900, -550))
		world.call_deferred("add_child", p)


func add_enemy(kind: String, pos: Vector2, id: String, aggro: bool) -> Enemy:
	var e := Enemy.new()
	e.kind = kind
	e.level = self
	e.id = id
	e.aggro = aggro
	e.position = pos
	e.facing = -1
	world.add_child(e)
	return e


func take_token(e: Node) -> bool:
	_attackers = _attackers.filter(func(a): return is_instance_valid(a))
	if e in _attackers:
		return true
	if _attackers.size() >= 2:
		return false
	_attackers.append(e)
	return true


func release_token(e: Node) -> void:
	_attackers.erase(e)


func add_combo() -> void:
	_combo += 1
	_combo_t = 1.8
	hud.show_combo(_combo)


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func flash_screen(c: Color) -> void:
	hud.flash(c)


func banner(text: String, c := Color.WHITE, dur := 1.1) -> void:
	hud.banner(text, c, dur)


func coin_pulse() -> void:
	hud.coin_pulse()


func show_go_arrow() -> void:
	hud.go_arrow()


func lock_camera(x0: float, x1: float) -> void:
	_lock_target = Vector2(x0, x1)


func unlock_camera() -> void:
	_lock_target = Vector2(-1e9, 1e9)


# --- Döngü ------------------------------------------------------------------

func _process(dt: float) -> void:
	if not finished and player.state != Player.S.DEAD:
		Game.run["time"] = float(Game.run.get("time", 0.0)) + dt
	for a in arenas:
		a.try_start(player.position.x)
	if _combo_t > 0.0:
		_combo_t -= dt
		if _combo_t <= 0.0:
			_combo = 0
			hud.show_combo(0)
	_update_camera(dt)
	_scroll_backdrop()


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("pause") and not finished:
		hud.open_pause()


func _view_size() -> Vector2:
	return get_viewport_rect().size / ZOOM


func _cam_target() -> Vector2:
	return player.position + Vector2(player.facing * 170.0, -210.0)


func _clamp_cam(p: Vector2) -> Vector2:
	var vs := _view_size()
	var lo := maxf(0.0, _lock.x)
	var hi := minf(level_end, _lock.y)
	if hi - lo < vs.x:
		p.x = (lo + hi) / 2.0
	else:
		p.x = clampf(p.x, lo + vs.x / 2.0, hi - vs.x / 2.0)
	p.y = minf(p.y, VIEW_BOTTOM - vs.y / 2.0)
	return p


func _update_camera(dt: float) -> void:
	# Kilit sınırları mevcut görüntüden hedefe yumuşakça daralır.
	var locked := _lock_target.x > -5e8
	if locked:
		if not _was_locked:
			var vs := _view_size()
			_lock = Vector2(cam.position.x - vs.x / 2.0, cam.position.x + vs.x / 2.0)
		_lock = _lock.lerp(_lock_target, 1.0 - exp(-dt * 4.0))
	else:
		_lock = Vector2(-1e9, 1e9)
	_was_locked = locked
	var t := _clamp_cam(_cam_target())
	cam.position.x = lerpf(cam.position.x, t.x, 1.0 - exp(-dt * 7.0))
	cam.position.y = lerpf(cam.position.y, t.y, 1.0 - exp(-dt * 4.5))
	cam.position = _clamp_cam(cam.position)
	if _shake > 0.1:
		cam.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake
		_shake = lerpf(_shake, 0.0, 1.0 - exp(-dt * 14.0))
	else:
		cam.offset = Vector2.ZERO


func snap_camera() -> void:
	cam.position = _clamp_cam(_cam_target())
	cam.reset_smoothing()


# --- Arka plan (paralaks, aynalı döşeme = dikişsiz) -------------------------

func _build_backdrop() -> void:
	_bg_layer = CanvasLayer.new()
	_bg_layer.layer = -10
	add_child(_bg_layer)
	var t: Texture2D = load(bg_path)
	for i in 4:
		var s := Sprite2D.new()
		s.texture = t
		s.centered = false
		s.flip_h = i % 2 == 1
		_bg_layer.add_child(s)
		_bg_sprites.append(s)
	var shade := ColorRect.new()
	shade.color = Color(0.05, 0.03, 0.1, 0.18)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg_layer.add_child(shade)


func _scroll_backdrop() -> void:
	var vp := get_viewport_rect().size
	var t := _bg_sprites[0].texture
	var sc := vp.y / t.get_height() * 1.18
	_bg_w = t.get_width() * sc
	var span := _bg_w * 2.0
	var ox := -fposmod(cam.position.x * 0.07, span)
	var oy := clampf(-vp.y * 0.12 - cam.position.y * 0.025, -vp.y * 0.18, 0.0)
	for i in _bg_sprites.size():
		var s := _bg_sprites[i]
		s.scale = Vector2(sc, sc)
		s.position = Vector2(ox + i * _bg_w, oy)


# --- Ölüm ve bölüm sonu -----------------------------------------------------

## Haritaya yerleştirilmiş coin'lerden toplananlar (düşman/vazo düşürdükleri hariç).
func placed_coins() -> int:
	var n := 0
	for k in Game.run["collected"]:
		if String(k).begins_with("c"):
			n += 1
	return n


func on_player_died() -> void:
	shake(16.0)
	var tw := create_tween()
	tw.tween_interval(1.3)
	tw.tween_callback(hud.show_death)
	tw.tween_interval(1.6)
	tw.tween_callback(Game.respawn)


func on_goal() -> void:
	finished = true
	player.controls_enabled = false
	Music.play("victory")
	Sfx.play("goal")
	var coins := int(Game.run["coins"])
	var stars := 1
	if placed_coins() >= int(totals["coins"] * 0.8):
		stars += 1
	if Game.run["secrets"].size() >= int(totals["secrets"]):
		stars += 1
	Game.finish_level(stars, coins)
	get_tree().create_timer(0.8).timeout.connect(func(): hud.show_results(stars))

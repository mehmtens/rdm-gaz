## Cutscene — oyun motorunda oynayan hikâye sahnesi (Dan the Man tarzı).
##
## Dünya duraklar; sahne düğümü ve aktörleri PROCESS_MODE_ALWAYS ile oynar. Sinema
## şeritleri iner, kamera sahneye kayar, aktörler yürür / koşar / araçla gider,
## konuşmalar kafalarının üstünde balonla çıkar. Enter / J / dokunma: repliği
## ilerletir; ESC: sahneyi atlar. Bitince oyuncu kamerası ve kontrol geri gelir.
##
## Kullanım (bölüm betiğinde):
##     var cs := Cutscene.new()
##     cs.trigger_x = 1800.0          # oyuncu bu x'i geçince (-1: bölüm başında)
##     cs.script_fn = _sahne_kacirma  # func _sahne_kacirma(cs: Cutscene) -> void (await'li)
##     add_child(cs)
class_name Cutscene
extends Node2D

signal done

const GAZELLE_FRAMES := preload("res://resources/gazelle_frames.tres")
const REDMOUNT_FRAMES := preload("res://resources/anim/redmount_frames.tres")
const THUG_FRAMES := preload("res://resources/anim/street_thug_frames.tres")
const KNIFE_FRAMES := preload("res://resources/anim/knife_agent_frames.tres")
const KARAHANLI_FRAMES := preload("res://resources/anim/karahanli_frames.tres")
const BRUISER_FRAMES := preload("res://resources/anim/armored_bruiser_frames.tres")
const RIFLE_FRAMES := preload("res://resources/anim/rifle_guard_frames.tres")
const ELITE_FRAMES := preload("res://resources/anim/elite_guard_frames.tres")
const BUS := preload("res://assets/environment/mahalle/bus.png")
const WAGON := preload("res://assets/environment/mahalle/freight_wagon.png")

const SPEAKER_COLORS := {
	"REDMOUNT": Color(1.0, 0.72, 0.42),
	"GAZELLE": Color(0.42, 0.9, 0.82),
	"KARAHANLI": Color(1.0, 0.45, 0.4),
}

## Bir anda yalnız bir sahne oynar (Main duraklat menüsünü bu sırada açmaz).
static var active: Cutscene = null

@export var trigger_x: float = -1.0
var script_fn: Callable
## Sahne bitince oyuncunun konacağı x (NAN: yerinde kalır).
var player_end_x: float = NAN

var _started := false
var _skip := false
var _actors := {}
var _cam: Camera2D
var _prev_cam: Camera2D
var _bars: CanvasLayer
var _top: ColorRect
var _bottom: ColorRect
var _hint: Label
var _advance := false
var _player: Node2D
var _hidden: Array = []
var _ui: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 4


func _process(_delta: float) -> void:
	if _started:
		return
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group(&"player") as Node2D
		return
	# Oyuncu havadayken başlama: aktör onun yerine konur, havada asılı kalmasın.
	var grounded: bool = not (_player is CharacterBody2D) or (_player as CharacterBody2D).is_on_floor()
	if (trigger_x < 0.0 or _player.global_position.x >= trigger_x) and grounded:
		# Başka bir sahne / diyalog / büfe açıkken bekle.
		if active != null or get_tree().paused:
			return
		_started = true
		_run()


func _input(event: InputEvent) -> void:
	if active != self:
		return
	if event.is_action_pressed(&"pause"):
		_skip = true
		_advance = true
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"attack") \
			or event.is_action_pressed(&"jump") \
			or (event is InputEventScreenTouch and event.pressed):
		_advance = true
		get_viewport().set_input_as_handled()


func _run() -> void:
	active = self
	get_tree().paused = true
	_player.visible = false
	# Bölümün bekleyen düşmanları sahnede görünmesin (oyun dönünce geri gelir).
	_hidden.clear()
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		if e is CanvasItem and (e as CanvasItem).visible:
			(e as CanvasItem).visible = false
			_hidden.append(e)
	_letterbox(true)
	_prev_cam = get_viewport().get_camera_2d()
	_cam = Camera2D.new()
	_cam.process_mode = Node.PROCESS_MODE_ALWAYS
	if _prev_cam != null:
		_cam.zoom = _prev_cam.zoom
		_cam.global_position = _prev_cam.get_screen_center_position()
	add_child(_cam)
	_cam.make_current()
	if script_fn.is_valid():
		await script_fn.call(self)
	await _finish()


func _finish() -> void:
	_letterbox(false)
	if not is_nan(player_end_x) and is_instance_valid(_player):
		_player.global_position.x = player_end_x
	if is_instance_valid(_player):
		_player.visible = true
	for e in _hidden:
		if is_instance_valid(e):
			(e as CanvasItem).visible = true
	_hidden.clear()
	if _prev_cam != null and is_instance_valid(_prev_cam):
		_prev_cam.make_current()
	for a in _actors.values():
		if is_instance_valid(a) and not a.get_meta(&"keep", false):
			a.queue_free()
	await get_tree().create_timer(0.25, true, false, true).timeout
	if is_instance_valid(_cam):
		_cam.queue_free()
	active = null
	get_tree().paused = false
	done.emit()


# --- Aktörler -------------------------------------------------------------

## kind: gazelle / redmount / thug / knife / bruiser / rifle / elite / karahanli / bus / wagon / voice
func actor(id: String, kind: String, pos: Vector2, facing := 1) -> Node2D:
	var root := Node2D.new()
	root.process_mode = Node.PROCESS_MODE_ALWAYS
	root.position = pos
	root.z_index = 3
	root.set_meta(&"kind", kind)
	if kind == "voice":
		# Görünmeyen konuşan (telsiz, tezgâh arkası, kapı ardı): yalnız balon çıkar.
		pass
	elif kind == "wagon":
		root.z_index = 2
		var w := Sprite2D.new()
		w.texture = WAGON
		w.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		w.scale = Vector2(400.0 / 1983.0, 400.0 / 1983.0)
		w.offset = Vector2(0, -WAGON.get_height() * 0.5 + 30.0)
		w.name = "Body"
		root.add_child(w)
	elif kind == "bus":
		root.z_index = 2   # araç karakterlerin arkasında
		var s := Sprite2D.new()
		s.texture = BUS
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.scale = Vector2(1.25, 1.25)
		s.offset = Vector2(0, -BUS.get_height() * 0.5 + 4.0)
		s.flip_h = facing < 0
		s.name = "Body"
		root.add_child(s)
	else:
		var a := AnimatedSprite2D.new()
		a.name = "Body"
		a.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		match kind:
			"gazelle":
				a.sprite_frames = GAZELLE_FRAMES
				a.scale = Vector2(0.47, 0.47)
				a.offset = Vector2(0, -128 + 6)
			"redmount":
				a.sprite_frames = REDMOUNT_FRAMES
				a.scale = Vector2(0.6, 0.6)
				a.offset = Vector2(0, -114)
			"thug":
				a.sprite_frames = THUG_FRAMES
				a.scale = Vector2(0.6, 0.6)
				a.offset = Vector2(0, -114)
			"knife":
				a.sprite_frames = KNIFE_FRAMES
				a.scale = Vector2(0.6, 0.6)
				a.offset = Vector2(0, -114)
			"bruiser":
				a.sprite_frames = BRUISER_FRAMES
				a.scale = Vector2(0.66, 0.66)
				a.offset = Vector2(0, -114)
			"elite":
				a.sprite_frames = ELITE_FRAMES
				a.scale = Vector2(0.62, 0.62)
				a.offset = Vector2(0, -114)
			"rifle":
				a.sprite_frames = RIFLE_FRAMES
				a.scale = Vector2(0.6, 0.6)
				a.offset = Vector2(0, -114)
			"karahanli":
				a.sprite_frames = KARAHANLI_FRAMES
				a.scale = Vector2(0.68, 0.68)
				a.offset = Vector2(0, -114)
		a.flip_h = facing < 0
		root.add_child(a)
		_anim(root, "idle" if kind != "gazelle" else "freed")
	add_child(root)
	_actors[id] = root
	return root


func get_actor(id: String) -> Node2D:
	return _actors.get(id)


## Aktörü sahne bitince bırak (ör. bölümde kalacak bir figür).
func keep(id: String) -> void:
	if _actors.has(id):
		_actors[id].set_meta(&"keep", true)


func face(id: String, dir: int) -> void:
	var b := _body(id)
	if b is AnimatedSprite2D:
		(b as AnimatedSprite2D).flip_h = dir < 0
	elif b is Sprite2D:
		(b as Sprite2D).flip_h = dir < 0


func pose(id: String, anim: String) -> void:
	_anim(_actors[id], anim)


func remove(id: String) -> void:
	if _actors.has(id):
		_actors[id].queue_free()
		_actors.erase(id)


## Yürü / koş: hedef x'e `time` saniyede (Gazelle'de yürüme karesi yok: sekerek).
func move(id: String, to_x: float, time: float, anim := "walk", wait := true) -> void:
	var a: Node2D = _actors[id]
	var dir := signi(int(to_x - a.position.x))
	if dir != 0:
		face(id, dir)
	_anim(a, anim)
	var t := create_tween()
	t.tween_property(a, ^"position:x", to_x, _dur(time))
	var body := _body(id)
	if a.get_meta(&"kind") == "gazelle" and body != null:
		var bob := create_tween().set_loops(maxi(1, int(time / 0.18)))
		bob.tween_property(body, ^"position:y", -5.0, _dur(0.09))
		bob.tween_property(body, ^"position:y", 0.0, _dur(0.09))
	if wait:
		await t.finished
		_anim(a, "idle" if a.get_meta(&"kind") != "gazelle" else "freed")


## Yay çizerek zıpla / savrul (ör. minibüse binme).
func hop(id: String, to: Vector2, time: float, height := 60.0) -> void:
	var a: Node2D = _actors[id]
	var from := a.position
	var t := create_tween()
	t.tween_method(func(k: float) -> void:
		a.position = from.lerp(to, k) + Vector2(0, -sin(k * PI) * height), 0.0, 1.0, _dur(time))
	await t.finished


## Kafanın üstünde konuşma balonu: daktilo + ilerletme tuşu ya da süre.
func say(id: String, speaker: String, text: String, hold := -1.0) -> void:
	var a: Node2D = _actors.get(id)
	var b := _Bubble.new()
	b.speaker = speaker
	b.text = text
	b.color = SPEAKER_COLORS.get(speaker, Color(0.9, 0.9, 0.95))
	var head := 150.0
	if a != null and a.get_meta(&"kind") == "bus":
		head = 210.0
	elif a != null and a.get_meta(&"kind") == "voice":
		head = 0.0
	b.position = (a.position if a != null else _cam.global_position) + Vector2(0, -head)
	_bubble_layer().add_child(b)
	_advance = false
	var auto := hold if hold > 0.0 else 1.4 + text.length() * 0.045
	var elapsed := 0.0
	while elapsed < auto and not _skip:
		await get_tree().process_frame
		var d := get_process_delta_time()
		elapsed += d
		b.reveal(d)
		if a != null and is_instance_valid(a):
			b.position = a.position + Vector2(0, -head)
		if _advance:
			_advance = false
			if b.done():
				break
			b.finish()
	b.queue_free()


## Yere yıkıl: yay çizip sırt üstü yat (gövde 85° döner).
func knock_down(id: String, to_x: float, time := 0.45) -> void:
	var a: Node2D = _actors[id]
	var body := _body(id)
	var dir := signf(to_x - a.position.x)
	_anim(a, "jump" if a.get_meta(&"kind") == "redmount" else "hurt")
	var t := create_tween()
	t.tween_property(body, ^"rotation", deg_to_rad(-85.0 * -dir), _dur(time))
	await hop(id, Vector2(to_x, a.position.y), time, 50.0)
	Fx.dust(a.global_position, 0.0, 8)
	if a.get_meta(&"kind") == "redmount":
		_anim(a, "idle")
		var b := body as AnimatedSprite2D
		if b != null:
			b.pause()


## Yerden kalk.
func get_up(id: String, time := 0.5) -> void:
	var body := _body(id)
	_anim(_actors[id], "crouch")
	var t := create_tween()
	t.tween_property(body, ^"rotation", 0.0, _dur(time))
	await t.finished
	_anim(_actors[id], "idle")


## Vuruş: saldırı karesi + karşıdakine sarsıntı.
func strike(id: String, anim := "attack") -> void:
	_anim(_actors[id], anim)
	Sfx.play(&"hit", randf_range(0.9, 1.1))
	shake(5.0)
	await wait(0.25)


## Tutulan biri debelenir: kısa sıçramalarla `to_x`'e sürüklenir.
func struggle(id: String, to_x: float, steps := 3) -> void:
	var a: Node2D = _actors[id]
	var from := a.position.x
	for i in steps:
		var x := lerpf(from, to_x, float(i + 1) / steps)
		_anim(a, "flinch")
		await hop(id, Vector2(x, a.position.y), 0.28, 14.0)
		await wait(0.12)


func dust(x: float, amount := 10) -> void:
	Fx.dust(Vector2(x, 0.0), 0.0, amount)


## Kapıdan içeri girer gibi sönerek kaybol.
func fade_out(id: String, time := 0.4) -> void:
	if not _actors.has(id):
		return
	var a: Node2D = _actors[id]
	var t := create_tween()
	t.tween_property(a, ^"modulate:a", 0.0, _dur(time))
	await t.finished
	remove(id)


## Sahne başladığı anda oyuncunun ayak konumu (oyuncu gizli; yerine aktör konur).
func player_pos() -> Vector2:
	return _player.global_position if _player != null else Vector2.ZERO


## Balonlar dünyayı izleyen ayrı katmanda: gece tonu (CanvasModulate) onları karartmaz.
func _bubble_layer() -> CanvasLayer:
	if _ui == null:
		_ui = CanvasLayer.new()
		_ui.layer = 1
		_ui.follow_viewport_enabled = true
		_ui.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_ui)
	return _ui


func wait(seconds: float) -> void:
	if _skip:
		return
	await get_tree().create_timer(seconds, true, false, true).timeout


## Kamerayı bir noktaya kaydır.
func pan(to: Vector2, time: float) -> void:
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(_cam, ^"global_position", to, _dur(time))
	await t.finished


func shake(strength := 6.0) -> void:
	if _skip:
		return
	var base := _cam.offset
	var t := create_tween()
	for i in 6:
		t.tween_property(_cam, ^"offset", base + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength, 0.03)
	t.tween_property(_cam, ^"offset", base, 0.03)


func is_skipping() -> bool:
	return _skip


# --- İç işler ---------------------------------------------------------------

func _dur(t: float) -> float:
	return 0.01 if _skip else t


func _body(id: String) -> Node2D:
	var a: Node2D = _actors.get(id)
	return a.get_node_or_null(^"Body") if a != null else null


func _anim(a: Node2D, anim: String) -> void:
	var b := a.get_node_or_null(^"Body")
	if b is AnimatedSprite2D:
		var s := b as AnimatedSprite2D
		if s.sprite_frames.has_animation(anim):
			s.play(anim)
		elif s.sprite_frames.has_animation("idle"):
			s.play("idle")


func _letterbox(show: bool) -> void:
	if show:
		_bars = CanvasLayer.new()
		_bars.layer = 7
		_bars.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_bars)
		_top = ColorRect.new()
		_bottom = ColorRect.new()
		for r in [_top, _bottom]:
			r.color = Color(0.02, 0.02, 0.03)
			r.anchor_right = 1.0
			_bars.add_child(r)
		_top.offset_bottom = 0.0
		_bottom.anchor_top = 1.0
		_bottom.anchor_bottom = 1.0
		_hint = Label.new()
		_hint.text = "ESC: sahneyi geç     Enter / J: ilerlet"
		_hint.add_theme_font_size_override(&"font_size", 15)
		_hint.add_theme_color_override(&"font_color", Color(0.75, 0.75, 0.8, 0.8))
		_hint.anchor_left = 1.0
		_hint.anchor_right = 1.0
		_hint.anchor_top = 1.0
		_hint.anchor_bottom = 1.0
		_hint.offset_left = -640.0
		_hint.offset_top = -34.0
		_bars.add_child(_hint)
		var t := create_tween().set_parallel(true)
		t.tween_property(_top, ^"offset_bottom", 78.0, 0.35)
		t.tween_property(_bottom, ^"offset_top", -78.0, 0.35)
	elif _bars != null:
		var t := create_tween().set_parallel(true)
		t.tween_property(_top, ^"offset_bottom", 0.0, 0.25)
		t.tween_property(_bottom, ^"offset_top", 0.0, 0.25)
		t.chain().tween_callback(_bars.queue_free)


## Konuşma balonu: piksel parşömen çerçeve (PixelUI "balon"), renkli isim şeridi,
## piksel kuyruk ve piksel yazı (24 px = 2x ızgara).
class _Bubble extends Node2D:
	var speaker := ""
	var text := ""
	var color := Color.WHITE
	var _shown := 0.0
	const CPS := 40.0
	const W := 456.0
	const FS := 24
	const TAIL := preload("res://assets/ui/pixel/balon_kuyruk.png")
	const NAME_STRIP := preload("res://assets/ui/pixel/balon_ad.png")

	func _ready() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS
		z_index = 20
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func reveal(d: float) -> void:
		_shown = minf(_shown + CPS * d, float(text.length()))
		queue_redraw()

	func done() -> bool:
		return _shown >= text.length()

	func finish() -> void:
		_shown = float(text.length())
		queue_redraw()

	func _draw() -> void:
		var font := PixelUI.font()
		var body := text.substr(0, int(_shown))
		var inner := W - 36.0
		var full_size := font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, inner, FS)
		var h := roundf((full_size.y + 66.0) / 3.0) * 3.0
		var r := Rect2(-W * 0.5, -h - 15.0, W, h)
		draw_style_box(PixelUI.box("balon"), r)
		draw_texture(TAIL, Vector2(-TAIL.get_width() * 0.5, -18.0))
		# İsim şeridi: konuşanın rengiyle boyanmış piksel şerit.
		var name_w := roundf((font.get_string_size(speaker, HORIZONTAL_ALIGNMENT_LEFT, -1, FS).x + 24.0) / 3.0) * 3.0
		draw_texture_rect(NAME_STRIP, Rect2(r.position.x + 9.0, r.position.y - 12.0, name_w, 30.0), false, color)
		draw_string(font, r.position + Vector2(21.0, 12.0), speaker, HORIZONTAL_ALIGNMENT_LEFT, -1, FS, Color(0.1, 0.07, 0.1))
		draw_multiline_string(font, r.position + Vector2(18.0, 51.0), body, HORIZONTAL_ALIGNMENT_LEFT, inner, FS, -1,
			Color(0.12, 0.09, 0.12))

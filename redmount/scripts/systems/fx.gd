## Fx — prosedürel görsel efekt autoload'u (Görev 15).
##
## Yeni sanat gerektirmez: her efekt kısa ömürlü, kendini `_draw` ile çizen bir
## Node2D. `Fx.slash()`, `Fx.spark()`, `Fx.dust()`, `Fx.ring()`, `Fx.afterimage()`,
## `Fx.popup()`. Hepsi `get_tree().current_scene` altına eklenir, süre dolunca
## kendini siler. Dünya duraklatılınca (`PAUSABLE`) efektler de donar.
extends Node


func _spawn(node: Node2D, at: Vector2) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		node.queue_free()
		return
	node.global_position = at
	node.z_index = 60
	node.process_mode = Node.PROCESS_MODE_PAUSABLE
	scene.add_child(node)


## Savuruş yayı — yumruk/sopa/bıçak temas anında. facing +1 sağ, -1 sol.
func slash(at: Vector2, facing: int, radius: float = 72.0, arc: float = 2.3,
		color: Color = Color(1, 1, 1, 0.92), dur: float = 0.14) -> void:
	_spawn(_Slash.new(facing, radius, arc, color, dur), at)


## Çarpma kıvılcımı — ışınsal kısa çizgiler + parlama.
func spark(at: Vector2, dir: Vector2 = Vector2.ZERO, count: int = 8,
		color: Color = Color(1, 0.92, 0.55), scale: float = 1.0) -> void:
	_spawn(_Spark.new(dir, count, color, scale), at)


## Toz bulutu — iniş / koşu / dash.
func dust(at: Vector2, dir: float = 0.0, count: int = 5, tint: Color = Color(0.82, 0.80, 0.74)) -> void:
	_spawn(_Dust.new(dir, count, tint), at)


## Genişleyen halka — kalkan / güçlendirme / şok.
func ring(at: Vector2, color: Color = Color(0.55, 0.8, 1.0), r0: float = 8.0,
		r1: float = 64.0, dur: float = 0.3, width: float = 4.0) -> void:
	_spawn(_Ring.new(color, r0, r1, dur, width), at)


## Hayalet iz — hızlı hareket (dash / koşu / hız güçlendirmesi).
func afterimage(src: Node2D, tint: Color = Color(0.6, 0.8, 1.1, 0.5), dur: float = 0.22) -> void:
	var tex: Texture2D = null
	var flip := false
	var off := Vector2.ZERO
	if src is AnimatedSprite2D:
		var a := src as AnimatedSprite2D
		if a.sprite_frames != null and a.sprite_frames.has_animation(a.animation):
			tex = a.sprite_frames.get_frame_texture(a.animation, a.frame)
		flip = a.flip_h
		off = a.offset
	elif src is Sprite2D:
		tex = (src as Sprite2D).texture
		flip = (src as Sprite2D).flip_h
		off = (src as Sprite2D).offset
	if tex == null:
		return
	var g := _Ghost.new(tex, flip, off, src.global_scale, src.global_rotation, tint, dur)
	_spawn(g, src.global_position)


## Yüzen yazı — hasar / bonus.
func popup(at: Vector2, text: String, color: Color = Color.WHITE, size: int = 22) -> void:
	_spawn(_Popup.new(text, color, size), at)


# ------------------------------------------------------------------------
# Efekt düğümleri (kendini çizer, süresi dolunca queue_free)
# ------------------------------------------------------------------------

class _Slash extends Node2D:
	var _f: int
	var _radius: float
	var _arc: float
	var _col: Color
	var _dur: float
	var _t: float = 0.0

	func _init(facing: int, radius: float, arc: float, color: Color, dur: float) -> void:
		_f = facing
		_radius = radius
		_arc = arc
		_col = color
		_dur = dur

	func _process(delta: float) -> void:
		_t += delta
		if _t >= _dur:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		var p := clampf(_t / _dur, 0.0, 1.0)
		# yay üst-arkadan öne-alta doğru süpürülür
		var a0: float = lerpf(-_arc * 0.5, _arc * 0.5, p) - 0.5
		var span: float = _arc * (1.0 - p) * 0.6 + 0.35
		var pts := PackedVector2Array()
		var steps := 10
		for i in steps + 1:
			var u := float(i) / float(steps)
			var ang: float = (a0 + u * span) * float(_f)
			pts.append(Vector2(cos(ang), sin(ang)) * _radius * (0.6 + 0.4 * u))
		var fade := 1.0 - p
		for i in pts.size() - 1:
			var w: float = (2.0 + 9.0 * (float(i) / float(pts.size()))) * fade
			draw_line(pts[i], pts[i + 1], Color(_col.r, _col.g, _col.b, _col.a * fade), w)
		# uçta parlak nokta
		draw_circle(pts[pts.size() - 1], 5.0 * fade, Color(1, 1, 1, 0.8 * fade))


class _Spark extends Node2D:
	var _dir: Vector2
	var _n: int
	var _col: Color
	var _s: float
	var _t: float = 0.0
	const DUR := 0.18
	var _angles: PackedFloat32Array = PackedFloat32Array()
	var _lens: PackedFloat32Array = PackedFloat32Array()

	func _init(dir: Vector2, n: int, col: Color, s: float) -> void:
		_dir = dir
		_n = n
		_col = col
		_s = s
		var directed := _dir.length() > 0.01
		var base: float = _dir.angle() if directed else 0.0
		for i in _n:
			if directed:
				_angles.append(base + randf_range(-1.1, 1.1))
			else:
				_angles.append(randf() * TAU)
			_lens.append(randf_range(14.0, 30.0) * _s)

	func _process(delta: float) -> void:
		_t += delta
		if _t >= DUR:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		var p := _t / DUR
		var fade := 1.0 - p
		draw_circle(Vector2.ZERO, 10.0 * _s * (1.0 - p) + 2.0, Color(1, 1, 1, 0.7 * fade))
		for i in _n:
			var d := Vector2(cos(_angles[i]), sin(_angles[i]))
			var a := d * (_lens[i] * (0.3 + 0.7 * p))
			var b := d * (_lens[i] * (0.3 + 0.7 * p) + 8.0 * _s)
			draw_line(a, b, Color(_col.r, _col.g, _col.b, fade), 2.5 * _s)


class _Dust extends Node2D:
	var _dir: float
	var _n: int
	var _tint: Color
	var _t: float = 0.0
	const DUR := 0.34
	var _pos: Array = []
	var _vel: Array = []
	var _r: PackedFloat32Array = PackedFloat32Array()

	func _init(dir: float, n: int, tint: Color) -> void:
		_dir = dir
		_n = n
		_tint = tint
		for i in _n:
			var spread := randf_range(-0.7, 0.7)
			_pos.append(Vector2(randf_range(-6, 6), randf_range(-4, 2)))
			var away := 1.0 if _dir == 0.0 else -signf(_dir)
			_vel.append(Vector2((away * randf_range(20, 70)) + spread * 40.0, randf_range(-45, -10)))
			_r.append(randf_range(3.0, 7.0))

	func _process(delta: float) -> void:
		_t += delta
		for i in _n:
			_pos[i] += _vel[i] * delta
			_vel[i] = _vel[i].lerp(Vector2.ZERO, delta * 3.0)
		if _t >= DUR:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		var fade := 1.0 - _t / DUR
		for i in _n:
			draw_circle(_pos[i], _r[i] * (0.5 + fade), Color(_tint.r, _tint.g, _tint.b, 0.5 * fade))


class _Ring extends Node2D:
	var _col: Color
	var _r0: float
	var _r1: float
	var _dur: float
	var _w: float
	var _t: float = 0.0

	func _init(col: Color, r0: float, r1: float, dur: float, w: float) -> void:
		_col = col
		_r0 = r0
		_r1 = r1
		_dur = dur
		_w = w

	func _process(delta: float) -> void:
		_t += delta
		if _t >= _dur:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		var p := _t / _dur
		var r: float = lerpf(_r0, _r1, ease(p, 0.35))
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(_col.r, _col.g, _col.b, (1.0 - p) * 0.9), _w * (1.0 - p) + 1.0, true)


class _Ghost extends Sprite2D:
	var _dur: float
	var _t: float = 0.0
	var _tint: Color

	func _init(tex: Texture2D, flip: bool, off: Vector2, scl: Vector2, rot: float, tint: Color, dur: float) -> void:
		texture = tex
		flip_h = flip
		offset = off
		scale = scl
		rotation = rot
		_tint = tint
		_dur = dur
		modulate = tint

	func _process(delta: float) -> void:
		_t += delta
		if _t >= _dur:
			queue_free()
			return
		modulate.a = _tint.a * (1.0 - _t / _dur)


class _Popup extends Node2D:
	var _text: String
	var _col: Color
	var _size: int
	var _t: float = 0.0
	const DUR := 0.7
	var _font: Font

	func _init(text: String, col: Color, size: int) -> void:
		_text = text
		_col = col
		_size = size

	func _ready() -> void:
		_font = ThemeDB.fallback_font

	func _process(delta: float) -> void:
		_t += delta
		position.y -= 42.0 * delta
		if _t >= DUR:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		if _font == null:
			return
		var fade := 1.0 - clampf((_t - 0.3) / 0.4, 0.0, 1.0)
		var w: float = _font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, _size).x
		draw_string(_font, Vector2(-w * 0.5 + 1, 1), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, _size, Color(0, 0, 0, 0.6 * fade))
		draw_string(_font, Vector2(-w * 0.5, 0), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, _size, Color(_col.r, _col.g, _col.b, fade))

## BattleArena — tempoyu yükselten kilitli dövüş kapısı (Görev 18).
##
## Oyuncu tetik alanına girince: iki yanda parlayan bariyer belirir (fiziksel +
## görsel), kamera arenaya kilitlenir, düşman dalgaları sırayla spawn olur.
## Hepsi temizlenince bariyerler düşer, kamera açılır, `cleared` yayılır ve
## (varsa) ödül düşer. Grup: "battle_arena". Spawn edilen düşmanları Main
## `enemy_spawned` ile sayaca bağlar.
class_name BattleArena
extends Area2D

signal cleared
signal enemy_spawned(enemy: Node)

## Bariyerlerin dünya-x konumları (arena genişliği).
@export var gate_left_x: float = 0.0
@export var gate_right_x: float = 640.0
## Zemin y'si + bariyer yüksekliği.
@export var floor_y: float = 0.0
@export var gate_height: float = 440.0
## İsteğe bağlı mekâna ait piksel kapı dokusu.
@export var gate_texture: Texture2D
## Yalnız kepenk/avlu/kapı mantığı olan mekânlarda fiziksel kapı kurulur.
@export var use_gates: bool = true
## Kamerayı arenaya kilitle.
@export var lock_camera: bool = true
## Düşman dalgaları — her biri PackedScene dizisi (Inspector'dan / tscn'den).
@export var wave1: Array[PackedScene] = []
@export var wave2: Array[PackedScene] = []
@export var wave3: Array[PackedScene] = []
## Dalga arası bekleme (sn).
@export var wave_delay: float = 0.9
## Temizlenince düşecek ödül (opsiyonel — HealthPickup / Coin vb).
@export var reward: PackedScene

var _active := false
var _done := false
var _alive: Array = []
var _waves: Array = []
var _wave_idx := 0
var _gates: Array = []
var _accent := Color(1.0, 0.42, 0.32)
var _saved_cam := Vector2.ZERO


func _ready() -> void:
	add_to_group(&"battle_arena")
	body_entered.connect(_on_body_entered)
	for w in [wave1, wave2, wave3]:
		if not w.is_empty():
			_waves.append(w)


func _on_body_entered(b: Node) -> void:
	if _active or _done or not b.is_in_group(&"player"):
		return
	_active = true
	set_deferred(&"monitoring", false)
	# Fizik sorgu akışı sırasında (body_entered) fiziksel gövde eklemek hata verir.
	call_deferred(&"_activate")


func _activate() -> void:
	if use_gates:
		_raise_gates()
	_lock_camera()
	Combat.shake(3.5)
	Combat.hitstop(0.06)
	Sfx.play(&"armor_break", 0.7)
	_spawn_wave()


# --- Bariyerler --------------------------------------------------------

func _raise_gates() -> void:
	_gates.append(_make_gate(gate_left_x))
	_gates.append(_make_gate(gate_right_x))


func _make_gate(x: float) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.global_position = Vector2(x, floor_y)
	var col := CollisionShape2D.new()
	var s := RectangleShape2D.new()
	s.size = Vector2(24.0, gate_height)
	col.shape = s
	col.position = Vector2(0, -gate_height * 0.5)
	body.add_child(col)
	body.add_child(_GateVis.new(gate_height, _accent, gate_texture))
	get_parent().add_child(body)
	return body


func _drop_gates() -> void:
	for g in _gates:
		if is_instance_valid(g):
			var v: Node = g.get_child(1)
			if v != null:
				(v as _GateVis).dissolve()
			g.get_child(0).set_deferred(&"disabled", true)
			g.get_tree().create_timer(0.35).timeout.connect(g.queue_free)
	_gates.clear()


# --- Kamera -----------------------------------------------------------

func _lock_camera() -> void:
	if not lock_camera:
		return
	var p := get_tree().get_first_node_in_group(&"player")
	if p == null:
		return
	var cam: Camera2D = p.get_node_or_null(^"Camera2D")
	if cam == null:
		return
	_saved_cam = Vector2(cam.limit_left, cam.limit_right)
	cam.limit_left = int(gate_left_x)
	cam.limit_right = int(gate_right_x)


func _unlock_camera() -> void:
	if not lock_camera or _saved_cam == Vector2.ZERO:
		return
	var p := get_tree().get_first_node_in_group(&"player")
	if p == null:
		return
	var cam: Camera2D = p.get_node_or_null(^"Camera2D")
	if cam == null:
		return
	cam.limit_left = int(_saved_cam.x)
	cam.limit_right = int(_saved_cam.y)


# --- Dalgalar --------------------------------------------------------

func _spawn_wave() -> void:
	if _wave_idx >= _waves.size():
		_finish()
		return
	var w: Array = _waves[_wave_idx]
	_wave_idx += 1
	var n: int = maxi(w.size(), 1)
	for i in w.size():
		if w[i] == null:
			continue
		var e: Node2D = w[i].instantiate()
		var frac := (float(i) + 0.5) / float(n)
		var x := lerpf(gate_left_x + 80.0, gate_right_x - 80.0, frac)
		e.global_position = Vector2(x, floor_y - 24.0)
		get_parent().add_child(e)
		if e.has_signal(&"defeated"):
			e.defeated.connect(_on_enemy_down)
		_alive.append(e)
		enemy_spawned.emit(e)
		Fx.ring(e.global_position + Vector2(0, -70), _accent, 8, 74, 0.35)
	Fx.spark(Vector2((gate_left_x + gate_right_x) * 0.5, floor_y - 80.0), Vector2.ZERO, 7, _accent)


func _on_enemy_down(e: Node) -> void:
	_alive.erase(e)
	if not _alive.is_empty():
		return
	if _wave_idx < _waves.size():
		await get_tree().create_timer(wave_delay, false).timeout
		if is_instance_valid(self):
			_spawn_wave()
	else:
		_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	if use_gates:
		_drop_gates()
	_unlock_camera()
	Combat.shake(2.5)
	Fx.popup(Vector2((gate_left_x + gate_right_x) * 0.5, floor_y - 130.0), "TEMİZ!", _accent, 30)
	if reward != null:
		var r: Node2D = reward.instantiate()
		r.global_position = Vector2((gate_left_x + gate_right_x) * 0.5, floor_y - 60.0)
		# _finish() fizik sorgu akışı sırasında (düşman ölümü) çağrılabilir —
		# Area2D ödülü doğrudan eklemek "flushing queries" hatası verir.
		get_parent().add_child.call_deferred(r)
	cleared.emit()


# --- Bariyer görseli -------------------------------------------------

class _GateVis extends Node2D:
	var _h: float
	var _col: Color
	var _t := 0.0
	var _fade := 1.0
	var _dying := false
	var _texture: Texture2D

	func _init(h: float, col: Color, tex: Texture2D = null) -> void:
		_h = h
		_col = col
		_texture = tex
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func dissolve() -> void:
		_dying = true

	func _process(delta: float) -> void:
		_t += delta
		if _dying:
			_fade = maxf(_fade - delta * 3.0, 0.0)
		queue_redraw()

	func _draw() -> void:
		if _texture != null:
			draw_texture_rect(_texture, Rect2(-12, -_h - (1.0 - _fade) * 80, 24, _h), false, Color(1, 1, 1, _fade))
			return
		var w := 12.0
		for i in 10:
			var yy := -_h + _h * (float(i) / 10.0)
			var a: float = (0.22 + 0.18 * sin(_t * 7.0 + i * 0.9)) * _fade
			draw_rect(Rect2(-w * 0.5, yy, w, _h / 10.0 + 1.0),
				Color(_col.r, _col.g, _col.b, a))
		draw_line(Vector2(0, -_h), Vector2(0, 0), Color(1, 1, 1, 0.45 * _fade), 2.0)

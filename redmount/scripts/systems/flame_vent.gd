## FlameVent — zeminden periyodik fışkıran alev sütunu (Görev 25).
##
## Area2D; `on_time` boyunca aktif (hasar + görsel), `off_time` boyunca sönük.
## Sönükken kısa bir "ısınma" parıltısıyla telegraph verir. Yatay koridor
## tuzağı: alev inene kadar bekle, sonra geç.
class_name FlameVent
extends Area2D

const ALEV := preload("res://assets/environment/pixel/alev.png")
const IZGARA := preload("res://assets/environment/pixel/alev_izgara.png")

@export var height: float = 130.0
@export var width: float = 40.0
@export var on_time: float = 1.1
@export var off_time: float = 1.6
@export var warn_time: float = 0.5
@export var damage: int = 12
@export var phase_offset: float = 0.0

var _col: CollisionShape2D
var _flame: Node2D
var _t: float = 0.0
var _active := false
var _hit_lock := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	_t = phase_offset * (on_time + off_time)

	_col = CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(width, height)
	_col.shape = r
	_col.position = Vector2(0, -height * 0.5)
	_col.disabled = true
	add_child(_col)

	# taban ızgara (piksel art)
	var grate := Sprite2D.new()
	grate.texture = IZGARA
	grate.scale = Vector2(3, 3)
	grate.position = Vector2(0, -3)
	grate.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(grate)

	_flame = _Flame.new()
	_flame.set(&"h", height)
	_flame.set(&"w", width)
	add_child(_flame)


func _physics_process(delta: float) -> void:
	var cycle := on_time + off_time
	_t = fmod(_t + delta, cycle)
	_hit_lock = maxf(_hit_lock - delta, 0.0)
	var want_active := _t < on_time
	if want_active != _active:
		_active = want_active
		_col.set_deferred(&"disabled", not _active)
		if _active:
			Sfx.play(&"swing", 0.5, -6.0)
	var warn := (not _active) and (_t > cycle - warn_time)
	_flame.set(&"lit", _active)
	_flame.set(&"warn", warn)
	_flame.set(&"tt", _flame.get(&"tt") + delta)
	_flame.queue_redraw()

	if _active and _hit_lock <= 0.0:
		for b in get_overlapping_bodies():
			if b.is_in_group(&"player") and b.has_method(&"apply_hit"):
				var away := signf(b.global_position.x - global_position.x)
				if is_zero_approx(away):
					away = 1.0
				b.apply_hit(damage, Vector2(away, -0.3), 220.0)
				_hit_lock = 0.6


class _Flame extends Node2D:
	var h: float = 130.0
	var w: float = 40.0
	var lit := false
	var warn := false
	var tt := 0.0

	func _draw() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var fw := ALEV.get_width() / 4.0
		var fr := int(tt * 14.0) % 4
		if warn:
			# Uyarı: ızgaradan kısa, titrek alev dili (aynı piksel kareler).
			var small := 0.25 + 0.1 * sin(tt * 30.0)
			draw_texture_rect_region(ALEV, Rect2(-fw * 1.5, -46.0 * 3.0 * small, fw * 3.0, 46.0 * 3.0 * small),
				Rect2(fr * fw, 0, fw, 46))
			return
		if not lit:
			return
		var hh := h * (0.9 + 0.1 * sin(tt * 22.0))
		draw_texture_rect_region(ALEV, Rect2(-w * 0.75, -hh, w * 1.5, hh), Rect2(fr * fw, 0, fw, 46))

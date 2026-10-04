## Fx — kısa ömürlü görsel efektler (kıvılcım, toz, yazı, parça). Hepsi kendi kendini siler.
class_name Fx
extends Node2D

var kind := ""
var life := 0.0
var dur := 0.2
var color := Color.WHITE
var size := 1.0
var seed_rot := 0.0


static func _spawn(parent: Node, pos: Vector2, k: String, d: float, c: Color, s: float) -> Fx:
	var f := Fx.new()
	f.kind = k
	f.dur = d
	f.color = c
	f.size = s
	f.position = pos
	f.z_index = 50
	f.seed_rot = randf() * TAU
	parent.add_child(f)
	return f


## Vuruş kıvılcımı: beyaz yıldız + halka.
static func spark(parent: Node, pos: Vector2, big := false) -> void:
	_spawn(parent, pos, "spark", 0.16 if not big else 0.22, Color(1, 0.95, 0.75), 1.6 if big else 1.0)


static func dust(parent: Node, pos: Vector2, s := 1.0) -> void:
	for i in 3:
		var f := _spawn(parent, pos + Vector2(randf_range(-20, 20), 0), "dust", 0.35, Color(0.8, 0.75, 0.85, 0.55), s * randf_range(0.7, 1.2))
		f.set_meta("v", Vector2(randf_range(-60, 60), randf_range(-60, -20)))


static func ring(parent: Node, pos: Vector2, c: Color, s := 1.0) -> void:
	_spawn(parent, pos, "ring", 0.3, c, s)


static func text(parent: Node, pos: Vector2, t: String, c := Color.WHITE, s := 1.0) -> void:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", int(34 * s))
	l.add_theme_color_override("font_color", c)
	l.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.08))
	l.add_theme_constant_override("outline_size", 10)
	l.position = pos - Vector2(60, 20)
	l.z_index = 60
	parent.add_child(l)
	var tw := l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 70, 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.6).set_delay(0.25)
	tw.tween_callback(l.queue_free)


## Kırılan nesneden parçalar: tek renkli küçük kareler savrulur.
static func shards(parent: Node, pos: Vector2, c: Color, n := 10) -> void:
	for i in n:
		var f := _spawn(parent, pos + Vector2(randf_range(-25, 25), randf_range(-40, 0)), "shard", randf_range(0.5, 0.8), c.lightened(randf_range(-0.2, 0.2)), randf_range(6, 14))
		f.set_meta("v", Vector2(randf_range(-420, 420), randf_range(-700, -250)))


func _process(dt: float) -> void:
	life += dt
	if has_meta("v"):
		var v: Vector2 = get_meta("v")
		if kind == "shard":
			v.y += 2200 * dt
		position += v * dt
		set_meta("v", v)
	if life >= dur:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var t := life / dur
	match kind:
		"spark":
			var r := 60.0 * size * (0.4 + t)
			var a := 1.0 - t
			var c := Color(color, a)
			for i in (4 if t < 0.85 else 0):
				var ang := seed_rot + i * PI / 2.0
				var dir := Vector2.from_angle(ang)
				var side := dir.orthogonal() * 7.0 * size * (1.0 - t)
				draw_colored_polygon(PackedVector2Array([dir * r, side, -dir * r * 0.15, -side]), c)
			draw_circle(Vector2.ZERO, 16.0 * size * (1.0 - t), Color(1, 1, 1, a))
			draw_arc(Vector2.ZERO, r * 0.8, 0, TAU, 20, Color(1, 0.7, 0.3, a * 0.8), 4.0)
		"dust":
			draw_circle(Vector2.ZERO, 18.0 * size * (0.6 + t), Color(color, color.a * (1.0 - t)))
		"ring":
			draw_arc(Vector2.ZERO, 30.0 + 110.0 * size * t, 0, TAU, 32, Color(color, 1.0 - t), 8.0 * (1.0 - t) + 1.0)
		"shard":
			draw_rect(Rect2(-size / 2, -size / 2, size, size), Color(color, 1.0 - t * t))

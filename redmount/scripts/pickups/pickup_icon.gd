## PickupIcon — prosedürel toplanabilir ikonu (Görev 22).
## Sanat dosyası yok; `kind`'e göre _draw ile çizilir + döner/nabız atar.
extends Node2D

## coin / health / ammo / armor / bat / knife / pistol / rifle /
## pu_damage / pu_speed / pu_invis / pu_shield
@export var kind: String = "coin"

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	match kind:
		"coin":
			_coin()
		"health":
			_health()
		"ammo":
			_ammo()
		"armor", "pu_shield":
			_shield(kind == "pu_shield")
		"bat":
			_bat()
		"knife":
			_knife()
		"pistol":
			_pistol()
		"rifle":
			_rifle()
		"pu_damage":
			_glyph(Color(1.0, 0.35, 0.3), "fist")
		"pu_speed":
			_glyph(Color(1.0, 0.85, 0.3), "bolt")
		"pu_invis":
			_glyph(Color(0.6, 0.8, 1.0), "ghost")
		_:
			_coin()


func _coin() -> void:
	var r := 13.0
	# dönme: genişlik %35–100 arası salınır (hiç sliver olmaz)
	var w := (0.35 + 0.65 * absf(cos(_t * 4.0))) * r
	var gold := Color(1.0, 0.82, 0.25)
	var edge := gold.darkened(0.35)
	draw_circle(Vector2(0, 3), r + 2.0, Color(0, 0, 0, 0.25))          # gölge
	# yan görünümlü disk
	draw_colored_polygon(_ellipse(w, r), edge)
	draw_colored_polygon(_ellipse(w * 0.78, r * 0.82), gold)
	draw_line(Vector2(0, -r * 0.5), Vector2(0, r * 0.5), edge, 2.0)
	# parıltı
	var s := 0.5 + 0.5 * sin(_t * 4.0)
	draw_circle(Vector2(-r * 0.4, -r * 0.4), 2.0 * s, Color(1, 1, 1, 0.8 * s))


func _health() -> void:
	var p := 1.0 + sin(_t * 3.5) * 0.08
	var red := Color(0.9, 0.2, 0.25)
	draw_circle(Vector2.ZERO, 15.0 * p, Color(red.r, red.g, red.b, 0.18))
	# haç
	var a := 5.0 * p
	var b := 13.0 * p
	draw_rect(Rect2(-a, -b, a * 2.0, b * 2.0), red)
	draw_rect(Rect2(-b, -a, b * 2.0, a * 2.0), red)
	draw_rect(Rect2(-a * 0.5, -b, a, b * 2.0), Color(1, 1, 1, 0.35))


func _ammo() -> void:
	var c := Color(0.45, 0.4, 0.32)
	draw_rect(Rect2(-9, -13, 18, 22), c)
	draw_rect(Rect2(-9, -13, 18, 5), c.lightened(0.25))
	for i in 3:
		draw_line(Vector2(-6 + i * 6, -6), Vector2(-6 + i * 6, 7), Color(0.85, 0.7, 0.3), 3.0)


func _shield(glow: bool) -> void:
	var c := Color(0.55, 0.75, 1.0) if glow else Color(0.6, 0.62, 0.68)
	if glow:
		var s := 0.5 + 0.5 * sin(_t * 4.0)
		draw_circle(Vector2.ZERO, 16.0, Color(c.r, c.g, c.b, 0.15 + 0.12 * s))
	var pts := PackedVector2Array([
		Vector2(0, -15), Vector2(12, -9), Vector2(12, 5), Vector2(0, 15), Vector2(-12, 5), Vector2(-12, -9),
	])
	draw_colored_polygon(pts, c.darkened(0.3))
	var inner := PackedVector2Array()
	for pt in pts:
		inner.append(pt * 0.7)
	draw_colored_polygon(inner, c)


func _bat() -> void:
	draw_set_transform(Vector2.ZERO, sin(_t * 1.5) * 0.15 - 0.5, Vector2.ONE)
	draw_line(Vector2(-14, 0), Vector2(2, 0), Color(0.2, 0.15, 0.12), 5.0)
	draw_line(Vector2(2, 0), Vector2(16, 0), Color(0.5, 0.34, 0.2), 9.0)
	draw_circle(Vector2(16, 0), 5.5, Color(0.55, 0.38, 0.22))


func _knife() -> void:
	draw_set_transform(Vector2.ZERO, sin(_t * 1.5) * 0.15 - 0.4, Vector2.ONE)
	draw_line(Vector2(-12, 0), Vector2(-4, 0), Color(0.22, 0.17, 0.15), 5.0)
	draw_colored_polygon(PackedVector2Array([Vector2(-4, -3), Vector2(16, -1), Vector2(-4, 3)]),
		Color(0.85, 0.87, 0.92))


func _pistol() -> void:
	var c := Color(0.2, 0.2, 0.23)
	draw_rect(Rect2(-11, -5, 20, 6), c)
	draw_rect(Rect2(-9, 1, 7, 9), c)
	draw_circle(Vector2(9, -2), 2.0, c)


func _rifle() -> void:
	var c := Color(0.18, 0.2, 0.21)
	draw_set_transform(Vector2.ZERO, sin(_t * 1.5) * 0.08 - 0.12, Vector2.ONE)
	draw_rect(Rect2(-17, -4, 27, 6), c)
	draw_rect(Rect2(8, -3, 12, 3), c.lightened(0.12))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-17, -3), Vector2(-24, 3), Vector2(-12, 3), Vector2(-8, 0),
	]), Color(0.38, 0.26, 0.17))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-2, 2), Vector2(5, 2), Vector2(2, 11), Vector2(-4, 11),
	]), c.darkened(0.08))
	draw_rect(Rect2(-3, -8, 10, 3), c.lightened(0.18))


func _glyph(c: Color, shape: String) -> void:
	var s := 0.6 + 0.4 * sin(_t * 4.0)
	draw_circle(Vector2.ZERO, 15.0, Color(c.r, c.g, c.b, 0.16 + 0.12 * s))
	draw_circle(Vector2.ZERO, 12.0, c.darkened(0.15))
	match shape:
		"fist":
			draw_rect(Rect2(-6, -5, 12, 10), Color(1, 1, 1, 0.9))
			draw_rect(Rect2(-6, -8, 4, 4), Color(1, 1, 1, 0.9))
		"bolt":
			draw_colored_polygon(PackedVector2Array([
				Vector2(2, -10), Vector2(-4, 1), Vector2(0, 1), Vector2(-2, 10),
				Vector2(5, -2), Vector2(1, -2)]), Color(1, 1, 1, 0.95))
		"ghost":
			draw_circle(Vector2(0, -2), 7.0, Color(1, 1, 1, 0.9))
			draw_rect(Rect2(-7, -2, 14, 9), Color(1, 1, 1, 0.9))
			draw_circle(Vector2(-2, -3), 1.5, c.darkened(0.3))
			draw_circle(Vector2(3, -3), 1.5, c.darkened(0.3))


func _ellipse(w: float, h: float) -> PackedVector2Array:
	var a := PackedVector2Array()
	for i in 16:
		var an := TAU * float(i) / 16.0
		a.append(Vector2(cos(an) * w, sin(an) * h))
	return a

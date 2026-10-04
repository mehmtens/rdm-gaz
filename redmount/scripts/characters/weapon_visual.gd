## WeaponVisual — Redmount elindeki sopa / bıçağı prosedürel çizer ve savurur
## (Görev 15). Gerçek silah sprite'ı yok; `_draw` ile basit şekil.
##
## Redmount `show_weapon(prefix)` / `hide_weapon()` çağırır; her fizik karesinde
## `tick()` ile savuruş fazı + ilerlemesi verilir. Savuruş yayını asıl bu düğüm
## yapar, gövde sprite'ı ona eşlik eder.
extends Node2D

var _prefix: String = ""
var _t: float = 0.0


func show_weapon(prefix: String) -> void:
	_prefix = prefix
	visible = true
	queue_redraw()


func hide_weapon() -> void:
	_prefix = ""
	visible = false


func tick(delta: float, swinging: bool, phase: int, progress: float, facing: int) -> void:
	_t += delta
	scale.x = -1.0 if facing < 0 else 1.0
	if _prefix == "":
		visible = false
		return
	visible = true

	var ang := 0.0
	if swinging:
		match phase:
			0:  # windup — arkaya/yukarı kaldır
				ang = lerpf(-1.9, -2.7, progress)
			1:  # active — öne/aşağı savur
				ang = lerpf(-2.7, 1.5, ease(progress, 0.12))
			_:  # recovery — dinlen
				ang = lerpf(1.5, -0.4, ease(progress, 0.5))
	else:
		ang = -0.5 + sin(_t * 3.0) * 0.08
	rotation = ang
	queue_redraw()


func _draw() -> void:
	if _prefix == "":
		return
	if _prefix.begins_with("knife"):
		draw_line(Vector2.ZERO, Vector2(13, 0), Color(0.22, 0.17, 0.15), 5.0)
		draw_colored_polygon(
			PackedVector2Array([Vector2(13, -3), Vector2(38, -1), Vector2(13, 3)]),
			Color(0.82, 0.84, 0.9))
	else:  # bat / sopa
		draw_line(Vector2(-6, 0), Vector2(6, 0), Color(0.18, 0.13, 0.1), 6.0)
		draw_line(Vector2(6, 0), Vector2(64, 0), Color(0.45, 0.30, 0.18), 12.0)
		draw_circle(Vector2(64, 0), 7.0, Color(0.5, 0.34, 0.2))

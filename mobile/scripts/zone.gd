## Zone — dikdörtgen tetik: kontrol noktası, gizli alan, ipucu, bölüm sonu.
class_name Zone
extends Node2D

var kind := "hint" ## "checkpoint", "secret", "hint", "goal"
var rect := Rect2()
var text := ""
var id := ""
var level: Node
var triggered := false
var _t := 0.0


func _process(dt: float) -> void:
	_t += dt
	var p: Player = get_tree().get_first_node_in_group("player")
	if p == null or p.state == Player.S.DEAD:
		return
	var inside := rect.has_point(p.position + Vector2(0, -60))
	match kind:
		"hint":
			if inside:
				level.hint(text)
		"checkpoint":
			if inside and not triggered:
				triggered = true
				Game.run["checkpoint"] = position
				p.heal(20)
				Sfx.play("checkpoint")
				level.banner("KONTROL NOKTASI", Color(0.6, 0.85, 1), 0.7)
		"secret":
			if inside and not triggered:
				triggered = true
				Game.run["secrets"][id] = true
				Sfx.play("powerup")
				level.banner("GİZLİ ALAN!", Color(1, 0.85, 0.3), 0.8)
		"goal":
			if inside and not triggered:
				triggered = true
				level.on_goal()
	if kind == "checkpoint":
		queue_redraw()


func _draw() -> void:
	if kind != "checkpoint":
		return
	# Direk + bayrak (hilal-yıldız sade simgesi); aktifken yukarı çıkar ve dalgalanır.
	draw_rect(Rect2(-5, -260, 10, 260), Color(0.25, 0.22, 0.28))
	draw_circle(Vector2(0, -262), 9, Color(0.95, 0.8, 0.4))
	var top := -250.0 if triggered else -90.0
	var wave := sin(_t * 6.0) * 6.0 if triggered else 0.0
	var col := Color(0.86, 0.12, 0.15) if triggered else Color(0.35, 0.33, 0.4)
	var pts := PackedVector2Array([Vector2(5, top), Vector2(110, top + wave), Vector2(110, top + 70 + wave), Vector2(5, top + 70)])
	draw_colored_polygon(pts, col)
	if triggered:
		draw_circle(Vector2(52, top + 35 + wave * 0.5), 18, Color.WHITE)
		draw_circle(Vector2(59, top + 35 + wave * 0.5), 15, col)

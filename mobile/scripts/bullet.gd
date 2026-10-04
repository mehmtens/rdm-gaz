## Bullet — yatay mermi. Oyuncununki düşman/kırılabilir vurur, düşmanınki oyuncuyu.
class_name Bullet
extends Node2D

var from_player := false
var dir := 1
var dmg := 12
var speed := 1500.0
var life := 1.4


func _ready() -> void:
	if not from_player:
		speed = 780.0
	z_index = 40


func _process(dt: float) -> void:
	life -= dt
	var step := Vector2(dir * speed * dt, 0)
	var q := PhysicsRayQueryParameters2D.create(position, position + step, Game.L_WORLD)
	var hit := get_world_2d().direct_space_state.intersect_ray(q)
	if not hit.is_empty() or life <= 0.0:
		Fx.spark(get_parent(), hit.get("position", position), false)
		queue_free()
		return
	position += step
	if from_player:
		for t in get_tree().get_nodes_in_group("hittable"):
			if t.can_be_hit() and t.hurt_rect().grow(10).has_point(position):
				t.take_hit(dmg, dir, 260.0, false)
				Fx.spark(get_parent(), position, false)
				Sfx.play("hit")
				queue_free()
				return
	else:
		var p: Player = get_tree().get_first_node_in_group("player")
		if p and not p.is_invulnerable() and p.hurt_rect().has_point(position):
			p.take_hit(dmg, position.x - dir * 20.0)
			queue_free()
			return
	queue_redraw()


func _draw() -> void:
	var c := Color(1, 0.95, 0.55) if from_player else Color(1, 0.45, 0.3)
	draw_line(Vector2(-dir * 46, 0), Vector2.ZERO, Color(c, 0.35), 8.0)
	draw_line(Vector2(-dir * 22, 0), Vector2(dir * 4, 0), c, 5.0)
	draw_circle(Vector2.ZERO, 5.0, Color.WHITE)

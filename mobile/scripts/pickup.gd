## Pickup — coin (yerleşik veya fırlayan), simit (can), sopa, tabanca.
class_name Pickup
extends Node2D

const TEX := {
	"coin": preload("res://art/items/coin.png"), "simit": preload("res://art/items/simit.png"),
	"bat": preload("res://art/items/bat.png"), "pistol": preload("res://art/items/pistol.png"),
}

var kind := "coin"
var id := ""
var level: Node
var loose := false ## Düşmandan/kırılandan fırlayan coin: yerçekimi + sekme.
var vel := Vector2.ZERO

var _t := 0.0
var _base_y := 0.0
var _magnet := false
var _spr: Sprite2D


func _ready() -> void:
	_t = randf() * TAU
	_base_y = position.y
	_spr = Sprite2D.new()
	_spr.texture = TEX[kind]
	_spr.scale = Vector2.ONE * (0.62 if kind == "coin" else 1.15)
	_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_spr)
	z_index = 5


func _process(dt: float) -> void:
	_t += dt
	var p: Player = get_tree().get_first_node_in_group("player")
	if p == null or p.state == Player.S.DEAD:
		return
	var chest := p.position + Vector2(0, -90)
	var d := position.distance_to(chest)
	if kind == "coin":
		_spr.scale.x = 0.62 * maxf(0.25, absf(cos(_t * 3.2)))
		if d < 190.0 and (not loose or _t > 0.35):
			_magnet = true
	if _magnet:
		position = position.move_toward(chest, (900.0 + 2600.0 * _t) * dt)
	elif loose:
		_physics(dt)
	else:
		position.y = _base_y + sin(_t * 3.0) * 6.0
		if kind != "coin":
			_spr.rotation = sin(_t * 2.0) * 0.12
	if d < 60.0 or (d < 110.0 and kind != "coin"):
		_collect(p)


func _physics(dt: float) -> void:
	vel.y += 2600.0 * dt
	var step := vel * dt
	var q := PhysicsRayQueryParameters2D.create(position, position + step + Vector2(0, 16 * signf(step.y)), Game.L_WORLD | Game.L_ONEWAY)
	var hit := get_world_2d().direct_space_state.intersect_ray(q)
	if not hit.is_empty() and vel.y > 0.0:
		position = hit["position"] - Vector2(0, 16)
		vel.y *= -0.45
		vel.x *= 0.7
		if absf(vel.y) < 80.0:
			vel = Vector2.ZERO
	else:
		position += step
	if position.y > level.kill_y:
		queue_free()


func _collect(p: Player) -> void:
	match kind:
		"coin":
			Game.run["coins"] = int(Game.run["coins"]) + 1
			Sfx.play("coin", 1.0 + fmod(Game.run["coins"], 8) * 0.04)
		"simit":
			p.heal(35)
		"bat":
			p.equip("bat", 14)
			Fx.text(level.fx_layer, position + Vector2(0, -60), "SOPA!", Color(1, 0.85, 0.4), 0.9)
		"pistol":
			p.equip("pistol", 12)
			Fx.text(level.fx_layer, position + Vector2(0, -60), "TABANCA!", Color(1, 0.85, 0.4), 0.9)
	if id != "":
		Game.run["collected"][id] = true
	if kind == "coin":
		level.coin_pulse()
	else:
		Fx.ring(level.fx_layer, position, Color(1, 0.9, 0.5), 0.6)
	queue_free()

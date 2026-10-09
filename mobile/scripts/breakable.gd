## Breakable — vazo/saksı/ağaç (içinden coin/eşya) ve katı "gizli duvar" (arkasında gizli oda).
class_name Breakable
extends Node2D

var tex: Texture2D
var hp := 1
var coins := 3
var drop := "" ## "", "simit", "bat", "pistol"
var solid := false
var id := ""
var level: Node
var shard_color := Color(0.75, 0.42, 0.28)

var _spr: Sprite2D
var _body: StaticBody2D


func _ready() -> void:
	add_to_group("hittable")
	_spr = Sprite2D.new()
	_spr.texture = tex
	_spr.centered = false
	_spr.offset = Vector2(-tex.get_width() / 2.0, -tex.get_height())
	add_child(_spr)
	if solid:
		_body = StaticBody2D.new()
		_body.collision_layer = Game.L_WORLD
		var cs := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(tex.get_width() - 10, tex.get_height())
		cs.shape = r
		cs.position = Vector2(0, -tex.get_height() / 2.0)
		_body.add_child(cs)
		add_child(_body)


func hurt_rect() -> Rect2:
	var w := float(tex.get_width())
	var h := float(tex.get_height())
	return Rect2(position.x - w / 2 - (10.0 if solid else 0.0), position.y - h, w + (20.0 if solid else 0.0), h)


func can_be_hit() -> bool:
	return hp > 0


func take_hit(_dmg: int, dir: int, _kb: float, _knock: bool) -> void:
	hp -= 1
	var tw := create_tween()
	_spr.position.x = dir * 8.0
	tw.tween_property(_spr, "position:x", 0.0, 0.12)
	if solid and hp > 0:
		_spr.modulate = Color(1, 1, 1).darkened(0.12 * (3 - hp))
		Sfx.play("armor_break", 1.2)
		return
	if hp <= 0:
		_break()


func _break() -> void:
	Sfx.play("weapon_break", 0.9 if solid else 1.2)
	Fx.shards(level.fx_layer, position + Vector2(0, -tex.get_height() / 2.0), shard_color, 16 if solid else 10)
	level.shake(6.0 if solid else 3.0)
	level.spawn_coins(position + Vector2(0, -tex.get_height() / 2.0), coins)
	if drop != "":
		level.add_pickup(drop, position + Vector2(0, -60), "")
	if id != "":
		Game.run["collected"][id] = true
	Game.run["smashed"] = int(Game.run.get("smashed", 0)) + 1
	remove_from_group("hittable")
	queue_free()

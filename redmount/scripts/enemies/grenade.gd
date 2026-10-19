## Grenade — Bombacının attığı el bombası (Dan the Man tarzı).
##
## Hedefe yay çizerek uçar, yere değince seker ve durur; ~0.9 sn kırmızı yanıp
## söner (oyuncuya kaçma payı), sonra patlar: yarıçaptaki oyuncuya hasar + itme,
## yakındaki kırılabilir kapları kırar, patlayıcı varilleri zincirler.
## Yerdeyken oyuncu vurursa geri seker (tekmeyle geri yollama).
class_name Grenade
extends Node2D

const TEX := preload("res://assets/environment/pixel/bomba.png")
const TEX_LIT := preload("res://assets/environment/pixel/bomba_ikaz.png")
const BOOM := preload("res://assets/environment/pixel/patlama.png")
const RADIUS := 150.0
const FUSE := 0.9

var damage := 20
var knockback := 380.0
var velocity := Vector2.ZERO
var _landed := false
var _fuse := FUSE
var _boom_t := -1.0
var _spin := 0.0


## Başlangıçtan hedefe `time` sn'de inen balistik hız.
static func throw_at(world: Node, from: Vector2, to: Vector2, dmg: int, time := 0.85) -> Grenade:
	var g := Grenade.new()
	g.damage = dmg
	var g_acc := 1400.0
	g.velocity = Vector2((to.x - from.x) / time, (to.y - from.y) / time - 0.5 * g_acc * time)
	world.add_child(g)
	g.global_position = from
	return g


func _ready() -> void:
	z_index = 6
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group(&"grenade")
	# Oyuncunun vuruşu yakalasın (kırılabilir kaplarla aynı katman).
	var hb := Area2D.new()
	hb.name = "Hurtbox"
	hb.collision_layer = 64
	hb.collision_mask = 8
	hb.monitoring = false
	var col := CollisionShape2D.new()
	var sh := CircleShape2D.new()
	sh.radius = 22.0
	col.shape = sh
	hb.add_child(col)
	add_child(hb)


func _physics_process(delta: float) -> void:
	if _boom_t >= 0.0:
		_boom_t += delta
		if _boom_t > 0.48:
			queue_free()
		queue_redraw()
		return
	if not _landed:
		velocity.y += 1400.0 * delta
		_spin += delta * 14.0 * signf(velocity.x)
		var step := velocity * delta
		var space := get_world_2d().direct_space_state
		var q := PhysicsRayQueryParameters2D.create(global_position, global_position + step + Vector2(0, 6), 1)
		var hit := space.intersect_ray(q)
		if not hit.is_empty():
			global_position = hit.position - Vector2(0, 6)
			if hit.normal.y < -0.5 and velocity.y > 0.0:
				if absf(velocity.y) > 260.0:
					velocity = Vector2(velocity.x * 0.4, -velocity.y * 0.3)
					Sfx.play(&"step", 1.6)
				else:
					_landed = true
					velocity = Vector2.ZERO
			else:
				velocity.x = -velocity.x * 0.4
		else:
			global_position += step
	else:
		_fuse -= delta
		if _fuse <= 0.0:
			_explode()
	queue_redraw()


## Yerdeki bombaya vurulursa: atanın yönüne doğru geri fırlar, fitil biraz uzar.
func apply_hit(_dmg: int, dir: Vector2, _kb: float) -> void:
	if _boom_t >= 0.0:
		return
	_landed = false
	velocity = Vector2(signf(dir.x) * 520.0, -420.0)
	_fuse = maxf(_fuse, 0.5)
	Sfx.play(&"hit", 1.4)


func _explode() -> void:
	_boom_t = 0.0
	Combat.shake(9.0)
	Sfx.play(&"heavy_hit", 0.6, 3.0)
	Fx.ring(global_position, Color(1.0, 0.7, 0.3, 0.9), 8.0, RADIUS, 0.28, 4.0)
	Fx.spark(global_position, Vector2.ZERO, 14, Color("ffb347"), 1.4)
	var pl := get_tree().get_first_node_in_group(&"player") as Node2D
	if pl != null and pl.has_method(&"apply_hit"):
		var d: Vector2 = pl.global_position + Vector2(0, -50) - global_position
		if d.length() < RADIUS:
			pl.apply_hit(damage, Vector2(signf(d.x) if d.x != 0.0 else 1.0, -0.5).normalized(), knockback)
	# Geri yollanan bomba düşmanları da yakar.
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		if is_instance_valid(e) and e.has_method(&"apply_hit"):
			var de: Vector2 = e.global_position + Vector2(0, -50) - global_position
			if de.length() < RADIUS * 0.8:
				e.apply_hit(damage + 10, Vector2(signf(de.x) if de.x != 0.0 else 1.0, -0.6).normalized(), 520.0)
	for p in get_tree().get_nodes_in_group(&"explosive"):
		if is_instance_valid(p) and (p.global_position - global_position).length() < RADIUS:
			p.apply_hit(1, Vector2.RIGHT, 0.0)


func _draw() -> void:
	if _boom_t >= 0.0:
		var f := mini(int(_boom_t / 0.08), 5)
		var s := 40.0 * 3.5
		draw_texture_rect_region(BOOM, Rect2(-s * 0.5, -s * 0.5, s, s), Rect2(f * 40, 0, 40, 40))
		return
	var lit := _landed and int(_fuse * (12.0 if _fuse < 0.4 else 6.0)) % 2 == 0
	var tex := TEX_LIT if lit else TEX
	draw_set_transform(Vector2.ZERO, _spin if not _landed else 0.0, Vector2(3, 3))
	draw_texture(tex, -tex.get_size() * 0.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
